#!/usr/bin/env python3
"""Render docs/realworld-*.svg from results/<round>/raw/rounds/<label>-app.csv (stdlib only).

usage: realworld_charts.py [round_dir]   default results/2026-09-05-r2
The CSVs come from helm's turn_usage.round_metrics; see REALWORLD.md § Method.
"""
import csv, os, sys, statistics as st
ROOT=os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
ROUND=sys.argv[1] if len(sys.argv)>1 else os.path.join(ROOT,'results','2026-09-07')
SERIES=[('DeepSeek-V4-Flash','dsv4-flash-vision-exp','#2a78d6'),
        ('Qwen3.8-Flash-Next','qwen38-flash-next-nvfp4','#eb6834'),
        ('GLM-5.3-Flash','glm53-flash-exl3','#1baf7a')]
data=[]
for name,label,color in SERIES:
    p=os.path.join(ROUND,'raw','rounds',f'{label}-app.csv')
    if not os.path.exists(p): continue
    rows=[{k:(float(v) if v not in ('','None') else None) for k,v in r.items()} for r in csv.DictReader(open(p))]
    data.append((name,rows,color))
W,H=900,420; L,R,T,B=70,70,40,56
ROUND_NAME=os.path.basename(os.path.realpath(ROUND))
SUB=f'Application task, effort low, one session per model. Source: helm turn_usage ledger, round {ROUND_NAME}.'
def head(title): return f'<svg xmlns="http://www.w3.org/2000/svg" width="{W}" height="{H}" viewBox="0 0 {W} {H}" font-family="-apple-system,Segoe UI,Helvetica,Arial,sans-serif" font-size="12"><rect width="{W}" height="{H}" fill="#fcfcfb"/><text x="{L}" y="22" font-size="15" font-weight="600" fill="#0b0b0b">{title}</text><text x="{L}" y="{H-8}" fill="#52514e">{SUB}</text>'
def axes(xmax,ymax,xlab,ylab,xfmt,yfmt,xt,yt):
    s=''
    for v in yt:
        y=T+(H-T-B)*(1-v/ymax); s+=f'<line x1="{L}" x2="{W-R}" y1="{y:.1f}" y2="{y:.1f}" stroke="#e6e5e0"/><text x="{L-8}" y="{y+4:.1f}" text-anchor="end" fill="#52514e">{yfmt(v)}</text>'
    for v in xt:
        x=L+(W-L-R)*v/xmax; s+=f'<text x="{x:.1f}" y="{H-B+16}" text-anchor="middle" fill="#52514e">{xfmt(v)}</text>'
    s+=f'<line x1="{L}" x2="{W-R}" y1="{H-B}" y2="{H-B}" stroke="#c3c2b7"/><text x="{(L+W-R)/2}" y="{H-B+32}" text-anchor="middle" fill="#52514e">{xlab}</text><text transform="translate(16,{(T+H-B)/2}) rotate(-90)" text-anchor="middle" fill="#52514e">{ylab}</text>'
    return s
def legend():
    s=''; x=L
    for name,_,color in data:
        s+=f'<line x1="{x}" x2="{x+22}" y1="{T-8}" y2="{T-8}" stroke="{color}" stroke-width="2.5"/><text x="{x+28}" y="{T-4}" fill="#0b0b0b">{name}</text>'; x+=28+len(name)*6.6+20
    return s
X=lambda v,m: L+(W-L-R)*min(v,m)/m
Y=lambda v,m: T+(H-T-B)*(1-min(v,m)/m)
# chart 1: context per round
xmax=max(len(r) for _,r,_ in data)
ymax=int((max(r['prompt_tokens'] for _,rows,_ in data for r in rows)//20000+1)*20000)
s=head('Context grows every round: prompt tokens the model re-reads, per tool-calling round')
s+=axes(xmax,ymax,'tool-calling round','prompt tokens',lambda v:f'{int(v)}',lambda v:f'{int(v/1000)}k',range(0,xmax+1,20),range(0,ymax+1,20000))
def decollide(items):
    items=sorted(items,key=lambda e:e[1])
    for i,e in enumerate(items):
        for prev in items[:i]:
            if abs(e[1]-prev[1])<13: e[1]=prev[1]+13
    return items
ends=[]
for name,rows,color in data:
    s+='<polyline points="'+' '.join(f'{X(r["round"],xmax):.1f},{Y(r["prompt_tokens"],ymax):.1f}' for r in rows)+f'" fill="none" stroke="{color}" stroke-width="2"/>'
    last=rows[-1]; x=X(last["round"],xmax); y=Y(last["prompt_tokens"],ymax)
    s+=f'<circle cx="{x:.1f}" cy="{y:.1f}" r="4" fill="{color}" stroke="#fcfcfb" stroke-width="2"/>'
    ends.append([x,y,f'{int(last["prompt_tokens"]/1000)}k'])
for x,y,label in decollide(ends):
    s+=f'<text x="{x+8:.1f}" y="{y+4:.1f}" fill="#0b0b0b">{label}</text>'
s+=legend()+'</svg>'
open(os.path.join(ROOT,'docs','realworld-context-per-round.svg'),'w').write(s)
# chart 2: end-to-end tok/s vs context
xmax2=ymax; ymax2=80
s=head('Throughput you actually wait on: output tok/s per round, prefill included, against context size')
s+=axes(xmax2,ymax2,'prompt tokens in that round (dots: rounds with 64+ output tokens; lines: median per 10k band)','output tok/s, round end to end',lambda v:f'{int(v/1000)}k',lambda v:f'{int(v)}',range(0,xmax2+1,20000),range(0,ymax2+1,20))
ends2=[]
for name,rows,color in data:
    pts=[(r['prompt_tokens'],r['tok_s_end_to_end']) for r in rows if r['tok_s_end_to_end'] and r['completion_tokens']>=64]
    for px,py in pts: s+=f'<circle cx="{X(px,xmax2):.1f}" cy="{Y(py,ymax2):.1f}" r="3.5" fill="{color}" fill-opacity="0.35" stroke="#fcfcfb" stroke-width="1"/>'
    bands={}
    for px,py in pts: bands.setdefault(int(px//10000),[]).append(py)
    med=[((b+0.5)*10000, st.median(v)) for b,v in sorted(bands.items()) if len(v)>=3]
    if med:
        s+='<polyline points="'+' '.join(f'{X(x,xmax2):.1f},{Y(y,ymax2):.1f}' for x,y in med)+f'" fill="none" stroke="{color}" stroke-width="2.5"/>'
        x,y=med[-1]; ends2.append([X(x,xmax2),Y(y,ymax2),f'{y:.0f}'])
for x,y,label in decollide(ends2):
    s+=f'<text x="{x+8:.1f}" y="{y+4:.1f}" fill="#0b0b0b" font-weight="600">{label}</text>'
s+=legend()+'</svg>'
open(os.path.join(ROOT,'docs','realworld-toks-vs-context.svg'),'w').write(s)
print('charts written:', [n for n,_,_ in data])
