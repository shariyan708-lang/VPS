# Telegram Selling Bot - VPS Edition

Normal Telegram bot for selling license keys/products. This is not a website and not a Telegram Mini App. Users and admins use everything inside Telegram.

## Features

- Telegram-only admin panel visible only to `ADMIN_IDS`
- Forced join channel login and verify flow
- Product, variant/day, price and stock management
- Stock-out variants are blocked from purchase and custom quantity
- Product icons support normal emoji and Telegram premium/custom emoji
- User wallet balance, add/deduct balance, top-up approval
- Ban/unban users
- Direct message and broadcast with media/custom emoji support
- Referral invite links with reward balance
- Redeem gift code system
- Order history and TXT export
- Maintenance mode
- Neon PostgreSQL support through `DATABASE_URL`
- SQLite fallback for local testing
- PostgreSQL reconnect/keepalive, cached settings, cached join checks and optimized indexes
- Concurrent update workers and shorter Telegram API timeouts to prevent one slow request from freezing the bot
- VPS systemd scripts for 24/7 hosting

## Files

```text
selling_bot.py
requirements.txt
.env.example
.gitignore
neon_optimize.sql
VPS_DEPLOY_GUIDE_BN.md
scripts/vps_install.sh
scripts/vps_systemd_install.sh
scripts/vps_update.sh
systemd/telegram-selling-bot.service.example
```

## VPS Quick Deploy

Ubuntu/Debian VPS:

```bash
sudo apt update
sudo apt install -y python3 python3-venv python3-pip git
```

Project folder:

```bash
cd /opt
sudo git clone YOUR_GITHUB_REPO_URL telegram-selling-bot
sudo chown -R $USER:$USER /opt/telegram-selling-bot
cd /opt/telegram-selling-bot
```

Environment:

```bash
cp .env.example .env
nano .env
```

Install and start:

```bash
bash scripts/vps_install.sh
sudo bash scripts/vps_systemd_install.sh
```

Logs:

```bash
journalctl -u telegram-selling-bot -f
```

Restart:

```bash
sudo systemctl restart telegram-selling-bot
```

Update:

```bash
bash scripts/vps_update.sh
```

Full Bengali guide: `VPS_DEPLOY_GUIDE_BN.md`.

## Environment

```env
BOT_TOKEN=your_bot_token
ADMIN_IDS=your_numeric_telegram_user_id
BOT_USERNAME=your_bot_username_without_@
DATABASE_URL=
DB_PATH=data/telegram_selling_bot.sqlite3
JOIN_CACHE_SECONDS=300
FAILED_JOIN_CACHE_SECONDS=20
SETTINGS_CACHE_SECONDS=5
UPDATE_WORKERS=4
MAX_PENDING_UPDATES=100
SLOW_UPDATE_LOG_SECONDS=3
POLLING_ERROR_SLEEP_SECONDS=2
TG_API_TIMEOUT_SECONDS=12
TG_GET_UPDATES_TIMEOUT_SECONDS=20
TG_SEND_TIMEOUT_SECONDS=12
TG_EDIT_TIMEOUT_SECONDS=10
TG_COPY_TIMEOUT_SECONDS=15
TG_MEMBER_TIMEOUT_SECONDS=8
TG_DOCUMENT_TIMEOUT_SECONDS=30
PG_CONNECT_TIMEOUT=10
PG_KEEPALIVES_IDLE=30
PG_KEEPALIVES_INTERVAL=10
PG_KEEPALIVES_COUNT=5
PG_RECONNECT_LOG_SECONDS=60
BROADCAST_DELAY_SECONDS=0.035
```

Leave `DATABASE_URL=` empty for local VPS SQLite database. Use PostgreSQL/Neon URL only if you want an external PostgreSQL database.

Use only one running bot process for one `BOT_TOKEN`. Do not run the same bot token on VPS and another host at the same time.

## Local Test

```bash
python selling_bot.py --init-db
python selling_bot.py --smoke-test
python selling_bot.py
```

## Neon Optimization

The bot creates tables and indexes automatically. For extra Neon performance, run `neon_optimize.sql` once in the Neon SQL Editor after first deploy.
