@echo off
chcp 65001 >nul
title RideFlow - Simple Build

echo ==========================================
echo    RIDEFLOW - SIMPLE BUILD
echo ==========================================
echo.

cd /d "%~dp0app"

echo Step 1: Installing pkg globally...
npm install -g pkg
if errorlevel 1 (
    echo Failed to install pkg globally
    echo Trying with sudo...
    npm install -g pkg --force
)

echo.
echo Step 2: Installing dependencies...
npm install

echo.
echo Step 3: Building executable...
node node_modules\pkg\lib-es5\bin.js . --out-path=dist

echo.
echo Step 4: Creating launcher...
node create-launcher.js

echo.
echo ==========================================
echo    BUILD COMPLETE!
echo ==========================================
echo.
echo Now you need to:
echo 1. Copy your .env file to app\dist\
echo 2. ZIP the dist folder
echo 3. Share with friends!
echo.
pause
