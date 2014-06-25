source $HOME/.antigen/antigen.zsh

# Load the oh-my-zsh's library.
antigen use oh-my-zsh

# Bundles from the default repo (robbyrussell's oh-my-zsh).
antigen bundle git
antigen bundle gem
antigen bundle command-not-found

# Syntax highlighting bundle.
antigen bundle zsh-users/zsh-syntax-highlighting

# Load the theme.
antigen theme gentoo

# Tell antigen that you're done.
antigen apply

if [[ "$OSTYPE" == "darwin"* ]]; then
  PATH=/usr/local/bin:/usr/local/sbin:$PATH
fi
[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*
PATH=$PATH:$HOME/.rvm/bin # Add RVM to PATH for scripting
export rvmsudo_secure_path=1

[ -e "${HOME}/.zsh_aliases" ] && source "${HOME}/.zsh_aliases"

if [[ "$TMUX" != "" ]]; then
  rvm use default
  cd ..;1
fi
