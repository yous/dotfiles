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

# Add /usr/local/bin to PATH for Mac OS X
if [[ "$OSTYPE" == "darwin"* ]]; then
  PATH=/usr/local/bin:/usr/local/sbin:$PATH
fi

# Load RVM into a shell session *as a function*
[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"
# Add RVM to PATH for scripting
PATH=$PATH:$HOME/.rvm/bin
export rvmsudo_secure_path=1

# Load aliases
[ -e "${HOME}/.zsh_aliases" ] && source "${HOME}/.zsh_aliases"

# Use right RVM gemset depending on directory
if [[ "$TMUX" != "" ]]; then
  rvm use default
  cd ..;1
fi
