# dotfiles

[![Build Status](https://github.com/yous/dotfiles/workflows/CI/badge.svg?branch=master)](https://github.com/yous/dotfiles/actions?query=branch%3Amaster)

[@yous](https://github.com/yous)' dotfiles.

## Table of Contents

- [Requirements](#requirements)
- [Installation](#installation)
  - [Git](#git)
  - [Homebrew](#homebrew)
  - [Ruby](#ruby)
  - [Rust](#rust)
  - [Python](#python)
  - [Zsh](#zsh)
  - [Vim](#vim)
  - [Neovim](#neovim)
  - [WeeChat](#weechat)
  - [Tools](#tools)
  - [IntelliJ, Android Studio](#intellij-android-studio)
  - [iTerm2](#iterm2)
- [License](#license)

## Requirements

- [Git](http://git-scm.com)

## Installation

Clone this repository:

``` sh
git clone https://github.com/yous/dotfiles.git
cd dotfiles
```

For available install options:

``` sh
./install.sh
```

| Command option | Description                              |
|----------------|------------------------------------------|
| `link`         | Install symbolic links                   |
| `brew`         | Install Homebrew on macOS (or Linux)     |
| `chruby`       | Install chruby                           |
| `formulae`     | Install Homebrew formulae using Brewfile |
| `pwndbg`       | Install pwndbg                           |
| `pyenv`        | Install pyenv with pyenv-virtualenv      |
| `rbenv`        | Install rbenv                            |
| `ruby-install` | Install ruby-install                     |
| `rustup`       | Install rustup                           |
| `rvm`          | Install RVM                              |
| `weechat`      | Install WeeChat configuration            |

In Windows, use `install.bat`. It links files into the user's home directory.

### Git

Set user-specific configurations on `~/.gitconfig.user`:

``` gitconfig
[user]
	name = Your Name
	email = you@example.com
```

If you are using a public PGP key:

``` gitconfig
[user]
	signingkey = YOUR KEY
```

You can also sign your each commit automatically:

``` gitconfig
[commit]
	gpgsign = true
```

For more information about signing commits, see
[A Git Horror Story: Repository Integrity With Signed Commits](http://mikegerwitz.com/papers/git-horror-story).

If you want to use Gmail for `git send-email`,

``` gitconfig
[sendemail]
	smtpEncryption = tls
	smtpServer = smtp.gmail.com
	smtpServerPort = 587
	smtpUser = you@gmail.com
```

For more information, see [the documentation](https://git-scm.com/docs/git-send-email)
for git-send-email.

Set local-specific configurations on `~/.gitconfig.local`:

``` gitconfig
[includeIf "gitdir:~/to/group/"]
	path = /path/to/foo.inc
```

For more information, see [conditional includes](https://git-scm.com/docs/git-config#_conditional_includes)
section in the git-config documentation.

If you want to use latest release of Git for Ubuntu:

``` sh
sudo add-apt-repository ppa:git-core/ppa
sudo apt-get update
```

Visit [the PPA of Git for Ubuntu](https://launchpad.net/~git-core/+archive/ubuntu/ppa)
for more information.

### Homebrew

If you want to install [Homebrew](http://brew.sh) or [Homebrew on Linux](https://docs.brew.sh/Homebrew-on-Linux),

``` sh
./install.sh brew
```

Then install Homebrew formulae with:

``` sh
./install.sh formulae
```

On macOS prior to Mojave, install Rust using rustup, and then install several
utilities using `cargo`:

``` sh
cargo install bat fd-find gitui ripgrep
```

### Ruby

#### chruby

If you want to install [chruby](https://github.com/postmodern/chruby), if you're
on macOS,

``` sh
brew install ruby-install
brew install chruby
```

Otherwise, install [ruby-install](https://github.com/postmodern/ruby-install)
first, if you're on Arch Linux,

``` sh
yaourt -S ruby-install
```

Otherwise,

``` sh
./install.sh ruby-install
```

Then install chruby,

``` sh
./install.sh chruby
```

#### RVM

If you want to install [RVM](http://rvm.io),

``` sh
./install.sh rvm
```

Update RVM with:

``` sh
rvm get stable
```

#### rbenv

If you want to install [rbenv](https://github.com/sstephenson/rbenv),

``` sh
./install.sh rbenv
```

### Rust

If you want to install [rustup](https://rustup.rs),

``` sh
./install.sh rustup
```

### Python

If you want to install [pyenv](https://github.com/pyenv/pyenv) and
[pyenv-virtualenv](https://github.com/pyenv/pyenv-virtualenv),

``` sh
./install.sh pyenv
```

### Zsh

To use [Zsh](http://www.zsh.org) as default shell,

``` sh
chsh -s /bin/zsh
```

If you use custom Zsh like compiled one by [Homebrew](http://brew.sh), add
`/usr/local/bin/zsh` to `/etc/shells` and

``` sh
chsh -s /usr/local/bin/zsh
```

To update Zsh plugins:

``` sh
zinit update --all
```

To update [Zinit](https://github.com/zdharma/zinit) itself:

``` sh
zinit self-update
```

To make RVM works with Vim on OS X Yosemite or earlier, move `/etc/zshenv` to
`/etc/zshrc` as [Tim Pope mentioned](https://github.com/tpope/vim-rvm#faq).

``` sh
sudo mv /etc/zshenv /etc/zshrc
```

### Vim

To install [Vim](http://www.vim.org) plugins,

```
:PlugInstall
```

You should install [Exuberant Ctags](http://ctags.sourceforge.net/) to use
[vim-gutentags](https://github.com/ludovicchabant/vim-gutentags). You should
install Node.js to use [coc.nvim](https://github.com/neoclide/coc.nvim).

To update Vim plugins:

```
:PlugUpdate
```

To update [vim-plug](https://github.com/junegunn/vim-plug):

```
:PlugUpgrade
```

For additional syntax checkers for coc.nvim, [ALE](https://github.com/dense-analysis/ale),
or [Syntastic](https://github.com/vim-syntastic/syntastic):

- C, C++
  - clang-check: `brew install llvm`
  - clang-tidy: `brew install llvm`
  - cppcheck: `brew install cppcheck`
- CSS
  - stylelint: `npm install -g stylelint stylelint-config-standard`
- JavaScript
  - ESLint: `npm install -g eslint`
- JSON
  - JSONLint: `npm install -g jsonlint`
- Python
  - flake8: `pip install flake8`
  - jedi: `pip install jedi`
- Ruby
  - RuboCop: `gem install rubocop`
  - Solargraph: `gem install solargraph`
- SASS, SCSS
  - stylelint: `npm install -g stylelint stylelint-config-sass-guidelines`

### Neovim

To use Python 2 or 3 via pyenv in [Neovim](https://neovim.io),

``` sh
pyenv install 2.7.18
pyenv virtualenv 2.7.18 neovim2
pyenv activate neovim2
pip install pynvim

pyenv install 3.8.2
pyenv virtualenv 3.8.2 neovim3
pyenv activate neovim3
pip install pynvim
```

To use Ruby in Neovim,

``` sh
gem install neovim
```

To use Node.js in Neovim,

``` sh
npm install -g neovim
```

### WeeChat

To install [WeeChat](https://weechat.org) configuration,

``` sh
./install.sh weechat
```

Then install scripts:

```
/script install autosort.py buffers.pl colorize_nicks.py iset.pl
```

To update WeeChat scripts:

```
/script update
/script upgrade
```

### Tools

#### pwndbg

If you want to install [pwndbg](https://github.com/pwndbg/pwndbg),

``` sh
./install.sh pwndbg
```

### IntelliJ, Android Studio

To use Tomorrow Theme:

1. Download `JetBrains/settings.jar` from [chriskempson/tomorrow-theme](https://github.com/chriskempson/tomorrow-theme).
2. Open File > Import Settings… in [IntelliJ](https://www.jetbrains.com/idea/) or
   [Android Studio](https://developer.android.com/studio).
3. Select downloaded `settings.jar`.
4. Open Settings > Editor > Colors Scheme.
5. Select one of Tomorrow Theme.

### iTerm2

To use Tomorrow Theme:

1. Download `schemes/Tomorrow*.itermcolors` from
   [mbadolato/iTerm2-Color-Schemes](https://github.com/mbadolato/iTerm2-Color-Schemes).
2. Open Preferences… > Profiles > Colors.
3. Click 'Load Presets…' and select 'Import…'.
4. Select downloaded `Tomorrow*.itermcolors`.
5. Click 'Load Presets…' again and select one of Tomorrow Theme.

## License

Copyright © Chayoung You. See [LICENSE.txt](LICENSE.txt) for details.
