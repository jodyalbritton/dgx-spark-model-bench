#!/usr/bin/env python3
"""Spark cluster inference benchmark (stdlib only).

Per prompt size: TTFT, prefill tok/s (prompt_tokens / TTFT), decode tok/s
(fixed 128-token output, thinking off, ignore_eos), at c=1; plus c=N
aggregate at short prompts. Then one reasoning probe with thinking on:
reasoning tokens, answer tokens, wall time, correctness.

Usage: spark_bench.py --base-url http://127.0.0.1:8081 --model <id> --label glm53 --out raw.json
"""
import argparse, json, statistics, sys, time, urllib.request, urllib.error
from concurrent.futures import ThreadPoolExecutor

HDR = {"Content-Type": "application/json"}
NO_THINK = {"thinking": False, "enable_thinking": False}

def post(base, path, body, timeout=3600):
    for attempt in range(3):
        req = urllib.request.Request(base + path, data=json.dumps(body).encode(), headers=HDR)
        try:
            with urllib.request.urlopen(req, timeout=timeout) as r:
                return json.load(r)
        except urllib.error.URLError as e:
            if attempt == 2: raise
            time.sleep(2 ** attempt)

def get(base, path):
    try:
        with urllib.request.urlopen(base + path, timeout=30) as r:
            return json.load(r)
    except Exception as e:
        return {"error": str(e)}

def count_tokens(base, model, text):
    return post(base, "/tokenize", {"model": model, "prompt": text}, timeout=600)["count"]

def build_prompt(base, model, target, nonce):
    unit = "benchmark context datum "
    head = f"unique request {nonce} "
    # calibrate tokens per unit once, then build in one shot and trim/extend
    sample = head + unit * 200
    per_unit = (count_tokens(base, model, sample) - count_tokens(base, model, head)) / 200
    n = max(1, int(target / per_unit))
    text = head + unit * n
    for _ in range(6):
        c = count_tokens(base, model, text)
        if abs(c - target) <= max(8, target // 200):
            return text, c
        n = max(1, int(n * target / max(1, c)))
        text = head + unit * n
    return text, count_tokens(base, model, text)

def stream_chat(base, model, messages, extra, timeout=3600):
    body = {"model": model, "messages": messages, "stream": True,
            "stream_options": {"include_usage": True}}
    body.update(extra)
    req = urllib.request.Request(base + "/v1/chat/completions", data=json.dumps(body).encode(), headers=HDR)
    t0 = time.perf_counter(); first = None; usage = None; reasoning = []; content = []; finish = None
    with urllib.request.urlopen(req, timeout=timeout) as r:
        for raw in r:
            line = raw.decode().strip()
            if not line.startswith("data: ") or line == "data: [DONE]": continue
            ev = json.loads(line[6:])
            ch = ev.get("choices") or []
            d = ch[0].get("delta", {}) if ch else {}
            rs = d.get("reasoning") or d.get("reasoning_content") or ""
            ct = d.get("content") or ""
            if first is None and (rs or ct): first = time.perf_counter()
            if rs: reasoning.append(rs)
            if ct: content.append(ct)
            if ch and ch[0].get("finish_reason"): finish = ch[0]["finish_reason"]
            if ev.get("usage"): usage = ev["usage"]
    t1 = time.perf_counter()
    u = usage or {}
    out_tok = u.get("completion_tokens") or 0
    return {"ttft_s": (first or t1) - t0, "elapsed_s": t1 - t0,
            "prompt_tokens": u.get("prompt_tokens", 0), "completion_tokens": out_tok,
            "decode_tok_s": (out_tok / max(1e-3, t1 - first)) if first and out_tok else None,
            "prefill_tok_s": u.get("prompt_tokens", 0) / max(1e-3, (first or t1) - t0),
            "finish_reason": finish, "usage": u,
            "reasoning_text": "".join(reasoning), "content_text": "".join(content)}

def decode_case(base, model, prompt, out_tokens):
    msgs = [{"role": "user", "content": prompt + "\nReturn exactly 128 numbered lowercase English words, then stop."}]
    extra = {"temperature": 0.6, "top_p": 0.95, "max_tokens": out_tokens, "min_tokens": out_tokens,
             "ignore_eos": True, "chat_template_kwargs": NO_THINK}
    r = stream_chat(base, model, msgs, extra)
    r.pop("reasoning_text"); r.pop("content_text")
    return r

def run_size(base, model, target, conc, out_tokens, log):
    prompts = [build_prompt(base, model, target, f"p{target}-c{conc}-r{i}-{time.time_ns()}") for i in range(conc)]
    t0 = time.perf_counter()
    with ThreadPoolExecutor(max_workers=conc) as ex:
        res = list(ex.map(lambda p: decode_case(base, model, p[0], out_tokens), prompts))
    el = time.perf_counter() - t0
    case = {"target_prompt_tokens": target, "concurrency": conc, "wall_s": el,
            "actual_prompt_tokens": [r["prompt_tokens"] for r in res],
            "median_ttft_s": statistics.median(r["ttft_s"] for r in res),
            "median_prefill_tok_s": statistics.median(r["prefill_tok_s"] for r in res),
            "median_decode_tok_s": statistics.median(r["decode_tok_s"] or 0 for r in res),
            "aggregate_decode_tok_s": sum(r["completion_tokens"] for r in res) / max(1e-3, el),
            "requests": res}
    log(f"size={target:>7} c={conc} prompt={case['actual_prompt_tokens'][0]:>7} ttft={case['median_ttft_s']:8.2f}s "
        f"prefill={case['median_prefill_tok_s']:9.1f} tok/s decode={case['median_decode_tok_s']:6.1f} tok/s "
        f"agg={case['aggregate_decode_tok_s']:6.1f} tok/s")
    return case

QUESTION = ("What is the smallest positive integer that leaves a remainder of 1 when divided by each of "
            "2, 3, 4, 5 and 6, and is exactly divisible by 7? Show your reasoning, then give the final "
            "answer on its own line as 'ANSWER: <number>'.")
EXPECTED = "301"

def reasoning_probe(base, model, max_tokens, log):
    msgs = [{"role": "user", "content": QUESTION}]
    extra = {"temperature": 0.0, "max_tokens": max_tokens,
             "chat_template_kwargs": {"thinking": True, "enable_thinking": True}}
    r = stream_chat(base, model, msgs, extra)
    u = r["usage"]; det = u.get("completion_tokens_details") or {}
    rt = det.get("reasoning_tokens")
    if rt is None:
        rt = count_tokens(base, model, r["reasoning_text"]) if r["reasoning_text"] else 0
    ans_text = r["content_text"]
    ans_tok = count_tokens(base, model, ans_text) if ans_text else 0
    last = [l for l in ans_text.splitlines() if "ANSWER" in l.upper()]
    correct = EXPECTED in (last[-1] if last else ans_text[-200:])
    probe = {"question": QUESTION, "expected": EXPECTED, "correct": correct,
             "reasoning_tokens": rt, "answer_tokens": ans_tok, "completion_tokens": u.get("completion_tokens"),
             "ttft_s": r["ttft_s"], "elapsed_s": r["elapsed_s"], "decode_tok_s": r["decode_tok_s"],
             "finish_reason": r["finish_reason"], "reasoning_text": r["reasoning_text"], "answer_text": ans_text}
    log(f"probe correct={correct} reasoning_tokens={rt} answer_tokens={ans_tok} total={u.get('completion_tokens')} "
        f"time={r['elapsed_s']:.1f}s decode={r['decode_tok_s'] or 0:.1f} tok/s finish={r['finish_reason']}")
    return probe

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--base-url", required=True); ap.add_argument("--model", required=True)
    ap.add_argument("--label", required=True); ap.add_argument("--out", required=True)
    ap.add_argument("--sizes", default="256,2048,8192,32768,65536,102400,153600")
    ap.add_argument("--conc-sizes", default="256,8192"); ap.add_argument("--conc", type=int, default=4)
    ap.add_argument("--out-tokens", type=int, default=128); ap.add_argument("--probe-max-tokens", type=int, default=16384)
    ap.add_argument("--agent-url", default="")
    a = ap.parse_args()
    def log(s): print(time.strftime("%H:%M:%S"), s, flush=True)
    base = a.base_url.rstrip("/")
    report = {"label": a.label, "model": a.model, "base_url": base, "started_utc": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()),
              "server": {"models": get(base, "/v1/models"), "version": get(base, "/version")},
              "agent_slots": get(a.agent_url, "/slots") if a.agent_url else None,
              "out_tokens": a.out_tokens, "cases": [], "probe": None}
    def save(): open(a.out, "w").write(json.dumps(report, indent=1))
    log(f"warmup"); decode_case(base, a.model, "warmup " * 50, 32)
    for s in [int(x) for x in a.sizes.split(",")]:
        try: report["cases"].append(run_size(base, a.model, s, 1, a.out_tokens, log))
        except Exception as e: log(f"size={s} c=1 FAILED: {e}"); report["cases"].append({"target_prompt_tokens": s, "concurrency": 1, "error": str(e)})
        save()
    for s in [int(x) for x in a.conc_sizes.split(",") if x]:
        try: report["cases"].append(run_size(base, a.model, s, a.conc, a.out_tokens, log))
        except Exception as e: log(f"size={s} c={a.conc} FAILED: {e}"); report["cases"].append({"target_prompt_tokens": s, "concurrency": a.conc, "error": str(e)})
        save()
    try: report["probe"] = reasoning_probe(base, a.model, a.probe_max_tokens, log)
    except Exception as e: log(f"probe FAILED: {e}"); report["probe"] = {"error": str(e)}
    report["finished_utc"] = time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()); save(); log("done")

if __name__ == "__main__": main()
