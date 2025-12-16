FROM alpine:3.20

LABEL maintainer="devops-lab"
LABEL lab="nginx-demo"
LABEL version="1.0"

RUN apk add --no-cache nginx bash curl && \
    mkdir -p /run/nginx /var/cache/nginx /var/log/nginx

COPY files/nginx.conf /etc/nginx/nginx.conf
COPY files/default.conf /etc/nginx/http.d/default.conf

ADD files/html.tar.gz /usr/share/nginx/html/

EXPOSE 80

ENTRYPOINT ["nginx"]
CMD ["-g", "daemon off;"]

