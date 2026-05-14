#!/bin/bash
# mhrv-rs Tunnel Node — نصب خودکار
# استفاده: PORT="..." AUTH="..." SSH_PORT="..." bash <(curl -fsSL ...)

set -e
LOG=/tmp/mhrv-install.log
export DEBIAN_FRONTEND=noninteractive

echo "⏳ در حال نصب... لاگ: $LOG"
echo ""

(
echo "[1/5] آماده‌سازی سیستم..."
dpkg --configure -a >> $LOG 2>&1 || true
apt-get update -qq >> $LOG 2>&1
apt-get install -y -q docker.io curl ufw >> $LOG 2>&1
systemctl enable docker --now >> $LOG 2>&1 || true

echo "[2/5] تنظیم Firewall..."
ufw --force reset >> $LOG 2>&1 || true
ufw default deny incoming >> $LOG 2>&1
ufw default allow outgoing >> $LOG 2>&1
ufw allow ${SSH_PORT}/tcp >> $LOG 2>&1
ufw allow ${PORT}/tcp >> $LOG 2>&1
ufw --force enable >> $LOG 2>&1

echo "[3/5] دانلود image..."
docker pull ghcr.io/therealaleph/mhrv-tunnel-node:latest >> $LOG 2>&1

echo "[4/5] راه‌اندازی container..."
docker rm -f mhrv-tunnel >> $LOG 2>&1 || true
docker run -d --name mhrv-tunnel \
  --restart unless-stopped \
  -p ${PORT}:${PORT} \
  -e PORT=${PORT} \
  -e TUNNEL_AUTH_KEY="${AUTH}" \
  ghcr.io/therealaleph/mhrv-tunnel-node:latest >> $LOG 2>&1

echo "[5/5] چک سلامت..."
sleep 8
H=$(curl -sf http://localhost:${PORT}/health 2>/dev/null)
PIP=$(curl -4s ifconfig.me 2>/dev/null)
echo "RESULT:${H}:${PIP}" >> $LOG
) 2>> $LOG

# نمایش نتیجه
RESULT=$(grep "RESULT:" $LOG | tail -1)
H=$(echo $RESULT | cut -d: -f2)
PIP=$(echo $RESULT | cut -d: -f3)
echo ""
if [ "$H" = "ok" ]; then
  echo "━━━━━━━━━━━━━━━━━━━"
  echo "✅ نصب موفق!"
  echo "IP  : ${PIP}"
  echo "PORT: ${PORT}"
  echo "KEY : ${AUTH}"
  echo "━━━━━━━━━━━━━━━━━━━"
  echo "بعد از ریستارت VPS هم خودکار روشن میشه ✅"
else
  echo "❌ خطا — بزن: cat $LOG"
fi
