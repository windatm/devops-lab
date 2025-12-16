FROM alpine:3.20

ENV APP_NAME demo-app
ENV APP_ENV=dev APP_VERSION=1.0

RUN mkdir -p /app && \
    echo "APP_NAME=${APP_NAME}" > /app/info.txt && \
    echo "APP_ENV=${APP_ENV}" >> /app/info.txt && \
    echo "APP_VERSION=${APP_VERSION}" >> /app/info.txt

CMD ["cat", "/app/info.txt"]

