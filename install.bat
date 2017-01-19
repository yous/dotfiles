@echo off

:: Files to link
set files=gemrc^

gitattributes_global^

gitconfig^

gitignore_global^

irbrc^

vimrc

:: Main
for %%a in (%files%) do (
  call :replaceFile %%a
)
goto :EOF

:: Functions
:replaceFile
if not "%2" == "" (
  set dest=%USERPROFILE%\%2
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
