#!/bin/bash

# RustDesk Server Build Script
# Builds and deploys custom RustDesk server with AI backend

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

VERSION=${VERSION:-"latest"}
IMAGE_NAME=${IMAGE_NAME:-"rustdesk-custom-server"}
AI_IMAGE_NAME=${AI_IMAGE_NAME:-"rustdesk-ai-backend"}

echo "================================================"
echo "  RustDesk Custom Server Build Script"
echo "================================================"
echo ""
echo "Version: $VERSION"
echo "Project Root: $PROJECT_ROOT"
echo ""

build_hbbs() {
    echo "[1/4] Building hbbs (ID Server)..."
    docker build \
        --build-arg VERSION=$VERSION \
        -t rustdesk/hbbs:$VERSION \
        -f Dockerfile.hbbs \
        .
    echo "hbbs build completed."
}

build_hbbr() {
    echo "[2/4] Building hbbr (Relay Server)..."
    docker build \
        --build-arg VERSION=$VERSION \
        -t rustdesk/hbbr:$VERSION \
        -f Dockerfile.hbbr \
        .
    echo "hbbr build completed."
}

build_ai_backend() {
    echo "[3/4] Building AI Backend..."
    cd "$PROJECT_ROOT/ai-backend"
    docker build \
        --build-arg NODE_ENV=production \
        -t $AI_IMAGE_NAME:$VERSION \
        .
    echo "AI Backend build completed."
    cd "$SCRIPT_DIR"
}

deploy() {
    echo "[4/4] Deploying with Docker Compose..."
    docker-compose -f docker-compose-full.yml down
    docker-compose -f docker-compose-full.yml up -d
    echo "Deployment completed."
}

verify() {
    echo ""
    echo "Verifying deployment..."
    echo ""

    echo "Container Status:"
    docker ps --filter "name=rustdesk" --filter "name=ai"

    echo ""
    echo "Health Checks:"
    curl -s http://localhost:8080/health || echo "AI Backend not ready yet"
    curl -s http://localhost/hbbs/health || echo "hbbs not ready yet"
    curl -s http://localhost/hbbr/health || echo "hbbr not ready yet"

    echo ""
    echo "Public Key (for client configuration):"
    if [ -f "$PROJECT_ROOT/data/id_ed25519.pub" ]; then
        cat "$PROJECT_ROOT/data/id_ed25519.pub"
    else
        docker exec rustdesk-hbbs cat /root/id_ed25519.pub 2>/dev/null || echo "Key not available yet"
    fi
}

case "${1:-deploy}" in
    build)
        build_hbbs
        build_hbbr
        build_ai_backend
        ;;
    deploy)
        deploy
        sleep 5
        verify
        ;;
    rebuild)
        build_hbbs
        build_hbbr
        build_ai_backend
        deploy
        sleep 5
        verify
        ;;
    verify)
        verify
        ;;
    logs)
        docker-compose -f docker-compose-full.yml logs -f
        ;;
    stop)
        docker-compose -f docker-compose-full.yml down
        ;;
    clean)
        docker-compose -f docker-compose-full.yml down -v
        docker system prune -f
        ;;
    *)
        echo "Usage: $0 {build|deploy|rebuild|verify|logs|stop|clean}"
        echo ""
        echo "Commands:"
        echo "  build   - Build all Docker images"
        echo "  deploy  - Deploy with docker-compose"
        echo "  rebuild - Rebuild and deploy"
        echo "  verify  - Verify deployment"
        echo "  logs    - Show container logs"
        echo "  stop    - Stop all containers"
        echo "  clean   - Stop and remove all data"
        exit 1
        ;;
esac