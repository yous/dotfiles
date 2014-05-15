# Config

## About

Configuration files for [@yous](https://github.com/yous)

## Requirements

- [Git][]
- [Vundle][]

[Git]: http://git-scm.com
[Vundle]: https://github.com/gmarik/vundle

## Install

1. Clone this repository:

        $ git clone git@github.com:yous/config.git
        $ cd config
        $ git submodule init
        $ git submodule update

2. Copy configuration files to home directory:

        $ ./install.sh
        $ git config --global core.excludesfile ~/.gitignore

3. Install dependencies:

    If you are using [RVM][],

        $ rvm use current@global
        $ gem install what_methods wirble

    Otherwise just install gems:

        $ gem install what_methods wirble

    In [Vim][],

        :BundleInstall

    To use [Zsh][] as default shell,

        $ chsh -s /bin/zsh

    To use [Tomorrow Theme][] on [iTerm2][]:

    1. Open Preferences... > Profiles > Colors.
    2. Click 'Load Presets...' and select 'Import...'.
    3. Select `*.itermcolors` files under `tomorrow-theme/iTerm2`.
    4. Click 'Load Presets...' again and select one of Tomorrow Theme.

[RVM]: http://rvm.io
[Vim]: http://www.vim.org
[Zsh]: http://www.zsh.org
[Tomorrow Theme]: https://github.com/ChrisKempson/Tomorrow-Theme
[iTerm2]: http://www.iterm2.com
