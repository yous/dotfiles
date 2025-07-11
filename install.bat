@echo off

:: Files to link
set files=ctags^

gemrc^

git-templates^

gitattributes_global^

gitconfig^

gitignore_global^

irbrc^

npmrc^

vimrc

:: Files to link into bin
set binfiles=diff-highlight^

diff-highlight.bat^

diff-hunk-list^

diff-hunk-list.bat^

server^

server.bat

:: Main
for %%a in (%files%) do (
  call :replaceFile %%a
)
for %%a in (%binfiles%) do (
  call :replaceFile bin\%%a %USERPROFILE%\bin\%%a
)
call :replaceFile pip.conf %APPDATA%\pip\pip.ini
call :replaceFile vimrc %USERPROFILE%\AppData\Local\nvim\init.vim
goto :EOF

:: Functions
:replaceFile
if not "%2" == "" (
  set dest=%2
) else (
  set dest=%USERPROFILE%\.%1
)
for %%f in ("%dest%") do set dirname=%%~dpf
if not exist %dirname% mkdir %dirname%
if exist %~dp0%1\* (
  mklink /j %dest% %~dp0%1
) else (
  mklink %dest% %~dp0%1
)
if %errorlevel% == 0 (
  echo Created %dest%
) else (
  echo Failed to create %dest%
)
goto :EOF
