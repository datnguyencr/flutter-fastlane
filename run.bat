@echo off
echo run docker build...
docker build \
  --build-arg FLUTTER_VERSION=3.38.1 \
  --build-arg OPENJDK_VERSION=17 \
  --build-arg BUILD_TOOLS_VERSION=36.1.0 \
  --build-arg ANDROID_PLATFORM=android-36.1 \
  --build-arg CMAKE_VERSION=3.22.1 \
  --build-arg NDK_VERSION=27.0.12077973 \
  -t flutter-fastlane:3.38.1 .

echo.
pause
