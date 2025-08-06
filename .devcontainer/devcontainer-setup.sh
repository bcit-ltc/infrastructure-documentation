#!/bin/sh
set -e

echo "=== Checking k3d installation ==="
k3d --version || { echo "k3d not found!"; exit 1; }

echo "=== Checking Docker installation ==="
docker --version || { echo "Docker not found!"; exit 1; }

echo "=== Creating k3d registry (if not exists) ==="
k3d registry create myregistry.localhost --port 5000 || true

echo "=== Creating k3d cluster with registry (if not exists) ==="
k3d cluster create mycluster --registry-use k3d-myregistry.localhost:5000 || true

echo "=== Building app Docker image ==="
docker build -t k3d-myregistry.localhost:5000/myapp:latest .

echo "=== Pushing image to local registry ==="
docker push k3d-myregistry.localhost:5000/myapp:latest

echo "=== Setup