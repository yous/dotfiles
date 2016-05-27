# OS X

## Tweak

- [구름 입력기](http://gureum.io) ([Unofficial releases](https://github.com/soomtong/gureum/releases))
    - [신세벌식 P](http://pat.im/1110)
- System Preferences
    - Language & Region > Advanced… > Times
        - Set "Medium" to "00-23:08:09"
    - Keyboard
        - Turn on "Automatically switch to a document's input source"
    - Users & Groups
        - Disable Guest User
    - App Store
        - Turn off "Automatically download apps purchased on other Macs"
- FaceTime
    - Turn off "Calls From iPhone"
- Safari
    - View
        - Show Status Bar
    - Preferences
        - General
            - Set "Remove history items" to "After one month" or "After two weeks"
            - Turn off "Open “safe” files after downloading"
        - AutoFill
            - Turn off every fields
        - Passwords
            - Turn off every fields
        - Extensions
            - [1Password](https://agilebits.com/onepassword)
            - [retab](https://github.com/brj/retab)
            - [uBlock](https://www.ublock.org)
        - Advanced
            - Turn on "Show full website address"
- Disable press-and-hold for keys in favor of key repeat:

    ``` sh
    defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false
    ```
- Set the prefix name of screen shots:

    ``` sh
    defaults write com.apple.screencapture name -string 'Screenshot'
    ```

# Windows

## Tweak

- [Greenshot](http://getgreenshot.org)
- [날개셋](http://moogi.new21.org/prg4.html)
    - [신세벌식 P](http://pat.im/1110)
- Turn on Remote Desktop
    - Set custom RDP port number via `regedit.exe`. Navigate to
      `HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp`
      and modify the value of `PortNumber`.
- Windows Update: Download updates but let me choose whether to install them
- Turn on Sticky Keys when SHIFT is pressed five times: Uncheck
- Disallow the system to suggest companion windows when using Snap
    - Turn off Settings > Multitasking > Allow the system to suggest companion windows when using Snap
- Configure Windows Updates
    - Run `gpedit.msc`
    - Select Computer Configuration > Administrative Templates > Windows Components > Windows Update
    - Open Configure Automatic Updates
    - Set it Enabled and choose "3 - Auto download and notify for install"
- Add a task to Tasks Scheduler:
    - Name: Windows Defender Update
    - Location: \
    - Run whether user is logged on or not: Check
    - Triggers: Daily, At 4:00 AM every day
    - Actions: Start a program, "C:\Program Files\Windows Defender\MpCmdRun.exe" -SignatureUpdate -MMPC
    - Allow task to be run on demand: Check
    - If the running task does not end when requested, force it to stop: Check
- Map CapsLock key to Control with `caps_lock_to_control.reg`:

  ``` registry
  Windows Registry Editor Version 5.00

  [HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Keyboard Layout]
  "Scancode Map"=hex:00,00,00,00,00,00,00,00,02,00,00,00,1d,00,3a,00,00,00,00,00
  ```

  You can revert with `remove_scancode_mappings.reg`:

  ``` registry
  Windows Registry Editor Version 5.00

  [HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Keyboard Layout]
  "Scancode Map"=-
  ```

## Fonts

- [나눔글꼴](http://hangeul.naver.com/font) (나눔바른고딕, 나눔명조)
- [D2 Coding](http://dev.naver.com/projects/d2coding)
- [KoPub 서체](http://www.kopus.org/biz/electronic/font.aspx)
- [Noto Sans CJK](https://www.google.com/get/noto/help/cjk/)

## Tools

- [Git](http://git-scm.com)
    - [dotfiles](https://github.com/yous/dotfiles)
- [gVim](http://www.vim.org/download.php#pc) and [Yongwei's gvim74.zip](http://wyw.dcweb.cn/#download)
    - [Python 2.7](https://www.python.org/downloads/)
    - [Ruby 2.0.0 (x86)](http://rubyinstaller.org/downloads/)
        - Add `bin` to `%PATH%`
    - [Ctags](http://ctags.sourceforge.net)
        - Put into `%USERPROFILE%\bin`
- [iPuTTY](https://bitbucket.org/daybreaker/iputty)
    - Put `putty.exe` into `%USERPROFILE%\bin`
    - Import [tomorrow-theme/PuTTY/Tomorrow Night.reg](https://github.com/yous/tomorrow-theme/blob/fix-putty-reg/PuTTY/Tomorrow%20Night.reg)
    - Default Settings
        - Columns: 80, Rows: 66
        - Lines of scrollback: 10000
        - Font: Consolas, 10-point
        - Use separated unicode font: Check
        - Font for unicode characters: D2Coding, 10-point
        - Hide mouse pointer when typing in window: Check
        - Show tray icon: Never
        - Remote character set: UTF-8
        - Terminal-type string: xterm-256color
    - Loco
        - Host Name: bbs@loco.kaist.ac.kr
        - Columns: 80, Rows: 62
        - Font: Fixedsys, 10-point
        - Use separated unicode font: Uncheck
        - Remote character set: Use font encoding
        - Treat CJK ambiguous characters as wide: Check
    - Put `loco.bat` into `%USERPROFILE%\bin` with:

      ``` bat
      @echo off
      start /b putty -load loco
      ```
- [Java SE](http://www.oracle.com/technetwork/java/javase/downloads/index.html)
- [MSYS2](https://msys2.github.io)
    - Option
        - Transparency: Med.
        - Cursor: Block
        - Blinking: Uncheck
        - Font: Consolas, 10-point
        - Show bold as font: Check
        - Locale: en\_US
        - Character set: UTF-8
        - Terminal Type: xterm-256color
    - Setup
        - `update-core`
        - Run MSYS2 again.
        - `pacman -Su`
        - `pacman -S zsh vim wget curl openssh grep tar unzip`
        - `C:\msys64\msys2_shell.bat`:

          ``` diff
          -start %WD%mintty -i /msys2.ico /usr/bin/bash --login %*
          +start %WD%mintty -i /msys2.ico /usr/bin/zsh --login %*
          ```
        - `ssh-keygen -t rsa -b 4096 -C "$(git config user.email)"`
- [TeX Live](https://www.tug.org/texlive/acquire-netinstall.html)
- Add `%USERPROFILE%\bin` to `%PATH%`

## Applications

- [1Password](https://agilebits.com/onepassword)
- [Bandizip](http://www.bandisoft.co.kr/bandizip/)
- [Chrome](https://www.google.com/chrome/)
- [Daum PotPlayer](http://tvpot.daum.net/application/PotPlayer.do)
- [Dropbox](https://www.dropbox.com/install)
- [VNC Viewer](https://www.realvnc.com/download/viewer/)
