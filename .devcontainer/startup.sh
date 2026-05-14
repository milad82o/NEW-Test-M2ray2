#!/bin/bash

UUID="${G2RAY_UUID:-$(python3 -c "import uuid; print(uuid.uuid4())")}"
PORT="${G2RAY_PORT:-443}"
NETWORK="${G2RAY_NETWORK:-xhttp}"
PATH_VAL="${G2RAY_PATH:-/}"
CODESPACE="${CODESPACE_NAME:-g2ray}"
SNI="${G2RAY_SNI:-${CODESPACE}-${PORT}.app.github.dev}"
TLS="${G2RAY_TLS:-true}"
MODE="${G2RAY_MODE:-packet-up}"
FRAG="${G2RAY_FRAGMENT:-false}"
FRAG_LEN="${G2RAY_FRAG_LEN:-100-200}"
FRAG_INT="${G2RAY_FRAG_INT:-10-20}"
REALITY="${G2RAY_REALITY:-false}"
REALITY_PK="${G2RAY_REALITY_PK:-}"
REALITY_SID="${G2RAY_REALITY_SID:-}"
REALITY_SNI="${G2RAY_REALITY_SNI:-}"
HOST_IP="${G2RAY_HOST:-94.130.50.12}"
FP="${G2RAY_FP:-chrome}"
WS_EARLY="${G2RAY_WS_EARLY:-true}"
WS_HOST="${G2RAY_WS_HOST:-example.com}"
H2_HOST="${G2RAY_H2_HOST:-example.com}"
H2_PATH="${G2RAY_H2_PATH:-/}"
GRPC_SVC="${G2RAY_GRPC_SVC:-test}"
GRPC_MULTI="${G2RAY_GRPC_MULTI:-false}"
NOISE="${G2RAY_NOISE:-false}"
NOISE_PKT="${G2RAY_NOISE_PKT:-d200}"
NOISE_SRC="${G2RAY_NOISE_SRC:-}"

echo "======================================"
echo "G2Ray - VLESS Proxy on Codespaces"
echo "======================================"
echo ""
echo "UUID: $UUID"
echo "Port: $PORT"
echo "Network: $NETWORK"
echo "SNI: $SNI"
echo "TLS: $TLS"
echo "Fragment: $FRAG"
echo "Reality: $REALITY"
echo "Codespace: $CODESPACE"
echo ""

python3 /home/sarcheshmeh/g2ray/.devcontainer/generate_config.py

echo ""
echo "======================================"
echo "VLESS Connection Link:"
echo "======================================"

SECURITY="none"
if [ "$TLS" = "true" ]; then
    if [ "$REALITY" = "true" ]; then
        SECURITY="reality"
    else
        SECURITY="tls"
    fi
fi

echo "vless://${UUID}@${HOST_IP}:${PORT}?encryption=none&type=${NETWORK}&security=${SECURITY}&sni=${SNI}#G2Ray-${CODESPACE}"
echo ""
echo "======================================"
echo "Web Configurator:"
echo "======================================"
echo "http://${CODESPACE}-3000.app.github.dev"
echo ""
echo "Start Xray..."
echo ""

exec /usr/local/bin/xray -c /etc/g2ray-generated.json
