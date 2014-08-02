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

# Add /usr/local/bin to PATH for Mac OS X
if [[ "$OSTYPE" == "darwin"* ]]; then
  PATH=/usr/local/bin:/usr/local/sbin:$PATH
fi

# Load RVM into a shell session *as a function*
[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"

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

# Load rbenv
if [ -e "$HOME/.rbenv" ]; then
  export PATH="$HOME/.rbenv/bin:$PATH"
  eval "$(rbenv init -)"
fi

# Load Antigen
[ -e "${HOME}/.zsh/antigen.zsh" ] && source "${HOME}/.zsh/antigen.zsh"

# Load aliases
[ -e "${HOME}/.zsh/aliases.zsh" ] && source "${HOME}/.zsh/aliases.zsh"

# For ls colors in Solarized theme
# https://github.com/seebi/dircolors-solarized/issues/10
[[ "$OSTYPE" == "darwin"* ]] && export LSCOLORS=gxfxbEaEBxxEhEhBaDaCaD
