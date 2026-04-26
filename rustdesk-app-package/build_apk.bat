@echo off
REM ========================================================
REM  RustDesk AI - Windows APK Build Script
REM  Builds Android APK using Flutter CLI
REM ========================================================

set SCRIPT_DIR=%~dp0
set FLUTTER_DIR=%SCRIPT_DIR%flutter
set ANDROID_OUTPUT_DIR=%SCRIPT_DIR%build\android
set VERSION=1.0.0
set BUILD_NUMBER=1

echo ================================================
echo   Building Android APK
echo ================================================
echo.

REM Check for Flutter in common locations
set FLUTTER_PATH=

if exist "D:\flutter-SDK\flutter\bin\flutter.bat" (
    set FLUTTER_PATH=D:\flutter-SDK\flutter\bin\flutter.bat
    goto found_flutter
)

if exist "D:\flutter\bin\flutter.bat" (
    set FLUTTER_PATH=D:\flutter\bin\flutter.bat
    goto found_flutter
)

if exist "C:\flutter\bin\flutter.bat" (
    set FLUTTER_PATH=C:\flutter\bin\flutter.bat
    goto found_flutter
)

REM Try PATH
where flutter >nul 2>&1
if %ERRORLEVEL% equ 0 (
    set FLUTTER_PATH=flutter
    goto found_flutter
)

echo ERROR: Flutter SDK not found!
echo Please install Flutter or add it to your PATH
echo Download from: https://flutter.dev/docs/get-started/install/windows
pause
exit /b 1

:found_flutter
echo Flutter found at: %FLUTTER_PATH%
echo.

cd /d "%FLUTTER_DIR%"

echo Cleaning old builds...
call "%FLUTTER_PATH%" clean
if %ERRORLEVEL% neq 0 (
    echo Clean failed, continuing...
)

echo.
echo Getting dependencies...
call "%FLUTTER_PATH%" pub get
if %ERRORLEVEL% neq 0 (
    echo.
    echo ERROR: pub get failed!
    pause
    exit /b 1
)

echo.
echo Building Debug APK...
call "%FLUTTER_PATH%" build apk --debug
if %ERRORLEVEL% neq 0 (
    echo.
    echo ERROR: Debug APK build failed!
    pause
    exit /b 1
)

echo.
echo Build Debug APK completed!
echo.
echo APK Output: %FLUTTER_DIR%\build\android\app\debug\app-debug.apk
echo.
echo You can also run this script again to build Release APK.
echo.
pause