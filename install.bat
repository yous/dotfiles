@echo off

:: Files to link
set files=irbrc^

gemrc^

gitconfig^

gitignore_global^

vimrc

:: Main
for %%a in (%files%) do (
  call :replaceFile %%a
)
goto :EOF

:: Functions
:replaceFile
set dest=%USERPROFILE%\.%1
mklink %dest% %~dp0%1
if %errorlevel% == 0 (
  echo Created %dest%
) else (
  echo Failed to create %dest%
)
goto :EOF
