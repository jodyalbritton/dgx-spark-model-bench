#!/usr/bin/env python3
"""Render RESULTS.md for one round from its raw/*.json (spark_bench.py) and raw/coding-*.json (helm).

usage: make_report.py [round_dir]   default: <benchmarks>/results/current
"""
import glob, json, os, sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
ROUND = os.path.abspath(sys.argv[1]) if len(sys.argv) > 1 else os.path.join(ROOT, "results", "current")
RAW = os.path.join(ROUND, "raw"); OUT = os.path.join(ROUND, "RESULTS.md")
ORDER = ["glm53-flash-exl3", "qwen38-flash-next-nvfp4", "dsv4-flash-vision-exp"]

def fmt(v, d=1):
    return "—" if v in (None, 0) else f"{v:,.{d}f}"

def load():
    runs = {}
    for f in sorted(glob.glob(f"{RAW}/*.json")):
        base = os.path.basename(f)
        if base.startswith(("coding-", "design-")) or base.endswith(".regrade.json"): continue  # helm benches load below
        r = json.load(open(f))
        if str(r.get("kind", "")).startswith("coding"):
            continue  # coding rows and their re-grades render in coding_section()
        runs[r["label"]] = r
    return [runs[k] for k in ORDER if k in runs] + [r for k, r in runs.items() if k not in ORDER]


def load_coding():
    runs = {}
    for f in sorted(glob.glob(f"{RAW}/coding-*.json")):
        if f.endswith(".regrade.json"): continue  # sibling re-grade files overlay the row below
        r = json.load(open(f)); runs[r["label"]] = r
    # A re-grade is the same app under the current oracle. When one exists it *is*
    # the score: the run-time grade was the harness's mistake, not the model's, so
    # the row carries the re-graded checks/scores (rounds, wall, tools stay the
    # run's own) and the provenance note below the table says what the oracle fix
    # changed. The as-graded file is never modified.
    for label, r in runs.items():
        f = f"{RAW}/coding-{label}.regrade.json"
        if not os.path.exists(f) or not r.get("app"): continue
        rg = json.load(open(f)); a = rg["app"]
        r["as_graded"] = {"checks": r["app"].get("checks", {}), "hidden_tests_sha": (r.get("harness") or {}).get("hidden_tests_sha")}
        r["regrade"] = rg
        r["app"].update(checks=a["checks"], scores=a.get("scores"), checks_passed=a["checks_passed"], checks_total=a["checks_total"],
                        screenshots=a.get("screenshots") or r["app"].get("screenshots"))
        r["summary"]["app_checks_passed"] = a["checks_passed"]; r["summary"]["app_checks_total"] = a["checks_total"]
    return [runs[k] for k in ORDER if k in runs] + [r for k, r in runs.items() if k not in ORDER]


def load_design():
    runs = {}
    for f in sorted(glob.glob(f"{RAW}/design-*.json")):
        if f.endswith(".regrade.json"): continue
        r = json.load(open(f)); runs[r["label"]] = r
    for label, r in runs.items():
        f = f"{RAW}/design-{label}.regrade.json"
        if os.path.exists(f) and r.get("site"):
            rg = json.load(open(f)); a = rg["site"]
            r["as_graded"] = {"checks": r["site"].get("checks", {})}; r["regrade"] = rg
            r["site"].update(checks=a["checks"], scores=a.get("scores"), checks_passed=a["checks_passed"], checks_total=a["checks_total"])
    return [runs[k] for k in ORDER if k in runs] + [r for k, r in runs.items() if k not in ORDER]


def load_review():
    """DESIGN_REVIEW scores, if the reviewer wrote review.json: {label: {line: mean, ...}}; and the vote, if vote.json exists."""
    out = {}
    for name in ("review", "vote"):
        f = f"{RAW}/review/{name}.json"
        out[name] = json.load(open(f)) if os.path.exists(f) else None
    return out


def secs(ms):
    return "—" if ms in (None, 0) else f"{ms/1000:,.0f}"


def coding_section(L):
    runs = load_coding()
    if not runs:
        return
    L.append("\n## Coding (helm agent) — the helm coding bench\n")
    L.append("Harness: `Helm.Evals.Coding` on the dev seat, one session per task through helm's real tool loop "
             "(memory off, MCP off, consult denied). **Fixtures** = seeded-bug modules graded by hidden ExUnit tests. "
             "**App** = the landing-site prompt, graded by a mechanical checklist: source checks, hidden LiveView tests copied in at grade time, "
             "and rendered checks through helm's own headless Chrome after a real boot on the bench port — no LLM judge. "
             "Uncached prompt = prompt − prefix-cache hits, the spend that costs compute. Failures: *refused* = helm said no (trust/approval/surface); "
             "*failed* = the model's own command or edit went wrong. Outcome: *done* = the model replied; *max_rounds* = the round cap ended the turn "
             "(graded on what was on disk); *timeout* = the deadline did; *abandoned* = the model's reply announced a next step or was blank, once nudged, and still was not a summary. "
             "Reasoning tokens prefixed `~` are estimated from the reasoning text (the backend reported no counter); *none seen* = the backend reported no counter and no reasoning text reached helm — either the model did not think (GLM: completion tokens match the visible text at both grades) or the channel is not surfaced (DeepSeek before its 2026-09-05 reload).\n")
    L.append("Every row below ran on one harness; the constants are written into each run's JSON:\n")
    for r in runs:
        h = r.get("harness")
        if not h:
            L.append(f"- **{r['label']}** — helm `{r.get('helm_sha','?')}`, pre-harness run (no `harness` block)")
            continue
        L.append(f"- **{r['label']}** — helm `{r.get('helm_sha','?')}`{' (dirty tree)' if r.get('helm_dirty') else ''}, prompt `{h.get('prompt_sha', '?')}`, "
                 f"round caps {h['fixture_rounds_cap']} (fixture) / {h['app_rounds_cap']} (app), "
                 f"deadlines {secs(h['fixture_deadline_ms'])}/{secs(h['app_deadline_ms'])} s, effort {h.get('effort', 'not set (template default)')}, PORT={h['port']}, memory {h['memory']}, tools {h['tools']}, "
                 f"{len(h.get('wire_tools', []))} tools on the wire, warm fixture {h.get('warm_fixture', 'none')}, "
                 f"{r['started_utc']} → {r.get('finished_utc') or '(running)'}")
    L.append("")
    L.append("### Quality\n")
    SOURCE = ["compile", "test", "lint", "countdown", "nav", "layout_replaced", "tests_added", "composite_registered"]
    BEHAVIOUR = ["tick", "signup", "about", "stats", "activity", "boots", "mobile_nav", "theme_toggle_mobile", "dark_theme", "tick_rendered"]
    L.append("| model | fixtures | easy | medium | hard | app checks | source: compile · test · lint · countdown · nav · layout · tests+ · composite+ | behaviour: tick · signup · about · stats · activity · boots · mobile nav · theme@390 · dark · 98@12s | scores |")
    L.append("|---|---:|---:|---:|---:|---:|---|---|---|")
    for r in runs:
        s = r["summary"]; b = s.get("by_band", {}); app = r.get("app") or {}; ch = app.get("checks", {}); sc = app.get("scores") or {}
        def band(k):
            v = b.get(k); return "—" if not v else f"{v['passed']}/{v['total']}"
        def glyphs(keys):
            return " · ".join("✅" if ch.get(k, {}).get("pass") else ("❌" if k in ch else "—") for k in keys)
        scores = (f"lint warnings {sc.get('lint_warnings', '—')} · tests +{sc.get('tests_added', '—')} · components +{sc.get('components_added', '—')}"
                  if sc else "—")
        appc = f"{s['app_checks_passed']}/{s['app_checks_total']}" if s.get("app_checks_total") else "—"
        L.append(f"| {r['label']} | {s['fixtures_passed']}/{s['fixtures_total']} | {band('easy')} | {band('medium')} | {band('hard')} | {appc} | {glyphs(SOURCE)} | {glyphs(BEHAVIOUR)} | {scores} |")
    L.append("")
    L.append("Checks with `—` did not exist on that run's harness. Screenshots per app: `screenshots/<label>-{desktop-light,desktop-dark,full-light,mobile-light,mobile-full-light,desktop-light-after-12s}.png`.")
    # provenance for re-graded rows: which oracle, and what its fix changed
    regraded = [r for r in runs if r.get("regrade")]
    if regraded:
        L.append("")
        L.append("Oracle provenance — a later oracle fixed a harness mistake, and the row above is the app under that oracle (`raw/coding-<label>.regrade.json`; the run-time file is untouched):\n")
        for r in regraded:
            rg = r["regrade"]; before = r["as_graded"]["checks"]; after = rg["app"]["checks"]
            fixed = [k for k in sorted(after) if k in before and not before[k].get("pass") and after[k].get("pass")]
            broke = [k for k in sorted(after) if k in before and before[k].get("pass") and not after[k].get("pass")]
            note = f"- **{r['label']}** — graded under hidden tests `{rg.get('hidden_tests_sha','?')}` on helm `{rg.get('helm_sha','?')}` (run-time oracle `{r['as_graded'].get('hidden_tests_sha','?')}`)"
            if fixed: note += f"; the oracle fix corrected: {', '.join(fixed)}"
            if broke: note += f"; regressed under the new oracle: {', '.join(broke)}"
            if not fixed and not broke: note += "; no check changed"
            L.append(note)
    L.append("")
    L.append("### Speed\n")
    L.append("| model | fixtures wall (s) | median fixture (s) | app wall (s) | app rounds | green at | app tool calls | tool time (s) | files touched | app TTFT (s) | app completion tok/s |")
    L.append("|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|")
    for r in runs:
        fx = r["fixtures"]; app = r.get("app") or {}
        walls = sorted(f["wall_ms"] for f in fx)
        med = walls[len(walls)//2] if walls else None
        # T31/T33: the finish line, tool time and the diff against the reference generation — absent before
        green = f"R{app['green_at']} (+{app.get('rounds_after_green', 0)})" if app.get("green_at") else ("—" if "green_at" in app else "n/a")
        tool_time = secs(app.get("tool_time_ms")) if app.get("tool_time_ms") is not None else "n/a"
        diff = app.get("diff") or {}
        touched = f"{diff['files']} (+{diff.get('insertions', 0)}/−{diff.get('deletions', 0)})" if diff.get("files") is not None else "n/a"
        L.append(f"| {r['label']} | {secs(r['summary']['fixtures_wall_ms'])} | {secs(med)} | {secs(app.get('wall_ms'))} | "
                 f"{app.get('rounds', '—')} | {green} | {app.get('tool_calls', '—')} | {tool_time} | {touched} | {secs(app.get('ttft_ms'))} | {fmt(app.get('completion_tok_s'))} |")
    L.append("")
    L.append("### Spend (tokens)\n")
    L.append("| model | fixtures uncached prompt | fixtures completion | fixtures reasoning | app prompt | app cached | app uncached prompt | app completion | app reasoning |")
    L.append("|---|---:|---:|---:|---:|---:|---:|---:|---:|")
    def reasoning_cell(rows):
        # T24: the backend's counter where reported, else bytes/4 of the reasoning text, marked ~
        rows = [r for r in rows if r]
        if not rows or all(r.get("reasoning_tokens") is None for r in rows): return "—"
        total = sum(r.get("reasoning_tokens") or 0 for r in rows)
        if all(r.get("reasoning_reported") for r in rows): return fmt(total, 0)
        # no counter and no reasoning text at all: the channel is not surfaced, not "zero reasoning"
        return "none seen" if total == 0 else "~" + fmt(total, 0)
    def cache_cell(row, key):
        # T23: a backend that never emits the counter is "not reported", not 0 and not blank
        if row.get("cached_reported") is False or row.get(key) is None:
            return "not reported" if row else "—"
        return fmt(row.get(key), 0)
    for r in runs:
        fx = r["fixtures"]; app = r.get("app") or {}
        fx_unc = "not reported" if any(f.get("uncached_prompt_tokens") is None for f in fx) else fmt(sum(f["uncached_prompt_tokens"] for f in fx), 0)
        L.append(f"| {r['label']} | {fx_unc} | {fmt(sum(f['completion_tokens'] for f in fx), 0)} | {reasoning_cell(fx)} | "
                 f"{fmt(app.get('prompt_tokens'), 0)} | {cache_cell(app, 'cached_tokens')} | {cache_cell(app, 'uncached_prompt_tokens')} | {fmt(app.get('completion_tokens'), 0)} | {reasoning_cell([app])} |")
    L.append("")
    L.append("### Failures and tool mix\n")
    L.append("| model | fixtures refused/failed | fixtures capped/timed out/abandoned | app outcome (ending, nudges) | app refused/failed | app tools | app failures |")
    L.append("|---|---:|---:|---|---:|---|---|")
    for r in runs:
        fx = r["fixtures"]; app = r.get("app") or {}; s = r["summary"]
        fr = sum(f.get("refused", 0) for f in fx); ff = sum(f.get("failed", 0) for f in fx)
        capped = f"{s.get('fixtures_capped', '—')}/{s.get('fixtures_timed_out', '—')}/{s.get('fixtures_abandoned', '—')}"
        outcome = app.get('outcome', '—') + (f" ({app['ending']}, {app.get('nudges', 0)} nudge{'s' if app.get('nudges', 0) != 1 else ''})" if app.get('ending') else "")
        if app.get('last_call'):  # T26: the short turn after the cap — its ending is the row's ending
            lc = app['last_call']; outcome += f"; last call {lc.get('outcome')} in {lc.get('rounds')} round{'s' if lc.get('rounds') != 1 else ''}"
        tools = ", ".join(f"{k} {v}" for k, v in sorted((app.get("tools") or {}).items(), key=lambda kv: -kv[1]))
        fails = "; ".join(f"{f['tool']} ({f['class']}): {' '.join(f['text'].split())[:60]}" for f in app.get("failures", [])) or "—"
        L.append(f"| {r['label']} | {fr}/{ff} | {capped} | {outcome} | {app.get('refused', '—')}/{app.get('failed', '—')} | {tools or '—'} | {fails} |")
    L.append("")
    failed = [(r["label"], f["name"], f["band"], f.get("outcome", "done")) for r in runs for f in r["fixtures"] if not f["pass"]]
    if failed:
        L.append("Fixtures failed: " + ", ".join(f"{l}: {n} ({b}, {o})" for l, n, b, o in failed) + "\n")
    L.append("Raw JSON per run (per-fixture rows, app checklist detail, final answers): `raw/coding-<label>.json`; "
             "the generated app itself stays under `work/<label>/`. Prompts, session policy, oracle methods and caveats, as run: `design/CODING_BENCH.md`.\n")

def server_line(r):
    m = (r.get("server", {}).get("models") or {}).get("data") or [{}]
    slot = (r.get("agent_slots") or {}).get("slots") or [{}]
    s = slot[0] if slot else {}
    prof = s.get("profile") or {}
    return (f"model `{r['model']}` · max_model_len {m[0].get('max_model_len','?'):,} · "
            f"engine {s.get('engine_build') or (r.get('server',{}).get('version') or {}).get('version','?')} · "
            f"image `{prof.get('image','?')}` · ctx {s.get('ctx','?')} · parallel {s.get('parallel','?')} · tp {s.get('tp_size','?')}")

GATES_STATIC = ["compile", "test", "lint", "layout_replaced", "page_tests", "composite_registered", "composite_reused", "theme_pair"]
GATES_RENDERED = ["boots", "routes", "demo_gone", "nav_current", "no_overflow", "contrast", "icons_resolve", "copy_clean", "mobile_nav", "theme_toggle_mobile", "dark_theme"]
RUBRIC = ["Identity", "Hierarchy and rhythm", "Type", "Colour and themes", "Phone", "Copy", "Restraint", "Composite"]


def design_section(L):
    runs = load_design()
    if not runs:
        return
    L.append("\n## Front-end design (helm design bench)\n")
    L.append("Harness: `Helm.Evals.Design` — one brief (the JobyCorp website), one `DESIGN.md`, a prepared JobyKit base per round, one session per model at its ceiling effort. "
             "Two layers, never blended: **gates** are mechanical, pass/fail, decided by the harness; **ranking** is the rubric scored by the reviewer from anonymised composites (three shuffled passes, mean), and the public vote on the same images. "
             "Protocol: `design/DESIGN_BENCH.md`.\n")
    L.append("Every row ran on one harness:\n")
    for r in runs:
        h = r.get("harness") or {}
        L.append(f"- **{r['label']}** — helm `{r.get('helm_sha','?')}`{' (dirty tree)' if r.get('helm_dirty') else ''}, brief `{h.get('prompt_sha','?')}`, DESIGN.md `{h.get('design_sha','?')}`, base `{h.get('base_sha','?')}` (joby_kit {h.get('joby_kit_version','?')}), "
                 f"effort {h.get('effort','?')}, vision {h.get('vision', 'describe')} ({h.get('vision_model','?')}), digest {h.get('digest_mode', 'gate')}, "
                 f"bash approval {(h.get('approvals') or {}).get('bash', 'seat default')}, browser {(h.get('browser') or {}).get('viewport', '?')}/{(h.get('browser') or {}).get('scheme', '?')}, "
                 f"cap {h.get('site_rounds_cap','?')} rounds / {secs(h.get('site_deadline_ms'))} s, {r['started_utc']} → {r.get('finished_utc') or '(running)'}")
    L.append("")
    L.append("### Gates\n")
    L.append("| model | gates | static (8) | rendered (11) | scores |")
    L.append("|---|---:|---|---|---|")
    for r in runs:
        site = r.get("site") or {}; ch = site.get("checks", {}); sc = site.get("scores") or {}
        def glyphs(keys):
            return " · ".join("✅" if ch.get(k, {}).get("pass") else ("❌" if k in ch else "—") for k in keys)
        scores = f"tests +{sc.get('tests_added','—')} · components +{sc.get('components_added','—')} · reused {sc.get('composites_reused','—')} · lint warnings {sc.get('lint_warnings','—')}" if sc else "—"
        L.append(f"| {r['label']} | {site.get('checks_passed','—')}/{site.get('checks_total','—')} | {glyphs(GATES_STATIC)} | {glyphs(GATES_RENDERED)} | {scores} |")
    L.append("")
    L.append("Static gates, in order: " + ", ".join(GATES_STATIC) + ". Rendered gates, in order: " + ", ".join(GATES_RENDERED) + ".")
    L.append("")
    fails = []
    for r in runs:
        ch = (r.get("site") or {}).get("checks", {})
        for k in GATES_STATIC + GATES_RENDERED:
            v = ch.get(k)
            if v and not v.get("pass"):
                fails.append(f"- **{r['label']}** `{k}`: {' '.join(str(v.get('detail','')).split())[:240].replace('|', '·')}")
    if fails:
        L.append("Failed gates, as the harness saw them:\n"); L.extend(fails); L.append("")
    regraded = [r for r in runs if r.get("regrade")]
    if regraded:
        L.append("Oracle provenance — the row is the site under the later gates (`raw/design-<label>.regrade.json`; the run-time file is untouched):\n")
        for r in regraded:
            before = r["as_graded"]["checks"]; after = r["regrade"]["site"]["checks"]
            fixed = [k for k in sorted(after) if k in before and not before[k].get("pass") and after[k].get("pass")]
            broke = [k for k in sorted(after) if k in before and before[k].get("pass") and not after[k].get("pass")]
            L.append(f"- **{r['label']}** — helm `{r['regrade'].get('helm_sha','?')}`" + (f"; corrected: {', '.join(fixed)}" if fixed else "") + (f"; regressed: {', '.join(broke)}" if broke else "") + ("; no check changed" if not fixed and not broke else ""))
        L.append("")
    review = load_review()
    L.append("### Ranking\n")
    if review["review"]:
        rv = review["review"]; vote = review["vote"] or {}
        L.append("| model | " + " | ".join(RUBRIC) + " | mean | X vote |")
        L.append("|---|" + "---:|" * (len(RUBRIC) + 2))
        for r in runs:
            row = rv.get(r["label"]) or {}
            vals = [row.get(line) for line in RUBRIC]
            mean = sum(v for v in vals if v is not None) / max(1, len([v for v in vals if v is not None])) if any(v is not None for v in vals) else None
            L.append(f"| {r['label']} | " + " | ".join(f"{v:.1f}" if isinstance(v, (int, float)) else "—" for v in vals) + f" | {mean:.2f} | {vote.get(r['label'], '—')} |" if mean is not None else f"| {r['label']} | " + " | ".join("—" for _ in RUBRIC) + f" | — | {vote.get(r['label'], '—')} |")
        L.append("")
        L.append("Rubric 1–5 per line, three shuffled passes, mean; the reviewer's prose is `DESIGN_REVIEW.md`. The X vote is recorded when it closes (`raw/review/vote.json`).")
    else:
        L.append("_Not yet reviewed: `Helm.Evals.Design.review_pack()` seals the key and renders `screenshots/review/{A,B,C}.png`; the reviewer writes `DESIGN_REVIEW.md` and `raw/review/review.json` (`{label: {line: score}}`) after the key is opened; `raw/review/vote.json` (`{label: votes}`) records the X vote._")
    L.append("")
    L.append("### Speed and tokens\n")
    L.append("| model | outcome (ending, nudges) | rounds | green at | wall (s) | tool time (s) | tool calls | files touched | uncached prompt | completion | reasoning | tools |")
    L.append("|---|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---|")
    for r in runs:
        site = r.get("site") or {}
        outcome = site.get("outcome", "—") + (f" ({site['ending']}, {site.get('nudges', 0)} nudge{'s' if site.get('nudges', 0) != 1 else ''})" if site.get("ending") else "")
        if site.get("last_call"):
            lc = site["last_call"]; outcome += f"; last call {lc.get('outcome')} in {lc.get('rounds')} round{'s' if lc.get('rounds') != 1 else ''}"
        tools = ", ".join(f"{k} {v}" for k, v in sorted((site.get("tools") or {}).items(), key=lambda kv: -kv[1]))
        # T31: the finish line, the tool time, the diff — absent on rounds before helm T31
        green = f"R{site['green_at']} (+{site.get('rounds_after_green', 0)})" if site.get("green_at") else ("—" if "green_at" in site else "n/a")
        tool_time = secs(site.get("tool_time_ms")) if site.get("tool_time_ms") is not None else "n/a"
        diff = site.get("diff") or {}
        touched = f"{diff['files']} (+{diff.get('insertions', 0)}/−{diff.get('deletions', 0)})" if diff.get("files") is not None else "n/a"
        L.append(f"| {r['label']} | {outcome} | {site.get('rounds','—')} | {green} | {secs(site.get('wall_ms'))} | {tool_time} | {site.get('tool_calls','—')} | {touched} | {site.get('uncached_prompt_tokens') if site.get('uncached_prompt_tokens') is not None else 'not reported'} | {site.get('completion_tokens','—')} | {site.get('reasoning_tokens','—')} | {tools or '—'} |")
    L.append("")
    L.append("*green at* = the round at which `mix precommit` was last green and `joby_kit.lint` last clean (the brief's finish line), and how many rounds followed; *tool time* = wall time inside tool calls; *files touched* = the model's diff against the staged base (`raw/diff-<label>.patch`).")
    L.append("")
    L.append("Screenshots per site: `screenshots/<label>-{home,research,about}-{light,dark}-{desktop,phone}.png`; the anonymised composites in `screenshots/review/`.")


def main():
    runs = load(); L = []
    round_name = os.path.basename(os.path.realpath(ROUND))
    L.append(f"# DGX Spark cluster (sparky + sparky2, TP=2) — model benchmarks, round `{round_name}`\n")
    L.append(f"Rendered by `design/make_report.py` from `results/{round_name}/raw/`. Protocol: `design/TESTPLAN.md`; coding-bench methods: `design/CODING_BENCH.md`; the run log for this round: `RUNLOG.md`.\n")
    if not runs:
        L.append("_Phase A (inference: `spark_bench.py`) was not run in this round; the inference tables are omitted._\n")
    inference = L.copy()  # marker: everything appended below until the coding section is Phase A
    L.append("Harness: `spark_bench.py` run on sparky against the head node over loopback. "
             "Decode rows use thinking off, `temperature 0.6`, fixed 128-token output (`min_tokens=max_tokens=128`, `ignore_eos`). "
             "TTFT = first streamed token (content or reasoning). Prefill tok/s = prompt tokens / TTFT. "
             "Decode tok/s = 128 / (end − first token). Prompts are unique per request (no prefix-cache hits). "
             "Reasoning probe: greedy (`temperature 0`), thinking on, one question, correctness checked against the known answer.\n")
    L.append("## Runs\n")
    for r in runs:
        L.append(f"- **{r['label']}** — {r['started_utc']} → {r.get('finished_utc','(running)')} — {server_line(r)}")
    L.append("")
    # c=1 tables per metric
    sizes = sorted({c["target_prompt_tokens"] for r in runs for c in r["cases"] if c.get("concurrency") == 1})
    def cell(r, s, key, d=1):
        for c in r["cases"]:
            if c.get("concurrency") == 1 and c["target_prompt_tokens"] == s:
                return "FAIL" if "error" in c else fmt(c.get(key), d)
        return "—"
    for title, key, d in [("Time to first token (s), c=1", "median_ttft_s", 2),
                          ("Prefill throughput (prompt tok/s), c=1", "median_prefill_tok_s", 0),
                          ("Decode throughput (tok/s per stream), c=1", "median_decode_tok_s", 1)]:
        L.append(f"## {title}\n")
        L.append("| prompt tokens | " + " | ".join(r["label"] for r in runs) + " |")
        L.append("|---:|" + "---:|" * len(runs))
        for s in sizes:
            L.append(f"| {s:,} | " + " | ".join(cell(r, s, key, d) for r in runs) + " |")
        L.append("")
    # concurrency
    L.append("## Concurrency (c>1): output tok/s over the whole wall (prefill included) · per-stream decode tok/s · median TTFT\n")
    L.append("| prompt tokens | c | " + " | ".join(r["label"] for r in runs) + " |")
    L.append("|---:|---:|" + "---:|" * len(runs))
    keys = sorted({(c["target_prompt_tokens"], c["concurrency"]) for r in runs for c in r["cases"] if c.get("concurrency", 1) > 1})
    for s, cc in keys:
        row = []
        for r in runs:
            m = [c for c in r["cases"] if c.get("concurrency") == cc and c["target_prompt_tokens"] == s]
            row.append("—" if not m else ("FAIL" if "error" in m[0] else
                       f"{fmt(m[0]['aggregate_decode_tok_s'])} wall · {fmt(m[0]['median_decode_tok_s'])}/stream · {fmt(m[0]['median_ttft_s'],2)} s"))
        L.append(f"| {s:,} | {cc} | " + " | ".join(row) + " |")
    L.append("")
    # probe
    L.append("## Reasoning probe (thinking on, greedy)\n")
    q = next((r["probe"]["question"] for r in runs if r.get("probe") and "question" in r["probe"]), "")
    L.append(f"Question: _{q}_ Expected answer: **301**.\n")
    L.append("| model | correct | reasoning tokens | answer tokens | total completion | wall time (s) | decode tok/s | finish |")
    L.append("|---|:---:|---:|---:|---:|---:|---:|---|")
    for r in runs:
        p = r.get("probe") or {}
        if "error" in p or not p: L.append(f"| {r['label']} | FAIL | | | | | | {p.get('error','')[:60]} |"); continue
        L.append(f"| {r['label']} | {'✅' if p['correct'] else '❌'} | {p['reasoning_tokens']:,} | {p['answer_tokens']:,} | "
                 f"{p['completion_tokens']:,} | {p['elapsed_s']:.1f} | {fmt(p['decode_tok_s'])} | {p['finish_reason']} |")
    # no inference rows → drop the Phase A sections entirely (the header
    # above already says so) rather than print six empty tables
    if not runs:
        L = inference
    # the coding section renders whenever coding rows exist — Phase B may
    # finish before Phase A in a round (TESTPLAN §6: no round-specific
    # strings here; notes live in the per-run JSON `notes` field)
    coding_section(L)
    design_section(L)
    notes = [(r["label"], r["notes"]) for r in runs if r.get("notes")]
    if notes:
        L.append("\n## Notes\n")
        for label, n in notes: L.append(f"- **{label}**: {n}")
    if runs:
        L.append("\nRaw JSON per inference run (full per-request records, reasoning and answer text): `raw/<label>.json`.\n")
    open(OUT, "w").write("\n".join(L) + "\n"); print(f"wrote {OUT}")

if __name__ == "__main__": main()
