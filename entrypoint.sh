#!/bin/sh

# 启动 x-tunnel (后台运行)
echo "Starting x-tunnel..."
x-tunnel ${XTUNNEL_ARGS} &

# 启动 cloudflared (前台运行，如果它挂了，容器就会退出)
echo "Starting cloudflared..."
if [ -n "$CF_TOKEN" ]; then
    exec cloudflared tunnel --no-autoupdate run --token ${CF_TOKEN}
else
    echo "Error: CF_TOKEN is not set."
    exit 1
fi
