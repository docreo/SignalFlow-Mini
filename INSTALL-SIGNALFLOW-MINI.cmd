@echo off
setlocal
title SignalFlow Mini V1 RD2 Installer
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0install.ps1"
if errorlevel 1 (
  echo.
  echo INSTALL FAILED. Existing installation was preserved or restored.
  pause
  exit /b 1
)
echo.
echo SignalFlow Mini V1 RD2 installation complete.
pause
