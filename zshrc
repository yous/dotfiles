# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

function add_to_path_once()
{
  if [[ ":$PATH:" != *":$1:"* ]]; then
    export PATH="$1:$PATH"
  fi
}

# Add /usr/local/bin to PATH for Mac OS X
if [[ "$OSTYPE" == "darwin"* ]]; then
  add_to_path_once "/usr/local/bin:/usr/local/sbin"
fi

# Load Linuxbrew
if [[ -d "$HOME/.linuxbrew" ]]; then
  add_to_path_once "$HOME/.linuxbrew/bin"
  export MANPATH="$HOME/.linuxbrew/share/man:$MANPATH"
  export INFOPATH="$HOME/.linuxbrew/share/info:$INFOPATH"
fi

# Set PATH to include user's bin if it exists
if [ -d "$HOME/bin" ]; then
  add_to_path_once "$HOME/bin"
fi

# Load RVM into a shell session *as a function*
if [[ -s "$HOME/.rvm/scripts/rvm" ]]; then
  source "$HOME/.rvm/scripts/rvm"

  if [[ "$(type rvm | head -n 1)" == "rvm is a shell function" ]]; then
    # Add RVM to PATH for scripting
    PATH=$PATH:$HOME/.rvm/bin
    export rvmsudo_secure_path=1

    # Use right RVM gemset when using tmux
    if [[ "$TMUX" != "" ]]; then
      rvm use default
      cd ..;cd -
    fi
  fi
fi

# Load rbenv
if [ -e "$HOME/.rbenv" ]; then
  export PATH="$HOME/.rbenv/bin:$PATH"
  eval "$(rbenv init -)"
fi

# Load pyenv
if which pyenv > /dev/null; then
  eval "$(pyenv init -)"
fi

# Load zgen
source $HOME/.zgen/zgen.zsh
# Check if there's no init script.
if ! zgen saved; then
  # Load the oh-my-zsh's library.
  zgen oh-my-zsh
  # A cd command that learns - easily navigate directories from the command line.
  zgen oh-my-zsh plugins/autojump
  # Homebrew aliases and completion.
  zgen oh-my-zsh plugins/brew
  # Run commands with bundle and bundle aliases
  zgen oh-my-zsh plugins/bundler
  # Guess what to install when running an unknown command.
  zgen oh-my-zsh plugins/command-not-found
  # Extracts different types of archives
  zgen oh-my-zsh plugins/extract
  # Autocompletion for gem command.
  zgen oh-my-zsh plugins/gem
  # Git aliases and completion.
  zgen oh-my-zsh plugins/git
  # npm completion.
  zgen oh-my-zsh plugins/npm
  # RVM aliases and completion.
  zgen oh-my-zsh plugins/rvm
  # tmux aliases and configurations.
  if which tmux &> /dev/null; then
    zgen oh-my-zsh plugins/tmux
  fi
  # Syntax highlighting bundle.
  zgen load zsh-users/zsh-syntax-highlighting
  # Load the theme.
  zgen load yous/zsh-themes lime
  # Save all to init script.
  zgen save
fi

# Oh My Zsh sets custom LSCOLORS from lib/theme-and-appearance.zsh
# This is default LSCOLORS from the man page of ls
[[ "$OSTYPE" == "darwin"* ]] && export LSCOLORS=exfxcxdxbxegedabagacad

# Check if reboot is required for Ubuntu
if [ -f /usr/lib/update-notifier/update-motd-reboot-required ]; then
  function reboot-required()
  {
    /usr/lib/update-notifier/update-motd-reboot-required
  }
fi

# Unset local functions
unset -f add_to_path_once

# Define aliases
alias git='noglob git'
alias v='vim'
alias vi='vim'
alias ruby-server='ruby -run -ehttpd . -p8000'
