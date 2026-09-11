#!/bin/bash
# the four agent benches on DeepSeek, in sequence, each run inside helm_dev@jobybook (T38)
R=/Users/jody/benchmarks/results/2026-09-10-baseline
M=deepseek-ai/DeepSeek-V4-Flash-Vision-Exp:fp8
L=dsv4-flash-vision-exp
cd /Users/jody/Work/helm
for b in fixtures phoenix_app js_app design; do
  echo "=== bench.$b start $(date -u +%H:%M:%SZ)"
  mix bench.$b --model $M --label $L --effort low > $R/$b-dsv4.log 2>&1
  echo "=== bench.$b exit $? $(date -u +%H:%M:%SZ)"
done
echo "=== all done $(date -u +%H:%M:%SZ)"
