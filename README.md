# 🛡️ mhrv-rs Full Tunnel Setup Guide

راهنمای کامل راه‌اندازی **mhrv-rs** با **Tunnel Node** روی VPS برای اندروید

> **📖 صفحه تعاملی:** [kian-irani.github.io/mhrv-setup-full-tunell](https://kian-irani.github.io/mhrv-setup-full-tunell)

---

## درباره این روش

این روش ترافیک گوشی را از طریق سرورهای Google رد می‌کند. ISP فقط اتصال به `www.google.com` می‌بیند — تا زمانی که گوگل در ایران فیلتر نشود کار می‌کند.

برای راه‌اندازی اولیه به یک فیلترشکن فعال نیاز داری — بعد دیگر مستقل خواهی بود.

---

## معماری

```
گوشی شما
  ↓
mhrv-rs (اپ اندروید)
  ↓  TLS — SNI: www.google.com  ← ISP این رو می‌بینه
Google Edge (فیلتر نمیشه)
  ↓
Apps Script (جیمیل شما — رایگان)
  ↓  HTTP
Tunnel Node (VPS هلند شما)
  ↓  TCP مستقیم
🌍 اینترنت آزاد
```

---

## لینک‌های مهم

| | |
|---|---|
| 📱 **mhrv-rs Android APK** | [آخرین نسخه](https://github.com/therealaleph/MasterHttpRelayVPN-RUST/releases/latest) |
| ⭐ **ریپو اصلی** | [therealaleph/MasterHttpRelayVPN-RUST](https://github.com/therealaleph/MasterHttpRelayVPN-RUST) |
| 🖥️ **Tunnel Node** | [مستندات VPS](https://github.com/therealaleph/MasterHttpRelayVPN-RUST/tree/main/tunnel-node) |
| 💻 **Termius SSH** | [Google Play](https://play.google.com/store/apps/details?id=com.server.auditor.ssh.client) |
| 🇮🇷 **Parsdev VPS** | [parsdev.com](https://parsdev.com/) — ایرانی، پرداخت ریالی |
| 🌐 **Netlen VPS** | [netlen.com.tr](https://www.netlen.com.tr/) — کریپتو، بدون KYC |
| 🐍 **پروژه اصلی Python** | [masterking32/MasterHttpRelayVPN](https://github.com/masterking32/MasterHttpRelayVPN) |

---

## مرحله ۱ — نصب Tunnel Node روی VPS

> برای تنظیم خودکار و کپی کردن کد با مقادیر شخصی‌سازی‌شده → [صفحه راهنما](https://kian-irani.github.io/mhrv-setup-full-tunell)

```bash
AUTH_KEY="YOUR_STRONG_SECRET"   # ← رمز خودت
SSH_PORT=22                      # ← پورت SSH سرورت
PORT=8080

export DEBIAN_FRONTEND=noninteractive
apt update -y -q && apt upgrade -y -q
apt install -y -q docker.io curl ufw
systemctl enable docker --now

ufw --force reset -q
ufw default deny incoming && ufw default allow outgoing
ufw allow ${SSH_PORT}/tcp && ufw allow ${PORT}/tcp
ufw --force enable

docker rm -f tunnel-node 2>/dev/null || true
docker pull ghcr.io/therealaleph/mhrv-tunnel-node:latest -q
docker run -d \
  --name tunnel-node --restart always \
  -p ${PORT}:${PORT} \
  -e TUNNEL_AUTH_KEY="${AUTH_KEY}" \
  -e PORT=${PORT} \
  ghcr.io/therealaleph/mhrv-tunnel-node:latest

sleep 5
HEALTH=$(curl -sf http://localhost:${PORT}/health 2>/dev/null)
[ "$HEALTH" = "ok" ] && echo "✅ OK" || echo "❌ ERROR"
echo "URL: http://$(curl -4s ifconfig.me):${PORT}"
```

---

## مرحله ۲ — CodeFull.gs در Apps Script

1. به [script.google.com](https://script.google.com) برو → New project
2. کد `CodeFull.gs` رو از [صفحه راهنما](https://kian-irani.github.io/mhrv-setup-full-tunell) کپی کن
3. **Deploy → New deployment → Web app**
   - Execute as: **Me** | Who has access: **Anyone**
4. هشدار «unsafe»: **Advanced → Go to (unsafe) → Allow**
5. **Deployment ID** رو کپی کن — فقط ID، نه کل URL

> ⚠️ **باگ کپی‌پیست:** بعد از paste آخر فایل رو چک کن — خط اضافه رو پاک کن وگرنه Syntax Error

---

## مرحله ۳ — چند Deployment برای سرعت بیشتر

> یه deployment per Google account — چند deployment روی یه جیمیل فایده نداره

- در Chrome، Brave، Firefox با جیمیل‌های مختلف وارد شو
- روی هر اکانت CodeFull.gs رو deploy کن و ID بگیر
- همه ID ها رو در اپ اندروید وارد کن (هر ID یک خط)

> 🔐 از جیمیل اصلیت استفاده نکن — جیمیل جدید بساز

> 👥 **اشتراک VPS:** یک VPS برای چند نفر کافیه — کافیه هر نفر CodeFull.gs رو با جیمیل خودش deploy کنه. نیازی به دسترسی به VPS ندارند.

---

## تنظیم اپ اندروید

- **Deployment IDs:** فقط ID (نه URL) — هر ID یک خط
- **Auth key:** همون رمز CodeFull.gs
- **Google IP:** `216.239.38.120` یا Auto-detect
- **Install MITM Certificate:** حتماً بزن

---

## محدودیت‌ها

| | |
|---|---|
| WebSocket (ChatGPT stream، Discord voice) | ❌ |
| ویدیو سنگین | ⚠️ سهمیه دارد |
| تلگرام | ✅ SOCKS5: `127.0.0.1:8086` |
| مرورگر | ✅ |

---

## تشکر

- ایده و پروتکل اصلی: **[@masterking32](https://github.com/masterking32)**
- پورت Rust و Full Tunnel: **[@therealaleph](https://github.com/therealaleph)**

---

## سازنده این راهنما

**Kian Irani**

- 📊 کانال فارکس: [t.me/kian_forex](https://t.me/kian_forex)
- ✈️ تلگرام: [t.me/Kian_irani_t](https://t.me/Kian_irani_t)
- 🐙 GitHub: [KIAN-IRANi](https://github.com/KIAN-IRANi)