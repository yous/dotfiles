@echo off

:: Files to link
set files=irbrc^

gemrc^

gitattributes_global^

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
if not "%2" == "" (
  set dest=%USERPROFILE%\%2
) else (
  set dest=%USERPROFILE%\.%1
)
for %%f in ("%dest%") do set dirname=%%~dpf
if not exist %dirname% mkdir %dirname%
mklink %dest% %~dp0%1
if %errorlevel% == 0 (
  echo Created %dest%
) else (
  echo Failed to create %dest%
)
goto :EOF
