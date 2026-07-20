@echo off
cd /d "%~dp0"
echo Publishing Orbit to github.com/callmegarrick/orbit ...
echo A GitHub sign-in window will appear - sign in with your browser when it does.
echo.
git push -u origin main
echo.
if %errorlevel%==0 (
  echo SUCCESS - Orbit's code is now on GitHub.
) else (
  echo Something went wrong - tell Claude what the message above says.
)
pause
