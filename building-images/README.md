# Building Images Lab

Lab package gồm 2 phần: `nginx-demo` và `env-basic` để học Dockerfile và build images.

## nginx-demo

Lab tạo Docker image chạy NGINX với cấu hình tùy chỉnh.

### Build image

```bash
cd building-images/nginx-demo
docker image build -t local:dockerfile-example .
```

### Chạy container với port mapping

```bash
docker run -d -p 8080:80 --name dockerfile-example local:dockerfile-example
```

### Kiểm tra web server

```bash
curl http://localhost:8080/
```

Hoặc mở trình duyệt và truy cập: http://localhost:8080/

### In version nginx

```bash
docker run --rm local:dockerfile-example -v
```

Lệnh này sẽ in version của nginx vì ENTRYPOINT/CMD cho phép truyền arguments.

### Kiểm tra labels

```bash
docker image inspect -f "{{.Config.Labels}}" local:dockerfile-example
```

### Xem logs

```bash
docker logs dockerfile-example
```

### Dừng và xóa container

```bash
docker stop dockerfile-example
docker rm dockerfile-example
```

### Tái tạo html.tar.gz

Nếu cần tái tạo file `files/html.tar.gz` từ thư mục `files/html/`:

```bash
cd building-images/nginx-demo
bash make-html-tar.sh
```

### Thí nghiệm .dockerignore

Để thực hành bài 5 về `.dockerignore`, đã có sẵn các thư mục `logs/`, `tmp/`, `backup/` với file lớn (tổng ~12MB).

**Build không có .dockerignore (giả sử):**
```bash
# Nếu xóa tạm .dockerignore để test
mv .dockerignore .dockerignore.bak
docker image build -t local:nginx-no-ignore .
# Quan sát dung lượng build context (sẽ lớn vì include logs/, tmp/, backup/)
```

**Build có .dockerignore:**
```bash
# Khôi phục .dockerignore
mv .dockerignore.bak .dockerignore
docker image build -t local:nginx-with-ignore .
# Quan sát dung lượng build context (sẽ nhỏ hơn nhiều)
```

So sánh:
- Dung lượng build context trước/sau `.dockerignore`
- Thời gian build
- Log build

## env-basic

Lab về sử dụng ENV variables trong Dockerfile.

### Build image

```bash
cd building-images/env-basic
docker image build -t local:env-basic .
```

### Chạy container

```bash
docker run --rm local:env-basic
```

Container sẽ tự động in nội dung file `/app/info.txt` chứa các biến môi trường:
- APP_NAME
- APP_ENV
- APP_VERSION

### Kiểm tra biến môi trường trong container

```bash
docker run --rm local:env-basic env | grep APP
```

## Lưu ý

- Không sử dụng docker-compose trong lab này
- Tất cả file cần thiết đã được đóng gói trong cấu trúc thư mục
- File `html.tar.gz` được tạo từ script `make-html-tar.sh` để đảm bảo cấu trúc tar đúng

