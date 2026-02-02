# --- 第一阶段：下载/构建工具 ---
FROM alpine:latest AS builder
RUN apk add --no-cache curl tar

# 设置版本号（建议根据需要更新）
ARG CLOUDFLARED_VERSION=latest
# 假设 x-tunnel 是常见的 Go 编译版本，这里以示例下载链接代替
# 如果你有特定的 x-tunnel 源码，也可以在这里进行编译

WORKDIR /downloads

# 下载 cloudflared (自动识别架构)
RUN ARCH=$(uname -m) && \
    if [ "$ARCH" = "x86_64" ]; then CF_ARCH="amd64"; elif [ "$ARCH" = "aarch64" ]; then CF_ARCH="arm64"; else CF_ARCH="arm"; fi && \
    curl -L https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-${CF_ARCH} -o cloudflared && \
    chmod +x cloudflared

# 下载 x-tunnel (请将此处替换为您具体的 x-tunnel 二进制下载地址)
# 示例：RUN curl -L https://github.com/user/x-tunnel/releases/download/v1.0/x-tunnel-linux -o x-tunnel && chmod +x x-tunnel
RUN touch x-tunnel && chmod +x x-tunnel 

# --- 第二阶段：最终运行镜像 ---
FROM alpine:latest
RUN apk add --no-cache ca-certificates libc6-compat

WORKDIR /app

# 从构建阶段拷贝二进制文件
COPY --from=builder /downloads/cloudflared /usr/local/bin/cloudflared
COPY --from=builder /downloads/x-tunnel /usr/local/bin/x-tunnel

# 拷贝启动脚本
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# 声明环境变量（方便运行时通过 -e 传入参数）
ENV CF_TOKEN=""
ENV XTUNNEL_ARGS=""

ENTRYPOINT ["/entrypoint.sh"]
