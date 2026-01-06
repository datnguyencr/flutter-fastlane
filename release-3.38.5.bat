@echo off
setlocal enabledelayedexpansion

REM --- Get current date in YYYYMMDD format ---
for /f "tokens=2-4 delims=/.- " %%a in ('date /t') do (
    set YYYY=%%c
    set MM=%%a
    set DD=%%b
)

REM --- Get current time in HHMMSSCC format ---
for /f "tokens=1 delims=." %%a in ("%time: =0%") do set T=%%a
set HH=%T:~0,2%
set MIN=%T:~3,2%
set SEC=%T:~6,2%
set MS=%T:~9,2%

REM --- Set Flutter version and Docker tag dynamically ---
set FLUTTER_BASE=3.38.5
set FLUTTER_VER=%FLUTTER_BASE%.%YYYY%%MM%%DD%%HH%%MIN%%SEC%%MS%
set DOCKER_TAG=%FLUTTER_VER%

REM --- Update docker_config.json ---
>docker_config.json (
  echo {
  echo   "flutter_version": "%FLUTTER_BASE%",
  echo   "docker_tag": "%DOCKER_TAG%"
  echo }
)

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
