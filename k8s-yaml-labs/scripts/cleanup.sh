#!/bin/bash
# Script cleanup để xóa tất cả resources trong lab
# Sử dụng --ignore-not-found để tránh lỗi nếu resource không tồn tại

set -e

echo "Cleaning up Kubernetes resources..."

# Xóa Pods
echo "Deleting pods..."
kubectl delete pod nginx-pod --ignore-not-found=true
kubectl delete pod test-pod --ignore-not-found=true

# Xóa Deployments
echo "Deleting deployments..."
kubectl delete deployment nginx-deployment --ignore-not-found=true
kubectl delete deployment web-deployment --ignore-not-found=true

# Xóa Services
echo "Deleting services..."
kubectl delete svc nginx-svc --ignore-not-found=true
kubectl delete svc web-svc --ignore-not-found=true

echo ""
echo "Cleanup completed!"
echo ""
echo "Remaining resources:"
kubectl get pod,deploy,svc

