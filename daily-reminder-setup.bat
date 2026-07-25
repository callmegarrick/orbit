@echo off
rem Optional: makes Windows open Kith every morning at 9:00 so you never miss a reminder.
rem Run this once. To remove later, run:  schtasks /delete /tn "Kith daily" /f
schtasks /create /f /tn "Kith daily" /sc daily /st 09:00 /tr "\"%~dp0Start Kith.bat\""
if %errorlevel%==0 (
  echo.
  echo Done! Kith will open every day at 9:00 am.
) else (
  echo.
  echo Could not create the task. Try right-clicking this file and "Run as administrator".
)
pause
