@echo off
REM Docker Build Script for Beats Music NFT Marketplace (Windows)
REM This script builds the Docker image with proper tagging

setlocal enabledelayedexpansion

REM Configuration
set IMAGE_NAME=beats-nft-marketplace
set DOCKERFILE_PATH=.\frontend\Dockerfile
set BUILD_CONTEXT=.\frontend

REM Get tag from argument or use 'latest'
set TAG=%1
if "%TAG%"=="" set TAG=latest

REM Get platform from argument or use default
set PLATFORM=%2
if "%PLATFORM%"=="" set PLATFORM=linux/amd64

echo ========================================
echo Beats Music NFT Marketplace - Docker Build
echo ========================================
echo Image Name: %IMAGE_NAME%
echo Tag: %TAG%
echo Platform: %PLATFORM%
echo.

REM Check if Docker is running
docker info >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Docker is not running
    echo Please start Docker Desktop and try again
    exit /b 1
)

REM Check if Dockerfile exists
if not exist "%DOCKERFILE_PATH%" (
    echo [ERROR] Dockerfile not found at %DOCKERFILE_PATH%
    exit /b 1
)

REM Check if build context exists
if not exist "%BUILD_CONTEXT%" (
    echo [ERROR] Build context directory not found at %BUILD_CONTEXT%
    exit /b 1
)

echo Building Docker image...
echo.

REM Build the image
docker build --platform %PLATFORM% -t %IMAGE_NAME%:%TAG% -t %IMAGE_NAME%:latest -f %DOCKERFILE_PATH% %BUILD_CONTEXT%

if errorlevel 1 (
    echo.
    echo [ERROR] Build failed
    exit /b 1
)

echo.
echo [SUCCESS] Build completed successfully!
echo.
echo Image tags created:
echo   - %IMAGE_NAME%:%TAG%
echo   - %IMAGE_NAME%:latest
echo.

REM Show image size
for /f "tokens=*" %%i in ('docker images %IMAGE_NAME%:%TAG% --format "{{.Size}}"') do set SIZE=%%i
echo Image size: %SIZE%
echo.

echo Next steps:
echo   1. Test locally: docker run -p 3000:3000 %IMAGE_NAME%:%TAG%
echo   2. Save for Portainer: docker save -o %IMAGE_NAME%.tar %IMAGE_NAME%:%TAG%
echo   3. Push to registry: .\scripts\docker-push.bat %TAG%
echo.

pause
