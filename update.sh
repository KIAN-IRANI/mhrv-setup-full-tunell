#!/bin/bash
LOG=/tmp/mhrv-update.log
echo "⏳ آپدیت در پس‌زمینه... لاگ: $LOG"
(
docker pull ghcr.io/therealaleph/mhrv-tunnel-node:latest
docker rm -f mhrv-tunnel 2>/dev/null || true
docker run -d --name mhrv-tunnel \
  --restart unless-stopped \
  -p ${PORT}:${PORT} -e PORT=${PORT} \
  -e TUNNEL_AUTH_KEY="${AUTH}" \
  ghcr.io/therealaleph/mhrv-tunnel-node:latest
sleep 6
H=$(curl -sf http://localhost:${PORT}/health 2>/dev/null)
echo "RESULT:${H}" >> $LOG
) >> $LOG 2>&1 &
wait $!
H=$(grep RESULT: $LOG | tail -1 | cut -d: -f2)
[ "$H" = "ok" ] && echo "✅ آپدیت موفق" || echo "❌ بزن: cat $LOG"
