#!/bin/zsh
# usage: design/tools/shoot_app.sh <label> [round_dir]   (round_dir default: results/current)
# Boots <round>/work/<label>/benchapp on PORT 4099 (dev env), captures screenshots into
# <round>/screenshots/<label>-*.png via cdp_shoot.py, then stops the server it started.
# Refuses to run if something else already holds 4099. Never kills a foreign process.
set -u
setopt null_glob
LABEL=$1
SELF=${0:A}
ROOT=${SELF:h:h:h}
ROUND=${2:-$ROOT/results/current}
APP=$ROUND/work/$LABEL/benchapp
OUT=$ROUND/screenshots
LOGDIR=${TMPDIR:-/tmp}
LOG=$LOGDIR/benchapp-server-$LABEL.log
export PORT=4099 MIX_ENV=dev
mkdir -p $OUT

if lsof -nP -iTCP:4099 -sTCP:LISTEN >/dev/null 2>&1; then echo "port 4099 busy:"; lsof -nP -iTCP:4099 -sTCP:LISTEN; exit 2; fi
cd $APP || { echo "no app at $APP"; exit 3; }
mix ecto.create --quiet 2>&1 | tail -2
mix phx.server > $LOG 2>&1 &
SPID=$!
echo "server pid $SPID (log: $LOG)"
up=0
for i in $(seq 1 60); do
  code=$(curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:4099/ || true)
  if [ "$code" = "200" ]; then echo "up after ${i}x2s"; up=1; break; fi
  sleep 2
done
if [ $up = 0 ]; then echo "SERVER DID NOT COME UP"; tail -30 $LOG; kill $SPID; exit 4; fi

rm -f $OUT/$LABEL-*.png
python3 ${SELF:h}/cdp_shoot.py $LABEL $OUT

echo "stopping server $SPID"
kill -TERM $SPID 2>/dev/null; sleep 4; kill -KILL $SPID 2>/dev/null
sleep 1
lsof -nP -iTCP:4099 -sTCP:LISTEN >/dev/null 2>&1 && { echo "WARN port still held:"; lsof -nP -iTCP:4099 -sTCP:LISTEN; } || echo "port 4099 free"
echo "--- server log (errors/warnings):"; grep -in "error\|warn" $LOG | head -10
