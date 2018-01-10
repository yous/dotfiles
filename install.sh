#!/bin/bash
set -e

DIRNAME="$(dirname "$0")"
DIR="$(cd "$DIRNAME" && pwd)"

function echoerr() {
  echo "$@" 1>&2
}

function init_submodules() {
  (cd "$DIR" && git submodule init)
  (cd "$DIR" && git submodule update)
}

function git_clone() {
  if [ ! -e "$HOME/$2" ]; then
    echo "Cloning '$1'..."
    git clone "$1" "$HOME/$2"
  else
    # shellcheck disable=SC2088
    echoerr "~/$2 already exists."
  fi
}

function replace_file() {
  DEST=${2:-.$1}

  # http://www.tldp.org/LDP/Bash-Beginners-Guide/html/sect_07_01.html
  # File exists and is a directory.
  [ ! -d "$(dirname "$HOME/$DEST")" ] && mkdir -p "$(dirname "$HOME/$DEST")"

  # FILE exists and is a symbolic link.
  if [ -h "$HOME/$DEST" ]; then
    if rm "$HOME/$DEST" && ln -s "$DIR/$1" "$HOME/$DEST"; then
      echo "Updated ~/$DEST"
    else
      echoerr "Failed to update ~/$DEST"
    fi
  # FILE exists.
  elif [ -e "$HOME/$DEST" ]; then
    if mv --backup=number "$HOME/$DEST" "$HOME/$DEST.old"; then
      echo "Renamed ~/$DEST to ~/$DEST.old"
      if ln -s "$DIR/$1" "$HOME/$DEST"; then
        echo "Created ~/$DEST"
      else
        echoerr "Failed to create ~/$DEST"
      fi
    else
      echoerr "Failed to rename ~/$DEST to ~/$DEST.old"
    fi
  else
    if ln -s "$DIR/$1" "$HOME/$DEST"; then
      echo "Created ~/$DEST"
    else
      echoerr "Failed to create ~/$DEST"
    fi
  fi
}

case "$1" in
  link)
    init_submodules
    for FILENAME in \
      'bashrc' \
      'ctags' \
      'gemrc' \
      'gitattributes_global' \
      'gitconfig' \
      'gitignore_global' \
      'ideavimrc' \
      'inputrc' \
      'irbrc' \
      'npmrc' \
      'profile' \
      'screenrc' \
      'tmux.conf' \
      'vintrc.yaml' \
      'vimrc' \
      'weechat' \
      'zprofile' \
      'zshrc'
    do
      replace_file "$FILENAME"
    done
    replace_file 'pip.conf' '.pip/pip.conf'
    replace_file 'tpm' '.tmux/plugins/tpm'
    for FILENAME in \
      'diff-highlight' \
      'diff-hunk-list' \
      'pyg' \
      'server'
    do
      replace_file "bin/$FILENAME" "bin/$FILENAME"
    done
    echo 'Done.'
    ;;
  antibody)
    if [ "$(uname)" = 'Darwin' ]; then
      brew install getantibody/tap/antibody
    else
      curl -sL https://git.io/antibody | bash -s
    fi
    ;;
  brew)
    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    ;;
  formulae)
    while read -r COMMAND; do
      trap 'break' INT
      [[ -z "$COMMAND" || ${COMMAND:0:1} == '#' ]] && continue
      IFS=' ' read -ra BREW_ARGS <<< "$COMMAND"
      brew "${BREW_ARGS[@]}"
    done < "$DIR/Brewfile" && echo 'Done.'
    ;;
  npm)
    if ! which npm &> /dev/null; then
      echoerr 'command not found: npm'
    else
      for PACKAGE in \
        'csslint' \
        'jshint' \
        'jslint' \
        'jsonlint'
      do
        if which $PACKAGE &> /dev/null; then
          echoerr "$PACKAGE is already installed."
        else
          echo "npm install -g $PACKAGE"
          npm install -g "$PACKAGE"
        fi
      done
    fi
    ;;
  pwndbg)
    init_submodules
    cd "${DIR}/pwndbg"
    ./setup.sh
    ;;
  pyenv)
    if [ "$(uname)" = 'Darwin' ]; then
      brew install pyenv
      brew install pyenv-virtualenv
    else
      curl -L https://raw.githubusercontent.com/pyenv/pyenv-installer/master/bin/pyenv-installer | bash
    fi
    ;;
  rbenv)
    if [ "$(uname)" = 'Darwin' ]; then
      brew install rbenv
    else
      git_clone https://github.com/rbenv/rbenv.git .rbenv
      git_clone https://github.com/rbenv/ruby-build.git .rbenv/plugins/ruby-build
    fi
    echo 'Done.'
    ;;
  rvm)
    command curl -sSL https://get.rvm.io | bash -s stable
    ;;
  z)
    init_submodules
    replace_file 'z/z.sh' '.z.sh'
  *)
    echo "usage: $(basename "$0") <command>"
    echo ''
    echo 'Available commands:'
    echo '    link      Install symbolic links'
    echo '    antibody  Install Antibody'
    echo '    brew      Install Homebrew'
    echo '    formulae  Install Homebrew formulae using Brewfile'
    echo '    npm       Install global Node.js packages'
    echo '    pwndbg    Install pwndbg'
    echo '    pyenv     Install pyenv with pyenv-virtualenv'
    echo '    rbenv     Install rbenv'
    echo '    rvm       Install RVM'
    echo '    z         Install z'
    ;;
esac
