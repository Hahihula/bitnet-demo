#!/usr/bin/env bash
set -euo pipefail

echo "========================================"
echo "  BitNet CPU Inference Demo"
echo "========================================"
echo ""
echo "Model: BitNet b1.58 2B (i2_s quantization)"
echo "Running on CPU..."
echo ""

exec python run_inference.py \
    -m models/BitNet-b1.58-2B-4T/ggml-model-i2_s.gguf \
    -p "You are a helpful assistant." \
    -n 250 \
    -cnv