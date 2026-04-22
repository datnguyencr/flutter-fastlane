@echo off
setlocal enabledelayedexpansion

echo Checking for new Flutter versions...
for /f "tokens=*" %%i in ('dart scripts/check_versions.dart') do set OUTPUT=%%i

if "!OUTPUT:~0,12!"=="NEW_VERSION=" (
    set VERSION=!OUTPUT:~12!
    echo Found new version: !VERSION!
    echo Starting release process...
    call release.bat !VERSION!
) else (
    echo !OUTPUT!
    echo No action needed.
    pause
)
