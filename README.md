# DevOps Lab

Bộ bài thực hành DevOps về Docker và Kubernetes, phù hợp cho người mới bắt đầu và muốn nâng cao kỹ năng containerization và orchestration.

## 📋 Mục lục

- [Tổng quan](#tổng-quan)
- [Cấu trúc thư mục](#cấu-trúc-thư-mục)
- [Prerequisites](#prerequisites)
- [Các bài lab](#các-bài-lab)
  - [Building Images Lab](#building-images-lab)
  - [Kubernetes YAML Labs](#kubernetes-yaml-labs)
- [Bắt đầu](#bắt-đầu)
- [Đóng góp](#đóng-góp)

## 🎯 Tổng quan

Repo này chứa các bài thực hành thực tế về:

- **Docker**: Build images, Dockerfile, build context, environment variables
- **Kubernetes**: Pod, Deployment, Service, YAML configuration, debugging

Tất cả bài lab đều có:

- ✅ File cấu hình đầy đủ, sẵn sàng chạy
- ✅ Hướng dẫn chi tiết từng bước
- ✅ Script cleanup để dọn dẹp resources
- ✅ Ví dụ thực tế và best practices

## 📁 Cấu trúc thư mục

```
devops-lab/
├── README.md                 # File này
├── building-images/          # Docker lab: Build images với Dockerfile
│   ├── README.md
│   ├── nginx-demo/           # Lab nginx với Dockerfile
│   └── env-basic/            # Lab environment variables
└── k8s-yaml-labs/            # Kubernetes lab: YAML configuration
    ├── README.md
    ├── 01-pod/               # Pod basics
    ├── 02-deployment/        # Deployment với replicas
    ├── 03-service-clusterip/ # Service ClusterIP
    ├── 04-service-nodeport/  # Service NodePort
    ├── 05-multi-resource/    # Multi-resource YAML
    ├── 06-debug-yaml/        # Debug YAML errors
    └── scripts/               # Cleanup scripts
```

## 🔧 Prerequisites

### Cho Building Images Lab

- Docker Engine hoặc Docker Desktop đã cài đặt
- Kiểm tra: `docker version`
- Quyền chạy Docker (user trong group `docker` hoặc root)

### Cho Kubernetes YAML Labs

- `kubectl` đã cài đặt
- Kubernetes cluster (local hoặc remote) đã kết nối
- Kiểm tra: `kubectl cluster-info`

**Gợi ý cluster local:**

- [Minikube](https://minikube.sigs.k8s.io/)
- [Kind](https://kind.sigs.k8s.io/)
- [Docker Desktop](https://www.docker.com/products/docker-desktop) (có Kubernetes built-in)

## 📚 Các bài lab

### Building Images Lab

Học cách build Docker images với Dockerfile, quản lý build context, và sử dụng environment variables.

**Thư mục**: [`building-images/`](building-images/)

**Nội dung**:

- Tạo Dockerfile cho nginx với Alpine Linux
- Sử dụng COPY, ADD, ENTRYPOINT, CMD
- Quản lý build context với `.dockerignore`
- Environment variables trong Dockerfile

**Bắt đầu**: Xem [building-images/README.md](building-images/README.md)

### Kubernetes YAML Labs

Học cách viết và quản lý Kubernetes resources bằng YAML, từ Pod đơn giản đến multi-resource stacks.

**Thư mục**: [`k8s-yaml-labs/`](k8s-yaml-labs/)

**Nội dung**:

1. **Pod**: Tạo Pod đơn giản
2. **Deployment**: Deployment với replicas và scaling
3. **Service ClusterIP**: Service nội bộ cluster
4. **Service NodePort**: Expose service ra ngoài cluster
5. **Multi-resource**: Quản lý nhiều resources trong một file
6. **Debug YAML**: Tìm và sửa lỗi YAML thường gặp

**Bắt đầu**: Xem [k8s-yaml-labs/README.md](k8s-yaml-labs/README.md)

## 🚀 Bắt đầu

### Clone repo

```bash
git clone <repository-url>
cd devops-lab
```

### Chọn lab để bắt đầu

**Nếu bạn mới học Docker:**

```bash
cd building-images
# Đọc README.md và làm theo hướng dẫn
```

**Nếu bạn đã biết Docker và muốn học Kubernetes:**

```bash
cd k8s-yaml-labs
# Đọc README.md và làm theo hướng dẫn
```

### Workflow chung

1. **Đọc README** trong thư mục lab để hiểu mục tiêu
2. **Kiểm tra prerequisites** (Docker/Kubernetes đã sẵn sàng)
3. **Làm theo từng bài** theo thứ tự
4. **Thực hành thêm** các bài tập mở rộng
5. **Cleanup** sau khi hoàn thành bằng script cleanup

## 📖 Chi tiết từng lab

### Building Images Lab

**Mục tiêu**: Hiểu cách build Docker images, quản lý layers, và tối ưu build context.

**Các bài thực hành**:

- Build image nginx với Dockerfile
- Sử dụng COPY vs ADD
- Quản lý build context với `.dockerignore`
- Environment variables

**Thời gian ước tính**: 1-2 giờ

### Kubernetes YAML Labs

**Mục tiêu**: Thành thạo viết YAML cho Kubernetes, hiểu các resource types và cách debug.

**Các bài thực hành**:

- Pod, Deployment, Service
- ClusterIP vs NodePort
- Multi-resource YAML
- Debug YAML errors

**Thời gian ước tính**: 2-3 giờ

## 🧹 Cleanup

Sau khi hoàn thành lab, nhớ cleanup resources:

**Docker:**

```bash
# Xóa images/containers đã tạo
docker image rm local:dockerfile-example local:env-basic
docker container prune
```

**Kubernetes:**

```bash
cd k8s-yaml-labs
bash scripts/cleanup.sh
```

## 💡 Tips

- **Đọc kỹ README** trong từng thư mục lab trước khi bắt đầu
- **Thực hành thêm** các bài tập mở rộng để hiểu sâu hơn
- **Quan sát logs** khi có lỗi: `docker logs`, `kubectl describe`, `kubectl logs`
- **Sử dụng `-o wide` hoặc `-o yaml`** để xem thông tin chi tiết
- **Cleanup thường xuyên** để tránh resource leak

## 🤝 Đóng góp

Nếu bạn tìm thấy lỗi hoặc muốn cải thiện bài lab:

1. Tạo issue mô tả vấn đề
2. Hoặc tạo pull request với cải thiện

## 📝 License

Repo này dùng cho mục đích học tập và thực hành.

## 🔗 Tài liệu tham khảo

- [Docker Documentation](https://docs.docker.com/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Dockerfile Best Practices](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/)
- [Kubernetes YAML Reference](https://kubernetes.io/docs/reference/kubernetes-api/)

---

**Happy Learning! 🎉**
