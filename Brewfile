if OS.mac?
  # macOS
  brew "reattach-to-user-namespace"

  # Basic tools
  brew "cmake"
  brew "cscope"
  brew "ctags"
  brew "git"
  brew "openssh"
  brew "wget"

  # QLColorCode
  brew "highlight" if MacOS.version < :catalina
end

# Utilities
brew "bottom"
brew "keychain" if OS.mac?
brew "lazygit"
brew "pre-commit"
brew "shellcheck"
brew "tmux"
brew "z"

# Don't have bottles for Rust
unless OS.mac? && MacOS.version < :mojave
  brew "bat"
  brew "fd"
  brew "ripgrep"
end

# Python
brew "python"
brew "pyenv" if OS.mac?

# Ruby
brew "ruby"
brew "chruby"

# Node.js
brew "n"

# Vim
brew "vim"
