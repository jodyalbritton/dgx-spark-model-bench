#!/bin/bash
# the four agent benches on Qwen, in sequence, detached from any tool timeout
R=/Users/jody/benchmarks/results/2026-09-10-baseline
M=RadixArk/Qwen3.8-Flash-Next-NVFP4:modelopt
L=qwen38-flash-next-nvfp4
cd /Users/jody/Work/helm
for b in fixtures phoenix_app js_app design; do
  echo "=== bench.$b start $(date -u +%H:%M:%SZ)"
  mix bench.$b --model $M --label $L --effort low --allow-dirty > $R/$b-qwen38.log 2>&1
  echo "=== bench.$b exit $? $(date -u +%H:%M:%SZ)"
done
echo "=== all done $(date -u +%H:%M:%SZ)"
