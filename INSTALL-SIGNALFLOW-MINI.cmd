@echo off
setlocal
title SignalFlow Mini Installer
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0install.ps1" -SkipBuild
if errorlevel 1 (
  echo.
  echo INSTALL FAILED. Existing recognized installation was preserved or restored.
  pause
  exit /b 1
)
echo.
echo SignalFlow Mini installation complete.
pause
