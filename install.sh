#!/bin/sh
mkdir ~/.local/share/ai
mkdir ~/.config/ai

touch ~/.local/share/ai/context.json
touch ~/.config/ai/config.json

cat <<EOF > ~/.config/ai/config.json
{
    "endpoint":"",
    "key":"",
    "model":"",
    "persona":""
}
EOF

BINARY_LOC=~/.local/bin/ai
touch $BINARY_LOC
curl -fsSL https://raw.githubusercontent.com/jinlong11222356/bash-ai-client/refs/heads/main/ai.sh > $BINARY_LOC
chmod +x $BINARY_LOC
