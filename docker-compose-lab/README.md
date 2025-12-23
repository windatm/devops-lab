# Docker Compose Lab

Lab thực hành về Docker Compose để triển khai multi-container application với frontend, backend service, và database.

## Mục tiêu

- Học cách sử dụng Docker Compose để orchestrate nhiều containers
- Hiểu về services, networks, volumes trong Docker Compose
- Thực hành environment variables và health checks
- Hiểu dependency management giữa services
- Thực hành debugging multi-container applications

## Prerequisites

- Docker Engine hoặc Docker Desktop đã cài đặt
- Docker Compose v2 (thường đi kèm với Docker Desktop)
- Kiểm tra: `docker compose version`
- Quyền chạy Docker

## Cấu trúc thư mục

```
docker-compose-lab/
├── README.md                 # File này
├── docker-compose.yml        # File compose chính
├── .env.example              # Template environment variables
├── frontend/                 # Frontend HTML/JS
│   ├── index.html
│   ├── app.js
│   └── style.css
├── backend/                  # Node.js backend service
│   ├── Dockerfile
│   ├── package.json
│   ├── server.js
│   └── .dockerignore
└── scripts/
    └── cleanup.sh            # Script cleanup resources
```

## Kiến trúc ứng dụng

Ứng dụng gồm 3 services:

1. **Frontend**: HTML/JavaScript UI để quản lý tasks
2. **Backend**: Node.js + Express API server
3. **Database**: PostgreSQL để lưu trữ tasks

```
┌─────────────┐
│  Frontend   │ (HTML/JS served by backend)
│  (Browser)  │
└──────┬──────┘
       │ HTTP
       ▼
┌─────────────┐      ┌─────────────┐
│  Backend    │◄────►│  Database   │
│  (Node.js)  │ SQL  │ (PostgreSQL)│
└─────────────┘      └─────────────┘
```

## Bắt đầu

### 1. Khởi động services

```bash
cd docker-compose-lab
docker compose up -d
```

Lệnh này sẽ:
- Build image cho backend service
- Tạo network `task-app-network`
- Tạo volume `task-postgres-data` cho database
- Khởi động 3 containers: `task-db`, `task-backend`

### 2. Kiểm tra services đang chạy

```bash
docker compose ps
```

Kết quả sẽ hiển thị trạng thái của tất cả services:
- `task-db`: Database service
- `task-backend`: Backend API service

### 3. Xem logs

Xem logs của tất cả services:
```bash
docker compose logs
```

Xem logs của một service cụ thể:
```bash
docker compose logs backend
docker compose logs db
```

Theo dõi logs real-time:
```bash
docker compose logs -f
```

### 4. Truy cập ứng dụng

Mở trình duyệt và truy cập: **http://localhost:3000**

Bạn sẽ thấy giao diện Task Manager với khả năng:
- Thêm task mới
- Xem danh sách tasks đã tạo

### 5. Kiểm tra health checks

```bash
# Health check của backend
curl http://localhost:3000/health

# Hoặc xem trạng thái health trong Docker
docker compose ps
```

## API Endpoints

Backend cung cấp các API endpoints:

- **GET /api/tasks**: Lấy danh sách tất cả tasks
  ```bash
  curl http://localhost:3000/api/tasks
  ```

- **POST /api/tasks**: Tạo task mới
  ```bash
  curl -X POST http://localhost:3000/api/tasks \
    -H "Content-Type: application/json" \
    -d '{"name": "Học Docker Compose"}'
  ```

- **GET /health**: Health check endpoint
  ```bash
  curl http://localhost:3000/health
  ```

## Thực hành thêm

### 1. Thay đổi environment variables

Tạo file `.env` từ template:
```bash
cp .env.example .env
```

Sửa các giá trị trong `.env`, ví dụ:
```env
PORT=8080
DB_PASSWORD=mypassword123
```

Khởi động lại services:
```bash
docker compose down
docker compose up -d
```

### 2. Scale backend service

Thử scale backend service (lưu ý: chỉ có ý nghĩa với load balancer):
```bash
docker compose up -d --scale backend=2
```

Xem các instances:
```bash
docker compose ps
```

### 3. Xem database data

Kết nối trực tiếp vào database container:
```bash
docker compose exec db psql -U taskuser -d taskdb
```

Trong PostgreSQL shell:
```sql
-- Xem tất cả tables
\dt

-- Xem dữ liệu tasks
SELECT * FROM tasks;

-- Thoát
\q
```

### 4. Xem volumes

Kiểm tra volumes đã tạo:
```bash
docker volume ls | grep task
docker volume inspect task-postgres-data
```

### 5. Xem networks

Kiểm tra networks:
```bash
docker network ls | grep task
docker network inspect task-app-network
```

### 6. Rebuild images

Nếu sửa code trong backend, rebuild image:
```bash
docker compose build backend
docker compose up -d
```

Hoặc rebuild tất cả:
```bash
docker compose build
docker compose up -d
```

### 7. Xem resource usage

```bash
docker stats
```

Hoặc cho một service cụ thể:
```bash
docker stats task-backend task-db
```

## Debugging

### Container không start

1. Xem logs:
   ```bash
   docker compose logs backend
   docker compose logs db
   ```

2. Kiểm tra health status:
   ```bash
   docker compose ps
   ```

3. Vào container để debug:
   ```bash
   docker compose exec backend sh
   docker compose exec db sh
   ```

### Database connection issues

1. Kiểm tra database đã sẵn sàng:
   ```bash
   docker compose exec db pg_isready -U taskuser
   ```

2. Kiểm tra environment variables:
   ```bash
   docker compose exec backend env | grep DB
   ```

3. Test kết nối từ backend:
   ```bash
   docker compose exec backend sh
   # Trong container
   node -e "const {Pool} = require('pg'); const p = new Pool({host:'db',user:'taskuser',password:'taskpass',database:'taskdb'}); p.query('SELECT 1').then(() => console.log('OK')).catch(e => console.error(e));"
   ```

### Frontend không load

1. Kiểm tra backend đang chạy:
   ```bash
   curl http://localhost:3000/health
   ```

2. Kiểm tra frontend files được serve:
   ```bash
   curl http://localhost:3000/
   ```

## Cleanup

### Dừng services (giữ data)

```bash
docker compose stop
```

### Dừng và xóa containers, networks (giữ volumes)

```bash
docker compose down
```

### Dừng và xóa tất cả (bao gồm volumes)

```bash
docker compose down -v
```

### Sử dụng cleanup script

```bash
bash scripts/cleanup.sh
```

Script này sẽ:
- Dừng và xóa containers, networks, volumes
- Xóa images đã build
- Cleanup orphaned resources

## Cấu trúc Docker Compose

### Services

- **db**: PostgreSQL database với health check
- **backend**: Node.js API server với health check và volume mount

### Networks

- **app-network**: Bridge network để các services giao tiếp

### Volumes

- **postgres_data**: Persistent volume cho database data

### Health Checks

- Database: Kiểm tra `pg_isready` mỗi 10s
- Backend: Kiểm tra `/health` endpoint mỗi 30s

### Dependencies

- Backend phụ thuộc database (chờ database healthy trước khi start)

## Lưu ý

- Database data được lưu trong volume `task-postgres-data`, sẽ không mất khi xóa containers
- Frontend được serve trực tiếp từ backend (không cần nginx riêng)
- Backend code được mount vào container để dễ development
- Health checks đảm bảo services sẵn sàng trước khi dependencies start
- Tất cả services restart tự động nếu crash (`restart: unless-stopped`)

## Troubleshooting

### Port đã được sử dụng

Nếu port 3000 đã được sử dụng, sửa trong `.env`:
```env
PORT=3001
```

### Permission denied

Đảm bảo user có quyền chạy Docker:
```bash
sudo usermod -aG docker $USER
# Logout và login lại
```

### Out of disk space

Xóa unused resources:
```bash
docker system prune -a --volumes
```

## Tài liệu tham khảo

- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [Docker Compose File Reference](https://docs.docker.com/compose/compose-file/)
- [PostgreSQL Docker Image](https://hub.docker.com/_/postgres)
- [Node.js Docker Image](https://hub.docker.com/_/node)

---

**Happy Learning! 🎉**

