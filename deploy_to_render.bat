@echo off
echo ========================================
echo FoodLink - Deploy to Render
echo ========================================
echo.

echo This script will help you deploy FoodLink to Render.
echo.
echo PREREQUISITES:
echo 1. GitHub account
echo 2. Code pushed to GitHub
echo 3. Render account (free at render.com)
echo.
pause

echo.
echo ========================================
echo Step 1: Check Git Status
echo ========================================
echo.

git status

echo.
echo Do you want to commit and push changes? (Y/N)
set /p commit=
if /i "%commit%"=="Y" (
    echo.
    set /p message=Enter commit message: 
    git add .
    git commit -m "%message%"
    git push origin main
    echo.
    echo ✅ Code pushed to GitHub!
)

echo.
echo ========================================
echo Step 2: Deploy to Render
echo ========================================
echo.
echo Now follow these steps:
echo.
echo 1. Go to https://render.com
echo 2. Sign up or log in with GitHub
echo 3. Click "New +" → "Web Service"
echo 4. Connect your FoodLink repository
echo 5. Configure:
echo    - Name: foodlink-api
echo    - Runtime: Node
echo    - Build Command: npm install
echo    - Start Command: npm start
echo    - Plan: Free
echo 6. Add Environment Variables:
echo    - JWT_SECRET: (click Generate)
echo    - NODE_ENV: production
echo 7. Click "Create Web Service"
echo.
echo Press any key after deployment is complete...
pause > nul

echo.
echo ========================================
echo Step 3: Get Your API URL
echo ========================================
echo.
set /p apiurl=Enter your Render URL (e.g., https://foodlink-api.onrender.com): 

echo.
echo Your API URL: %apiurl%
echo.

echo ========================================
echo Step 4: Update Flutter App
echo ========================================
echo.
echo Updating Flutter app with production URL...
cd food_link_app

echo.
echo Running update script...
dart run ../food_link_app/update_api_url.dart

echo.
echo ========================================
echo Step 5: Build Flutter APK
echo ========================================
echo.
echo Do you want to build the APK now? (Y/N)
set /p build=
if /i "%build%"=="Y" (
    echo.
    echo Cleaning...
    flutter clean
    
    echo.
    echo Getting dependencies...
    flutter pub get
    
    echo.
    echo Building release APK...
    flutter build apk --release
    
    echo.
    echo ========================================
    echo ✅ Deployment Complete!
    echo ========================================
    echo.
    echo Backend URL: %apiurl%
    echo APK Location: food_link_app\build\app\outputs\flutter-apk\app-release.apk
    echo.
    echo You can now distribute the APK to users!
)

echo.
pause
