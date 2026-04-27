# 🛡️ mhrv-rs Full Tunnel Setup Guide

راهنمای کامل راه‌اندازی **mhrv-rs** با **Tunnel Node** روی VPS — دور زدن رایگان DPI برای همه اپ‌ها

> **📖 راهنمای تعاملی:** [kian-irani.github.io/mhrv-setup-full-tunell](https://kian-irani.github.io/mhrv-setup-full-tunell)

---

## معماری

```
گوشی شما
  ↓
mhrv-rs (اپ اندروید)
  ↓ TLS — SNI: www.google.com  ← ISP این رو می‌بینه
Google Edge (فیلتر نمیشه)
  ↓
Apps Script (جیمیل شما — رایگان)
  ↓ HTTP
Tunnel Node (VPS هلند شما)
  ↓ TCP مستقیم
🌍 اینترنت آزاد
```

---

## لینک‌های مهم

| | |
|---|---|
| 📱 **اپ اندروید (mhrv-rs)** | [آخرین نسخه](https://github.com/therealaleph/MasterHttpRelayVPN-RUST/releases/latest) |
| ⭐ **ریپو اصلی** | [therealaleph/MasterHttpRelayVPN-RUST](https://github.com/therealaleph/MasterHttpRelayVPN-RUST) |
| 🖥️ **Tunnel Node مستندات** | [tunnel-node/README](https://github.com/therealaleph/MasterHttpRelayVPN-RUST/tree/main/tunnel-node) |
| 💻 **Termius SSH** | [Google Play](https://play.google.com/store/apps/details?id=com.server.audit) |
| 🌐 **خرید VPS (ارز دیجیتال)** | [netlen.com.tr](https://www.netlen.com.tr/) |
| 🐍 **پروژه اصلی Python** | [masterking32/MasterHttpRelayVPN](https://github.com/masterking32/MasterHttpRelayVPN) |

---

## مرحله ۱ — نصب Tunnel Node روی VPS

```bash
# مقادیر رو تنظیم کن، بعد کل کد رو Paste کن
AUTH_KEY="YOUR_STRONG_SECRET"
SSH_PORT=22
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
curl -sf http://localhost:${PORT}/health && echo "✅ OK" || echo "❌ ERROR"
echo "URL: http://$(curl -4s ifconfig.me):${PORT}"
```

---

## مرحله ۲ — CodeFull.gs در Apps Script

1. برو به [script.google.com](https://script.google.com) → New project
2. کد `CodeFull.gs` رو Paste کن (از [صفحه راهنما](https://kian-irani.github.io/mhrv-setup-full-tunell))
3. ۳ مقدار اول رو تنظیم کن:

```javascript
const AUTH_KEY          = "YOUR_SECRET";
const TUNNEL_SERVER_URL = "http://YOUR_VPS_IP:8080";
const TUNNEL_AUTH_KEY   = "YOUR_SECRET";
```

4. **Deploy → New deployment → Web app**
   - Execute as: **Me** | Who has access: **Anyone**
5. Deployment ID رو کپی کن

> ⚠️ **باگ کپی‌پیست:** بعد از Paste آخر فایل رو چک کن — خط اضافه رو پاک کن

---

## مرحله ۳ — تنظیم اپ اندروید

- **Deployment ID:** فقط ID رو وارد کن (نه کل URL)
- **Auth key:** همون رمز CodeFull.gs
- **Google IP:** `216.239.38.120` یا Auto-detect
- **Install MITM Certificate:** حتماً بزن

### چند Deployment برای سرعت بیشتر

> یه deployment per Google account — برای scale باید اکانت‌های مختلف استفاده کرد

- در هر مرورگر (Chrome، Brave، Firefox) با یه جیمیل جدید وارد شو
- CodeFull.gs رو deploy کن و ID رو بگیر
- هشدار «unsafe»: **Advanced → Go to (unsafe) → Allow**
- همه ID ها رو در اپ اضافه کن (هر ID یه خط)

> 🔐 از جیمیل اصلیت استفاده نکن — جیمیل جدید بساز

---

## چک وضعیت VPS

```bash
docker ps && \
curl -sf http://localhost:8080/health && echo " ✅ OK" && \
echo "IP: $(curl -4s ifconfig.me)"
```

---

## محدودیت‌ها

| موضوع | وضعیت |
|---|---|
| WebSocket (ChatGPT stream، Discord voice) | ❌ کار نمی‌کنه |
| ویدیو سنگین (YouTube 1080p) | ⚠️ سهمیه دارد |
| تلگرام | ✅ با SOCKS5 `127.0.0.1:8086` |
| مرورگر | ✅ کامل |
| SSH از طریق تانل | ✅ کامل |

---

## تشکر

- ایده و پیاده‌سازی اصلی: **[@masterking32](https://github.com/masterking32)**
- پورت Rust و Full Tunnel: **[@therealaleph](https://github.com/therealaleph)**