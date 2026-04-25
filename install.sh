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

SH_LOC=~/.local/bin/ai
touch $SH_LOC
curl -fsSL https://raw.githubusercontent.com/jinlong11222356/bash-ai-client/refs/heads/main/ai.sh > $SH_LOC
chmod +x $SH_LOC
FORGET_LOC=~/.local/bin/forget
touch $FORGET_LOC
chmod +x $FORGET_LOC
echo "echo '' > $FORGET_LOC"
