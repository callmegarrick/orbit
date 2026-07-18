@echo off
rem Registers a Windows task: every morning at 9:00 a native Orbit notification
rem appears (browser can be fully closed). Clicking it opens the app.
schtasks /create /f /tn "Orbit morning nudge" /sc daily /st 09:00 /tr "powershell.exe -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File \"%~dp0orbit-notify.ps1\""
if %errorlevel%==0 (
  echo.
  echo Done! Windows will show an Orbit notification every morning at 9:00.
  echo Tip: turn on auto-backup in Orbit's Settings so the notification
  echo shows actual names and birthdays instead of a generic reminder.
) else (
  echo Something went wrong - try right-clicking this file and "Run as administrator".
)
echo.
pause
