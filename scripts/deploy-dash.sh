#!/usr/bin/env bash
set -euo pipefail
echo "[1/5] ensure bun"
command -v bun >/dev/null 2>&1 || { curl -fsSL https://bun.sh/install | bash; }
[ -x /usr/local/bin/bun ] || ln -sf /root/.bun/bin/bun /usr/local/bin/bun
bun --version

echo "[2/5] fetch repo"
mkdir -p /opt/bricks-core
[ -d /opt/bricks-core/dotfiles/.git ] || \
  git clone https://github.com/kerollosmakary-ai/new.git /opt/bricks-core/dotfiles
cd /opt/bricks-core/dotfiles
git fetch --all -q
git reset --hard "origin/BRICKS" -q
git log --oneline -1

echo "[3/5] stage app"
APP=/opt/bricks-core/dash
rm -rf "$APP"; mkdir -p "$APP"
cp -r apps/bricks-dash/. "$APP"/
ls "$APP"

echo "[4/5] unit"
cat > /etc/systemd/system/bricks-dash.service << 'UNIT'
[Unit]
Description=BRICKS Dash (Bun)
After=network.target

[Service]
Type=simple
WorkingDirectory=/opt/bricks-core/dash
ExecStart=/usr/local/bin/bun run src/index.ts
Environment=PORT=8003
Environment=PHONE_LLM=http://127.0.0.1:8080
Environment=DASH_TOKEN=
Restart=always
RestartSec=3
User=root

[Install]
WantedBy=multi-user.target
UNIT
systemctl daemon-reload
systemctl enable --now bricks-dash.service
systemctl restart bricks-dash.service

echo "[5/5] verify"
sleep 2
systemctl is-active bricks-dash.service
curl -s -o /dev/null -w 'http %{http_code}\n' http://127.0.0.1:8003/ || true
