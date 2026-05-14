#!/bin/bash

echo "[g2ray] Generating dynamic config..."
python3 /app/generate_config.py

echo ""
echo "================================================"
echo "[g2ray] Starting Xray in tmux session..."
echo "================================================"

tmux kill-session -t g2ray 2>/dev/null || true
tmux new-session -d -s g2ray
tmux send-keys -t g2ray "sudo /usr/local/bin/xray run -c /etc/xray/g2ray.json &>/tmp/xray.log" Enter
sleep 3
show-link.sh

echo ""
echo "[g2ray] Server running in tmux session 'g2ray'"
echo "[g2ray] View logs: tmux attach -t g2ray"
echo "[g2ray] Stop session: tmux kill-session -t g2ray"
