#!/bin/bash
# mhrv-rs Tunnel Node — نصب خودکار
# استفاده: PORT="..." AUTH="..." SSH_PORT="..." bash <(curl -fsSL ...)

set -e
LOG=/tmp/mhrv-install.log
export DEBIAN_FRONTEND=noninteractive

# ── چک root ──
if [ "$(id -u)" -ne 0 ]; then
  echo "❌ این اسکریپت نیاز به root داره"
  echo "   اگه root نیستی، اول 'sudo -i' بزن یا 'sudo' جلوش بذار"
  exit 1
fi

# ── validation: قبل از هر کاری، متغیرها رو چک کن ──
if [ -z "$PORT" ] || ! echo "$PORT" | grep -qE '^[0-9]+$' || [ "$PORT" -lt 1 ] || [ "$PORT" -gt 65535 ]; then
  echo "❌ خطا: PORT معتبر نیست (مثال: PORT=\"8080\")"
  exit 1
fi
if [ -z "$SSH_PORT" ] || ! echo "$SSH_PORT" | grep -qE '^[0-9]+$' || [ "$SSH_PORT" -lt 1 ] || [ "$SSH_PORT" -gt 65535 ]; then
  echo "❌ خطا: SSH_PORT معتبر نیست (مثال: SSH_PORT=\"22\")"
  exit 1
fi
if [ -z "$AUTH" ] || [ "${#AUTH}" -lt 6 ]; then
  echo "❌ خطا: AUTH معتبر نیست — حداقل ۶ کاراکتر"
  exit 1
fi

# ── چک پورت در حال استفاده ──
if ss -lntH 2>/dev/null | awk '{print $4}' | grep -qE ":${PORT}$"; then
  echo "❌ پورت ${PORT} الان توسط برنامه دیگه‌ای استفاده می‌شه"
  echo "   پورت دیگه‌ای انتخاب کن یا برنامه فعلی رو stop کن"
  echo "   دیدن برنامه: ss -lntp | grep :${PORT}"
  exit 1
fi

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
  echo "╔════════════════════════════════════════════════╗"
  echo "║                                                ║"
  echo "║          ✅  نصب با موفقیت انجام شد            ║"
  echo "║                                                ║"
  echo "╚════════════════════════════════════════════════╝"
  echo ""
  echo "┌─ اطلاعات سرور شما ──────────────────────────────"
  echo "│"
  echo "│   🌐 IP سرور      :  ${PIP}"
  echo "│   🔌 پورت تونل    :  ${PORT}"
  echo "│   🔑 کلید AUTH    :  ${AUTH}"
  echo "│"
  echo "└─────────────────────────────────────────────────"
  echo ""
  echo "📋 مراحل بعدی:"
  echo ""
  echo "  1️⃣  به صفحه‌ی تنظیمات برگرد:"
  echo "      https://kian-irani.github.io/mhrv-setup-full-tunell/"
  echo ""
  echo "  2️⃣  در سربرگ «📝 Apps Script» کد آماده‌شده رو"
  echo "      کپی کن و در script.google.com پیست کن"
  echo ""
  echo "  3️⃣  Deploy → New deployment → Web app"
  echo "      Execute as: Me  |  Access: Anyone"
  echo ""
  echo "  4️⃣  Deployment ID رو در اپ mhrv-rs وارد کن"
  echo "      همراه با AUTH key بالا"
  echo ""
  echo "💡 سرویس بعد از ریستارت VPS هم خودکار روشن می‌شه ✅"
  echo ""
  echo "🔧 برای چک وضعیت بعداً:"
  echo "   PORT=\"${PORT}\" bash <(curl -fsSL https://raw.githubusercontent.com/KIAN-IRANI/mhrv-setup-full-tunell/main/check.sh)"
  echo ""
else
  echo "╔════════════════════════════════════════════════╗"
  echo "║          ❌  نصب با خطا مواجه شد               ║"
  echo "╚════════════════════════════════════════════════╝"
  echo ""
  echo "آخرین خطوط لاگ:"
  echo "─────────────────────────────────"
  tail -15 $LOG 2>/dev/null
  echo "─────────────────────────────────"
  echo ""
  echo "لاگ کامل: cat $LOG"
  echo ""
  echo "🆘 اگه مشکل حل نشد به پشتیبانی پیام بده: @Kian_irani_t"
fi
