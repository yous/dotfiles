irb() {
  if [[ -a Gemfile ]]; then
    bundle exec irb $*
  else
    command irb $*
  fi
}

rake() {
  if [[ -a Gemfile ]]; then
    bundle exec rake $*
  else
    command rake $*
  fi
}

ruby() {
  if [[ -a Gemfile ]]; then
    bundle exec ruby $*
  else
    command ruby $*
  fi
}

alias sudo='sudo '
alias ag='apt-get'
alias v='vim'
alias vi='vim'
