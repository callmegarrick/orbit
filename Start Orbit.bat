@echo off
rem Starts the Orbit server (hidden) and opens the app in your default browser.
start "" /min powershell -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File "%~dp0serve.ps1"
timeout /t 1 /nobreak >nul
start "" "http://localhost:8123/"
