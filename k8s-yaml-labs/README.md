# Kubernetes YAML Labs

Bộ bài thực hành về Kubernetes YAML với 6 bài lab từ cơ bản đến nâng cao.

## Prerequisites

- Đã cài đặt `kubectl`
- Đã có Kubernetes cluster (local hoặc remote) và đã kết nối
- Kiểm tra kết nối: `kubectl cluster-info`

## Cấu trúc bài lab

- **01-pod**: Tạo Pod đơn giản
- **02-deployment**: Tạo Deployment với replicas
- **03-service-clusterip**: Tạo Service ClusterIP
- **04-service-nodeport**: Tạo Service NodePort
- **05-multi-resource**: File YAML chứa nhiều resources
- **06-debug-yaml**: Debug các lỗi YAML thường gặp

## Bài 1: Pod

Tạo Pod nginx đơn giản.

```bash
kubectl apply -f 01-pod/pod-nginx.yaml
```

Kiểm tra:

```bash
kubectl get pods
kubectl describe pod nginx-pod
```

**Thực hành thêm**: Thay đổi image sang `nginx:1.26` trong YAML, apply lại và quan sát thay đổi:

```bash
# Sửa image trong file
# Sau đó apply lại
kubectl apply -f 01-pod/pod-nginx.yaml

# Quan sát Pod được recreate
kubectl get pods -w
```

**Đánh giá**: Pod chạy trạng thái Running, image đúng theo YAML. Hiểu rõ mối quan hệ file YAML và trạng thái Pod.

Xóa:

```bash
kubectl delete pod nginx-pod
```

## Bài 2: Deployment

Tạo Deployment với 3 replicas.

```bash
kubectl apply -f 02-deployment/deploy-nginx.yaml
```

Kiểm tra:

```bash
kubectl get deployments
kubectl get pods -l app=nginx -o wide
kubectl rollout status deployment/nginx-deployment
```

**Thực hành thêm**: Scale trực tiếp trong YAML (sửa `replicas: 3` → `5`), apply lại và quan sát:

```bash
# Sửa replicas trong file
# Sau đó apply lại
kubectl apply -f 02-deployment/deploy-nginx.yaml

# Quan sát Deployment scale up
kubectl get pods -l app=nginx -w
```

**Đánh giá**: Deployment luôn duy trì đúng số replicas theo YAML. Học viên thấy rõ cơ chế "desired state" của Deployment.

Xóa:

```bash
kubectl delete deployment nginx-deployment
```

## Bài 3: Service ClusterIP

Tạo Service ClusterIP để expose Pods trong cluster.

**Lưu ý**: Cần có Pods/Deployment với label `app: nginx` đang chạy trước.

```bash
# Đảm bảo có Deployment từ bài 2
kubectl apply -f 02-deployment/deploy-nginx.yaml

# Tạo Service
kubectl apply -f 03-service-clusterip/svc-nginx-clusterip.yaml
```

Kiểm tra:

```bash
kubectl get svc nginx-svc
kubectl describe svc nginx-svc
```

### Test Service từ trong cluster

Tạo Pod test để truy cập Service:

```bash
kubectl run test-pod --image=busybox:1.36 -it --rm --restart=Never -- sh
```

Bên trong Pod test, thử:

```bash
# Dùng wget
wget -qO- http://nginx-svc

# Hoặc dùng curl (nếu có)
curl nginx-svc

# Hoặc dùng nslookup để kiểm tra DNS
nslookup nginx-svc
# Sẽ thấy DNS: nginx-svc.default.svc.cluster.local
```

**Đánh giá**: Hiểu cách Service + selector trỏ tới Pod backend. Thấy được DNS Service trong cluster (`nginx-svc.default.svc.cluster.local`).

Xóa:

```bash
kubectl delete svc nginx-svc
```

## Bài 4: Service NodePort

Tạo Service NodePort để expose ra ngoài cluster.

```bash
# Đảm bảo có Deployment
kubectl apply -f 02-deployment/deploy-nginx.yaml

# Tạo Service NodePort
kubectl apply -f 04-service-nodeport/svc-nginx-nodeport.yaml
```

Kiểm tra:

```bash
kubectl get svc nginx-svc
kubectl describe svc nginx-svc
```

Truy cập từ bên ngoài:

```bash
# Lấy Node IP
kubectl get nodes -o wide

# Truy cập: http://<NODE_IP>:30080
curl http://<NODE_IP>:30080
```

**So sánh**: ClusterIP vs NodePort về cách truy cập:

- **ClusterIP**: Chỉ truy cập được từ trong cluster
- **NodePort**: Truy cập được từ bên ngoài cluster qua `<NodeIP>:30080`

**Đánh giá**: Hiểu Service type NodePort và cách expose ứng dụng ra ngoài cluster.

Xóa:

```bash
kubectl delete svc nginx-svc
```

## Bài 5: Multi-resource

File YAML chứa nhiều resources (Deployment + Service) cách nhau bằng `---`.

```bash
kubectl apply -f 05-multi-resource/web-stack.yaml
```

Kiểm tra:

```bash
kubectl get deploy,svc,pod -l app=web
```

**Thực hành thêm**: Cập nhật version image trong YAML (`nginx:1.25` → `nginx:1.27`), apply lại và quan sát:

```bash
# Sửa image trong file
# Sau đó apply lại
kubectl apply -f 05-multi-resource/web-stack.yaml

# Quan sát rollout
kubectl rollout status deployment/web-deployment
kubectl get pods -l app=web -w
```

**Đánh giá**: Học YAML gồm nhiều resource. Thấy được lợi ích khi quản lý cấu hình bằng Git + YAML.

Xóa:

```bash
kubectl delete -f 05-multi-resource/web-stack.yaml
```

## Bài 6: Debug YAML

Thực hành debug các lỗi YAML thường gặp.

**Nhiệm vụ**:

1. Đọc YAML, dự đoán lỗi trước khi apply
2. Chạy `kubectl apply -f error-*.yaml`
3. Ghi lại thông báo lỗi
4. Sửa YAML cho đúng, apply lại tới khi triển khai thành công

### 6.1: Lỗi apiVersion

```bash
kubectl apply -f 06-debug-yaml/error-apiversion.yaml
```

**Lỗi**: `apiVersion: apps/v2` không tồn tại (phải là `apps/v1`)

**Sửa**: Đổi `apiVersion: apps/v2` → `apiVersion: apps/v1`

### 6.2: Lỗi selector/label không khớp

```bash
kubectl apply -f 06-debug-yaml/error-selector-label.yaml
```

**Lỗi**: `selector.matchLabels: app: nginx` nhưng `template.labels: app: web` → Deployment không tạo được ReplicaSet/Pods

**Sửa**: Đổi `template.metadata.labels.app: web` → `app: nginx` để khớp với selector

### 6.3: Lỗi thiếu template

```bash
kubectl apply -f 06-debug-yaml/error-missing-template.yaml
```

**Lỗi**: Thiếu `spec.template` → Deployment không có template để tạo Pods

**Sửa**: Thêm đầy đủ `spec.template` với metadata.labels và spec.containers

**Đánh giá**: Nhớ cấu trúc YAML chuẩn, đặc biệt cặp selector ↔ labels, apiVersion, spec. Rèn kỹ năng đọc lỗi kubectl và tự debug.

## Cleanup

Dùng script cleanup để xóa tất cả resources:

```bash
bash scripts/cleanup.sh
```

Hoặc xóa thủ công:

```bash
kubectl delete pod nginx-pod --ignore-not-found=true
kubectl delete deployment nginx-deployment web-deployment --ignore-not-found=true
kubectl delete svc nginx-svc web-svc --ignore-not-found=true
kubectl delete pod test-pod --ignore-not-found=true

# Kiểm tra còn lại
kubectl get pod,deploy,svc
```

## Lưu ý

- Tất cả resources tạo trong namespace `default` (không chỉ định namespace)
- Image tags cố định: `nginx:1.25`, `busybox:1.36`
- Các file YAML đã được kiểm tra đúng schema Kubernetes
- File lỗi trong bài 6 parse được nhưng sai logic/schema
