#!/bin/bash
LOG=/tmp/mhrv-update.log

# ── چک root ──
if [ "$(id -u)" -ne 0 ]; then
  echo "❌ این اسکریپت نیاز به root داره (برای کنترل docker)"
  echo "   اگه root نیستی، اول 'sudo -i' بزن یا 'sudo' جلوش بذار"
  exit 1
fi

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
PIP=$(curl -4s -m 5 ifconfig.me 2>/dev/null)
echo ""
if [ "$H" = "ok" ]; then
  echo "╔════════════════════════════════════════════════╗"
  echo "║          ✅  آپدیت با موفقیت انجام شد           ║"
  echo "╚════════════════════════════════════════════════╝"
  echo ""
  echo "┌─ اطلاعات سرور شما ──────────────────────────────"
  echo "│"
  [ -n "$PIP" ] && echo "│   🌐 IP سرور      :  ${PIP}"
  echo "│   🔌 پورت تونل    :  ${PORT}"
  echo "│   🔑 کلید AUTH    :  ${AUTH}"
  echo "│"
  echo "└─────────────────────────────────────────────────"
  echo ""
  echo "💡 کلید و آدرس عوض نشده — نیازی به redeploy Apps Script نیست ✅"
  echo ""
else
  echo "╔════════════════════════════════════════════════╗"
  echo "║          ❌  آپدیت با خطا مواجه شد              ║"
  echo "╚════════════════════════════════════════════════╝"
  echo ""
  echo "برای دیدن جزئیات: cat $LOG"
  echo "اگه مشکل حل نشد: @Kian_irani_t"
fi
