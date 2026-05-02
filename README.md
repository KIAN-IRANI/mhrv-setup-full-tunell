<div align="center">

# 🛡️ mhrv-rs راهنمای فارسی — Full Tunnel Setup

**راهنمای کامل راه‌اندازی اینترنت آزاد با روش mhrv-rs + VPS Tunnel**

[![GitHub Pages](https://img.shields.io/badge/صفحه%20تعاملی-آنلاین-brightgreen?style=for-the-badge&logo=github)](https://kian-irani.github.io/mhrv-setup-full-tunell/)
[![Guide](https://img.shields.io/badge/راهنمای%20تصویری-8%20مرحله-blue?style=for-the-badge&logo=gitbook)](https://kian-irani.github.io/mhrv-setup-full-tunell/guide.html)
[![Telegram](https://img.shields.io/badge/کانال%20آموزشی-Telegram-26A5E4?style=for-the-badge&logo=telegram)](https://t.me/kian_irani_cdn_f)
[![Bot](https://img.shields.io/badge/ربات%20اسکریپت-دریافت%20رایگان-green?style=for-the-badge&logo=telegram)](https://t.me/Mhrv_script_bot)
[![App](https://img.shields.io/badge/mhrv--rs-v1.9.7-orange?style=for-the-badge&logo=android)](https://github.com/therealaleph/MasterHttpRelayVPN-RUST/releases/latest)

---

**🇮🇷 این راهنما توسط [Kian Irani](https://github.com/KIAN-IRANi) تهیه شده**  
با تشکر از [@therealaleph](https://github.com/therealaleph) (Rust Port) و [@masterking32](https://github.com/masterking32) (ایده اصلی)

</div>

---

## ⚡ چی هست؟

یه روش **رایگان** و **بدون نیاز به root** برای دور زدن DPI و فیلترینگ روی اندروید.

ترافیک گوشی از طریق **Google Edge** رد میشه — ISP فقط اتصال به `www.google.com` می‌بینه و قادر به تشخیص یا فیلتر کردن نیست.

```
📱 گوشی شما
    ↓  TLS — SNI: www.google.com  ← ISP فقط این رو می‌بینه
☁️ Google Edge  (فیلتر نمیشه)
    ↓
📝 Apps Script  (جیمیل شما — رایگان)
    ↓
🖥️ Tunnel Node  (VPS)
    ↓
🌍 اینترنت آزاد
```

---

## ✅ مزایا

| ویژگی | وضعیت |
|---|---|
| 🆓 کاملاً رایگان | ✅ Google Apps Script رایگانه |
| 🔓 بدون Root | ✅ نیازی به روت نیست |
| 📜 بدون Certificate | ✅ از v1.7.7+ |
| 📱 همه اپ‌ها | ✅ Full Tunnel — تلگرام، یوتیوب، بانک |
| 🔄 Multi-Deployment | ✅ چند جیمیل = سرعت بیشتر |
| 📤 اشتراک QR | ✅ کانفیگ رو با QR به دیگران بده |

---

## 🚀 شروع سریع

### روش ۱ — بدون VPS (فقط جیمیل)

> اسکریپت آماده رو از ربات بگیر، روی جیمیل deploy کن، تمومه!

```
1. از ربات @Mhrv_script_bot اسکریپت بگیر
2. روی script.google.com deploy کن
3. Deployment ID رو به اپ mhrv-rs بده
4. Connect!
```

👉 **[دریافت اسکریپت از ربات](https://t.me/Mhrv_script_bot)**

### روش ۲ — با VPS (Full Tunnel کامل)

> برای تلگرام و اپ‌هایی که TCP خام نیاز دارن

```bash
# نصب خودکار tunnel-node روی VPS
# کد از صفحه تعاملی بگیر — IP و رمز خودکار وارد میشه
```

👉 **[صفحه تعاملی — کد خودکار بگیر](https://kian-irani.github.io/mhrv-setup-full-tunell/)**

---

## 📖 راهنماها

| راهنما | لینک |
|---|---|
| 🖥️ صفحه تعاملی کامل (VPS + Apps Script + اندروید) | [باز کن](https://kian-irani.github.io/mhrv-setup-full-tunell/) |
| 📖 راهنمای تصویری deploy — ۸ مرحله با عکس | [باز کن](https://kian-irani.github.io/mhrv-setup-full-tunell/guide.html) |
| 📱 دانلود آخرین APK اندروید | [دانلود](https://github.com/therealaleph/MasterHttpRelayVPN-RUST/releases/latest) |
| 🤖 ربات دریافت اسکریپت (رایگان با دعوت) | [@Mhrv_script_bot](https://t.me/Mhrv_script_bot) |
| 📌 کانال آموزشی و پشتیبانی | [@kian_irani_cdn_f](https://t.me/kian_irani_cdn_f) |

---

## ⚙️ ساختار پروژه

```
mhrv-setup-full-tunell/
├── index.html      ← صفحه تعاملی (تنظیمات + کد VPS + Apps Script + آندروید)
├── guide.html      ← راهنمای تصویری گام‌به‌گام deploy
└── README.md       ← همین فایل
```

---

## 🔧 محدودیت‌ها

| مورد | وضعیت |
|---|---|
| WebSocket (Discord voice) | ❌ کار نمی‌کنه |
| YouTube (بدون Full Tunnel) | ⚠️ نیاز به VPS |
| سهمیه روزانه | ⚠️ 20k call/روز هر اکانت گوگل |
| تلگرام | 💡 از SOCKS5 Proxy استفاده کن: `127.0.0.1:8086` |

---

## 📦 نسخه‌های مهم

| نسخه | تغییرات |
|---|---|
| v1.9.7 | LAN share toggle، multi-edge fronting groups |
| v1.9.4 | long-poll 5s→15s، tunnel-node بهبود |
| v1.8.5 | Full Tunnel (no cert)، استریم ویدیو fix |
| v1.7.7 | Export config / QR code، App splitting |

---

## 🙏 تشکر

- **[@masterking32](https://github.com/masterking32)** — ایده اصلی و پروتکل Python
- **[@therealaleph](https://github.com/therealaleph)** — پورت Rust و Full Tunnel
- **[Kian Irani](https://github.com/KIAN-IRANi)** — این راهنما و صفحه تعاملی

---

<div align="center">

**📌 [کانال آموزشی](https://t.me/kian_irani_cdn_f) | 🤖 [ربات اسکریپت](https://t.me/Mhrv_script_bot) | 🛡️ [صفحه تعاملی](https://kian-irani.github.io/mhrv-setup-full-tunell/)**

</div>
