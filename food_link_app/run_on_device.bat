@echo off
echo ========================================
echo FoodLink - Run on Android Device
echo ========================================
echo.

echo Checking for connected devices...
flutter devices
echo.

echo ========================================
echo IMPORTANT: Authorize USB Debugging
echo ========================================
echo.
echo 1. Check your phone screen for "Allow USB debugging?" dialog
echo 2. Tap "Allow" or "OK"
echo 3. Make sure USB mode is set to "File Transfer" (not "Charging only")
echo.
echo Press any key after authorizing your device...
pause > nul

echo.
echo Checking devices again...
flutter devices
echo.

echo ========================================
echo Running FoodLink on your device...
echo ========================================
echo.
flutter run

pause
