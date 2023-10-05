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
brew "keychain" if OS.mac?
brew "lazygit"
brew "pre-commit"
brew "shellcheck"
brew "tmux"
brew "z"

# Don't have bottles for Rust
unless OS.mac? && MacOS.version < :big_sur
  brew "bat"
  brew "bottom"
  brew "fd"
  brew "ripgrep"
end

# rtx
brew "rtx"

# Python
brew "python"

# Ruby
brew "ruby"

# Vim
brew "vim"
