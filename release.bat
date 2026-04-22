@echo off
setlocal enabledelayedexpansion

REM --- Usage: release.bat [version] ---
REM --- If version is not provided, it attempts to find the latest stable version ---

set INPUT_VER=%1

if "%INPUT_VER%"=="" (
    echo No version provided. Checking for latest stable Flutter version...
    for /f "tokens=*" %%i in ('dart scripts/check_versions.dart 0.0.0') do set OUTPUT=%%i
    if "!OUTPUT:~0,12!"=="NEW_VERSION=" (
        set FLUTTER_BASE=!OUTPUT:~12!
    ) else (
        echo Could not determine latest version. Please provide it manually: release.bat 3.38.7
        exit /b 1
    )
) else (
    set FLUTTER_BASE=%INPUT_VER%
)

REM --- Get current date/time for unique tag ---
for /f "tokens=2-4 delims=/.- " %%a in ('date /t') do (
    set YYYY=%%c
    set MM=%%a
    set DD=%%b
)
for /f "tokens=1 delims=." %%a in ("%time: =0%") do set T=%%a
set HH=%T:~0,2%
set MIN=%T:~3,2%
set SEC=%T:~6,2%
set MS=%T:~9,2%

set DOCKER_TAG=%FLUTTER_BASE%.%YYYY%%MM%%DD%%HH%%MIN%%SEC%%MS%

echo -----------------------------
echo Processing Flutter version %FLUTTER_BASE%
echo Docker tag: %DOCKER_TAG%

REM --- Create and push Git tag ---
echo Tagging release v%DOCKER_TAG%...
git tag -a v%DOCKER_TAG% -m "Release %DOCKER_TAG%"
git push origin v%DOCKER_TAG%

echo Done! Tag v%DOCKER_TAG% pushed.
pause
