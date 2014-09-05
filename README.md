# Config

## About

Configuration files for [@yous](https://github.com/yous)

## Requirements

- [Git][]

[Git]: http://git-scm.com

## Install

1. Clone this repository:

        git clone https://github.com/yous/config.git
        cd config
        git submodule init
        git submodule update

2. Install [Vundle.vim][]:

[Vundle.vim]: https://github.com/gmarik/Vundle.vim

        git clone https://github.com/gmarik/Vundle.vim.git ~/.vim/bundle/Vundle.vim

3. Copy configuration files to home directory:

        ./install.sh link
        vim +PluginInstall +qall

4. If you are using [rbenv][], execute additional script:

[rbenv]: https://github.com/sstephenson/rbenv

        ./install.sh rbenv

### Adblock Plus

To use [Adblock Plus][] filter, install its browser plugin and add subscription as 'YousList' with the url:

```
https://raw.githubusercontent.com/yous/config/master/adblock.txt
```

[Adblock Plus]: https://adblockplus.org

### IntelliJ, Android Studio

To use [Tomorrow Theme][]:

[Tomorrow Theme]: https://github.com/ChrisKempson/Tomorrow-Theme

1. Open File > Import Settings… in [IntelliJ][] or [Android Studio][].
2. Select `tomorrow-theme/Jetbrains/settings.jar`.
3. Open Settings > Editor > Colors & Fonts.
4. Select a scheme of Tomorrow Theme.

[IntelliJ]: http://www.jetbrains.com/idea/
[Android Studio]: http://developer.android.com/sdk/installing/studio.html

### Git

Set user-specific configurations on `gitconfig`:

```
[user]
	name = Your Name
	email = you@example.com
```

If you are using [Keybase][]:

[Keybase]: https://keybase.io

```
[user]
	signingkey = YOUR KEY
[commit]
	gpgsign = true
```

For more information about signing commits, see [A Git Horror Story: Repository Integrity With Signed Commits](http://mikegerwitz.com/papers/git-horror-story).

### iTerm2

To use [Solarized][] on [iTerm2][]:

[Solarized]: https://github.com/altercation/solarized
[iTerm2]: http://www.iterm2.com

1. Open Preferences… > Profiles > Colors.
2. Click 'Load Presets…' and select 'Import…'.
3. Select `*.itermcolors` files under `solarized/iterm2-colors-solarized/`.
4. Click 'Load Presets…' again and select one of Solarized.

To use [Tomorrow Theme][]:

1. Open Preferences… > Profiles > Colors.
2. Click 'Load Presets…' and select 'Import…'.
3. Select `*.itermcolors` files under `tomorrow-theme/iTerm2/`.
4. Click 'Load Presets…' again and select one of Tomorrow Theme.

### Ruby

If you are using [RVM][],

[RVM]: http://rvm.io

``` sh
rvm use current@global
gem install wirble
```

Otherwise just install gems:

``` sh
gem install wirble
```

### Vim

To update [Vim][] plugins:

[Vim]: http://www.vim.org

- In Vim:

        :PluginUpdate

- In terminal:

        vim +PluginUpdate +qall

### Zsh

To use [Zsh][] as default shell,

[Zsh]: http://www.zsh.org

``` sh
chsh -s /bin/zsh
```

If you use custom Zsh like compiled one by [Homebrew][],

[Homebrew]: http://brew.sh

``` sh
chsh -s /usr/local/bin/zsh
```

To update [Antigen][]:

[Antigen]: http://antigen.sharats.me

``` sh
antigen selfupdate
```

To update Zsh plugins:

``` sh
antigen update
```

To make RVM works on Mac OS X Vim, move `/etc/zshenv` to `/etc/zshrc` as [Tim Pope mentioned](https://github.com/tpope/vim-rvm#faq).

``` sh
sudo mv /etc/zshenv /etc/zshrc
```
