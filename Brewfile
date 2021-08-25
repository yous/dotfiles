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
brew "bat" unless OS.mac? && MacOS.version <= :high_sierra
brew "clementtsang/bottom/bottom"
brew "fd"
brew "gitui" unless OS.mac? && MacOS.version <= :high_sierra
brew "keychain" if OS.mac?
brew "pre-commit"
brew "ripgrep"
brew "z"

# Python
brew "python"
brew "pyenv"

# Ruby
brew "ruby"
brew "chruby"

# Node.js
brew "n"

# Vim
brew "vim"

# Krypton
brew "kryptco/tap/kr" if OS.mac?
