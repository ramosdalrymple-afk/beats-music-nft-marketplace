#!/bin/bash

# Docker Build Script for Beats Music NFT Marketplace
# This script builds the Docker image with proper tagging

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
IMAGE_NAME="beats-nft-marketplace"
DOCKERFILE_PATH="./frontend/Dockerfile"
BUILD_CONTEXT="./frontend"

# Get version from package.json or use 'latest'
if [ -f "./frontend/package.json" ]; then
    VERSION=$(grep '"version"' ./frontend/package.json | head -1 | sed 's/.*"version": "\(.*\)".*/\1/')
else
    VERSION="latest"
fi

# Parse command line arguments
TAG="${1:-latest}"
PLATFORM="${2:-linux/amd64}"

echo -e "${GREEN}=== Beats Music NFT Marketplace - Docker Build ===${NC}"
echo -e "Image Name: ${YELLOW}${IMAGE_NAME}${NC}"
echo -e "Tag: ${YELLOW}${TAG}${NC}"
echo -e "Version: ${YELLOW}${VERSION}${NC}"
echo -e "Platform: ${YELLOW}${PLATFORM}${NC}"
echo ""

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo -e "${RED}Error: Docker is not running${NC}"
    echo "Please start Docker and try again"
    exit 1
fi

# Check if Dockerfile exists
if [ ! -f "$DOCKERFILE_PATH" ]; then
    echo -e "${RED}Error: Dockerfile not found at $DOCKERFILE_PATH${NC}"
    exit 1
fi

# Check if build context exists
if [ ! -d "$BUILD_CONTEXT" ]; then
    echo -e "${RED}Error: Build context directory not found at $BUILD_CONTEXT${NC}"
    exit 1
fi

echo -e "${GREEN}Building Docker image...${NC}"
echo ""

# Build the image
docker build \
    --platform "$PLATFORM" \
    -t "${IMAGE_NAME}:${TAG}" \
    -t "${IMAGE_NAME}:${VERSION}" \
    -t "${IMAGE_NAME}:latest" \
    -f "$DOCKERFILE_PATH" \
    "$BUILD_CONTEXT"

# Check if build was successful
if [ $? -eq 0 ]; then
    echo ""
    echo -e "${GREEN}✓ Build completed successfully!${NC}"
    echo ""
    echo -e "${GREEN}Image tags created:${NC}"
    echo -e "  • ${YELLOW}${IMAGE_NAME}:${TAG}${NC}"
    echo -e "  • ${YELLOW}${IMAGE_NAME}:${VERSION}${NC}"
    echo -e "  • ${YELLOW}${IMAGE_NAME}:latest${NC}"
    echo ""

    # Show image size
    SIZE=$(docker images "${IMAGE_NAME}:${TAG}" --format "{{.Size}}")
    echo -e "${GREEN}Image size:${NC} ${YELLOW}${SIZE}${NC}"
    echo ""

    # Provide next steps
    echo -e "${GREEN}Next steps:${NC}"
    echo -e "  1. Test locally: ${YELLOW}docker run -p 3000:3000 ${IMAGE_NAME}:${TAG}${NC}"
    echo -e "  2. Save for Portainer: ${YELLOW}docker save -o ${IMAGE_NAME}.tar ${IMAGE_NAME}:${TAG}${NC}"
    echo -e "  3. Push to registry: ${YELLOW}./scripts/docker-push.sh ${TAG}${NC}"
    echo ""
else
    echo -e "${RED}✗ Build failed${NC}"
    exit 1
fi

# Optional: Clean up dangling images
read -p "Do you want to clean up dangling images? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Cleaning up dangling images...${NC}"
    docker image prune -f
    echo -e "${GREEN}✓ Cleanup complete${NC}"
fi
