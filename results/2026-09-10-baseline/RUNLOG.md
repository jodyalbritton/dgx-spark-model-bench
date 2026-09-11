# 2026-09-10-baseline — three runs per model on the merged harness

helm `8e15c3a` (main, clean tree; T35 merged). Seven arms; three repeats
on the realistic arms, five on the two cells; ingest alternating
uncached/cached; warm-up on the ingest prompt; decode window first delta
to last; spoiled cases re-run and kept as `rejected`; prefill floor
1,000. Rendered `RESULTS.md` is the record; this log states what was
run and what held.

## GLM 5.3 Flash EXL3 — three runs, back to back

`glm53-flash-exl3-r1` 05:50:49–05:59:53 UTC · `-r2` 05:59:54–06:08:59 ·
`-r3` 06:09:01–06:17:46 (2026-09-11 UTC; the evening of 2026-09-10 in
Jody's timezone). 75 cases, 0 rejected, 0 shared-slot, 0 thinking leaks,
0 JSON parse failures; every acceptance gap within ±6; bracket 83–134 ms.

### Harness changes, checked against the records

| change | evidence |
|---|---|
| warm-up prefills at size | r1 warm-up: 13,186 prompt tokens, 0 cached, TTFT 13.7 s; r2/r3 warm-ups hit the cache (10,752 cached, 3.1 s) |
| ingest alternates | every run: seq 1 and 3 uncached (0 cached, prefill 964–974 tok/s), seq 2 cached (10,752, TTFT 3.0 s, prefill blank) |
| prefill from full prefills only | ingest prefill n=2 per run; spark_bench and recipe blank |
| four paragraphs | ingest `hit_cap` 0/9 (was 3/3 at six) |
| window to last delta | `duration_ms − last_token_ms` median 1–3 ms on GLM's exl3 stream |
| re-run on a shared slot | never triggered; max gap 6 |
| five cell repeats | recipe and spark_bench n=5 in every run |

### Decode, median tok/s per run, [min–max], acceptance

| arm | r1 | r2 | r3 | spread of medians |
|---|---:|---:|---:|---:|
| prose | 25.9 [25.9–26.6] 0.27 | 25.9 [25.4–26.1] 0.27 | 26.2 [26.0–26.7] 0.28 | 1 % |
| json | 25.4 [22.7–25.7] 0.26 | 25.9 [20.9–27.6] 0.29 | 25.9 [22.5–26.2] 0.29 | 2 % |
| recipe | 32.0 [30.5–34.6] 0.37 | 32.1 [27.7–32.5] 0.37 | 30.4 [28.9–32.7] 0.36 | 5 % |
| ingest | 29.8 [29.4–31.8] 0.33 | 29.4 [29.3–31.1] 0.33 | 28.4 [27.0–30.0] 0.31 | 5 % |
| spark_bench | 54.9 [54.7–62.1] 0.81 | 52.9 [46.6–58.0] 0.72 | 56.9 [50.7–62.5] 0.83 | 8 % |
| json_free | 24.9 [22.8–27.2] 0.24 | 30.4 [25.8–31.2] 0.33 | 25.2 [23.1–25.8] 0.25 | 22 % |
| synthetic | 32.0 [30.7–36.8] 0.38 | 25.6 [22.2–41.6] 0.27 | 43.7 [39.9–47.0] 0.58 | 71 % |

Ratios per run — structured/prose 0.978 / 1.002 / 0.988; guided/free
1.018 / 0.854 / 1.029; recipe/prose 1.234 / 1.239 / 1.162;
spark_bench/prose 2.116 / 2.042 / 2.170; synthetic/prose 1.233 / 0.990 /
1.669.

### What the three runs establish

- **The harness reproduces.** Prose, json, recipe, ingest and the
  script cell repeat within 1–8 % of median across three runs on one
  deployment in one half hour, with every case reconciled.
- **Two arms do not repeat on GLM, and the record says why.** `synthetic`
  spans 25.6–43.7 across runs with acceptance 0.27–0.58 on identical
  input at temperature 0; `json_free`'s r2 median (30.4, acceptance
  0.33) sits outside r1 and r3 (24.9, 25.2; 0.24, 0.25). In both, the
  decode moved with the acceptance and the gaps reconcile, so it is the
  engine's drafting that varied, not the measurement. Those two arms'
  medians are not a baseline number for GLM; their ranges are.
- Prose hit the 900 cap in 5 of 9 cases (finish_reason `length`), which
  is the same task on every run and is recorded per case.

The three records are the GLM baseline on this harness. DeepSeek and
Qwen follow, three runs each, in turn.

## DeepSeek V4 Flash Vision Exp — three runs, back to back

`dsv4-flash-vision-exp-r1` 06:29:33–06:36:21 UTC · `-r2` 06:36:22–06:42:35 ·
`-r3` 06:42:36–06:48:54 (2026-09-11 UTC). 75 cases, 0 rejected, 0
shared-slot, 0 thinking leaks; 1 JSON parse failure in each of r1 and
r2 (`json_free`, natural stop, counted for decode); every acceptance gap
within ±5; bracket 74–140 ms.

### Harness changes, checked against the records

| change | evidence |
|---|---|
| warm-up prefills at size | r1 warm-up: 12,734 prompt tokens, 0 cached, **TTFT 29.5 s** (≈ 430 tok/s — the cold prefill that landed inside `ingest 1` on 2026-09-10 now lands in the warm-up); r2/r3 warm-ups cached (12,288), 0.7–0.8 s |
| ingest alternates | seq 1 and 3 uncached in every run, prefill 1,466–1,514 tok/s across all six; seq 2 cached, TTFT 0.47–0.50 s, prefill blank |
| four paragraphs | ingest `hit_cap` 0/9 |
| window to last delta | `duration_ms − last_token_ms` median 1–2 ms |
| re-run on a shared slot | never triggered; max gap 5 |

Still visible after the warm-up: in r1 the first `synthetic` and
`spark_bench` cases (2nd and 3rd of the run) took 6.4 s and 5.9 s to
first token against 0.27–0.84 s for the same cells in r2 and r3. The
warm-up warmed the 12.7k shape; the ~1.2k and ~280-token shapes paid
their own first-time cost on this vLLM build. Medians over five cell
repeats absorb it; the per-case TTFTs are in the record.

### Decode, median tok/s per run, [min–max], acceptance

| arm | r1 | r2 | r3 | spread of medians |
|---|---:|---:|---:|---:|
| prose | 36.9 [34.5–38.5] 0.27 | 36.1 [34.8–37.0] 0.24 | 36.7 [34.2–38.2] 0.27 | 2 % |
| json_free | 35.6 [34.6–37.4] 0.24 | 35.0 [33.5–37.5] 0.25 | 34.9 [34.8–37.7] 0.24 | 2 % |
| recipe | 40.4 [39.6–43.8] 0.30 | 41.0 [38.2–42.2] 0.32 | 41.5 [39.3–41.8] 0.31 | 3 % |
| json | 34.4 [33.8–41.3] 0.25 | 33.6 [33.1–33.9] 0.24 | 35.3 [34.7–36.0] 0.26 | 5 % |
| spark_bench | 53.6 [53.4–54.4] 0.45 | 53.6 [49.3–55.4] 0.44 | 50.8 [42.5–56.2] 0.46 | 6 % |
| ingest | 37.9 [34.6–43.9] 0.31 | 35.1 [32.8–50.6] 0.28 | 35.2 [32.9–40.8] 0.25 | 8 % |
| synthetic | 41.4 [38.9–45.7] 0.34 | 44.7 [37.3–63.8] 0.39 | 43.6 [42.8–47.9] 0.38 | 8 % |

Ratios per run — structured/prose 0.932 / 0.931 / 0.961; guided/free
0.965 / 0.960 / 1.011; recipe/prose 1.096 / 1.138 / 1.130;
spark_bench/prose 1.454 / 1.486 / 1.383; synthetic/prose 1.124 / 1.239 /
1.187.

### What the three runs establish

- **Every arm repeats within 2–8 % of median** across three runs in
  twenty minutes, with every case reconciled. DeepSeek is the steadier
  of the two models so far: its synthetic arm spans 41.4–44.7 where
  GLM's spanned 25.6–43.7.
- Prose 36.1–36.9 agrees with the 2026-09-10 row (35.9) measured on the
  previous harness revision.
- Prose hit the 900 cap in 3 of 9 cases.

The three records are the DeepSeek baseline on this harness. Qwen
follows.

## Qwen 3.8 Flash Next NVFP4 — three runs, back to back

`qwen38-flash-next-nvfp4-r1` 07:04:58–07:10:07 UTC · `-r2` 07:10:08–07:15:19 ·
`-r3` 07:15:21–07:20:29 (2026-09-11 UTC). Same harness commit
`8e15c3a`, but `helm_dirty: true` on all three: at launch the tree
carried an uncommitted edit to `priv/bench/make_report.py` and its test
(report only — nothing under `lib/`), and the runs went ahead with
`--allow-dirty`. 75 cases, 0 rejected, 0 shared-slot, 0 thinking leaks,
0 JSON parse failures, 0 cap hits on any arm; every acceptance gap
within ±2; bracket 71–118 ms.

### Harness changes, checked against the records

| change | evidence |
|---|---|
| warm-up prefills at size | r1 warm-up: 13,718 prompt tokens, 0 cached, TTFT 7.0 s; r2/r3 cached (11,200), 1.3 s |
| ingest alternates | seq 1 and 3 uncached in every run, prefill 2,537–2,872 tok/s; seq 2 cached (9,600–11,200), TTFT 1.1–1.7 s, prefill blank |
| window to last delta | `duration_ms − last_token_ms` median 2–3 ms |
| re-run on a shared slot | never triggered; max gap 2 |

### Decode, median tok/s per run, [min–max], acceptance

| arm | r1 | r2 | r3 | spread of medians |
|---|---:|---:|---:|---:|
| ingest | 43.6 [41.0–46.6] 0.55 | 42.9 [39.9–44.7] 0.53 | 43.4 [42.9–45.5] 0.55 | 1 % |
| json | 49.0 [47.6–51.8] 0.65 | 49.8 [49.1–51.0] 0.66 | 50.2 [48.8–50.3] 0.66 | 2 % |
| recipe | 51.6 [48.2–52.4] 0.71 | 50.5 [48.6–51.5] 0.68 | 51.4 [49.8–52.7] 0.69 | 2 % |
| spark_bench | 59.4 [53.7–60.4] 0.89 | 60.2 [55.9–61.8] 0.91 | 59.1 [57.5–61.5] 0.90 | 2 % |
| json_free | 50.5 [50.1–51.9] 0.68 | 50.8 [50.0–53.6] 0.68 | 49.5 [49.1–51.8] 0.65 | 3 % |
| prose | 48.5 [47.0–48.7] 0.63 | 46.7 [45.5–47.5] 0.60 | 47.2 [45.9–47.3] 0.59 | 4 % |
| synthetic | 54.8 [45.9–55.9] 0.75 | 41.9 [38.0–52.1] 0.51 | 47.5 [44.7–55.6] 0.61 | 31 % |

Ratios per run — structured/prose 1.010 / 1.067 / 1.065; guided/free
0.972 / 0.980 / 1.016; recipe/prose 1.062 / 1.082 / 1.089;
spark_bench/prose 1.222 / 1.290 / 1.251; synthetic/prose 1.129 / 0.897 /
1.005.

### What the three runs establish

- **Six arms repeat within 1–4 % of median** across three runs in
  sixteen minutes, every case reconciled within ±2.
- **Synthetic does not repeat on Qwen either**: 54.8 / 41.9 / 47.5 with
  acceptance 0.75 / 0.51 / 0.61 on identical input at temperature 0.
  Same shape as GLM's (25.6–43.7, acceptance 0.27–0.58). DeepSeek's held
  (41.4–44.7).
- Prose 46.7–48.5 agrees with the 2026-09-10 row (46.7).

The three records are the Qwen baseline on this harness.

## The round, in one table

Three runs per model, medians of the run medians are not computed here;
the per-run figures above and in `RESULTS.md` are the record. Spread of
the three run medians, per arm:

| arm | GLM 5.3 | DeepSeek V4 | Qwen 3.8 |
|---|---:|---:|---:|
| prose | 1 % | 2 % | 4 % |
| json | 2 % | 5 % | 2 % |
| json_free | 22 % | 2 % | 3 % |
| ingest | 5 % | 8 % | 1 % |
| recipe | 5 % | 3 % | 2 % |
| spark_bench | 8 % | 6 % | 2 % |
| synthetic | 71 % | 8 % | 31 % |

225 cases across nine records: 0 rejected, 0 shared-slot, 0 thinking
leaks, 2 JSON parse failures (DeepSeek `json_free`), every acceptance
gap within ±6, every bracket under 141 ms, every uncached ingest case a
full prefill, every warm-up a prefill at size.
