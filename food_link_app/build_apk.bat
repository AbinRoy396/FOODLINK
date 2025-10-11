@echo off
echo ========================================
echo Building FoodLink APK for Release
echo ========================================
echo.

echo Step 1: Cleaning previous builds...
flutter clean

echo.
echo Step 2: Getting dependencies...
flutter pub get

echo.
echo Step 3: Building release APK...
flutter build apk --release

echo.
echo ========================================
echo Build Complete!
echo ========================================
echo.
echo APK Location:
echo build\app\outputs\flutter-apk\app-release.apk
echo.
echo You can now install this APK on any Android device!
echo.
pause
