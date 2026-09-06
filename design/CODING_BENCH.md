# Coding bench — prompts and test methods (helm T22 → T24, third edition)

The coding rows in a round's `RESULTS.md` come from `Helm.Evals.Coding`,
the agentic bench in the helm repo (`lib/helm/evals/coding.ex`). One
model at a time drives helm's real session loop — the same tools,
approvals, digest gate and ledger the operator uses — through two
parts, and the harness grades what lands on disk and what renders in a
browser. No LLM judge anywhere. This file records exactly what the
models are shown and exactly how each verdict is reached, so a round
can be reproduced or re-graded.

The raw inference numbers (TTFT, prefill, decode, concurrency) in the
same report come from `spark_bench.py`, a separate harness; this
document covers only the coding bench. The round protocol around both
is `TESTPLAN.md`.

**Edition.** The first round (2026-09-04, `results/2026-09-04/`) ran the
first edition: 12 fixtures, a one-line system prompt, a regex-only app
checklist. Everything below is the second edition (T23) unless marked
*round 1*. The two are different benches; the `harness` block in each
run's JSON (and its `prompt_sha`) says which one a row ran on.

## What every model sees

### The session

Each task is one fresh helm session, `kind: interactive`, trusted,
bound to no project, with this policy:

| policy key | value | effect |
|---|---|---|
| `main` | the model id | the model under test, pinned per session (the gateway default is irrelevant) |
| `memory` | `off` | no standing memory blocks, no recall, no ingest, no reflection — the store never learns run N's solutions for run N+1 |
| `tools` | `native` | helm's native tools only; MCP servers dropped regardless of UI state |
| `max_rounds` | 35 (fixture) / 128 (app) | the turn ends with `max_rounds` at the cap and is graded on what is on disk |
| `env` | `PORT=4099` | exported to every bash call, so the generated app's runtime config lands on the bench port with no model action |
| `effort` | `low` | `reasoning_effort` sent to airo (T24); a grade every template accepts literally — `medium` meant three different things (Qwen medium, GLM max, DeepSeek low) and `high` had DeepSeek read for an hour without writing |
| `approvals` | `consult: deny`, `edit: allow`, `write: allow` | consult (cloud egress) is refused; file tools run without a prompt; bash keeps its default, so destructive-looking commands (`rm -rf`, `sudo`, `kill`/`pkill`/`killall`, …) ask — and with nobody at the conn the harness denies them, which lands as a *refused* failure |

Hard deadlines: 600 s per fixture, 3600 s for the app. The deadline is
a stop, not a wait: on expiry the harness stops the turn and grades the
disk. The caps are what end a runaway turn; a turn ended by cap, stop
or deadline still writes its ledger row for the rounds that completed.

**One helm SHA per round.** `run/1` refuses to start on a dirty tree
and records the SHA (`helm_sha`), the prompt's SHA-256 prefix
(`harness.prompt_sha`) and the hidden tests' (`harness.hidden_tests_sha`)
in the JSON.

**Endings and the nudge (T24).** A turn that ends by the model's own
reply is classified from its last non-empty line: `summary` (the
default), `narrated` (ends with a colon, or "let me" / "now I'll" /
"next I'll" / "I will now"), or `blank` (no text — a reasoning-only
round). Only a `narrated` or `blank` ending draws the one nudge
("Continue until every requirement in the task is done, then reply
with the one-line summary.") under the same cap and deadline; if the
reply is still not a summary the outcome is **`abandoned`**, never
`done`. Rows carry `ending` and `nudges`. (Round 2 nudged every task —
34 wasted turns for one model — and wrote `done` for a narrated
abandonment.)

### The tools on the wire (21)

`read`, `edit`, `write`, `bash`, `grep`, `sgrep`, `glob`, `tree`,
`outline`, `changes`, `read_artifact`, `proc`, `proc_logs`, `job`,
`preview`, `project_docs`, `web_search`, `todo`, `session_search`,
`consult`, `agent`.

No memory tools (memory off), no MCP tools. `consult` is on the wire
but every call is denied. `proc`/`proc_logs`/`project_docs` refuse in
an unbound session and say why (a server of the model's own runs with
`bash(background: true)`, `job(kill)` stops it); `preview` works for
unbound sessions through the shared workspace browser. Bash runs in the
session cwd with a 30 s default foreground timeout (120 s max); a
command naming helm's own pid is refused outright; `kill`, `pkill` and
`killall` ask for approval (denied in the bench).

### The system prompt (second edition, as run)

```
You are helm, an agent at the conn of the JobyCorp fleet. Be direct and concise.

Working method: survey before you read. `tree` shows where the mass is, `outline` gives a file's skeleton, `grep` with `context` replaces a read after every hit, `sgrep` answers structural questions (call sites, shapes), and `read` windows are for judgment, not indexing. Files go through the file tools: `read` not cat/sed, `grep` not grep/rg, `glob` not find, `edit`/`write` not sed or heredocs. Bash runs things: builds, tests, mix tasks. Dev servers and long commands run with `bash(background: true)`; `job` polls and kills them. Never signal a process you did not start. Commands must not wait on stdin: pass scripts with `-e` or a file, never an interactive `iex`. Read enough to act, act, verify, and stop.
```

Then, for an unbound session, one sentence naming its working
directory ("This session's working directory is `<cwd>`; relative
paths and bash resolve there") — round 1 had one model search the
whole disk for a file in its cwd and another `cd` into a path it
invented. *Round 1* ran on the first line alone: the working-method
paragraph was in config but the server had not been restarted, and
every round-1 `harness.system_prompt` shows the one-liner.

The model also sees, automatically, whatever instruction files helm
injects on first touch under a directory: for the app task that is the
generated app's own `AGENTS.md` (~7k tokens of Phoenix/JobyKit
guidance, including "run `mix precommit` when done"). This is the
real environment and is identical across models.

### Warm-up

Before the measured fixtures, one throwaway fixture (`clamp`) runs
under the same policy and is discarded, so no model's first row
carries a cold prefix cache (round 1: DeepSeek's first fixture had a
17 s TTFT against a 0.5 s median). Before the app task the harness
wipes the work dir, drops the `benchapp_dev` and `benchapp_test`
databases, and runs a throwaway `mix joby_kit.new` so hex and build
caches are warm.

## Part A — the fixtures (17)

Seeded-bug modules under `priv/evals/speculative/<name>/` in the helm
repo. Each is a `solution.ex` whose `@moduledoc` is the specification
and whose body has at least one deliberate bug, plus a hidden ExUnit
file the model never sees, plus a `reference.ex` that must pass it. A
corpus-integrity test in helm asserts, for every fixture, that the
seeded bug fails and the reference passes. Everything in the fixture
dir except `hidden_test.exs` is copied into the session's scratch
directory — so a fixture may ship a visible test file.

| fixture | band | hidden tests | spec (first line of the @moduledoc) |
|---|---|---:|---|
| clamp | easy | 5 | `clamp(x, lo, hi)` returns x limited to the inclusive range lo..hi |
| first_or | easy | 4 | `first_or(list, default)` returns the first element of the list, or the default |
| parse_int | easy | 5 | `parse(string)` parses a base-10 integer, tolerating surrounding whitespace |
| pricing | medium | 6 | Storefront pricing, all values integer cents |
| split_bill | medium | 4 | `split(total_cents, n)` splits an integer amount of cents across n people |
| month_end | medium | 4 | `last_day_of_next_month(date)` returns the %Date{} for the last day of next month |
| binary_search | medium | 5 | `find(tuple, target)` searches a sorted tuple of integers |
| interval_merge | medium | 5 | `merge(intervals)` takes a list of {start, stop} integer tuples |
| split_bill_signed | medium | 4 | as `split_bill`, and total_cents may be negative: floored base, non-negative remainder, largest-first |
| nth_one_based | medium | 4 | `nth(list, position)` returns the element at a ONE-based position; 0, negative, past the end are `:none` |
| rate_limiter | hard | 2 | A concurrent admission counter; `start()` returns `{:ok, counter}` |
| safe_echo | hard | 5 | `run(input)` echoes untrusted user input back EXACTLY as given |
| lru_cache | hard | 4 | A functional LRU cache; `new(capacity)` (capacity >= 1) builds it |
| percentile | hard | 7 | `percentile(values, p)` computes the p-th percentile (p in 0..100) |
| safe_echo_exact | hard | 5 | `run(input)` returns input EXACTLY: `-n`, `-e`, backslash sequences are data; one trailing newline removed; never handed to a shell |
| ring_buffer | hard | 5 | A fixed-capacity FIFO ring buffer; `push/2` returns the buffer, `pop/1` returns `{value, buffer}` or `:empty` |
| visible_test_lies | hard | 4 | `slugify(title)` turns a title into a URL slug (hyphens); ships a visible `solution_test.exs` with one test that contradicts the doc |

The five second-edition fixtures each target a gap round 1's drafts
had. Re-graded against the two extended ones, all six round-1 drafts
(`split_bill` × 3, `safe_echo` × 3) fail: negatives for every model;
backslash sequences and the trailing newline for GLM and DeepSeek,
leading dashes for Qwen. `ring_buffer`'s API mixes return conventions
on purpose (the trap is in a hand-written probe, the oracle is
ordinary — round 1's 35-round argument with a correct `lru_cache`).
`nth_one_based` counts like a person and says so. `visible_test_lies`
measures who follows the `@moduledoc` over a test that lies; fixing the
visible test is allowed.

**Prompt** (verbatim, one user message, markdown; the session cwd
holds the fixture's files):

```markdown
The file `solution.ex` contains a module whose intended behavior is documented in its `@moduledoc`. The `@moduledoc` is the complete specification. The module has at least one bug.

1. Fix `solution.ex` in place, changing as little as possible.
2. Keep the module name and the public API exactly as they are.
3. Do not use the `consult` tool.
4. When you are done, reply with a one-line summary.
```

**Oracle.** After the turn ends (reply, cap, or deadline), the harness
copies the model's final `solution.ex` and the fixture's
`hidden_test.exs` into a fresh directory and runs
`elixir hidden_test.exs`. Exit 0 is a pass; anything else is a fail
with the test output kept. No `solution.ex` on disk is a fail. The
draft is stored in the row (`draft`) so an oracle change can re-grade
a past run without re-running the model.

## Part B — the app task (second edition)

**Prompt** (verbatim, one user message, markdown; the session cwd is
an empty work directory `work/<label>/`; `prompt_sha 6fb75d99`):

```markdown
# Phoenix Elixir app benchmark

JobyKit is already installed. The app you build is the artifact being
benchmarked: a modern demo landing site for a fictional product of your
choice. It is not a tool for running benchmarks; no benchmark-themed
features or copy.

## Setup

1. In the current working directory run `mix joby_kit.new benchapp`, then work inside the `benchapp` directory it creates.
2. Remove the stock JobyKit demo content: the generator's `simple_nav` header and "built with" footer in `lib/benchapp_web/components/layouts.ex`, and the welcome content of HomeLive in `lib/benchapp_web/live/home_live.ex`. Keep the `/design` and `/custom-designs` pages.

## Requirements

Mobile and desktop views, and working light and dark themes, throughout.

3. A top navigation bar in `Layouts.app` with id `main-nav` that marks the current page's link with `aria-current="page"`, has a menu that works at phone widths behind a toggle button with id `nav-toggle`, and a theme toggle with id `theme-toggle` usable at both widths.
4. HomeLive as a landing page with a hero.
5. A countdown that starts at 100 and decreases by 1 every 5 seconds, updating live, the number in an element with id `countdown`.
6. A newsletter signup form with id `signup-form` and one email input. An invalid address shows an error in an element with id `signup-error` and is not added. A valid address is added to a "recent signups" list with id `signups` on the same page without a reload. The same address submitted twice shows the error and is not added again. In-memory is fine; no database.
7. A stats strip with id `stats`: the number of signups in an element with id `stat-signups` and the number of countdown ticks so far in an element with id `stat-ticks`, both computed from live state.
8. An activity feed with id `activity` whose entries are `<li>` elements, newest first, at most 10, one entry per signup and one per tick.
9. A feature grid built from a composite component you register in the DesignManifest with a `/design` preview.
10. A second page at `/about`, linked from the nav, on the same layout.

## Tests

11. Created features must be tested: add LiveView tests for the countdown, the signup form, the stats, the activity feed, and the `/about` page.

## Constraints

- The dev server must run on port 4099; the `PORT` environment variable is already set to 4099. Do not use any other port.
- Do not stop or kill processes you did not start.
- When you are done, reply with a one-line summary.
```

Why it reads this way: "modern" became a list a check can see; the
element ids are the contract the hidden tests and the rendered checks
read (a real brief works the same way, and every model gets the same
contract); the app is declared the artifact under benchmark because
round-1 models read "app for benchmarking purposes" as a product brief
and invented "instant benchmarks for your code"; "created features
must be tested" makes the tests-added check fair; the third edition is
numbered markdown (same words), no longer dictates the email field's
name (oracle v2 reads it), and states the two things round 2 tested
without saying: duplicates are rejected, the theme toggle is usable at
both widths. It still does not name the verification commands — the
generated `AGENTS.md` already says `mix precommit`.

**Checklist.** Three kinds of check, each its own column; the app row's
`checks_passed/checks_total` counts them all. All commands run with
`PORT=4099` and a 900 s limit.

Source checks:

| check | method | pass when |
|---|---|---|
| generated | `benchapp/mix.exs` exists | it does (if not, this is the only check and it fails) |
| compile | `MIX_ENV=dev mix compile --warnings-as-errors` | exit 0 |
| test | `MIX_ENV=test mix test` | exit 0 |
| lint | `MIX_ENV=dev mix joby_kit.lint` | exit 0 (warnings allowed; the count is a score) |
| countdown | regex over `home_live.ex` | `\b100\b` **and** (`5_?000` or `:timer.seconds(5)`) **and** (`send_after` or `send_interval`) |
| nav | regex over `layouts.ex` and `home_live.ex` | either matches `<nav\b`, `simple_nav`, or `navbar` |
| layout_replaced | markers in `layouts.ex` | **not** all three of `JobyKit.NavComponent.simple_nav`, `built with`, `/design.json` present |
| tests_added | the `N tests, M failures` line of `mix test`, minus the generator's 4 | ≥ 5 |
| composite_registered | `component(`/`component ` registrations at line start in `design_manifest.ex`, minus the generator's 1 | ≥ 1 |

Hidden LiveView tests (`priv/evals/coding/app_tests/benchmark_hidden_test.exs`
in helm, copied into `test/benchapp_web/live/` at grade time, run once
with `--seed 0`, removed; the model never sees them, and its own tests
count separately):

| check | the test |
|---|---|
| tick | `live(conn, "/")`; `#countdown` renders 100; sleep 5.3 s; renders 99 |
| signup | find the email input inside `#signup-form` on the rendered page and build params to match its actual `name` (`email` or the kit's `signup[email]`); submit `nope` → `#signup-error` present and `#signups` lacks it; submit `ada@example.com` → `#signups` contains it; submit it again → `#signup-error` present and the address listed once (T24) |
| about | `GET /about` is 200; exactly one `#main-nav`; an `a[aria-current="page"][href="/about"]` inside it |
| stats | `#stat-signups` renders 0, then 1 after a valid signup; `#stat-ticks` renders 1 after 5.3 s |
| activity | after a signup, `#activity li` ≥ 1 and the first `li` names the address; after 5.3 s the count is at least one higher (anchored on entries, so an empty-state placeholder `<li>` that leaves as the first entry arrives is fine) |
| activity (cap) | eleven signups in quick succession leave exactly 10 `#activity li` (T24) |

Failures map back by the test-name prefix. If the file does not run at
all (the app's tests do not compile), all five fail with the compiler's
tail as the detail. This is **oracle v3** (`hidden_tests_sha 6ccd80bc`; v2 was `2924139b`):
v1 assumed the field was named `email` and counted list items by raw
delta; round 2 showed both assumptions punishing legitimate choices,
and the round's compiling apps were re-graded (below).

Rendered checks — the app boots on 4099 under the oracle's own
supervision (a foreign holder of the port fails these and is never
killed), then helm's own headless Chrome (`Helm.Preview.Chrome`,
profile `bench`, wiped first so the theme script sees no remembered
choice; never the operator's workspace browser) loads `/` and takes
six screenshots into `screenshots/<label>-*.png`:

| check | method | pass when |
|---|---|---|
| boots | only if `compile` passed (a non-compiling app is never booted — a 200 on the port would be someone else's); `GET /` polled every 2 s for up to 90 s; then the pid holding 4099 must be in the process group the oracle started | a 200 whose body matches `<nav\b`, served by the oracle's own server |
| mobile_nav | viewport 390×844 with mobile emulation, light scheme | `#nav-toggle` is visible, or any `#main-nav a` is visible |
| theme_toggle_mobile | same viewport | `#theme-toggle` is visible (exists-but-hidden fails; the round-2 design review's finding) |
| dark_theme | `prefers-color-scheme: dark` emulated, page reloaded | `<html data-theme>` is `dark`, or `body`'s computed background differs from the light render |
| tick_rendered | desktop, light, page held open 12 s | `#countdown` reads 98 |

The shots: `desktop-light`, `full-light` (whole page), `desktop-dark`,
`mobile-light`, `mobile-full-light`, `desktop-light-after-12s` (1440×900
desktop). Per shot the row keeps `render.<shot>`: `data-theme`, body
background, countdown text, LiveView connected, page height, whether
`#main-nav`/`#theme-toggle` exist, and the mobile visibility flags.
Both schemes are set explicitly: headless Chrome inherits the OS
appearance, and this Mac runs dark.

**Scores** (numbers in `app.scores`, never a pass): `lint_warnings`
("Summary: N warnings" from the lint), `tests_added`, `tests_total`,
`components_added`, `page_height`.

The design review stays hand-written from the screenshots, a record
and not a score; an LLM judge is a non-goal.

### Re-grades

`Helm.Evals.Coding.regrade_app(label)` re-runs the whole app checklist
on the stored app under the current oracle and writes
`raw/coding-<label>.regrade.json` beside the as-graded record, which is
never modified (TESTPLAN §1). Screenshots take the `<label>-regrade`
prefix. The report renders as-graded and re-graded side by side with
the oracle's `hidden_tests_sha`. A re-grade is meaningful only for an
app that compiles; an invalid one goes to `raw/superseded/` with a run
log note (round 2: Qwen).

## Runs on record

Round 1 (`results/2026-09-04/`, first edition: 12 fixtures, one-line
system prompt, regex checklist + boot):

| label | helm | started → finished (UTC) | result |
|---|---|---|---|
| glm53-flash-exl3 | 6629000 | 2026-09-04 13:47:37 → 14:01:05 | fixtures 12/12 (1 cap); app 8/8 |
| dsv4-flash-vision-exp | fd0c053 | 2026-09-04 14:13:52 → 14:31:25 | fixtures 12/12; app 8/8 |
| qwen38-flash-next-nvfp4 | f20cefe | 2026-09-04 14:46:16 → 14:58:22 | fixtures 12/12; app 8/8 |

Round 2 (`results/2026-09-04-r2/`, second edition, prompt `025cf1ec`,
17 fixtures, hidden LiveView tests, rendered checks, the nudge):

| label | helm | started → finished (UTC) | as graded → oracle v2 |
|---|---|---|---|
| qwen38-flash-next-nvfp4 | 529686a | 2026-09-04 18:34:08 → 19:14:03 | fixtures 17/17; app 5/18 (does not compile; re-grade n/a) |
| glm53-flash-exl3 | 0080265 | 2026-09-04 22:54:02 → 23:41:36 | fixtures 15/17 (2 caps); app 14/18 → 14/18 at the cap |
| dsv4-flash-vision-exp | d1f9891 | 2026-09-05 02:30:29 → 03:11:20 | fixtures 17/17; app 17/18 → **18/18** |

Within a round the SHAs differ by sprint-doc commits only; the
`harness` blocks compare equal.

Round 3 (`results/2026-09-05/`, third edition, prompt `6fb75d99`,
hidden tests `6ccd80bc`, effort `low`, one SHA `0e79f20`):

| label | started → finished (UTC) | result |
|---|---|---|
| dsv4-flash-vision-exp | 2026-09-05 19:37:28 → 20:11:20 | fixtures 17/17; app **19/19** `done` |
| glm53-flash-exl3 | 2026-09-05 20:33:17 → 21:00:46 | fixtures 15/17; app 15/19 at the 128 cap |
| qwen38-flash-next-nvfp4 | 2026-09-05 21:19:26 → stopped 22:23 | fixtures 17/17; app abandoned by the operator at 42 rounds, nothing written (helm carries no reasoning between rounds; the model re-planned every round) |

DeepSeek's earlier `high` run the same day (16/17; app 7/19 `timeout`, an
hour of reading and no writes) is in `raw/superseded/` as the effort
data point.

## Metrics — what each column means

All per-task numbers are read from what the session itself persisted:
the `turn_usage` ledger row and the tool messages' metadata. The
harness adds wall-clock and the verdicts.

| column | meaning |
|---|---|
| outcome | `done` (the model replied with a summary), `abandoned` (narrated or blank ending, nudged once, still not a summary), `max_rounds` (the cap ended the turn), `timeout` (the deadline did), `error: …` |
| ending / nudges | how the last reply ended (`summary` / `narrated` / `blank`) and how many nudges the task drew (0 or 1) |
| reasoning_tokens / reasoning_reported | thinking volume per row: the backend's counter when it reports one (Qwen), else bytes/4 of the surfaced reasoning text (DeepSeek, printed `~`); `none seen` when neither exists (GLM: its completion counts match its visible text, so it does not think through this engine) |
| wall | harness wall-clock from session start to turn end, ms |
| rounds | model calls in the turn (one per assistant message) |
| tool calls | tool messages, with a per-tool breakdown |
| refused | tool failures where helm said no: approval denied, trust, no project, a path outside or escaping the session roots |
| failed | tool failures that were the model's own: non-zero exit, timeout, bad edit, bad arguments |
| prompt / cached / uncached / completion | tokens summed over the turn's rounds as reported by the backend through airo; uncached = prompt − cached |
| cached_reported | whether any round of the turn carried a cache counter at all; when false, cached and uncached are `null` and the report prints **not reported** — a backend that never emits the counter is not a backend with zero hits |
| TTFT | time to first token of the turn's **first** round |
| completion tok/s | completion tokens over the turn's duration (all rounds) |
| draft (fixtures) | the model's final `solution.ex` |
| final / final_line | the model's last text reply, whole, and its last non-empty line (the one-line summary the prompt asked for) |

## Protocol

One model on the cluster at a time; the operator loads the next model
between runs (`TESTPLAN.md` §2 pre-flight, §4). From helm's dev seat
(iex or a tidewave eval), on a clean tree:

```
Helm.Evals.Coding.run(model: "<airo model id>", label: "<label>")
python3 design/make_report.py
```

Options: `only: [:fixtures]` / `only: [:app]`, `fixtures: ["clamp"]`,
`warm: false`, `root: "<round dir>"` (default `results/current`),
`allow_dirty: true` (never for a scored row). A run writes
`raw/coding-<label>.json` after every fixture and after the app task
(a crash loses one row); re-running a part merges into the existing
file.

After each task the harness kills the session's own background jobs,
then any process whose cwd is inside the scratch directory (never
helm's own process, never anything outside the directory), stops the
turn if still running, and archives the session. The session id in
each row is the durable handle on its transcript — helm's auto-titler
renames sessions within seconds, so titles are not.

## Artifacts, per round

- `raw/coding-<label>.json` — the full record per run: `harness`
  block, per-fixture rows (metrics, oracle output, draft), the app row
  (metrics, per-check detail, scores, render probes, screenshot paths,
  final answer), summary.
- `RESULTS.md` § "Coding (helm agent)" — rendered by
  `design/make_report.py` from every `raw/coding-*.json`; hand edits
  do not survive a re-run.
- `work/<label>/benchapp` — the generated app as the model left it.
- `screenshots/<label>-*.png` — the six shots.
- `raw/superseded/` — off-protocol runs, out of the report.
- helm repo: `docs/sprints/T22-coding-bench.md` (round 1: design, the
  run-2 post-mortem, a readout per run) and
  `docs/sprints/T23-coding-bench-2.md` (this edition: why each change).

## Known limitations

- Spend is comparable only where the backend reports a cache counter;
  the report says "not reported" where it does not (`TESTPLAN.md` §2
  names the launch flag that fixes this at the source).
- The rendered checks read ids the prompt specifies; an app that
  builds the right thing under different ids fails them. That is the
  contract, stated in the prompt, the same for every model.
- The `about` check requires `/about` to render through the router
  (LiveView or controller); the hidden test uses a plain GET.
