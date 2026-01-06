# Lab Jenkins CI/CD với GitHub + Jenkins Poll SCM Event

> Mục tiêu: Hướng dẫn cách cài đặt Jenkins trên Docker, thiết lập GitHub repo và tạo Jenkins pipeline với Jenkins Poll SCM event (thay vì webhook). Hướng dẫn sẽ chạy hết trên Docker với việc sử dụng GitHub để trigger Jenkins job.

---

## Tài liệu Jenkins Official

- [Installing Jenkins on Docker](https://www.jenkins.io/doc/book/installing/docker/)
- [Pipeline Guided Tour (Getting Started)](https://www.jenkins.io/doc/pipeline/tour/getting-started/)
- [Pipeline Tour (Hello World)](https://www.jenkins.io/doc/pipeline/tour/hello-world/)
- [Tutorials - Pipeline](https://www.jkins.io/doc/tutorials/#pipeline)
- [Using Docker with Pipeline](https://www.jenkins.io/doc/book/pipeline/docker/)
- [Pipeline Syntax Reference](https://www.jenkins.io/doc/book/pipeline/syntax/)

---

## 0) Yêu cầu môi trường

- Docker Engine + Docker Compose (v2)
- Git
- Trình duyệt (Chrome/Firefox/Edge)

Kiểm tra nhanh:

```bash
docker --version
docker compose version
git --version
```

---

## PHẦN A — Lab 1: Cài Jenkins Controller trên Docker (có Persistent Storage)

### A1) Tạo thư mục lab + các file cần thiết

```bash
mkdir -p jenkins-docker-lab && cd jenkins-docker-lab
```

### A1.1) Tạo `Dockerfile` (custom Jenkins image có Docker CLI + Blue Ocean)

> Custom image Jenkins để cài đặt **docker-ce-cli** và cài plugin **Blue Ocean** (UI cho Jenkins Pipeline).

```bash
cat > Dockerfile <<'DOCKERFILE'
FROM jenkins/jenkins:lts-jdk21

USER root

# Cài Docker CLI vào image Jenkins (để Jenkinsfile gọi được docker build, docker run, ...)
RUN apt-get update && apt-get install -y lsb-release ca-certificates curl && \
    install -m 0755 -d /etc/apt/keyrings && \
    curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc && \
    chmod a+r /etc/apt/keyrings/docker.asc && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] \
    https://download.docker.com/linux/debian $(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
    | tee /etc/apt/sources.list.d/docker.list > /dev/null && \
    apt-get update && apt-get install -y docker-ce-cli && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

USER jenkins

# Cài các plugin hay dùng trong docs/tutorial:
RUN jenkins-plugin-cli --plugins "blueocean docker-workflow"
DOCKERFILE
```

### A1.2) Tạo `docker-compose.yml` (Jenkins + docker:dind + volumes)

```bash
cat > docker-compose.yml <<'YAML'
version: "3.8"

services:
  docker:
    image: docker:dind
    container_name: jenkins-docker
    privileged: true
    environment:
      DOCKER_TLS_CERTDIR: /certs
    volumes:
      - jenkins-docker-certs:/certs/client
      - jenkins-data:/var/jenkins_home
    networks:
      - jenkins
    ports:
      - "2376:2376"

  jenkins:
    build:
      context: .
      dockerfile: Dockerfile
    container_name: jenkins-blueocean
    restart: on-failure
    environment:
      DOCKER_HOST: tcp://docker:2376
      DOCKER_CERT_PATH: /certs/client
      DOCKER_TLS_VERIFY: "1"
    ports:
      - "8080:8080"     # Jenkins Web UI
      - "50000:50000"   # Inbound agent (JNLP)
    volumes:
      - jenkins-data:/var/jenkins_home
      - jenkins-docker-certs:/certs/client:ro
    networks:
      - jenkins
    depends_on:
      - docker

networks:
  jenkins:
    driver: bridge

volumes:
  jenkins-data:
  jenkins-docker-certs:
YAML
```

### A2) Build & chạy Jenkins

```bash
docker compose up -d --build
docker compose ps
```

### A3) Lấy mật khẩu unlock Jenkins và hoàn tất setup wizard

Truy cập: http://localhost:8080  
Lấy mật khẩu unlock:

```bash
docker logs jenkins-blueocean
```

---

## PHẦN B — Lab 2: Tạo repo demo nhỏ + Pipeline CI/CD (Pipeline-as-Code)

### B1) Tạo repo GitHub và upload code

Tạo repo `hello-jenkins` trên GitHub.

### B1.1) Tạo project + source code

```bash
mkdir hello-jenkins && cd hello-jenkins
git init
```

Tạo `package.json`:

```bash
cat > package.json <<'JSON'
{
  "name": "hello-jenkins",
  "version": "1.0.0",
  "description": "Tiny demo app for Jenkins CI/CD",
  "main": "server.js",
  "scripts": {
    "start": "node server.js",
    "test": "node test.js"
  }
}
JSON
```

Tạo `server.js`:

```bash
cat > server.js <<'JS'
const http = require('http');

const port = process.env.PORT || 3000;

const server = http.createServer((req, res) => {
  res.writeHead(200, {'Content-Type': 'text/plain; charset=utf-8'});
  res.end('Hello Jenkins CI/CD!\n');
});

server.listen(port, () => {
  console.log(`Server listening on http://0.0.0.0:${port}`);
});
JS
```

Tạo `test.js`:

```bash
cat > test.js <<'JS'
const http = require('http');

function assert(cond, msg) {
  if (!cond) {
    console.error('TEST FAILED:', msg);
    process.exit(1);
  }
}

const server = http.createServer((req, res) => {
  res.end('ok');
});

server.listen(0, () => {
  const { port } = server.address();
  http.get(`http://127.0.0.1:${port}`, (res) => {
    assert(res.statusCode === 200, `status should be 200, got ${res.statusCode}`);
    server.close(() => {
      console.log('TEST PASSED');
      process.exit(0);
    });
  }).on('error', (err) => {
    console.error(err);
    process.exit(1);
  });
});
JS
```

### B1.2) Tạo Dockerfile cho app

```bash
cat > Dockerfile <<'DOCKERFILE'
FROM node:20-alpine
WORKDIR /app
COPY . .
EXPOSE 3000
CMD ["node", "server.js"]
DOCKERFILE
```

### B1.3) Tạo Jenkinsfile (Pipeline CI/CD)

```bash
cat > Jenkinsfile <<'JENKINSFILE'
pipeline {
  agent none

  stages {
    stage('Checkout') {
      agent any
      steps {
        checkout scm
      }
    }

    stage('Test') {
      agent {
        docker {
          image 'node:20-alpine'
        }
      }
      steps {
        sh 'node -v'
        sh 'npm test'
      }
    }

    stage('Build Docker Image') {
      agent any
      steps {
        sh 'docker build -t hello-jenkins:${BUILD_NUMBER} .'
      }
    }

    stage('Deploy') {
      agent any
      steps {
        sh '''
          docker rm -f hello-jenkins || true
          docker run -d --name hello-jenkins -p 3000:3000 hello-jenkins:${BUILD_NUMBER}
        '''
      }
    }
  }
}
JENKINSFILE
```

### B1.4) Commit code và push lên GitHub

```bash
git add .
git commit -m "Init hello-jenkins demo with Dockerfile + Jenkinsfile"
```


> 1. Tạo repo `hello-jenkins` (không README)
> 2. Copy repo URL
> 3. Chạy:
>    git remote add origin <repo-url>
>    git branch -M main
>    git push -u origin main


```bash
git remote add origin https://github.com/<your-username>/hello-jenkins.git

git push -u origin main
```

---

## PHẦN C — Cấu hình Jenkins để Poll SCM

### C1) Tạo Jenkins Job (Pipeline từ SCM)

1. **New Item**
![alt text](image.png)
2. Nhập tên: `hello-jenkins`
3. Chọn **Pipeline** → OK
4. Tab **Pipeline**:
   - **Definition:** Pipeline script from SCM
   - **SCM:** Git
   - **Repository URL:** repo bạn vừa push
   - **Credentials:** (nếu repo private)
   - **Script Path:** `Jenkinsfile`

![alt text](image-1.png)
5. Save → **Build Now**

Jenkins sẽ tự động kiểm tra code thay đổi (cả qua Polling).

---

## PHẦN D — Snippet Jenkinsfile hay dùng

### D1) `when` (chạy stage theo branch/env)

```groovy
stage('Deploy') {
  when { branch 'main' }
  steps { echo 'Deploying...' }
}
```

### D2) `post` actions (luôn chạy / khi fail / archive artifacts)

```groovy
post {
  always { echo 'Pipeline finished' }
  success { archiveArtifacts artifacts: 'dist/**', fingerprint: true }
  failure { echo 'Build failed' }
}
```

### D3) `retry` / `timeout`

```groovy
retry(3) {
  sh 'npm test'
}
```

---

# BONUS — Sử dụng Git server local bằng Docker (Gitea)

Tạo Git server local để thay thế GitHub, dùng webhook từ Gitea vào Jenkins.

1) Thêm service Gitea vào docker-compose:
```yaml
gitea:
  image: gitea/gitea:latest
  container_name: gitea
  ports:
    - "3001:3000"
    - "2222:22"
  volumes:
    - gitea-data:/data
```

2) Tạo repo trên Gitea và push code lên:
```bash
git remote add origin http://localhost:3001/<user>/hello-jenkins.git
git push -u origin main
```

---

Chúc bạn lab vui 🤝
