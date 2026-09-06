@echo off
setlocal
title SignalFlow Mini V1 RD2 Build and Install
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0install.ps1"
if errorlevel 1 (
  echo.
  echo BUILD OR INSTALL FAILED.
  pause
  exit /b 1
)
echo.
echo SignalFlow Mini V1 RD2 is ready for owner test.
pause
