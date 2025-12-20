@echo off
REM Docker Push Script for Beats Music NFT Marketplace (Windows)
REM This script pushes the Docker image or saves it as TAR for Portainer

setlocal enabledelayedexpansion

REM Configuration
set IMAGE_NAME=beats-nft-marketplace

REM Get tag from argument or use 'latest'
set TAG=%1
if "%TAG%"=="" set TAG=latest

echo ========================================
echo Beats Music NFT Marketplace - Docker Push
echo ========================================
echo.

REM Check if Docker is running
docker info >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Docker is not running
    echo Please start Docker Desktop and try again
    exit /b 1
)

REM Check if image exists locally
docker images %IMAGE_NAME%:%TAG% --format "{{.Repository}}" | findstr /C:"%IMAGE_NAME%" >nul
if errorlevel 1 (
    echo [ERROR] Image %IMAGE_NAME%:%TAG% not found locally
    echo Please build the image first: .\scripts\docker-build.bat
    exit /b 1
)

echo Select destination:
echo   1 - Docker Hub (public/private repository)
echo   2 - Local Registry (e.g., localhost:5000)
echo   3 - Save as TAR file (for manual Portainer import) [RECOMMENDED]
echo.
set /p CHOICE="Enter choice (1-3): "

if "%CHOICE%"=="1" goto dockerhub
if "%CHOICE%"=="2" goto local
if "%CHOICE%"=="3" goto tar
echo [ERROR] Invalid choice
exit /b 1

:dockerhub
echo.
echo Pushing to Docker Hub...
echo.
set /p DOCKERHUB_USERNAME="Enter your Docker Hub username: "

REM Tag image
docker tag %IMAGE_NAME%:%TAG% %DOCKERHUB_USERNAME%/%IMAGE_NAME%:%TAG%
docker tag %IMAGE_NAME%:%TAG% %DOCKERHUB_USERNAME%/%IMAGE_NAME%:latest

echo.
echo Please login to Docker Hub:
docker login

echo.
echo Pushing to Docker Hub...
docker push %DOCKERHUB_USERNAME%/%IMAGE_NAME%:%TAG%
docker push %DOCKERHUB_USERNAME%/%IMAGE_NAME%:latest

echo.
echo [SUCCESS] Successfully pushed to Docker Hub!
echo Image URL: %DOCKERHUB_USERNAME%/%IMAGE_NAME%:%TAG%
echo.
echo To use in Portainer:
echo   Image: %DOCKERHUB_USERNAME%/%IMAGE_NAME%:%TAG%
goto end

:local
echo.
echo Pushing to local registry...
echo.
set /p REGISTRY_ADDRESS="Enter local registry address (e.g., localhost:5000 or 192.168.1.100:5000): "

REM Tag for local registry
docker tag %IMAGE_NAME%:%TAG% %REGISTRY_ADDRESS%/%IMAGE_NAME%:%TAG%

echo.
echo Pushing to local registry...
docker push %REGISTRY_ADDRESS%/%IMAGE_NAME%:%TAG%

echo.
echo [SUCCESS] Successfully pushed to local registry!
echo Image URL: %REGISTRY_ADDRESS%/%IMAGE_NAME%:%TAG%
echo.
echo To use in Portainer:
echo   Image: %REGISTRY_ADDRESS%/%IMAGE_NAME%:%TAG%
goto end

:tar
echo.
echo Saving image as tar file for Portainer import...
echo.

set TAR_FILE=%IMAGE_NAME%-%TAG%.tar

echo Saving to %TAR_FILE%
docker save -o %TAR_FILE% %IMAGE_NAME%:%TAG%

if errorlevel 1 (
    echo [ERROR] Failed to save image
    exit /b 1
)

REM Get file size
for %%A in (%TAR_FILE%) do set SIZE=%%~zA

REM Convert bytes to MB
set /a SIZE_MB=%SIZE% / 1048576

echo.
echo [SUCCESS] Successfully saved image!
echo File: %TAR_FILE%
echo Size: %SIZE_MB% MB
echo.
echo To import in Portainer:
echo   1. Go to Portainer -^> Images -^> Import
echo   2. Upload %TAR_FILE%
echo   3. Create container from %IMAGE_NAME%:%TAG%
goto end

:end
echo.
echo Done!
pause
