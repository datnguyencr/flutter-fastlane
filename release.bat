@echo off
setlocal

REM --- Read Flutter version and Docker tag from docker_config.json ---
for /f "usebackq tokens=*" %%i in (`powershell -Command "(Get-Content docker_config.json | ConvertFrom-Json).flutter_version"`) do set FLUTTER_VER=%%i
for /f "usebackq tokens=*" %%i in (`powershell -Command "(Get-Content docker_config.json | ConvertFrom-Json).docker_tag"`) do set DOCKER_TAG=%%i

echo -----------------------------
echo Processing Flutter version %FLUTTER_VER%
echo Docker tag: %DOCKER_TAG%

REM --- Commit changes if needed ---
git add docker_config.json
git commit -m "Release %DOCKER_TAG%"
git push

REM --- Create and push Git tag ---
git tag -a v%DOCKER_TAG% -m "Release %DOCKER_TAG%"
git push origin v%DOCKER_TAG%

echo Done! Tag v%DOCKER_TAG% pushed.
pause
