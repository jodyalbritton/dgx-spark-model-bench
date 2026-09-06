# DGX Spark model benchmarks — overall report

Written 2026-09-04 from everything in this folder: `RESULTS.md`,
`design/CODING_BENCH.md`, `design/spark_bench.py`, `design/make_report.py`, the raw inference
JSON/logs in `raw/`, the coding-bench JSON in `raw/coding-*.json` (plus the
superseded DeepSeek run), and the three generated apps under `work/`. The
apps were also booted and screenshotted; that part is written up separately in
`DESIGN_REVIEW.md`.

Three models, one cluster (sparky + sparky2, tensor-parallel 2), one model
loaded at a time:

| label | model | quant / backend | ctx | spec decode |
|---|---|---|---:|---|
| glm53-flash-exl3 | GLM-5.3-Flash | EXL3 4 bpw, custom `glm53-flash-sm121` image, engine `0.1.dev20051` | 524k | dflash, 7 tokens |
| qwen38-flash-next-nvfp4 | Qwen3.8-Flash-Next | NVFP4 (modelopt), vLLM `qwen38-flash-next` image, engine `0.1.dev20073` | 1M (YaRN ×4 over a 262k native window) | MTP, 3 tokens |
| dsv4-flash-vision-exp | DeepSeek-V4-Flash-Vision-Exp | fp8, `dspark-vllm-gx10:0.1.1`, vLLM `0.25.2.dev0` | 1M | dspark, 6 tokens |

## 1. Headline

- **Quality is a three-way tie at the ceiling of this bench.** 12/12 fixtures
  and 8/8 app checks for every model, and every model got the reasoning probe
  right. The corpus cannot separate them; the differences below are speed,
  spend, behaviour under the agent loop, and code quality that the checks do
  not grade.
- **Qwen3.8 is the fastest raw engine.** Best prefill by a wide margin (2.5 to
  2.75k tok/s from 8k tokens up, roughly 2.4× GLM and 1.5× DeepSeek), best
  decode at c=1 in most rows, and the best concurrency scaling. Its one
  weakness is a ~1.2 s fixed per-request overhead that makes it the slowest of
  the three on tiny prompts.
- **DeepSeek is the cheapest to run as an agent** because it is the only
  backend that reports and (evidently) exploits prefix caching: 61k uncached
  prompt tokens for the whole app task against 632k (GLM) and 1.09M (Qwen)
  upper bounds. But it took the most rounds, the most tool calls, and wasted
  ~3 minutes of fixture time on bash commands that hit the 30 s timeout.
- **GLM is the most economical agent in rounds and completion tokens** (27
  rounds / 4.1k completion tokens for the app versus 43 / 12.5k and 59 /
  17.4k), and its final app page is the most complete. But it produced the only
  runaway turn of the whole bench (lru_cache: 35 rounds, 16 failed commands,
  hit the cap) and it has the lowest raw prefill throughput, which is what an
  agent loop is mostly doing.
- **Best generated app: DeepSeek's**, by responsiveness and code hygiene
  (see `DESIGN_REVIEW.md`). GLM second, Qwen third.

If you have to pick one model for helm's interactive seat on this hardware
today: **Qwen3.8 for latency, DeepSeek for spend and app quality, GLM if you
value short, terse turns and can live with the prefill cost.** The bench needs
harder fixtures before it can say more about correctness.

## 2. Raw inference (`design/spark_bench.py`)

Method recap: synthetic prompts of a repeated filler phrase with a unique
nonce (so no prefix-cache hits), thinking off, 128 forced output tokens,
`temperature 0.6`. TTFT = first streamed token. Prefill tok/s = prompt tokens
/ TTFT. Decode tok/s = 128 / (end − first token).

### 2.1 Time to first token and prefill, c=1

| prompt tokens | GLM TTFT (s) | Qwen TTFT (s) | DSv4 TTFT (s) | GLM prefill | Qwen prefill | DSv4 prefill |
|---:|---:|---:|---:|---:|---:|---:|
| 256 | 0.85 | 1.26 | 0.31 | 330 | 226 | 884 |
| 2,048 | 2.34 | 1.27 | 1.21 | 884 | 1,633 | 1,707 |
| 8,192 | 8.12 | 3.44 | 4.49 | 1,015 | 2,397 | 1,833 |
| 32,768 | 29.28 | 12.07 | 17.80 | 1,121 | 2,719 | 1,843 |
| 65,536 | 58.02 | 23.83 | 37.38 | 1,130 | 2,753 | 1,754 |
| 102,400 | 90.71 | 38.88 | 58.14 | 1,129 | 2,636 | 1,762 |
| 153,600 | 137.51 | 60.79 | 92.29 | 1,117 | 2,528 | 1,665 |

Reading:

- **Fixed overhead** (the 256-token row) is DeepSeek 0.3 s, GLM 0.85 s, Qwen
  1.26 s. Qwen's 2,048-token TTFT is the same as its 256-token TTFT, so ~1.2 s
  of every Qwen request is scheduler/launch cost, not compute. For short
  interactive turns that overhead is the whole latency.
- **Asymptotic prefill** is flat from 8k up for all three, so these are real
  compute ceilings: GLM ≈ 1.12k, DeepSeek ≈ 1.75k, Qwen ≈ 2.7k tok/s. Qwen's
  slight decline past 64k (2,753 → 2,528) is attention cost growing; DeepSeek
  shows the same slope; GLM is flat because it is bottlenecked elsewhere.
- **A 150k-token context costs 2.3 minutes on GLM, 1.5 on DeepSeek, 1 on
  Qwen.** Nobody's 500k–1M context window is usable interactively; at these
  rates 500k tokens is 3 to 7 minutes of prefill.

### 2.2 Decode, c=1 (tok/s per stream)

| prompt tokens | GLM | Qwen | DSv4 |
|---:|---:|---:|---:|
| 256 | 50.5 | 55.1 | 55.9 |
| 2,048 | 44.9 | 57.5 | 57.4 |
| 8,192 | 55.5 | 63.8 | 51.7 |
| 32,768 | 46.7 | 64.9 | 51.4 |
| 65,536 | 46.7 | 55.4 | 47.7 |
| 102,400 | 55.9 | 60.5 | 64.4 |
| 153,600 | 58.2 | 59.4 | 73.1 |

All three sit in the 45 to 65 tok/s band at c=1, which on a Spark is the
memory-bandwidth ceiling for a single stream plus whatever speculative
decoding buys back. Qwen is the most consistent. Two things are odd (see
§5): decode does not degrade with context length, and DeepSeek's decode
*rises* to 73 tok/s at 153k. Both are speculative-decoding artefacts of the
degenerate prompt, not evidence of a faster model at long context.

### 2.3 Concurrency

| prompt | c | GLM | Qwen | DSv4 |
|---:|---:|---|---|---|
| 256 | 4 | 81.0 wall · 30.9/stream · 1.51 s | 92.5 wall · 38.9/stream · 1.62 s | 95.5 wall · 30.4/stream · 1.10 s |
| 8,192 | 4 | 15.1 wall · 19.4/stream · 24.50 s | 32.7 wall · 40.7/stream · 12.40 s | 23.2 wall · 14.7/stream · 11.47 s |

- At 8k×4, Qwen delivers 32.7 aggregate tok/s against 23.5 at c=1 (+39%).
  DeepSeek: 23.2 vs 18.4 (+26%). GLM: 15.1 vs 12.3 (+23%), and its per-stream
  decode halves. GLM's per-request TTFTs at 8k×4 were 14.2 / 19.8 / 29.3 /
  30.5 s: the four prefills ran nearly serially. That is consistent with its
  launch flags (`--max-num-batched-tokens 2048`,
  `--long-prefill-token-threshold 1024`), which are much smaller than the
  8192 the other two use. GLM's concurrency figure is partly a config choice.
- Qwen at 256×4 admitted requests in two pairs (TTFT 0.34, 0.34, 2.9, 2.9 s);
  GLM batched all four together (1.51 s each); DeepSeek admitted one first and
  three together (0.36, 1.10, 1.10, 1.10 s). Different schedulers, same
  aggregate.

### 2.4 Reasoning probe

All three answered 301. DeepSeek did it in 410 completion tokens and 7.0 s,
Qwen in 716 and 13.4 s, GLM in 828 and 16.6 s. GLM's reasoning trace is the
most legible (clean modular arithmetic, explicit verification); Qwen's and
DeepSeek's traces are terse "We need answer math" style notes. GLM also
duplicated the whole derivation in the visible answer, which is where its
extra tokens went. A one-question greedy probe is a smoke test, not a
reasoning benchmark.

## 3. Coding bench (helm agent, T22)

Method recap: helm's real session loop, memory off, MCP off, consult denied,
one-line system prompt, 21 tools on the wire. Part A: 12 seeded-bug modules
graded by hidden ExUnit tests. Part B: generate a JobyKit Phoenix app, replace
the layout, build a landing page with a 5-second countdown, graded by a
mechanical checklist.

### 3.1 Quality

Every fixture, every band, every app check: pass, for all three. The bench is
saturated (the run doc says so). The only pre-harness data point is the
superseded DeepSeek run from 11:59Z, which scored 11/12 (pricing failed
because the oracle then pinned `FunctionClauseError`) and 6/7 on the app
(layout not replaced, because that earlier prompt said "remove the main app
layout" and DeepSeek kept the stock chrome and put the nav inside HomeLive).
The prompt and oracle were tightened after that run, so it is not comparable.

### 3.2 Speed in the agent loop

| | GLM | Qwen | DSv4 |
|---|---:|---:|---:|
| fixtures wall (s) | 405 | **257** | 509 |
| median fixture (s) | **13** | 18 | 51 |
| fixture rounds / tool calls | 81 / 70 | **59 / 47** | 61 / 49 |
| fixture failures (model's own) | 19 | **3** | 7 |
| fixture median TTFT (ms) | 2,094 | 1,762 | **491** |
| fixture median completion tok/s | 17 | **34** | 28 |
| app wall (s) | **363** | 430 | 496 |
| app rounds / tool calls | **27 / 30** | 43 / 44 | 59 / 64 |
| app completion tokens | **4,112** | 12,490 | 17,414 |
| app completion tok/s | 11.3 | 29.1 | **35.1** |

Per fixture (wall s / rounds / failed+refused):

| fixture | band | GLM | Qwen | DSv4 |
|---|---|---|---|---|
| clamp | easy | 13 / 3 / 0 | 18 / 5 / 0 | 38 / 3 / 0 |
| first_or | easy | 10 / 3 / 0 | 11 / 4 / 0 | 17 / 3 / 0 |
| parse_int | easy | 10 / 3 / 0 | 11 / 4 / 0 | 59 / 8 / 1 |
| pricing | medium | 11 / 3 / 0 | 44 / 5 / 1 | 56 / 6 / 0 |
| split_bill | medium | 18 / 5 / 1 | 13 / 4 / 0 | 8 / 3 / 0 |
| month_end | medium | 29 / 5 / 0 | 17 / 5 / 0 | 51 / 5 / 1 |
| binary_search | medium | 12 / 3 / 0 | 20 / 5 / 0 | 15 / 3 / 0 |
| interval_merge | medium | 72 / 11 / 2 | 40 / 6 / 1 | 120 / 9 / 2 |
| rate_limiter | hard | 11 / 3 / 0 | 16 / 4 / 0 | 8 / 3 / 0 |
| safe_echo | hard | 21 / 4 / 0 | 21 / 6 / 0 | 66 / 7 / 1 |
| lru_cache | hard | **187 / 35 / 17** | 13 / 4 / 0 | 11 / 3 / 0 |
| percentile | hard | 11 / 3 / 0 | 34 / 7 / 1 | 60 / 8 / 2 |

Reading:

- **GLM's typical fixture is the fastest (3 rounds, ~11 s) and its worst is
  the slowest.** Without lru_cache its fixture wall would be 218 s, beating
  Qwen. Its style is read → edit → reply; it verifies less than the others and
  was right anyway on this corpus.
- **Qwen is the most consistent**: no fixture under 10 s, none over 44 s, only
  three failed commands across 47 tool calls, and it habitually wrote a quick
  verification script before replying (it stress-tested rate_limiter with 200
  concurrent callers against a limit of 50).
- **DeepSeek's slowness is self-inflicted.** Six bash calls hit helm's 30 s
  foreground timeout (parse_int, month_end, interval_merge ×1, safe_echo,
  percentile, plus one more in the app). Each costs a full 30 s plus a round
  to recover, which is ~3 of its 8.5 fixture minutes. It also paid a 17 s
  cold TTFT on the first fixture (clamp) before its prefix cache warmed; every
  later fixture started in under 0.6 s.
- **Completion tok/s in the loop is far below raw decode for everyone**, and
  most for GLM (11–17 vs 50 raw). This column is completion tokens over the
  whole turn duration, so it is dominated by prefill of the growing context
  each round. GLM's 1.1k tok/s prefill on ~23k tokens per round is ~20 s per
  round before it writes anything; that, not decode, is why GLM's app turn
  averaged 13 s per round while emitting only 150 tokens per round.

### 3.3 Spend

| | GLM | Qwen | DSv4 |
|---|---:|---:|---:|
| fixtures prompt tokens (summed over rounds) | 509k | 317k | 325k |
| fixtures cached | — | — | 300k |
| fixtures uncached prompt | 509k | 317k | **25k** |
| fixtures completion | **7.6k** | 9.3k | 14.1k |
| app prompt tokens | 632k | 1,085k | 2,153k |
| app cached | — | — | 2,091k |
| app uncached prompt | 632k | 1,085k | **62k** |
| app completion | **4.1k** | 12.5k | 17.4k |
| app prompt per round | 23.4k | 25.2k | 36.5k |

The cache column is the important caveat, and `design/CODING_BENCH.md` already flags
it: only DeepSeek's vLLM reports `cached_tokens`. GLM's launch argv includes
`--enable-prefix-caching` and vLLM V1 enables it by default for Qwen, so both
are probably caching too and simply not reporting it. The arithmetic supports
that: if GLM really re-prefilled 632k tokens at 1.1k tok/s the app turn would
have needed ~9.5 minutes of prefill alone, and it finished in 6. So treat the
GLM/Qwen "uncached" numbers as upper bounds and do not rank spend on them.

What *can* be compared is completion tokens and rounds. GLM says a third as
much as DeepSeek to get the same checklist score. DeepSeek reads more (12
reads, 14 edits on the app) and narrates more. Qwen is in between.

## 4. Elixir correctness review of the fixture drafts

All 36 drafts pass their hidden tests. I read every draft against its
`@moduledoc` and ran the two cases where the models diverged.

### 4.1 Where all three converged (and are right)

- **clamp**: two of three wrote `x |> max(lo) |> min(hi)`, GLM wrote
  `min(hi) |> max(lo)`. Equivalent given `lo <= hi`.
- **first_or**: multi-clause heads (`[]` / `[h | _]`) from GLM and DeepSeek;
  Qwen used a `case` inside one clause. Same semantics, multi-clause is the
  idiom.
- **parse_int**: all three `String.trim` then `Integer.parse` and accept only
  `{int, ""}`. Correct, including `"+5"`, `"-"`, and `""`.
- **pricing**: all three moved validation into guards (so bad input raises
  `FunctionClauseError`), compute `gross - div(gross * pct, 100)` and add 499
  unless quantity is 0. Rounding of the discount is unspecified; floor is a
  reasonable choice and all three made it. Qwen's `if quantity == 0, do: 0`
  short-circuit is equivalent since gross is 0 there.
- **binary_search**: identical drafts, `lo > hi` terminator. Handles the empty
  tuple (`hi = -1`).
- **rate_limiter**: identical `Agent.get_and_update` drafts, the correct
  atomic fix.
- **lru_cache**: identical drafts (Qwen's formatting differs). Correct.
  `List.delete` on the recency list is O(n); fine for a fixture.
- **percentile**: same algorithm in all three (`rank = p / 100 * (n - 1)`,
  `trunc` and `ceil`, interpolate, always float). `trunc` equals `floor` here
  because rank is non-negative. `Kernel.ceil/1` returns an integer, so
  `Enum.at` is safe. DeepSeek special-cases `low == high`; the others rely on
  `(rank - lower)` being 0.0, which is fine.
- **interval_merge**: all sort then fold with `start <= cur_stop`. GLM folds
  from an empty accumulator with a two-clause anonymous function; Qwen and
  DeepSeek seed the accumulator with the first interval. DeepSeek's
  `def merge([first | rest]) do [first | rest] = Enum.sort([first | rest])`
  re-binds its own head arguments, which compiles but is awkward. All correct.

### 4.2 Where they diverged, with a real behavioural difference

**split_bill — negative totals.** GLM used `Integer.mod/2` (floored) for the
remainder; Qwen and DeepSeek used `rem/2` (truncated). All use `div/2`
(truncated). The spec says "an integer amount of cents" and gives no sign
constraint; the hidden tests only use non-negative totals. Run against
`split(-100, 3)`:

| model | result |
|---|---|
| GLM | `[-32, -32, -33]`, sums to **−97** (wrong: floored mod mixed with truncated div) |
| Qwen, DeepSeek | `FunctionClauseError` (`List.duplicate` with a negative count) |

GLM's final reply claims it "verified for positive, exact, and negative
totals". It did not; the negative case is wrong. Raising is arguably the
better failure mode than a silent wrong sum, but none of the three handled or
documented the sign question. If negative totals matter, the fix is
`Integer.floor_div` + `Integer.mod`, or a guard.

**safe_echo — two different fixes.** GLM and DeepSeek kept `System.shell` and
single-quoted the input with `'\''` escaping (the "minimal change" reading).
Qwen replaced the shell with `System.cmd("echo", [input])`. Both pass the
hidden tests; both have an edge the tests do not cover:

| input | `System.shell("echo '…'")` (GLM, DSv4) | `System.cmd("echo", [input])` (Qwen) |
|---|---|---|
| `a\nb` (literal backslash-n) | `/bin/sh`'s builtin echo expands it to a real newline: **not** "exactly as given" | preserved |
| `-n` | printed as `-n` | `/bin/echo` treats it as a flag: **empty output** |

Qwen's fix is the one a reviewer would want (no shell, no quoting, no
injection surface at all) and it is the more idiomatic Elixir. GLM's and
DeepSeek's quoting is correct POSIX quoting but leaves the input at the mercy
of the shell's `echo`. A fully faithful implementation would need `printf
'%s'` or to skip the subprocess entirely, which the spec's "using the system
echo command" forbids.

**month_end — struct hygiene.** GLM resets `day: 1` before calling
`Date.days_in_month/1`. Qwen never resets the day, so for a 31st it briefly
holds an invalid `%Date{}` such as 2024-02-31 before overwriting it.
DeepSeek resets the day in one branch and not the other. None of that is
observable because `days_in_month` only reads year and month, but GLM's is
the version that would survive a future `Date` validation. None used the
modern `Date.shift/2` + `Date.end_of_month/1`, which is defensible under
"change as little as possible".

**Reply discipline.** The prompt asked for a one-line summary. GLM's lru_cache
reply ends mid-sentence with a colon (the round cap cut it off). Qwen's
pricing reply opens with a self-correction about a "899" mental-math slip
before the summary. DeepSeek's replies often have a "The fix works" preamble
before the summary line. Only GLM's normal replies are reliably one line.

### 4.3 The generated apps' Elixir

Covered in detail in `DESIGN_REVIEW.md`. Summary:

- All three countdowns are correct LiveView: `Process.send_after` only when
  `connected?`, a `:tick` `handle_info`, clamp at 0, no interval left running
  after 0. Verified live: 100 → 98 in 11 s on each.
- DeepSeek and Qwen registered a `feature_card` composite with a manifest
  entry and a `/design` preview, per the JobyKit contract. GLM inlined the
  cards and took three `duplicated_class_string` lint warnings (pass, but
  the other two were clean).
- Qwen left a catch-all `handle_event/3` that swallows every client event,
  and nests a `<button>` inside an `<a>`.
- DeepSeek assigns `mobile_open: false` and never reads it.
- Nobody wrote a test for the countdown. All three `test/` trees are
  byte-identical to a fresh `mix joby_kit.new`.
- All three ran `mix precommit`, so `mix format` rewrote the generator's
  `design_manifest.ex` and `design_previews.ex` (parentheses, blank lines).
  Those diffs are formatter output, not model edits.

## 5. Quirks and caveats found in the logs and raw data

**Inference bench**

1. **The DeepSeek re-run file is missing.** `RESULTS.md` says the 256/2048
   c=1 and 256/8192 c=4 rows were "replaced by a warm re-run
   (raw/dsv4-rerun.json)". That file is not in `raw/`. The log
   `raw/dsv4-flash-vision-exp.log` still shows the cold numbers (8.54 s and
   12.49 s TTFT at 256 and 2048; 6.59 s and 17.23 s at c=4) while
   `raw/dsv4-flash-vision-exp.json` holds the warm ones (0.31, 1.21, 1.10,
   11.47 s). So the JSON was patched in place and the provenance of the
   patch is gone. The GLM and Qwen rows were *not* re-warmed, so their
   256-token rows carry whatever first-shape cost their engines have. Either
   restore the re-run file or re-run all three with the same warm protocol.
2. **The synthetic prompt is degenerate.** It is one phrase ("benchmark
   context datum ") repeated thousands of times. Prefill numbers are fine
   (compute does not care), but decode numbers are inflated by speculative
   decoding: a draft model predicts continuations of repetitive text
   unusually well, which is why decode does not fall with context and why
   DeepSeek's decode *rises* from 56 to 73 tok/s between 256 and 153k
   tokens. Real agent transcripts will decode slower than this table. A
   natural-text filler (or `--speculative-config` off for the decode rows)
   would give honest decode numbers.
3. **Qwen's log has a container being paused around it.** The first and
   last lines of `raw/qwen38-flash-next-nvfp4.log` are `blissful_elion` /
   `paused head download` and `resumed head download`. Something (a Hugging
   Face download in a container of that name) was paused for the run and
   resumed after. Good practice, but it means the head node was not idle
   before the Qwen run and the log should say what was paused and why.
4. **Log timestamps are local (PDT), JSON timestamps are UTC.** `02:24:45`
   in the GLM log is `09:24:45Z` in its JSON. Harmless once you know.
5. **GLM's concurrency row is partly a config artefact** (§2.3): its batched
   token budget is a quarter of the other two's, so its four 8k prefills
   serialised. Compare only after aligning `--max-num-batched-tokens`.
6. **Qwen ran with YaRN ×4** (`original_max_position_embeddings 262144`).
   Nothing in the bench went past 154k, so no row is in the extrapolated
   region, but the 1M `max_model_len` in the header is not a native window.
7. **Engine versions are not comparable across models.** GLM and Qwen run
   `0.1.dev…` builds of a custom fork; DeepSeek runs `vLLM 0.25.2.dev0`.
   Some of the fixed-overhead and scheduler differences are engine, not
   model.
8. **Only DeepSeek's server reports `cached_tokens`; only Qwen's reports
   `reasoning_tokens`.** The reasoning-token counts for GLM and DeepSeek in
   the probe table come from re-tokenizing the reasoning text client-side,
   which is close but not the same counter.

**Coding bench**

9. **GLM's lru_cache turn is the one real failure of the run**, even though
   it passed. The draft was correct early (it is byte-identical to the other
   two models' drafts), but GLM spent the remaining rounds trying to prove
   it with a scratch script that pattern-matched `put/3` as if it returned a
   tuple. The same `MatchError` on `%{map: %{a: 1}, order: [:a], capacity:
   2}` appears ten times, helm's guardrail ("this exact call has now failed
   2 times — change approach") fired, the model tried to write to `/tmp`
   (refused: outside session roots), tried `:erlang.element` and
   `tuple_size` on the map, and ran out of rounds with its summary line
   half-written. 187 s and 278k prompt tokens for a fix it had in round 3.
   That is a stuck-loop behaviour worth a dedicated fixture.
10. **DeepSeek repeatedly ran commands that block on stdin.** Six
    `killed: exceeded 30000ms timeout` failures across five fixtures and the
    app, then `sh: timeout: command not found` when it reached for GNU
    `timeout` on macOS, then `No file named /tmp/test_sol.exs`. It never
    changed strategy after the first timeout. That is a model habit
    (probably `iex` or a piped `elixir` without `-e`) that a one-line hint
    in the working-method prompt would fix.
11. **Qwen hallucinated a path from nowhere**: `cd /home/conn/src/web` (in
    percentile). "conn" is helm vocabulary, so it invented a plausible helm
    home. `design/CODING_BENCH.md` already notes that unbound sessions are not told
    their cwd and that two models went looking for it; this is the concrete
    instance. Qwen's other app failure, `exit 1 heroicons`, is a `grep`/`ls`
    for the heroicons dep returning nothing, harmless.
12. **DeepSeek's cold-start TTFT lands on the first fixture.** clamp's TTFT
    was 17.0 s versus a median of 0.49 s afterwards. The fixture summary
    "median 51 s" is honest, but the first-fixture number should be marked
    as cache-cold, or the harness should warm the model the way it warms
    hex.
13. **`final` is truncated in the JSON.** Qwen's app summary ends `a
    registered \`fe` and DeepSeek's ends mid-bullet. `design/CODING_BENCH.md` says
    the final is "truncated", but the truncation length is not recorded and
    it cuts Qwen's actual one-line summary off. Store the full final reply
    or at least the last line.
14. **The superseded DeepSeek run has a contradictory check.** Its
    `layout_replaced` check reads `pass: false` with detail "Layouts.app
    differs from the generator's stock nav+footer". The detail string was
    written for the pass case. It is out of the report already, but the
    string bug may still be in the harness.
15. **The `test` check measures nothing model-specific.** It passes on the
    generator's own four tests, which none of the models touched. Consider a
    check that requires at least one new test file, or a hidden LiveView
    test that mounts HomeLive, sends `:tick`, and asserts 99.
16. **The `nav` and `countdown` checks are regex-only.** They passed for all
    three and would also pass for a page that does not render. `boots`
    catches the crash case, but nothing verifies the tick actually
    decrements over the wire. The 11-second CDP capture in this review did
    that by hand; it is cheap to automate.
17. **helm SHAs differ across the three coding runs** (`6629000`,
    `fd0c053`, `f20cefe`). The doc says the differences are docs and one
    failure-classifier regex, and the `harness` blocks compare equal. Fine,
    but pin one SHA next time so the sentence is unnecessary.
18a. **No reasoning effort was sent.** Found while reviewing round 2: the
    helm SHAs of this round predate the effort dial, so `reasoning_effort`
    was never on the wire and every model ran at its chat template's
    default: Qwen `xhigh`, DeepSeek `low` (the server's default kwargs),
    and GLM with thinking **off** altogether (its template labelled the
    empty think block `max`; corrected 2026-09-06, see round 4's
    `REPORT.md` §1a). The three-way tie was reached with the two slower
    models at their maximum effort and DeepSeek at its minimum. Details and
    the DeepSeek effort ladder are in round 2's `REPORT.md`, §5 item 11.
18. **The working-method system prompt was not in effect** (documented in
    `design/CODING_BENCH.md`). Items 9, 10 and 11 above are exactly the behaviours
    that paragraph targets ("background jobs for servers", "file tools not
    bash"), so its absence probably cost DeepSeek and GLM the most.

## 6. Recommendations for the next run

1. Restore or regenerate `raw/dsv4-rerun.json`, and warm all three engines
   the same way before the 256-token rows.
2. Use natural-text filler for the prompts, and run the decode rows twice:
   once as now, once with speculative decoding disabled, so the table shows
   what the draft model buys.
3. Align `--max-num-batched-tokens` before comparing concurrency, and add a
   c=2 / c=8 row at 8k so scaling is a curve, not a point.
4. Restart helm so the working-method paragraph is actually sent, then
   re-run the coding bench as a new row.
5. Add fixtures that discriminate: the current 12 are solved in three rounds
   by everyone. Candidates from this review: negative amounts in split_bill,
   backslash/`-n` inputs in safe_echo, a stuck-loop trap like lru_cache's
   tuple-vs-map confusion, and a fixture where the moduledoc is wrong on
   purpose to see who argues.
6. Grade the app on behaviour, not regex: a hidden LiveView test for the
   tick, a mobile-viewport render check for the nav, and lint warnings as a
   score rather than a pass.
7. Record the full final reply, and report `cached_tokens` as "not
   reported" rather than as zero for engines that do not emit it.
