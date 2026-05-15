#!/bin/bash
PORT="${PORT:-8080}"

# بررسی وضعیت
STATUS=$(docker inspect -f "{{.State.Status}}" mhrv-tunnel 2>/dev/null)
STARTED=$(docker inspect -f "{{.State.StartedAt}}" mhrv-tunnel 2>/dev/null | cut -c1-16)
RESTART=$(docker inspect -f "{{.HostConfig.RestartPolicy.Name}}" mhrv-tunnel 2>/dev/null)
ERRS=$(docker logs --tail 50 mhrv-tunnel 2>&1 | grep -i "error\|panic" | tail -3)
PIP=$(curl -4s -m 5 ifconfig.me 2>/dev/null)
AUTH_RUN=$(docker inspect -f '{{range .Config.Env}}{{println .}}{{end}}' mhrv-tunnel 2>/dev/null | grep "^TUNNEL_AUTH_KEY=" | cut -d= -f2-)

# ── چک سلامت چند مرحله‌ای ──
# مرحله ۱: آیا پورت باز و listening هست؟
PORT_LISTEN="no"
if ss -lntH 2>/dev/null | awk '{print $4}' | grep -qE ":${PORT}$"; then
  PORT_LISTEN="yes"
elif command -v nc >/dev/null && nc -z 127.0.0.1 ${PORT} 2>/dev/null; then
  PORT_LISTEN="yes"
fi

# مرحله ۲: HTTP response code (هر کدی، حتی 404، یعنی سرویس بالاست)
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" -m 5 http://127.0.0.1:${PORT}/ 2>/dev/null)

# تصمیم نهایی برای health
HEALTH="bad"
if [ "$PORT_LISTEN" = "yes" ] && [ -n "$HTTP_CODE" ] && [ "$HTTP_CODE" != "000" ]; then
  HEALTH="ok"
fi

echo ""
if [ "$STATUS" = "running" ] && [ "$HEALTH" = "ok" ]; then
  echo "╔════════════════════════════════════════════════╗"
  echo "║          ✅  سرویس فعال و سالم است             ║"
  echo "╚════════════════════════════════════════════════╝"
else
  echo "╔════════════════════════════════════════════════╗"
  echo "║          ⚠️  سرویس مشکل دارد                   ║"
  echo "╚════════════════════════════════════════════════╝"
fi
echo ""
echo "┌─ وضعیت ─────────────────────────────────────────"
echo "│"
if [ "$STATUS" = "running" ]; then
  echo "│   Container   :  ✅ در حال اجرا (از $STARTED)"
else
  echo "│   Container   :  ❌ ${STATUS:-نصب نشده}"
fi
if [ "$PORT_LISTEN" = "yes" ]; then
  echo "│   پورت ${PORT}   :  ✅ در حال گوش دادن"
else
  echo "│   پورت ${PORT}   :  ❌ بسته"
fi
if [ "$HEALTH" = "ok" ]; then
  echo "│   پاسخ سرویس :  ✅ HTTP ${HTTP_CODE} (سالم)"
else
  echo "│   پاسخ سرویس :  ❌ پاسخ نمی‌ده"
fi
echo "│   Restart     :  ${RESTART:-نامشخص}"
[ -n "$ERRS" ] && echo "│   آخرین خطا  :  $ERRS" || echo "│   لاگ خطا    :  ✅ تمیز"
echo "│"
echo "└─────────────────────────────────────────────────"

# اگه همه‌چی OK بود، اطلاعات کلیدی رو هم برای یادآوری نشون بده
if [ "$STATUS" = "running" ] && [ "$HEALTH" = "ok" ]; then
  echo ""
  echo "┌─ اطلاعات سرور (برای Apps Script) ──────────────"
  echo "│"
  [ -n "$PIP" ]      && echo "│   🌐 IP سرور      :  ${PIP}"
  echo "│   🔌 پورت تونل    :  ${PORT}"
  [ -n "$AUTH_RUN" ] && echo "│   🔑 کلید AUTH    :  ${AUTH_RUN}"
  echo "│"
  echo "└─────────────────────────────────────────────────"
  echo ""
  echo "💡 اگه می‌خوای کد Apps Script رو دوباره بسازی:"
  echo "   به صفحه برو، فیلدها رو پر کن، از سربرگ «📝 Apps Script»"
  echo "   کد رو کپی کن و در script.google.com پیست کن."
  echo ""
  echo "   🔗 https://kian-irani.github.io/mhrv-setup-full-tunell/"
else
  echo ""
  echo "🆘 برای کمک به پشتیبانی پیام بده: @Kian_irani_t"
fi
echo ""
