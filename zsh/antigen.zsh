source $HOME/.antigen/antigen.zsh

# Load the oh-my-zsh's library.
antigen use oh-my-zsh

antigen bundles <<EOBUNDLES
  # Bundles from the default repo (robbyrussell's oh-my-zsh).

  # Guess what to install when running an unknown command.
  command-not-found

  # Extracts different types of archives
  extract

  # Autocompletion for gem command.
  gem

  # Git aliases and completion.
  git

  # RVM aliases and completion.
  rvm

  # tmux aliases and configurations.
  tmux

  # Syntax highlighting bundle.
  zsh-users/zsh-syntax-highlighting
EOBUNDLES

# Load the theme.
antigen theme gentoo

# Tell antigen that you're done.
antigen apply
