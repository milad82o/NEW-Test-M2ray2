#!/bin/bash
# g2ray start script — uses tmux for persistent process + optional keepalive
tmux kill-session -t g2ray 2>/dev/null || true
tmux new-session -d -s g2ray
tmux send-keys -t g2ray "sudo /usr/local/bin/xray run -c /etc/xray/g2ray.json &>/tmp/xray.log" Enter
sleep 2
show-link.sh
echo "[g2ray] Server running in tmux session g2ray"
echo "[g2ray] View log: tmux attach -t g2ray"
