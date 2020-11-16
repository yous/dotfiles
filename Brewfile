if OS.mac?
  # macOS
  brew "reattach-to-user-namespace"

  # Basic tools
  brew "cmake"
  brew "cscope"
  brew "ctags"
  brew "git"
  brew "openssh"
  brew "tmux"
  brew "wget"
  brew "zsh"

  # QLColorCode
  brew "highlight" if MacOS.version < :catalina
end

# Utilities
brew "bat"
brew "fd"
brew "htop"
brew "keychain" if OS.mac?
brew "pre-commit"
brew "ripgrep"
brew "tig"
brew "z"

# Python
brew "python"
brew "pyenv"
brew "pyenv-virtualenv"

# Ruby
brew "ruby"
brew "chruby"

# Node.js
brew "node"

# Vim
brew "vim"

# Krypton
brew "kryptco/tap/kr" if OS.mac?
