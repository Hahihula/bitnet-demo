#!/usr/bin/env bash
set -euo pipefail

echo "BitNet Interactive Mode"
echo "Enter your prompt (or type \"exit\" to quit):"

while true; do
    read -r -p "> " user_prompt
    if [[ "$user_prompt" == "exit" ]]; then
        break
    fi
    python run_inference.py \
        -m models/BitNet-b1.58-2B-4T/ggml-model-i2_s.gguf \
        -p "$user_prompt" \
        -n 200 \
        -temp 0.7 \
        -t 6                  # adjust to your runner cores
    echo ""
done