#!/usr/bin/env python3
"""Export each agent session's per-round ledger from helm's dev database to
results/<round>/raw/rounds/<label>-<bench>.csv (stdlib + psql only).

usage: export_rounds.py [round_dir]   default: results/current
Reads the session_id from raw/phoenix-*.json (app), raw/design-*.json (site) and
raw/js_app-*.json (app); queries turn_usage.round_metrics for the session's
main-loop turn; writes one row per round. Columns match REALWORLD.md's method:
tok_s_end_to_end = completion / duration; tok_s_decode_est = (completion − 1) /
(duration − ttft), blank when there is no TTFT or no window.
"""
import csv, glob, json, os, subprocess, sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
ROUND = os.path.abspath(sys.argv[1]) if len(sys.argv) > 1 else os.path.join(ROOT, "results", "current")
RAW = os.path.join(ROUND, "raw"); OUT = os.path.join(RAW, "rounds"); os.makedirs(OUT, exist_ok=True)
DB = dict(user="postgres", password="postgres", host="localhost", db="helm_dev")
COLS = ["round", "prompt_tokens", "cached_tokens", "uncached_tokens", "completion_tokens", "reasoning_tokens",
        "ttft_ms", "duration_ms", "tok_s_end_to_end", "tok_s_decode_est"]

def fetch(session_id):
    sql = ("select to_json(round_metrics)::text from turn_usage where session_id = '%s' and kind = 'turn' "
           "order by inserted_at desc limit 1" % session_id)
    out = subprocess.run(["psql", "-U", DB["user"], "-h", DB["host"], "-d", DB["db"], "-Atc", sql],
                         env={**os.environ, "PGPASSWORD": DB["password"]}, capture_output=True, text=True, check=True)
    return json.loads(out.stdout.strip() or "[]")

for prefix, key, bench in [("phoenix", "app", "app"), ("design", "site", "design"), ("js_app", "app", "js_app")]:
    for f in sorted(glob.glob(os.path.join(RAW, f"{prefix}-*.json"))):
        r = json.load(open(f)); sid = (r.get(key) or {}).get("session_id")
        if not sid: continue
        rounds = sorted(fetch(sid), key=lambda m: m["round"])
        path = os.path.join(OUT, f"{r['label']}-{bench}.csv")
        with open(path, "w", newline="") as fh:
            w = csv.writer(fh); w.writerow(COLS)
            for m in rounds:
                p, c, comp = m.get("prompt_tokens") or 0, m.get("cached_tokens") or 0, m.get("completion_tokens") or 0
                d, t = m.get("duration_ms"), m.get("ttft_ms")
                e2e = round(comp * 1000 / d, 1) if d else ""
                dec = round((comp - 1) * 1000 / (d - t), 1) if isinstance(t, int) and d and comp > 1 and d - t > 0 else ""
                w.writerow([m["round"], p, c, p - c, comp, m.get("reasoning_tokens") or 0, t if t is not None else "", d, e2e, dec])
        print(f"wrote {os.path.relpath(path, ROOT)} ({len(rounds)} rounds)")
