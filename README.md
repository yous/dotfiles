# Config

Configuration files for [@yous](https://github.com/yous).

- [Requirements](#requirements)
- [Install](#install)
    - [IntelliJ, Android Studio](#intellij-android-studio)
    - [Homebrew](#homebrew)
    - [Git](#git)
    - [iTerm2](#iterm2)
    - [Ruby](#ruby)
    - [Vim](#vim)
    - [Zsh](#zsh)
    - [Mac OS X](#mac-os-x)

## Requirements

- [Git](http://git-scm.com)

## Install

Clone this repository:

``` sh
git clone https://github.com/yous/config.git
cd config
```

For available install options:

``` sh
./install.sh
```

Command option | Description
---------------|-----------------------------------------------
`link`         | Install symbolic links
`brew`         | Install Homebrew
`brews`        | Install brews
`ntfs`         | Install ntfs-3g to write to NTFS external disk
`rbenv`        | Install rbenv
`rvm`          | Install RVM
`vim`          | Install Vim environments

### IntelliJ, Android Studio

To use [Tomorrow Theme](https://github.com/ChrisKempson/Tomorrow-Theme):

1. Open File > Import Settings… in [IntelliJ](http://www.jetbrains.com/idea/) or [Android Studio](http://developer.android.com/sdk/installing/studio.html).
2. Select `tomorrow-theme/Jetbrains/settings.jar`.
3. Open Settings > Editor > Colors & Fonts.
4. Select a scheme of Tomorrow Theme.

### Homebrew

If you want to install [Homebrew](http://brew.sh),

``` sh
./install.sh brew
```

Then install brews with:

``` sh
rvm use system # To compile Vim with Ruby support
./install.sh brews
```

### Git

Set user-specific configurations on `gitconfig`:

```
[user]
	name = Your Name
	email = you@example.com
```

If you are using [Keybase](https://keybase.io):

```
[user]
	signingkey = YOUR KEY
[commit]
	gpgsign = true
```

For more information about signing commits, see [A Git Horror Story: Repository Integrity With Signed Commits](http://mikegerwitz.com/papers/git-horror-story).

### iTerm2

To use [Solarized](https://github.com/altercation/solarized) on [iTerm2](http://www.iterm2.com):

1. Open Preferences… > Profiles > Colors.
2. Click 'Load Presets…' and select 'Import…'.
3. Select `*.itermcolors` files under `solarized/iterm2-colors-solarized/`.
4. Click 'Load Presets…' again and select one of Solarized.

To use [Tomorrow Theme](https://github.com/ChrisKempson/Tomorrow-Theme):

1. Open Preferences… > Profiles > Colors.
2. Click 'Load Presets…' and select 'Import…'.
3. Select `*.itermcolors` files under `tomorrow-theme/iTerm2/`.
4. Click 'Load Presets…' again and select one of Tomorrow Theme.

### Ruby

If you want to install [RVM](http://rvm.io),

``` sh
./install.sh rvm
```

If you want to install [rbenv](https://github.com/sstephenson/rbenv),

``` sh
./install.sh rbenv
```

If you are using RVM,

``` sh
rvm use current@global
gem install wirble
```

Otherwise just install gems:

``` sh
gem install wirble
```

### Vim

To install [vim-plug](https://github.com/junegunn/vim-plug) and other [Vim](http://www.vim.org) plugins,

``` sh
./install.sh vim
```

To update vim-plug:

```
:PlugUpgrade
```

To update Vim plugins:

```
:PlugUpdate
```

### Zsh

To use [Zsh](http://www.zsh.org) as default shell,

``` sh
chsh -s /bin/zsh
```

If you use custom Zsh like compiled one by [Homebrew](http://brew.sh),

``` sh
chsh -s /usr/local/bin/zsh
```

To update [Antigen](http://antigen.sharats.me):

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

### Mac OS X

To write to NTFS external disk,

``` sh
./install.sh ntfs
```

You can see more information in [How to Write to NTFS External Disk Drives from OS X 10.9.2 Mavericks](http://coolestguidesontheplanet.com/how-to-write-to-a-ntfs-drive-from-os-x-mavericks/). The original `/sbin/mount_ntfs` links to `/System/Library/Filesystems/ntfs.fs/Contents/Resources/mount_ntfs`.
