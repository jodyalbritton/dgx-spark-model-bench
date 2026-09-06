# Benchmark test plan — DGX Spark cluster, repeatable protocol

Status: draft for the second round, written 2026-09-04 after the first round
(`REPORT.md`, `DESIGN_REVIEW.md`). The first round's inference prompts and
warm-up were improvised in a Claude Code session; this document fixes the
protocol so the next round, and every round after it, is run the same way and
can be compared row for row.

## 0. Folder layout

```
benchmarks/
  README.md          layout and the short version of this plan
  design/            what a round IS: this plan, CODING_BENCH.md, spark_bench.py,
                     make_report.py, tools/, corpus/ — stable across rounds
  results/
    current ->       symlink to the round being run; every harness writes here
    <round>/         one directory per round, named by date (YYYY-MM-DD[-suffix])
      RUNLOG.md      the run log (§7)
      RESULTS.md     rendered by design/make_report.py
      REPORT.md, DESIGN_REVIEW.md   hand-written
      raw/  work/  screenshots/     harness output
```

Starting a round: `mkdir results/<round>` and repoint the symlink
(`ln -sfn <round> results/current`). Nothing under `design/` changes during a
round; nothing under `results/<round>/` is edited by hand except the three
markdown files. Finished rounds are never overwritten.

Three phases, run in order per model, one model loaded at a time:

| phase | harness | output | doc |
|---|---|---|---|
| A. inference | `design/spark_bench.py` | `raw/<label>.json`, `raw/<label>.log` | this file, §3 |
| B. coding (helm agent) | `Helm.Evals.Coding` | `raw/coding-<label>.json`, `work/<label>/benchapp` | `design/CODING_BENCH.md` + this file, §4 |
| C. app capture | `design/tools/shoot_app.sh` | `screenshots/<label>-*.png` | this file, §5 |

All output paths above are relative to `results/current/`. Then
`python3 design/make_report.py` renders `RESULTS.md`, and the hand-written
`REPORT.md` / `DESIGN_REVIEW.md` are updated from the raw files (§6).

Items marked **DECIDE** are choices the operator has to make before the run
and record in the run log; the plan does not pick them.

## 1. Ground rules

1. **One harness version per round.** Pin one helm SHA and one
   `spark_bench.py` for all models in a round. Record both in the run log
   (§7). If either changes mid-round, the round restarts.
2. **Raw files are append-only.** Never patch a value inside
   `raw/<label>.json` by hand. A re-run gets its own file with its own
   label (for example `dsv4-flash-vision-exp-warm2`) and the report notes
   which file feeds which row. The first round lost the provenance of the
   DeepSeek warm re-run exactly this way (`REPORT.md` §5, item 1).
   `make_report.py` keys runs by `label`, so two files with the same label
   silently overwrite each other; unique labels are mandatory.
3. **Same warm-up for every model.** Whatever is warmed for one model is
   warmed for all three (§3.3). No model gets a cold first row while another
   gets a warm one.
4. **Record the host state.** Before each model: what else is running on the
   head node (containers, downloads), and what was paused for the run. The
   first round paused a container (`blissful_elion`) for Qwen only, noted
   only by two stray log lines.
5. **Timestamps in UTC everywhere.** The `.log` files currently print local
   time (`time.strftime("%H:%M:%S")`) while the JSON is UTC. Switch the log
   to `time.gmtime()` or accept the offset and say so in the run log.
6. **Nothing foreign on port 4099**, and never kill a process the harness did
   not start. Same rule as `CODING_BENCH.md`.

## 2. Pre-flight per model

Run through this list and paste the answers into the run log before Phase A.

- [ ] Model loaded via airo_agent `POST /load` with the payload named in the
      log. GLM was the "pre-existing agent load" last time; load it through
      the same path as the others so the payload is on record.
- [ ] `GET /v1/models` and `GET /version` captured (spark_bench.py does this
      into the JSON's `server` block; check it is not `{"error": …}`).
- [ ] `GET /slots` on airo_agent captured (the `agent_slots` block). This is
      where the launch argv lives; the following flags are checked against
      it:
  - `--enable-prefix-caching` present (or the engine's documented default
    is on).
  - `--enable-prompt-tokens-details` present. This is the flag that puts
    `prompt_tokens_details.cached_tokens` in every usage block. Only the
    DeepSeek profile had it in the first round, which is why the cached
    column was blank for GLM and Qwen. Without it the spend columns are not
    comparable and the round should not start.
  - `--max-num-batched-tokens` — **DECIDE**: align all three (the first round
    ran GLM at 2048 and the others at 8192, which serialised GLM's
    concurrent prefills), or keep each engine's tuned value and label the
    concurrency rows as "as deployed". Either is fine; mixing without saying
    so is not.
  - `--speculative-config` recorded verbatim (method and token count).
- [ ] **Reasoning effort is explicit.** helm must be at or after S35
      (`Helm.Effort`, commit `5d68e49`) so `reasoning_effort` is actually
      sent; every bench session sets `policy["effort"]`; the grade is
      recorded in the run log and, once the harness writes it, in the
      `harness` block. Rounds 1 and 2 sent nothing and ran Qwen at
      `xhigh`, DeepSeek at `low`, and GLM with thinking off. **DECIDE**
      the grade(s) for the round. Note what each template does with a
      grade: GLM accepts only `low`/`high` and turns anything else into
      `max`, and `low` collapses its thinking to near zero; Qwen accepts
      `low`/`medium`/`xhigh`; DeepSeek accepts `low`/`high`/`max` and turns
      anything else into `low`. `medium` is therefore not a level field;
      `low` and `high` are.
- [ ] **Thinking is actually on.** `reasoning_effort` does not enable
      thinking on every template. GLM's needs
      `chat_template_kwargs.enable_thinking: true`, set in the airo
      deployment's request defaults (rounds 1 to 3 ran GLM with thinking
      off because it was not). Before each model's run, one helm-shaped
      probe through `Helm.Airo.stream` must return a non-empty reasoning
      field and a correct answer to a small trap question; record both in
      the run log.
- [ ] **Effort ladder probe** on the loaded model: the round-1 probe
      question at each grade the template accepts, reasoning tokens
      recorded (`design/tools/effort_probe.py`; DeepSeek's ladder from
      2026-09-05 is in `results/2026-09-04-r2/REPORT.md` §5 item 11).
- [ ] Head node otherwise idle; anything paused is named in the run log.
- [ ] helm dev server restarted after any config change, and
      `harness.system_prompt` in the first fixture row checked against what
      the config says. The first round's "working method" paragraph was
      never sent because the server was not restarted (`CODING_BENCH.md`,
      "The system prompt (as run)").
- [ ] Port 4099 free (`lsof -nP -iTCP:4099 -sTCP:LISTEN` prints nothing).
- [ ] `results/current` points at this round's directory, and the helm
      harness output root is `~/benchmarks/results/current` (§4.1, item 0).
- [ ] `benchapp_dev` and `benchapp_test` dropped. `work/<label>/` is wiped
      by the coding harness inside the current round only; previous rounds'
      apps are untouched under their own `results/<round>/work/`.

## 3. Phase A — inference (`spark_bench.py`)

### 3.1 What stays the same

Sizes 256 / 2,048 / 8,192 / 32,768 / 65,536 / 102,400 / 153,600 tokens at
c=1. Thinking off, `temperature 0.6`, `top_p 0.95`, fixed 128-token output
(`min_tokens = max_tokens = 128`, `ignore_eos`). TTFT = first streamed token
(content or reasoning). Prefill tok/s = prompt tokens / TTFT. Decode tok/s =
128 / (end − first token). The reasoning probe (301 question, greedy,
thinking on) stays as the smoke test. One request per size at c=1 is enough
for prefill and TTFT, which were stable to a few percent across sizes.

### 3.2 What changes

**Prompt corpus.** The first round's filler was one phrase repeated
("benchmark context datum "), which makes the decode rows a measure of how
well the draft model predicts repetition (`REPORT.md` §5, item 2). Replace
it with natural text:

- **DECIDE** the source. Requirements: plain prose, English, license-free,
  large enough to cut 160k tokens without repeating, checked into
  `design/corpus/` so the round is reproducible from this folder. The nonce
  line stays at the head of every prompt so prefix caching still misses.
- `build_prompt` changes from "repeat a unit n times" to "take the first n
  characters of the corpus, then trim to the token target". The calibration
  loop (six passes against `/tokenize`) can stay.

**Decode rows, twice.** Speculative decoding is a launch flag, so isolating
it means a second load per model:

- **DECIDE** whether to pay for it this round. If yes: after the main run,
  reload the model with `--speculative-config` removed, run only the c=1
  decode rows (`--sizes 256,8192,65536`, `--conc-sizes ""`, skip the probe),
  label `<label>-nospec`. If no: keep the spec-on numbers and the report
  keeps the caveat.

**Concurrency.** Add c=2 and c=8 at 8,192 tokens so scaling is a curve.
This needs `--conc` to accept a list (currently one integer) or three
invocations with `--sizes ""`. Each c=N case must fit the engine's
`parallel` slot count (GLM 4, DeepSeek 6, Qwen 8 last round); c=8 on GLM
or DeepSeek will queue and should be reported as such, not as a slower
model.

**Log in UTC** (§1, item 5).

### 3.3 Warm-up (identical for all models)

The first round warmed only DeepSeek's short rows, after the fact. Fixed
protocol:

1. The existing `warmup` request (32 tokens) runs once.
2. Then every prompt shape in the run is issued once and discarded: each
   c=1 size, each c=N batch shape. That is one extra pass through the size
   list. At last round's rates this costs about 6 minutes on GLM, 3 on
   DeepSeek, 2.5 on Qwen.
3. Only then does the measured pass start.

DeepSeek's documented FlashInfer autotune (8–12 s on the first request per
shape) is what step 2 absorbs; the same step absorbs whatever GLM and Qwen
pay on first shape, which the first round never measured.

`spark_bench.py` needs a `--warm-all-shapes` flag for step 2, or a wrapper
that runs the size list once with `--out /dev/null`. Either way the warm
pass is not written into the measured JSON.

### 3.4 Command

```
cd ~/benchmarks
python3 design/spark_bench.py --base-url http://127.0.0.1:8081 --model <airo id> \
  --label <label> --out results/current/raw/<label>.json --agent-url <airo_agent url> \
  --corpus design/corpus/<file> --warm-all-shapes 2>&1 | tee results/current/raw/<label>.log
```

(`--corpus` and `--warm-all-shapes` are the two additions described above;
they do not exist yet.)

### 3.5 Acceptance

- All c=1 rows have `finish_reason: length` and `completion_tokens: 128`.
- The JSON `server.version` and `agent_slots` blocks are populated.
- `usage.prompt_tokens_details.cached_tokens` is present (and 0) on every
  request, for every model. If it is missing, the flag in §2 was not
  applied.
- No `FAILED` line in the log.

## 4. Phase B — coding bench (`Helm.Evals.Coding`)

`CODING_BENCH.md` is the authoritative description of prompts, policy,
tools, oracle and checklist. It does not change except where listed here.

### 4.1 Harness changes before the round

0. **Output root.** The harness writes `raw/coding-<label>.json` and
   `work/<label>/` under `~/benchmarks/results/current/`, not under
   `~/benchmarks/` as in the first round. One path change in
   `lib/helm/evals/coding.ex`.
1. **Working-method system prompt in effect.** Restart helm after the config
   change and verify `harness.system_prompt` in the JSON (§2). This is a new
   harness and gets new rows; do not merge them with the first round's.
2. **Warm the model before the first fixture.** The first fixture last round
   carried DeepSeek's cold prefix cache (17 s TTFT vs 0.5 s median). Run one
   throwaway fixture (any, discarded, not written to the JSON) before the
   twelve measured ones. This mirrors the hex/build warm-up the harness
   already does for the app.
3. **Store the full final reply.** `final` is truncated to an unrecorded
   length and cut Qwen's actual one-line summary off. Store it whole, or at
   least the last line separately.
4. **Report "not reported" for cache counters** the backend does not emit,
   not 0. With the flag in §2 this should no longer arise, but the renderer
   should distinguish the two.
5. **Fix the `layout_replaced` detail string** in the fail branch (it reads
   "differs from the generator's stock nav+footer" on a fail; seen in the
   superseded run).
6. **Tell the session its cwd.** `CODING_BENCH.md` lists this as a queued
   one-line change; Qwen's `cd /home/conn/src/web` is the concrete case.

### 4.2 Fixture additions — **DECIDE** which to include

The twelve T08 fixtures were solved by every model, mostly in three rounds;
they no longer discriminate. Candidates that came out of the first round's
review (`REPORT.md` §4), each with a hidden test the current drafts would
fail:

| candidate | what it probes | first-round evidence |
|---|---|---|
| split_bill with negative totals | floored vs truncated division | GLM returned a wrong sum; Qwen and DeepSeek raised |
| safe_echo with `\n` literal and `-n` inputs | shell `echo` escape/flag handling | GLM/DeepSeek expand escapes; Qwen's `/bin/echo` eats `-n` |
| a fixture whose natural verification path is a stuck loop | recovery from a wrong test harness | GLM's lru_cache: 35 rounds on a fix it had in round 3 |
| a fixture whose `@moduledoc` contradicts an obvious reading | willingness to argue with the spec | the "complete specification" sentence exists because a model did this once |
| a fixture that needs a long-running command | `bash(background: true)` discipline | DeepSeek's six 30 s timeouts |

Any new fixture gets the same `solution.ex` + hidden `ExUnit` shape, a
band, and an entry in the `CODING_BENCH.md` table.

### 4.3 App checklist additions — **DECIDE** which to include

All current checks except `boots` are regex-only. Candidates, cheapest
first:

| check | method | pass when |
|---|---|---|
| tick | hidden `Phoenix.LiveViewTest` file copied in at grade time: `live(conn, "/")`, assert 100, `send(view.pid, :tick)`, assert 99 | test passes |
| new_test | any file under `test/` not present in a fresh `mix joby_kit.new` | at least one |
| lint_warnings | count from `mix joby_kit.lint` output | reported as a number, not pass/fail |
| mobile_nav | after `boots`, render at 390 px and check that a `<nav>` or a menu toggle is visible | see §5; can be automated from `design/tools/cdp_shoot.py` output |

None of the three first-round apps added a test, so `new_test` would have
scored 0/3 and is the sharpest of these.

### 4.4 Command

From helm's dev seat, per model, exactly as `CODING_BENCH.md`:

```
Helm.Evals.Coding.run(model: "<airo model id>", label: "<label>")
```

Then `python3 design/make_report.py`.

## 5. Phase C — app capture (`design/tools/shoot_app.sh`)

New this round. Boots the generated app on 4099 in the dev env, captures
it with headless Chrome over the DevTools protocol, stops it, and refuses
to start if anything else holds the port. One app at a time.

```
design/tools/shoot_app.sh <label>            # uses results/current
design/tools/shoot_app.sh <label> results/<round>   # any past round
```

Produces `screenshots/<label>-{desktop-light,desktop-dark,full-light,
mobile-light,mobile-full-light,desktop-light-after-11s}.png` and prints, per
shot, the resolved theme, whether the LiveView socket connected, the
countdown text, and the page height. The `after-11s` shot is the live-tick
proof: it must read 98 (two ticks at 5 s).

Requirements: Google Chrome at `/Applications/Google Chrome.app`, Postgres
up, `mix` on PATH, port 4099 free. No Python packages beyond the stdlib.

Acceptance per app: HTTP 200, `connected=True`, countdown `100` on the first
shot and `98` on the last, `nav=True`. Anything else is a `boots`-class
failure and goes in the design review as such.

The design review itself stays hand-written from the screenshots. The
prompt gives one design word ("modern"), so the review is a record, not a
score; if design is to be scored, the prompt (or a skill) has to say what
"modern" means first.

## 6. Reporting

1. `python3 design/make_report.py [round_dir]` regenerates that round's
   `RESULTS.md` from its `raw/*.json` and `raw/coding-*.json` (default
   round: `results/current`). Two of its notes ("Thinking
   control", "Load path") are hard-coded strings about the first round;
   move them into the per-run `notes` field of the JSON (the field the
   script already reads) or delete them before the next render, or they
   will describe a round that is no longer in the table.
2. `REPORT.md` and `DESIGN_REVIEW.md` are written per round from that
   round's raw files and screenshots and live beside them. Previous rounds
   keep theirs; there is nothing to archive.
3. `results/<round>/raw/superseded/` keeps out-of-protocol runs. Anything run under this
   plan that later turns out to be off-protocol moves there rather than
   being deleted.

## 7. Run log

One file per round, `results/<round>/RUNLOG.md`, filled in as you go. Minimum
contents, per model:

- label, airo model id, payload file, image, engine version, `parallel`,
  `max_model_len`, speculative config, batched-token budget (from
  `agent_slots`)
- helm SHA, `spark_bench.py` git or checksum, corpus file
- what was running/paused on the head node
- phase start/finish in UTC (A, B, C)
- any deviation from this plan, and why

## 8. Order and budget

Per model, from the first round's timings: load (unmeasured), Phase A
about 5 to 8 minutes plus the warm pass (§3.3) and the optional no-spec
reload, Phase B about 12 to 18 minutes, Phase C about 2 minutes. Run A → B
→ C for one model before loading the next, so every model's rows come from
the same session of the same load.

## 9. Open decisions (collected)

- §2 batched-token alignment
- §2 reasoning-effort grade(s) for the round (`low` and/or `high`; not `medium`)
- §3.2 corpus source
- §3.2 no-spec decode reload: yes/no
- §4.2 which new fixtures
- §4.3 which new app checks
