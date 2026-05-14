#!/bin/bash
PORT="${PORT:-8080}"

# بررسی وضعیت
STATUS=$(docker inspect -f "{{.State.Status}}" mhrv-tunnel 2>/dev/null)
STARTED=$(docker inspect -f "{{.State.StartedAt}}" mhrv-tunnel 2>/dev/null | cut -c1-16)
H=$(curl -sf -m 5 http://localhost:${PORT}/health 2>/dev/null)
RESTART=$(docker inspect -f "{{.HostConfig.RestartPolicy.Name}}" mhrv-tunnel 2>/dev/null)
ERRS=$(docker logs --tail 50 mhrv-tunnel 2>&1 | grep -i "error\|panic" | tail -3)
PIP=$(curl -4s -m 5 ifconfig.me 2>/dev/null)
AUTH_RUN=$(docker inspect -f '{{range .Config.Env}}{{println .}}{{end}}' mhrv-tunnel 2>/dev/null | grep "^TUNNEL_AUTH_KEY=" | cut -d= -f2-)

echo ""
if [ "$STATUS" = "running" ] && [ "$H" = "ok" ]; then
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
[ "$H" = "ok" ] && echo "│   Health      :  ✅ سالم" || echo "│   Health      :  ❌ پاسخ نمی‌ده"
echo "│   Restart     :  ${RESTART:-نامشخص}"
[ -n "$ERRS" ] && echo "│   آخرین خطا  :  $ERRS" || echo "│   لاگ خطا    :  ✅ تمیز"
echo "│"
echo "└─────────────────────────────────────────────────"

# اگه همه‌چی OK بود، اطلاعات کلیدی رو هم برای یادآوری نشون بده
if [ "$STATUS" = "running" ] && [ "$H" = "ok" ]; then
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
