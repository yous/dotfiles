# dotfiles

[![Build Status](https://travis-ci.org/yous/dotfiles.svg?branch=master)](https://travis-ci.org/yous/dotfiles)

[@yous](https://github.com/yous)' dotfiles.

## Table of Contents

- [Requirements](#requirements)
- [Installation](#installation)
  - [Git](#git)
  - [Homebrew](#homebrew)
  - [Ruby](#ruby)
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

Command option | Description
---------------|-----------------------------------------------
`link`         | Install symbolic links
`antibody`     | Install Antibody
`brew`         | Install Homebrew
`formulae`     | Install Homebrew formulae using Brewfile
`pwndbg`       | Install pwndbg
`pyenv`        | Install pyenv with pyenv-virtualenv
`rbenv`        | Install rbenv
`rvm`          | Install RVM
`weechat`      | Install WeeChat configuration
`z`            | Install z

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

If you want to install [Homebrew](http://brew.sh),

``` sh
./install.sh brew
```

Then install Homebrew formulae with:

``` sh
./install.sh formulae
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
wget -O ruby-install-0.7.0.tar.gz https://github.com/postmodern/ruby-install/archive/v0.7.0.tar.gz
tar -xzvf ruby-install-0.7.0.tar.gz
cd ruby-install-0.7.0/
sudo make install
```

Then install chruby,

``` sh
wget -O chruby-0.3.9.tar.gz https://github.com/postmodern/chruby/archive/v0.3.9.tar.gz
tar -xzvf chruby-0.3.9.tar.gz
cd chruby-0.3.9/
sudo make install
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

If you want to install [rbenv](https://github.com/sstephenson/rbenv), if you're
on macOS,

``` sh
brew install rbenv
```

Otherwise,

``` sh
./install.sh rbenv
```

#### Gems

If you are using RVM,

``` sh
gem update --system
rvm use current@global
gem install bundler rubocop ruby-lint wirble
```

Otherwise just install gems:

``` sh
gem update --system
gem install bundler rubocop ruby-lint wirble
```

### Python

If you want to install [pyenv](https://github.com/yyuu/pyenv) and
[pyenv-virtualenv](https://github.com/yyuu/pyenv-virtualenv), if you're on
macOS,

``` sh
brew install pyenv
brew install pyenv-virtualenv
```

Otherwise,

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
antibody update
```

To make RVM works with Vim on OS X Yosemite or earlier, move `/etc/zshenv` to
`/etc/zshrc` as [Tim Pope mentioned](https://github.com/tpope/vim-rvm#faq).

``` sh
sudo mv /etc/zshenv /etc/zshrc
```

#### Antibody

If you want to install [Antibody](https://getantibody.github.io), if you're on
macOS,

``` sh
brew install getantibody/tap/antibody
```

Otherwise,

``` sh
./install.sh antibody
```

### Vim

To install [Vim](http://www.vim.org) plugins,

```
:PlugInstall
```

You should install [Exuberant Ctags](http://ctags.sourceforge.net/) to use
[vim-gutentags](https://github.com/ludovicchabant/vim-gutentags). You should
install CMake to use [YouCompleteMe](https://github.com/Valloric/YouCompleteMe).

To update Vim plugins:

```
:PlugUpdate
```

To update [vim-plug](https://github.com/junegunn/vim-plug):

```
:PlugUpgrade
```

For additional syntax checkers for [ale](https://github.com/w0rp/ale) or
[Syntastic](https://github.com/scrooloose/syntastic):

- C, C++
  - clang-check: `brew install llvm`
  - clang-tidy: `brew install llvm`
  - cppcheck: `brew install cppcheck`
- CSS
  - CSSLint: `npm install -g csslint`
- HTML
  - JSHint: `npm install -g jshint`
- JavaScript
  - ESLint: `npm install -g eslint`
  - JSHint: `npm install -g jshint`
  - JSLint: `npm install -g jslint`
- JSON
  - JSONLint: `npm install -g jsonlint`
- Python
  - flake8: `pip install flake8`
- Ruby
  - RuboCop: `gem install rubocop`
  - ruby-lint: `gem install ruby-lint`
- SASS: `gem install sass`
- SCSS: `gem install sass scss-lint`
- xHTML
  - JSHint: `npm install -g jshint`

### Neovim

To use Python 2 or 3 via pyenv in [Neovim](https://neovim.io),

``` sh
pyenv install 2.7.15
pyenv virtualenv 2.7.15 neovim2
pyenv activate neovim2
pip install pynvim

pyenv install 3.6.5
pyenv virtualenv 3.6.5 neovim3
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

#### z

If you want to install [z](https://github.com/rupa/z), if you're on macOS,

``` sh
brew install z
```

Otherwise,

``` sh
./install.sh z
```

### IntelliJ, Android Studio

To use [Tomorrow Theme](https://github.com/ChrisKempson/Tomorrow-Theme):

1. Open File > Import Settings… in [IntelliJ](http://www.jetbrains.com/idea/) or
   [Android Studio](http://developer.android.com/sdk/installing/studio.html).
2. Select `tomorrow-theme/JetBrains/settings.jar`.
3. Open Settings > Editor > Colors & Fonts.
4. Select a scheme of Tomorrow Theme.

### iTerm2

To use [Tomorrow Theme](https://github.com/ChrisKempson/Tomorrow-Theme):

1. Open Preferences… > Profiles > Colors.
2. Click 'Load Presets…' and select 'Import…'.
3. Select `*.itermcolors` files under `tomorrow-theme/iTerm2/`.
4. Click 'Load Presets…' again and select one of Tomorrow Theme.

## License

Copyright © Chayoung You. See [LICENSE.txt](LICENSE.txt) for details.
