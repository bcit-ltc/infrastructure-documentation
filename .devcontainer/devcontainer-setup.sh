#!/bin/sh
set -e

# Create k3d registry if it doesn't exist
k3d registry create myregistry.localhost --port 5000 || true

# Create k3d cluster with the registry
k3d cluster create mycluster --registry-use k3d-myregistry.localhost:5000 || true

# Build your app Docker image (replace 'myapp' and path as needed)
docker build -t k3d-myregistry.localhost:5000/myapp:latest .

# Push the image to the local registry
docker push k3d-myregistry.localhost:5000/myapp:latest