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

# Set PATH to includes user's bin if it exists
if [ -d "$HOME/bin" ]; then
  PATH=$HOME/bin:$PATH
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
source $HOME/.antigen/antigen.zsh
# Load the oh-my-zsh's library.
antigen use oh-my-zsh
# A cd command that learns - easily navigate directories from the command line.
antigen bundle autojump
# Homebrew aliases and completion.
antigen bundle brew
# Run commands with bundle and bundle aliases
antigen bundle bundler
# Guess what to install when running an unknown command.
antigen bundle command-not-found
# Extracts different types of archives
antigen bundle extract
# Autocompletion for gem command.
antigen bundle gem
# Git aliases and completion.
antigen bundle git
# npm completion.
antigen bundle npm
# RVM aliases and completion.
antigen bundle rvm
# tmux aliases and configurations.
if which tmux &> /dev/null; then
  antigen bundle tmux
fi
# Syntax highlighting bundle.
antigen bundle zsh-users/zsh-syntax-highlighting
# Load the theme.
antigen theme yous/zsh-themes lime
# Tell antigen that you're done.
antigen apply

# For ls colors in Solarized theme
# https://github.com/seebi/dircolors-solarized/issues/10
[[ "$OSTYPE" == "darwin"* ]] && export LSCOLORS=gxfxbEaEBxxEhEhBaDaCaD

# Check if reboot is required for Ubuntu
if [ -f /usr/lib/update-notifier/update-motd-reboot-required ]; then
  function reboot-required()
  {
    /usr/lib/update-notifier/update-motd-reboot-required
  }
fi

# Define aliases
alias git='noglob git'
alias rake='noglob rake'
alias ag='apt-get'
alias v='vim'
alias vi='vim'
