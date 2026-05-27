#!/usr/bin/env bash
set -euo pipefail

if [ "$(id -u)" -ne 0 ]; then
  echo "Run this script with sudo:"
  echo "sudo bash scripts/vps_systemd_install.sh"
  exit 1
fi

APP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RUN_USER="${SUDO_USER:-$(logname 2>/dev/null || echo root)}"
SERVICE_FILE="/etc/systemd/system/telegram-selling-bot.service"

if [ ! -f "$APP_DIR/.env" ]; then
  echo "Missing $APP_DIR/.env"
  echo "Copy .env.example to .env and set BOT_TOKEN, ADMIN_IDS, BOT_USERNAME, DATABASE_URL first."
  exit 1
fi

if [ ! -x "$APP_DIR/.venv/bin/python" ]; then
  echo "Missing virtualenv. Run first:"
  echo "bash scripts/vps_install.sh"
  exit 1
fi

cat > "$SERVICE_FILE" <<SERVICE
[Unit]
Description=Telegram Selling Bot
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
User=$RUN_USER
WorkingDirectory=$APP_DIR
EnvironmentFile=$APP_DIR/.env
Environment=PYTHONUNBUFFERED=1
Environment=PYTHONDONTWRITEBYTECODE=1
ExecStart=$APP_DIR/.venv/bin/python $APP_DIR/selling_bot.py
Restart=always
RestartSec=5
KillSignal=SIGINT
TimeoutStopSec=30
NoNewPrivileges=true

[Install]
WantedBy=multi-user.target
SERVICE

systemctl daemon-reload
systemctl enable telegram-selling-bot
systemctl restart telegram-selling-bot
systemctl --no-pager --lines=25 status telegram-selling-bot

echo "Service installed."
echo "Logs: journalctl -u telegram-selling-bot -f"
