@echo off
rem Removes the Desktop + Start Menu shortcuts (your files are kept).
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0install.ps1" -Uninstall
pause
