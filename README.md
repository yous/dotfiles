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

### [IntelliJ][] or [Android Studio][]

[IntelliJ]: http://www.jetbrains.com/idea/
[Android Studio]: http://developer.android.com/sdk/installing/studio.html

To use [Tomorrow Theme][]:

[Tomorrow Theme]: https://github.com/ChrisKempson/Tomorrow-Theme

1. Open File > Import Settings....
2. Select `tomorrow-theme/Jetbrains/settings.jar`.
3. Open Settings > Editor > Colors & Fonts.
4. Select a scheme of Tomorrow Theme.

### [iTerm2][]

To use [Tomorrow Theme][] on [iTerm2][]:

[iTerm2]: http://www.iterm2.com

1. Open Preferences... > Profiles > Colors.
2. Click 'Load Presets...' and select 'Import...'.
3. Select `*.itermcolors` files under `tomorrow-theme/iTerm2`.
4. Click 'Load Presets...' again and select one of Tomorrow Theme.

### [Ruby][]

[Ruby]: https://www.ruby-lang.org

If you are using [RVM][],

[RVM]: http://rvm.io

``` sh
$ rvm use current@global
$ gem install what_methods wirble
```

Otherwise just install gems:

``` sh
$ gem install what_methods wirble
```

### [Vim][]

[Vim]: http://www.vim.org

```
:BundleInstall
```

### [Zsh][]

[Zsh]: http://www.zsh.org

To use [Zsh][] as default shell,

``` sh
$ chsh -s /bin/zsh
```
