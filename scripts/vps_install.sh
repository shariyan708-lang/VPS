#!/usr/bin/env bash
set -euo pipefail

APP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$APP_DIR"

echo "==> Creating Python virtual environment"
python3 -m venv .venv

echo "==> Upgrading pip"
.venv/bin/python -m pip install --upgrade pip wheel setuptools

echo "==> Installing Python dependencies"
.venv/bin/python -m pip install -r requirements.txt

if [ ! -f .env ]; then
  echo "==> Creating .env from .env.example"
  cp .env.example .env
  echo "Edit .env before starting the bot: nano .env"
fi

echo "==> Initializing database schema"
.venv/bin/python selling_bot.py --init-db

echo "==> Running smoke test"
.venv/bin/python selling_bot.py --smoke-test

echo "VPS install complete."
echo "Next: edit .env, then run: sudo bash scripts/vps_systemd_install.sh"
