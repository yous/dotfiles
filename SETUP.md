# macOS

## Tweak

- [구름 입력기](http://gureum.io) ([Unofficial releases](https://github.com/soomtong/gureum/releases))
  - [신세벌식 P2](https://pat.im/1136)
- [Workman Layout](http://workmanlayout.org)
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
  - Install NTFS-3G by running `brew install ntfs-3g`
  - From OS X El Capitan, reboot in [recovery mode](https://support.apple.com/en-us/HT201314)
    - Open Utilities > Terminal
  - Run following commands:

    ``` sh
    mv /Volumes/Macintosh\ HD/sbin/mount_ntfs /Volumes/Macintosh\ HD/sbin/mount_ntfs.orig
    ln -s /Volumes/Macintosh\ HD/usr/local/sbin/mount_ntfs /Volumes/Macintosh\ HD/sbin/mount_ntfs
    ```

## Fonts

- [Hack](https://sourcefoundry.org/hack/)
- [SF Mono](https://developer.apple.com/fonts/)
  - macOS Sierra: `/Applications/Utilities/Terminal.app/Contents/Resources/Fonts/SF-Mono-*`
  - macOS High Sierra: `/Applications/Utilities/Terminal.app/Contents/Resources/Fonts/SFMono-*`

## Applications

- [반디집](https://www.bandisoft.com/bandizip.mac/)
- [1Password](https://agilebits.com/downloads)
- [AppCleaner](https://freemacsoft.net/appcleaner/)
  - Turn on SmartDelete
- [Chrome](https://www.google.com/chrome/)
- [Contexts](https://contexts.co)
- [Dropbox](https://www.dropbox.com/install)
- [Fluor](https://github.com/Pyroh/Fluor)
- [GPG Suite](https://gpgtools.org)
  - Customize > Uncheck GPGMail
- [Itsycal](https://www.mowglii.com/itsycal/)
- [MacTeX](https://www.tug.org/mactex/)
- [Safari Extensions](https://safari-extensions.apple.com)
  - [1Password](https://safari-extensions.apple.com/details/?id=com.agilebits.onepassword4-safari-2BUA8C4S2C)
  - [Translate](https://safari-extensions.apple.com/details/?id=com.sidetree.Translate-S64NDGV2C5)
  - [uBlock Origin](https://safari-extensions.apple.com/details/?id=com.el1t.uBlock-3NU33NW2M3)
- Quick Look
  - [BetterZip Quick Look Generator](https://macitbetter.com/BetterZip-Quick-Look-Generator/)
  - [Suspicious Package](https://www.mothersruin.com/software/SuspiciousPackage/)
  - [QLColorCode](https://github.com/anthonygelibert/QLColorCode)
  - [QLMarkdown](https://github.com/toland/qlmarkdown)
  - [QLStephen](https://whomwah.github.io/qlstephen/)
  - [QuickLookCSV](https://github.com/p2/quicklook-csv)
  - [qlImageSize](https://github.com/Nyx0uf/qlImageSize)

# Windows

## Tweak

- [날개셋](http://moogi.new21.org/prg4.html)
  - [신세벌식 P2](https://pat.im/1136)
- [Workman Layout](http://workmanlayout.org)
  - 날개셋 제어판 > 시스템 계층 > 고급 시스템 옵션
    - Set "한글 IME와 연결할 영문 키보드 드라이버" to "Workman (US) Keyboard Layout (wm-us.dll)", then reboot
  - 날개셋 제어판 > 편집기 계층 > 단축글쇠
    - Add "RAlt" for "1 글자판(입력 항목) 전환" with expression of "!A"
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

- [나눔글꼴](https://hangeul.naver.com/font) (나눔바른고딕, 나눔명조)
- [D2 Coding](https://github.com/naver/d2codingfont)
- [KoPub 서체](http://www.kopus.org/biz/electronic/font.aspx)
- [Noto CJK](https://www.google.com/get/noto/help/cjk/)

## Tools

- [Git](https://git-scm.com)
  - [dotfiles](https://github.com/yous/dotfiles)
- [gVim](https://github.com/vim/vim-win32-installer/releases)
  - [Python 2.7.15](https://www.python.org/downloads/release/python-2715/)
  - [Python 3.6.5](https://www.python.org/downloads/release/python-365/)
  - [Ruby 2.4.4 (x86)](https://rubyinstaller.org/downloads/archives/)
    - Add `bin` and `bin/ruby_builtin_dlls` to `%PATH%`
  - [Ctags](https://github.com/universal-ctags/ctags-win32)
    - Put into `%USERPROFILE%\bin`
- [iPuTTY](https://github.com/iPuTTY/iPuTTY)
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
- [MSYS2](https://www.msys2.org)
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
    - `pacman -Syu`
    - Run MSYS2 again if needed.
    - `pacman -Su`
    - `pacman -S vim wget curl openssh grep tar unzip`
    - `ssh-keygen -t rsa -b 4096 -C "$(git config user.email)"`
- [TeX Live](https://www.tug.org/texlive/acquire-netinstall.html)
- Add `%USERPROFILE%\bin` to `%PATH%`

## Applications

- [팟플레이어](https://tv.kakao.com/guide/potplayer)
- [1Password](https://agilebits.com/downloads)
- [Bandizip](https://www.bandisoft.com/bandizip/)
- [Chrome](https://www.google.com/chrome/)
- [Dropbox](https://www.dropbox.com/install)
- [ShareX](https://getsharex.com)
- [VNC Viewer](https://www.realvnc.com/download/viewer/)
