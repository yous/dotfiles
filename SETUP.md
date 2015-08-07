# Windows

## Tweak

- [Greenshot](http://getgreenshot.org)
- [MacType](https://code.google.com/p/mactype/)
    - [Custom.ini](https://www.dropbox.com/s/ass01wzc9l3zwoz/Custom.ini?dl=0)
    - Load with MacTray
    - Run as Administrator: Check
    - Standalone loading mode
- [WizMouse](http://antibody-software.com/web/software/software/wizmouse-makes-your-mouse-wheel-work-on-the-window-under-the-mouse/)
- [날개셋](http://moogi.new21.org/prg4.html)
- Turn on Remote Desktop
- Windows Update: Download updates but let me choose whether to install them
- Turn on Sticky Keys when SHIFT is pressed five times: Uncheck
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
- [나눔고딕코딩](http://dev.naver.com/projects/nanumfont/)
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
    - Default Settings
        - Columns: 80, Rows: 66
        - Lines of scrollback: 10000
        - Font: Consolas, 10-point
        - Use separated unicode font: Check
        - Font for unicode characters: 나눔고딕코딩, 10-point
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
        - `pacman -Suy`
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
- [FileZilla](https://filezilla-project.org)
- [Gitter](https://gitter.im)
- [VNC Viewer](https://www.realvnc.com/download/viewer/)
