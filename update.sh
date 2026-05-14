#!/bin/bash
LOG=/tmp/mhrv-update.log

# ── validation ──
if [ -z "$PORT" ] || ! echo "$PORT" | grep -qE '^[0-9]+$' || [ "$PORT" -lt 1 ] || [ "$PORT" -gt 65535 ]; then
  echo "❌ خطا: PORT معتبر نیست (مثال: PORT=\"8080\")"
  exit 1
fi
if [ -z "$AUTH" ] || [ "${#AUTH}" -lt 6 ]; then
  echo "❌ خطا: AUTH معتبر نیست — حداقل ۶ کاراکتر"
  exit 1
fi

echo "⏳ آپدیت... لاگ: $LOG"
(
# ── اول pull — اگه fail شد، container قدیمی دست‌نخورده می‌مونه ──
docker pull ghcr.io/therealaleph/mhrv-tunnel-node:latest
# ── pull موفق بود، حالا جایگزین کن ──
docker rm -f mhrv-tunnel 2>/dev/null || true
docker run -d --name mhrv-tunnel \
  --restart unless-stopped \
  -p ${PORT}:${PORT} -e PORT=${PORT} \
  -e TUNNEL_AUTH_KEY="${AUTH}" \
  ghcr.io/therealaleph/mhrv-tunnel-node:latest
sleep 6
H=$(curl -sf http://localhost:${PORT}/health 2>/dev/null)
echo "RESULT:${H}" >> $LOG
) >> $LOG 2>&1
H=$(grep RESULT: $LOG | tail -1 | cut -d: -f2)
[ "$H" = "ok" ] && echo "✅ آپدیت موفق" || echo "❌ بزن: cat $LOG"
