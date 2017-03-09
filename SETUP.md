# macOS

## Tweak

- [구름 입력기](http://gureum.io) ([Unofficial releases](https://github.com/soomtong/gureum/releases))
    - [신세벌식 P2](http://pat.im/1136)
- [Workman Layout](http://www.workmanlayout.com/blog/)
    - Remove U.S. from `AppleEnabledInputSources` in `~/Library/Preferences/com.apple.HIToolbox.plist`, and then reboot

      ``` plist
      <dict>
      	<key>InputSourceKind</key>
      	<string>Keyboard Layout</string>
      	<key>KeyboardLayout ID</key>
      	<integer>0</integer>
      	<key>KeyboardLayout Name</key>
      	<string>U.S.</string>
      </dict>
      ```

      You may have ABC instead of U.S.

      ``` plist
      <dict>
      	<key>InputSourceKind</key>
      	<string>Keyboard Layout</string>
      	<key>KeyboardLayout ID</key>
      	<integer>252</integer>
      	<key>KeyboardLayout Name</key>
      	<string>ABC</string>
      </dict>
      ```

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
- [FUSE for macOS](https://osxfuse.github.io)
    - Install FUSE for macOS package
    - Install NTFS-3G by running `brew install homebrew/fuse/ntfs-3g`
    - From OS X El Capitan, reboot in [recovery mode](https://support.apple.com/en-us/HT201314)
        - Open Utilities > Terminal
    - Run following commands:

      ``` sh
      sudo mv /Volumes/Macintosh\ HD/sbin/mount_ntfs /Volumes/Macintosh\ HD/sbin/mount_ntfs.orig
      sudo ln -s /Volumes/Macintosh\ HD/usr/local/sbin/mount_ntfs /Volumes/Macintosh\ HD/sbin/mount_ntfs
      ```

## Fonts

- [SF Mono](https://developer.apple.com/fonts/) (`/Applications/Utilities/Terminal.app/Contents/Resources/Fonts/SF-Mono-*`)

## Applications

- [1Password](https://agilebits.com/downloads)
- [AppCleaner](http://freemacsoft.net/appcleaner/)
    - Turn on SmartDelete
- [Chrome](https://www.google.com/chrome/)
- [Dropbox](https://www.dropbox.com/install)
- [Fantastical](https://flexibits.com/fantastical)
- [GPG Suite](https://gpgtools.org)
    - Customize > Uncheck GPGMail
- [HyperSwitch](https://bahoom.com/hyperswitch)
    - App Switcher
        - Check "When activating an app without windows, try to open the default window"
- [MacTeX](https://www.tug.org/mactex/)
- [Palua](https://itunes.apple.com/kr/app/palua/id431494195?mt=12)
- [Safari Extensions](https://safari-extensions.apple.com)
    - [1Password](https://safari-extensions.apple.com/details/?id=com.agilebits.onepassword4-safari-2BUA8C4S2C)
    - [uBlock](https://www.ublock.org)
- [The Unarchiver](https://itunes.apple.com/kr/app/the-unarchiver/id425424353?mt=12)
- Quick Look
    - [BetterZip Quick Look Generator](https://macitbetter.com/BetterZip-Quick-Look-Generator/)
    - [Suspicious Package](http://www.mothersruin.com/software/SuspiciousPackage/)
    - [QLColorCode](https://github.com/anthonygelibert/QLColorCode)
    - [QLMarkdown](https://github.com/toland/qlmarkdown)
    - [QLStephen](https://whomwah.github.io/qlstephen/)
    - [QuickLookCSV](https://github.com/p2/quicklook-csv)
    - [qlImageSize](https://github.com/Nyx0uf/qlImageSize)
- [WinArchiver Lite](https://itunes.apple.com/kr/app/winarchiver-lite/id414855915?mt=12)

# Windows

## Tweak

- [Greenshot](http://getgreenshot.org)
- [날개셋](http://moogi.new21.org/prg4.html)
    - [신세벌식 P2](http://pat.im/1136)
- Turn on Remote Desktop
    - Set custom RDP port number via `regedit.exe`. Navigate to
      `HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp`
      and modify the value of `PortNumber`.
    - Ignore remote keyboard layout by adding `IgnoreRemoteKeyboardLayout` under
      `HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Keyboard Layout` with
      data type `REG_DWORD` and the value `1`.
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
- [gVim](http://www.vim.org/download.php#pc) and [Yongwei's gvim80.zip](http://wyw.dcweb.cn/#download)
    - [Python 2.7](https://www.python.org/downloads/)
    - [Ruby 2.2.5 (x86)](http://rubyinstaller.org/downloads/)
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
        - Font: Fixedsys, 10-point (Script: Korean)
        - Use separated unicode font: Uncheck
        - Remote character set: Use font encoding
        - Treat CJK ambiguous characters as wide: Check
    - Put `loco.bat` into `%USERPROFILE%\bin` with:

      ``` bat
      @echo off
      start /b putty -load Loco
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
        - `pacman -Sy pacman`
        - Run MSYS2 again if needed.
        - `pacman -Syu`
        - Run MSYS2 again if needed.
        - `pacman -Su`
        - `pacman -S vim wget curl openssh grep tar unzip`
        - `ssh-keygen -t rsa -b 4096 -C "$(git config user.email)"`
- [TeX Live](https://www.tug.org/texlive/acquire-netinstall.html)
- Add `%USERPROFILE%\bin` to `%PATH%`

## Applications

- [1Password](https://agilebits.com/downloads)
- [Bandizip](http://www.bandisoft.co.kr/bandizip/)
- [Chrome](https://www.google.com/chrome/)
- [Daum PotPlayer](http://tvpot.daum.net/application/PotPlayer.do)
- [Dropbox](https://www.dropbox.com/install)
- [VNC Viewer](https://www.realvnc.com/download/viewer/)
