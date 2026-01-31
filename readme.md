## Demo dockerfile for BitNet 1b llm
microsoft/BitNet 1b llm with CPU inference

https://github.com/microsoft/BitNet
## Build
docker build -t hahihula/bitnet-demo .

## Run demo
docker run -it hahihula/bitnet-demo

## Run with custom prompt
docker run -it hahihula/bitnet-demo python run_inference.py \
    -m models/BitNet-b1.58-2B-4T/ggml-model-i2_s.gguf \
    -p "Tell me a joke about the person who invented the telephone" \
    -n 250

## Interactive mode
docker run -it hahihula/bitnet-demo /bin/bash /app/interactive.sh

## Shell access
docker run -it hahihula/bitnet-demo /bin/bash