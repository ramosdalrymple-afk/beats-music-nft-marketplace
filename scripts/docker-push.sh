#!/bin/bash

# Docker Push Script for Beats Music NFT Marketplace
# This script pushes the Docker image to a registry (Docker Hub or local registry)

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
IMAGE_NAME="beats-nft-marketplace"

# Parse command line arguments
TAG="${1:-latest}"
REGISTRY_TYPE="${2:-dockerhub}"  # dockerhub, local, or custom
CUSTOM_REGISTRY="${3:-}"

echo -e "${GREEN}=== Beats Music NFT Marketplace - Docker Push ===${NC}"
echo ""

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo -e "${RED}Error: Docker is not running${NC}"
    echo "Please start Docker and try again"
    exit 1
fi

# Check if image exists locally
if ! docker images "${IMAGE_NAME}:${TAG}" --format "{{.Repository}}" | grep -q "${IMAGE_NAME}"; then
    echo -e "${RED}Error: Image ${IMAGE_NAME}:${TAG} not found locally${NC}"
    echo -e "Please build the image first: ${YELLOW}./scripts/docker-build.sh${NC}"
    exit 1
fi

# Function to push to Docker Hub
push_to_dockerhub() {
    echo -e "${BLUE}Pushing to Docker Hub...${NC}"
    echo ""

    # Check if logged in
    if ! docker info | grep -q "Username"; then
        echo -e "${YELLOW}Please login to Docker Hub:${NC}"
        docker login
    fi

    # Get Docker Hub username
    echo -e "${YELLOW}Enter your Docker Hub username:${NC}"
    read -r DOCKERHUB_USERNAME

    # Tag image with Docker Hub username
    REMOTE_IMAGE="${DOCKERHUB_USERNAME}/${IMAGE_NAME}:${TAG}"

    echo -e "${GREEN}Tagging image as ${REMOTE_IMAGE}${NC}"
    docker tag "${IMAGE_NAME}:${TAG}" "${REMOTE_IMAGE}"

    # Also tag as latest if not already latest
    if [ "$TAG" != "latest" ]; then
        echo -e "${GREEN}Also tagging as ${DOCKERHUB_USERNAME}/${IMAGE_NAME}:latest${NC}"
        docker tag "${IMAGE_NAME}:${TAG}" "${DOCKERHUB_USERNAME}/${IMAGE_NAME}:latest"
    fi

    echo -e "${GREEN}Pushing to Docker Hub...${NC}"
    docker push "${REMOTE_IMAGE}"

    if [ "$TAG" != "latest" ]; then
        docker push "${DOCKERHUB_USERNAME}/${IMAGE_NAME}:latest"
    fi

    echo ""
    echo -e "${GREEN}✓ Successfully pushed to Docker Hub!${NC}"
    echo -e "${GREEN}Image URL:${NC} ${YELLOW}${DOCKERHUB_USERNAME}/${IMAGE_NAME}:${TAG}${NC}"
    echo ""
    echo -e "${GREEN}To use in Portainer:${NC}"
    echo -e "  Image: ${YELLOW}${DOCKERHUB_USERNAME}/${IMAGE_NAME}:${TAG}${NC}"
}

# Function to push to local registry
push_to_local() {
    echo -e "${BLUE}Pushing to local registry...${NC}"
    echo ""

    # Get local registry address
    echo -e "${YELLOW}Enter local registry address (e.g., localhost:5000 or 192.168.1.100:5000):${NC}"
    read -r REGISTRY_ADDRESS

    # Tag for local registry
    REMOTE_IMAGE="${REGISTRY_ADDRESS}/${IMAGE_NAME}:${TAG}"

    echo -e "${GREEN}Tagging image as ${REMOTE_IMAGE}${NC}"
    docker tag "${IMAGE_NAME}:${TAG}" "${REMOTE_IMAGE}"

    echo -e "${GREEN}Pushing to local registry...${NC}"
    docker push "${REMOTE_IMAGE}"

    echo ""
    echo -e "${GREEN}✓ Successfully pushed to local registry!${NC}"
    echo -e "${GREEN}Image URL:${NC} ${YELLOW}${REMOTE_IMAGE}${NC}"
    echo ""
    echo -e "${GREEN}To use in Portainer:${NC}"
    echo -e "  Image: ${YELLOW}${REMOTE_IMAGE}${NC}"
}

# Function to push to custom registry
push_to_custom() {
    if [ -z "$CUSTOM_REGISTRY" ]; then
        echo -e "${YELLOW}Enter custom registry address (e.g., registry.example.com):${NC}"
        read -r CUSTOM_REGISTRY
    fi

    echo -e "${BLUE}Pushing to custom registry: ${CUSTOM_REGISTRY}${NC}"
    echo ""

    # Check if login is needed
    echo -e "${YELLOW}Do you need to login to the registry? (y/N)${NC}"
    read -r -n 1 LOGIN_NEEDED
    echo

    if [[ $LOGIN_NEEDED =~ ^[Yy]$ ]]; then
        docker login "$CUSTOM_REGISTRY"
    fi

    # Tag for custom registry
    REMOTE_IMAGE="${CUSTOM_REGISTRY}/${IMAGE_NAME}:${TAG}"

    echo -e "${GREEN}Tagging image as ${REMOTE_IMAGE}${NC}"
    docker tag "${IMAGE_NAME}:${TAG}" "${REMOTE_IMAGE}"

    echo -e "${GREEN}Pushing to custom registry...${NC}"
    docker push "${REMOTE_IMAGE}"

    echo ""
    echo -e "${GREEN}✓ Successfully pushed to custom registry!${NC}"
    echo -e "${GREEN}Image URL:${NC} ${YELLOW}${REMOTE_IMAGE}${NC}"
}

# Function to save as tar file (for manual Portainer import)
save_as_tar() {
    echo -e "${BLUE}Saving image as tar file for Portainer import...${NC}"
    echo ""

    TAR_FILE="${IMAGE_NAME}-${TAG}.tar"

    echo -e "${GREEN}Saving to ${TAR_FILE}${NC}"
    docker save -o "${TAR_FILE}" "${IMAGE_NAME}:${TAG}"

    # Get file size
    if [ -f "$TAR_FILE" ]; then
        SIZE=$(ls -lh "$TAR_FILE" | awk '{print $5}')
        echo ""
        echo -e "${GREEN}✓ Successfully saved image!${NC}"
        echo -e "${GREEN}File:${NC} ${YELLOW}${TAR_FILE}${NC}"
        echo -e "${GREEN}Size:${NC} ${YELLOW}${SIZE}${NC}"
        echo ""
        echo -e "${GREEN}To import in Portainer:${NC}"
        echo -e "  1. Go to Portainer → Images → Import"
        echo -e "  2. Upload ${YELLOW}${TAR_FILE}${NC}"
        echo -e "  3. Create container from ${YELLOW}${IMAGE_NAME}:${TAG}${NC}"
    else
        echo -e "${RED}✗ Failed to save image${NC}"
        exit 1
    fi
}

# Main menu
echo -e "${YELLOW}Select destination:${NC}"
echo -e "  ${GREEN}1${NC} - Docker Hub (public/private repository)"
echo -e "  ${GREEN}2${NC} - Local Registry (e.g., localhost:5000)"
echo -e "  ${GREEN}3${NC} - Custom Registry"
echo -e "  ${GREEN}4${NC} - Save as TAR file (for manual Portainer import)"
echo ""
echo -e "${YELLOW}Enter choice (1-4):${NC}"

# If registry type was provided as argument
case "$REGISTRY_TYPE" in
    dockerhub|1)
        push_to_dockerhub
        ;;
    local|2)
        push_to_local
        ;;
    custom|3)
        push_to_custom
        ;;
    tar|4)
        save_as_tar
        ;;
    *)
        # Interactive mode
        read -r -n 1 CHOICE
        echo
        case "$CHOICE" in
            1)
                push_to_dockerhub
                ;;
            2)
                push_to_local
                ;;
            3)
                push_to_custom
                ;;
            4)
                save_as_tar
                ;;
            *)
                echo -e "${RED}Invalid choice${NC}"
                exit 1
                ;;
        esac
        ;;
esac

echo ""
echo -e "${GREEN}Done!${NC}"
