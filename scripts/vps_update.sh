#!/usr/bin/env bash
set -euo pipefail

APP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$APP_DIR"

if command -v git >/dev/null 2>&1 && [ -d .git ]; then
  echo "==> Pulling latest code"
  git pull --ff-only
fi

echo "==> Updating dependencies"
.venv/bin/python -m pip install --upgrade pip wheel setuptools
.venv/bin/python -m pip install -r requirements.txt

echo "==> Applying database schema checks"
.venv/bin/python selling_bot.py --init-db

echo "==> Running smoke test"
.venv/bin/python selling_bot.py --smoke-test

if command -v systemctl >/dev/null 2>&1; then
  echo "==> Restarting service"
  sudo systemctl restart telegram-selling-bot
  sudo systemctl --no-pager --lines=20 status telegram-selling-bot
fi

echo "Update complete."
