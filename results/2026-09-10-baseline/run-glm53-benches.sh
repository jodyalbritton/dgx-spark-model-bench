#!/bin/bash
# the four agent benches on GLM, in sequence, each run inside helm_dev@jobybook (T38)
R=/Users/jody/benchmarks/results/2026-09-10-baseline
M=Mia-AiLab/GLM-5.3-Flash-EXL3-TR3-4bpw:exl3
L=glm53-flash-exl3
cd /Users/jody/Work/helm
for b in fixtures phoenix_app js_app design; do
  echo "=== bench.$b start $(date -u +%H:%M:%SZ)"
  mix bench.$b --model $M --label $L --effort low > $R/$b-glm53.log 2>&1
  echo "=== bench.$b exit $? $(date -u +%H:%M:%SZ)"
done
echo "=== all done $(date -u +%H:%M:%SZ)"
