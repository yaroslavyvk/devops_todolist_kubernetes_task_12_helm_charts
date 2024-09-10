#!/bin/bash

# Prevent script from exiting if any commands fail
set -e

# Step 0: Create a Kubernetes cluster using kind
echo "Creating Kubernetes cluster using kind..."
kind create cluster --config cluster.yml

# Step 1: Inspect nodes for labels and apply taints
echo "Inspecting nodes for labels..."
kubectl get nodes --show-labels

echo "Applying taints to nodes labeled with 'app=mysql'..."
kubectl taint nodes -l app=mysql app=mysql:NoSchedule --overwrite

# Step 2: Install NGINX Ingress Controller
echo "Installing NGINX Ingress Controller..."
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

# Wait for the Ingress controller to be ready
echo "Waiting for the Ingress controller to be ready..."
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=90s

# Step 3: Install the todoapp Helm chart
echo "Installing the todoapp Helm chart..."
helm install todoapp-release .infrastructure/helm-chart/todoapp

echo "Bootstrap process completed successfully!"
