#!/bin/sh

# 启动 xtun (后台运行)
# 假设 xtun 的用法是 xtun -config config.json 或直接接参数
if [ -n "$XTUN_ARGS" ]; then
    echo "Starting xtun with args: ${XTUN_ARGS}"
    /usr/local/bin/xtun ${XTUN_ARGS} &
else
    echo "Warning: XTUN_ARGS is empty, xtun might not do anything."
fi

# 启动 cloudflared (前台运行)
if [ -n "$CF_TOKEN" ]; then
    echo "Starting cloudflared..."
    exec /usr/local/bin/cloudflared tunnel  --no-autoupdate --edge-ip-version 4 --protocol http2  --metrics 0.0.0.0:${M_PORT}   run --token ${CF_TOKEN}
else
    echo "Error: CF_TOKEN is not set. Cloudflared requires a token to run."
    exit 1
fi
