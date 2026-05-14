#!/bin/bash
PORT="${PORT:-8080}"
echo "━━━━━━ وضعیت mhrv-tunnel ━━━━━━"
STATUS=$(docker inspect -f "{{.State.Status}}" mhrv-tunnel 2>/dev/null)
STARTED=$(docker inspect -f "{{.State.StartedAt}}" mhrv-tunnel 2>/dev/null | cut -c1-16)
if [ "$STATUS" = "running" ]; then
  echo "Container : ✅ Running (از $STARTED)"
else
  echo "Container : ❌ $STATUS"
fi
H=$(curl -sf -m 5 http://localhost:${PORT}/health 2>/dev/null)
[ "$H" = "ok" ] && echo "Health    : ✅ OK" || echo "Health    : ❌ DOWN"
RESTART=$(docker inspect -f "{{.HostConfig.RestartPolicy.Name}}" mhrv-tunnel 2>/dev/null)
echo "Restart   : $RESTART"
ERRS=$(docker logs --tail 50 mhrv-tunnel 2>&1 | grep -i "error\|panic" | tail -3)
[ -n "$ERRS" ] && echo "آخرین خطا: $ERRS" || echo "لاگ خطا  : ✅ تمیز"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
