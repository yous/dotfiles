# Config

Configuration files for [@yous](https://github.com/yous)

## Requirements

* [Git][]
* [Vundle][]

[Git]: http://git-scm.com
[Vundle]: https://github.com/gmarik/vundle

## Install

1. Clone this repository:

    ``` sh
    $ git clone git@github.com:yous/config.git
    $ cd config
    $ git submodule init
    $ git submodule update
    ```

2. Copy configuration files to home directory:

    ``` sh
    $ ./install.sh
    $ git config --global core.excludesfile ~/.gitignore
    ```

3. Install dependencies:

    ``` sh
    $ gem install what_methods wirble
    ```

    In Vim,

    ```
    :BundleInstall
    ```

    To use zsh as default shell,

    ``` sh
    $ chsh -s /bin/zsh
    ```
