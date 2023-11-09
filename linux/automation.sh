#!/bin/bash
# This script is used to automate the process of building and pushing the Docker image

# Declare default values for variables
DOCKER_REGISTRY=
IMAGE_NAME="stack-io"

function parseCLIArgs() {
    # Parse CLI arguments
    while [[ $# -gt 0 ]]; do
        key="$1"
        case $key in
            -r|--registry)
            DOCKER_REGISTRY="$2"
            shift 2 
            ;;
            -i|--image)
            IMAGE_NAME="$2"
            shift 2
            ;;
            -p|--push)
            PUSH=true
            shift 1
            ;;
            *)
            echo "Unknown option: $1"
            exit 1
            ;;
        esac
    done
}

# Use docker inspect to get a list of all tags for the image
TAGS=$(docker inspect --format='{{.RepoTags}}' "$DOCKER_REGISTRY$IMAGE_NAME")
# Extract individual tags and find the latest version
LATEST_VERSION=$(echo "$TAGS" | grep -Eo '([0-9]+\.[0-9]+\.[0-9]+)' | sort -Vr | head -n 1)

# Change to the root directory of the project, if not already there
cd "$(git rev-parse --show-cdup)" || exit
function bumpVersion() {
    # Use docker inspect to get a list of all tags for the image
    TAGS=$(docker inspect --format='{{.RepoTags}}' $DOCKER_REGISTRY$IMAGE_NAME)
    # Extract individual tags and find the latest version
    LATEST_VERSION=$(echo "$TAGS" | grep -Eo '([0-9]+\.[0-9]+\.[0-9]+)' | sort -Vr | head -n 1)

    if [ -z "$LATEST_VERSION" ]; then
        echo "v0.0.1"
        return
    fi

    # Parse major, minor, and patch versions
    MAJOR=$(echo "$LATEST_VERSION" | cut -d '.' -f 1)
    MINOR=$(echo "$LATEST_VERSION" | cut -d '.' -f 2)
    PATCH=$(echo "$LATEST_VERSION" | cut -d '.' -f 3)

    # Increment the appropriate version component (e.g., minor)
    echo "v$MAJOR.$MINOR.$((PATCH+1))"
}

# Parse CLI arguments
parseCLIArgs "$@"

# Using minikube's Docker daemon
eval "$(minikube docker-env)"

# Bump the version, build the image and push it to the registry
IMAGE_TAG=$(bumpVersion)
export MY_NEW_IMAGE="$DOCKER_REGISTRY$IMAGE_NAME:$IMAGE_TAG"

set -x
if [[ -z "$PUSH" ]]; then
    echo "Building image $MY_NEW_IMAGE"
    docker build -t "$MY_NEW_IMAGE" ./dockerize
else
    echo "Building and pushing image $MY_NEW_IMAGE"
    docker build --push -t "$MY_NEW_IMAGE" ./dockerize
fi
set +x

# Render the Kubernetes manifest to include the new image tag
# Can also be done with envsubst
sed "s|\$MY_NEW_IMAGE|$MY_NEW_IMAGE|g" linux/script.yaml > linux/new-app.yaml
# envsubst "'$MY_NEW_IMAGE'" < linux/script.yaml > linux/new-app.yaml

# Diff the new manifest with the current manifest
kubectl diff -f ./kubernetes/app.yaml -f linux/new-app.yaml