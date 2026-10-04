# پنل رسمی 3X-UI برای Ploi Cloud

این پروژه یک wrapper کوچک روی image رسمی `MHSanaei/3x-ui:v3.9.0` است. کد پنل و Xray از پروژهٔ رسمی می‌آید و فقط Nginx/Supervisor برای سازگاری با HTTP Appهای Ploi اضافه شده است.

## چه چیزی روی Ploi کار می‌کند؟

- پنل مدیریتی 3x-ui روی دامنهٔ Ploi
- SSL دامنه توسط Ploi
- Subscriptionها و APIهایی که از همان پورت پنل استفاده می‌کنند
- نگه‌داری SQLite و تنظیمات روی Volume
- Health check روی `/health`

## محدودیت مهم

Ploi Cloud در مستندات عمومی خود App را به‌صورت HTTP ارائه می‌کند و TCP/UDP public port یا TCP mapping مستقل را مستند نکرده است. بنابراین بالا آمدن پنل به‌تنهایی به معنی کارکرد همهٔ لینک‌های VLESS/VMess/Trojan/WireGuard نیست. برای هر inbound خام TCP/UDP، سرویس باید public TCP/UDP port واقعی ارائه کند.

اگر فقط WebSocket روی یک مسیر ثابت و gRPC مورد پشتیبانی Ploi باشد، می‌توان برای آن مسیرهای اختصاصی Nginx اضافه کرد؛ این wrapper به‌صورت پیش‌فرض هیچ inbound کاربر را حدس نمی‌زند.

## Deploy در Ploi

از Git repository استفاده کن:

```text
Repository: این repository
Dockerfile: Dockerfile
HTTP Port: 8080
Replicas: 1
Health check: /health
Region: Frankfurt یا Amsterdam
```

اگر Ploi از همین repository مستقیم Deploy می‌کند، branch `main` را انتخاب کن. اگر از GitHub fork استفاده می‌کنی، همین فایل‌ها را در root آن fork قرار بده.

## Volume

حداقل یک Volume روی مسیر زیر Mount کن:

```text
/etc/x-ui
```

برای نگه‌داری Certificateهای پنل و فایل‌های ACME نیز می‌توان Volume دوم را روی این مسیر Mount کرد:

```text
/root/cert
```

بدون Volume، تنظیمات پنل و SQLite ممکن است در redeploy از بین بروند.

## Environment variables

```text
PORT=8080
XUI_PORT=20530
XUI_WS_PORT=10001
XUI_WS_PATH=/xws
XUI_ENABLE_FAIL2BAN=false
XUI_DB_TYPE=sqlite
XUI_DB_FOLDER=/etc/x-ui
XUI_INIT_WEB_BASE_PATH=/admin/
```

`XUI_INIT_WEB_BASE_PATH` اختیاری است. اگر تنظیمش می‌کنی، بعد از اولین اجرا پنل را از مسیر زیر باز کن:

```text
https://DOMAIN/admin/
```

اگر بدون مسیر می‌خواهی:

```text
XUI_INIT_WEB_BASE_PATH=/
```

## ساخت کانفیگ روی Sliplane

در Sliplane برای این Service گزینهٔ **Expose service** را فعال کن و پروتکل را
`TCP/HTTP` بگذار. پورت داخلی را `8080` و Health check را `/health` تنظیم کن.

در پنل 3x-ui یک Inbound با این مشخصات بساز:

```text
Protocol: VLESS
Port: 10001
Network: WebSocket (ws)
Path: /xws
TLS داخل Xray: خاموش
```

در قسمت Client یک لینک با این مشخصات تولید می‌شود:

```text
Address: دامنهٔ Sliplane، بدون https://
Port: 443
Security: TLS
Transport: WebSocket
Path: /xws
Host/SNI: همان دامنهٔ Sliplane
```

علت خاموش‌بودن TLS داخل Xray این است که HTTPS در ورودی عمومی Sliplane terminate
می‌شود و Nginx درخواست WebSocket را به پورت داخلی `10001` منتقل می‌کند.

> کانفیگ‌های Reality، TCP خام، UDP، WireGuard، Hysteria و TUIC با این HTTP Service
> قابل تضمین نیستند، چون Sliplane برای هر Service فقط یک پورت عمومی دارد. برای آن‌ها
> باید یک Service جداگانه با پروتکل TCP یا UDP بسازی؛ آن Service دیگر دامنهٔ HTTPS
> پنل را ارائه نمی‌کند.

## ورود اولیه

پس از اولین اجرا، Log پنل رسمی 3x-ui معمولاً اطلاعات login اولیه یا مسیر دسترسی را نشان می‌دهد. بلافاصله username/password را تغییر بده و از password قوی استفاده کن.

## چرا Fail2ban خاموش است؟

Image رسمی Fail2ban را دارد، اما Fail2ban برای اعمال ban به `NET_ADMIN` و `NET_RAW` نیاز دارد. Appهای managed مثل Ploi معمولاً این capabilityها را بدون تأیید در اختیار کانتینر نمی‌گذارند. بنابراین `XUI_ENABLE_FAIL2BAN=false` گذاشته شده تا startup به‌دلیل iptables شکست نخورد.

## تست

بعد از Deploy:

```text
https://DOMAIN/health
```

باید پاسخ زیر را بدهد:

```text
ok
```

سپس دامنهٔ Ploi را باز کن و پنل را بررسی کن. خطای پنل در Log را از مسیر Logs خود Ploi بخوان.

## قوانین استفاده

قبل از فعال‌کردن inboundها و استفادهٔ عمومی، Terms و Acceptable Use فعلی Ploi Cloud را بررسی کن. استفادهٔ قانونی و شخصی مسئولیت کاربر است؛ mining، malware، حمله، spam و مصرفی که به زیرساخت یا کاربران دیگر آسیب بزند ممنوع است.
