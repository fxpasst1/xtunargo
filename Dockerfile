# --- 第一阶段：构建/下载层 ---
FROM alpine:latest AS builder
RUN apk add --no-cache curl

WORKDIR /downloads

# 定义架构映射逻辑并下载 xtun
# 注意：GitHub 网页链接需转为 raw.githubusercontent.com 才能直接下载
ARG XTUN_BASE_URL="https://raw.githubusercontent.com/fxpasst1/xtun/main/bin"

RUN ARCH=$(uname -m) && \
    if [ "$ARCH" = "x86_64" ]; then \
        XTUN_BIN="xtun-linux-amd64" && CF_ARCH="amd64"; \
    elif [ "$ARCH" = "aarch64" ]; then \
        XTUN_BIN="xtun-linux-arm64" && CF_ARCH="arm64"; \
    else \
        XTUN_BIN="xtun-linux-arm" && CF_ARCH="arm"; \
    fi && \
    # 下载 xtun
    curl -L "${XTUN_BASE_URL}/${XTUN_BIN}" -o xtun && \
    chmod +x xtun && \
    # 下载 cloudflared
    curl -L "https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-${CF_ARCH}" -o cloudflared && \
    chmod +x cloudflared

# --- 第二阶段：运行层 ---
FROM alpine:latest
# 安装基本运行库（xtun 可能是静态编译的，但 alpine 需要 ca-certificates 来做 HTTPS 转发）
RUN apk add --no-cache ca-certificates libc6-compat tzdata

WORKDIR /app

# 从 builder 层拷贝
COPY --from=builder /downloads/xtun /usr/local/bin/xtun
COPY --from=builder /downloads/cloudflared /usr/local/bin/cloudflared

# 拷贝启动脚本
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# 默认环境变量
ENV CF_TOKEN=""
ENV XTUN_ARGS=""

ENTRYPOINT ["/entrypoint.sh"]
