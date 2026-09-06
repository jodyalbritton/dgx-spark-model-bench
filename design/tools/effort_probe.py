#!/usr/bin/env python3
"""Effort ladder: run the round-1 probe question against the model on 127.0.0.1:8081 at each
reasoning_effort grade and print reasoning/answer token counts. Run ON the head node:
    ssh sparky python3 - < design/tools/effort_probe.py
"""
import json, sys, time, urllib.request
BASE="http://127.0.0.1:8081"
Q=("What is the smallest positive integer that leaves a remainder of 1 when divided by each of "
   "2, 3, 4, 5 and 6, and is exactly divisible by 7? Show your reasoning, then give the final "
   "answer on its own line as 'ANSWER: <number>'.")
def post(path, body, timeout=1800):
    req=urllib.request.Request(BASE+path, data=json.dumps(body).encode(), headers={"Content-Type":"application/json"})
    return json.load(urllib.request.urlopen(req, timeout=timeout))
model=post("/v1/models",{}) if False else json.load(urllib.request.urlopen(BASE+"/v1/models"))["data"][0]["id"]
def ntok(text):
    return post("/tokenize",{"model":model,"prompt":text},timeout=120)["count"] if text else 0
print("model:", model)
for effort in [None, "low", "medium", "high", "max"]:
    body={"model":model,"messages":[{"role":"user","content":Q}],"temperature":0,"max_tokens":16384,
          "chat_template_kwargs":{"thinking":True,"enable_thinking":True}}
    if effort: body["reasoning_effort"]=effort
    t0=time.time()
    try:
        r=post("/v1/chat/completions", body)
    except urllib.error.HTTPError as e:
        print(f"effort={effort!s:7s} HTTP {e.code}: {e.read()[:300]}"); continue
    dt=time.time()-t0
    m=r["choices"][0]["message"]; u=r["usage"]
    reasoning=m.get("reasoning_content") or m.get("reasoning") or ""
    content=m.get("content") or ""
    det=u.get("completion_tokens_details") or {}
    rt=det.get("reasoning_tokens"); rt = rt if rt is not None else ntok(reasoning)
    ans=[l for l in content.splitlines() if "ANSWER" in l.upper()]
    print(f"effort={effort!s:7s} reasoning_tok={rt:5d} answer_tok={ntok(content):4d} completion={u['completion_tokens']:5d} "
          f"wall={dt:5.1f}s finish={r['choices'][0]['finish_reason']} correct={'301' in (ans[-1] if ans else content[-200:])}", flush=True)
