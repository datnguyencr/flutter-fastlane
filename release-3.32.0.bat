@echo off
setlocal enabledelayedexpansion

REM --- Get current date in YYYYMMDD format ---
for /f "tokens=2-4 delims=/.- " %%a in ('date /t') do (
    set YYYY=%%c
    set MM=%%a
    set DD=%%b
)

REM --- Get current time in HHMM format ---
for /f "tokens=1-2 delims=: " %%a in ('time /t') do (
    set HH=%%a
    set MIN=%%b
)

REM --- Set Flutter version and Docker tag dynamically ---
set FLUTTER_BASE=3.32.0
set FLUTTER_VER=%FLUTTER_BASE%.%YYYY%%MM%%DD%
set DOCKER_TAG=%FLUTTER_VER%

echo -----------------------------
echo Processing Flutter version %FLUTTER_VER%
echo Docker tag: %DOCKER_TAG%

REM --- Commit changes ---
git add docker_config.json
git commit -m "Release %DOCKER_TAG%"
git push

REM --- Create and push Git tag ---
git tag -a v%DOCKER_TAG% -m "Release %DOCKER_TAG%"
git push origin v%DOCKER_TAG%

echo Done! Tag v%DOCKER_TAG% pushed.
pause
