import os
import json
import uuid

def get_env(name, default=''):
    return os.environ.get(name, default)

def main():
    UUID = get_env('G2RAY_UUID', str(uuid.uuid4()))
    PORT = int(get_env('G2RAY_PORT', '443'))
    NETWORK = get_env('G2RAY_NETWORK', 'xhttp')
    PATH_VAL = get_env('G2RAY_PATH', '/')
    CODESPACE = get_env('CODESPACE_NAME', 'g2ray')
    SNI = get_env('G2RAY_SNI', CODESPACE + '-' + PORT + '.app.github.dev')
    TLS = get_env('G2RAY_TLS', 'true').lower() == 'true'
    MODE = get_env('G2RAY_MODE', 'packet-up')
    FRAG = get_env('G2RAY_FRAGMENT', 'false').lower() == 'true'
    FRAG_LEN = get_env('G2RAY_FRAG_LEN', '100-200')
    FRAG_INT = get_env('G2RAY_FRAG_INT', '10-20')
    REALITY = get_env('G2RAY_REALITY', 'false').lower() == 'true'
    REALITY_PK = get_env('G2RAY_REALITY_PK', '')
    REALITY_SID = get_env('G2RAY_REALITY_SID', '')
    REALITY_SNI = get_env('G2RAY_REALITY_SNI', SNI)
    HOST_IP = get_env('G2RAY_HOST', '94.130.50.12')
    FP = get_env('G2RAY_FP', 'chrome')
    WS_EARLY = get_env('G2RAY_WS_EARLY', 'true').lower() == 'true'
    WS_HOST = get_env('G2RAY_WS_HOST', 'example.com')
    H2_HOST = get_env('G2RAY_H2_HOST', 'example.com')
    H2_PATH = get_env('G2RAY_H2_PATH', '/')
    GRPC_SVC = get_env('G2RAY_GRPC_SVC', 'test')
    GRPC_MULTI = get_env('G2RAY_GRPC_MULTI', 'false').lower() == 'true'
    NOISE = get_env('G2RAY_NOISE', 'false').lower() == 'true'
    NOISE_PKT = get_env('G2RAY_NOISE_PKT', 'd200')
    NOISE_SRC = get_env('G2RAY_NOISE_SRC', '')

    inbound = {
        'tag': 'vless-in',
        'port': int(PORT),
        'protocol': 'vless',
        'settings': {
            'clients': [{'id': UUID, 'flow': ''}],
            'decryption': 'none'
        }
    }

    stream = {}

    if NETWORK == 'ws':
        ws = {'path': PATH_VAL, 'headers': {'Host': WS_HOST}}
        if WS_EARLY:
            ws['maxEarlyData'] = 2048
            ws['earlyDataHeaderName'] = 'Sec-WebSocket-Protocol'
        stream['wsSettings'] = ws
    elif NETWORK == 'h2':
        stream['httpSettings'] = {'host': [H2_HOST], 'path': H2_PATH}
    elif NETWORK == 'grpc':
        grpc = {'serviceName': GRPC_SVC, 'multiMode': GRPC_MULTI}
        stream['grpcSettings'] = grpc
    else:
        stream['xhttpSettings'] = {'mode': MODE, 'path': PATH_VAL}

    if TLS:
        stream['security'] = 'tls'
        if REALITY:
            stream['tlsSettings'] = {'serverNames': [SNI]}
            stream['realitySettings'] = {
                'publicKey': REALITY_PK,
                'shortId': REALITY_SID,
                'serverNames': [REALITY_SNI]
            }
            if FP:
                stream['realitySettings']['fingerprint'] = FP
        else:
            stream['tlsSettings'] = {'serverNames': [SNI]}
            if FP:
                stream['tlsSettings']['fingerprint'] = FP

    inbound['streamSettings'] = stream

    config = {
        'log': {'loglevel': 'warning'},
        'inbounds': [inbound],
        'outbounds': [{'tag': 'direct', 'protocol': 'freedom', 'settings': {}}]
    }

    if FRAG:
        config['outbounds'].insert(0, {
            'tag': 'fragment-out',
            'protocol': 'freedom',
            'settings': {
                'fragment': {
                    'packets': 'tlshello',
                    'length': FRAG_LEN,
                    'interval': {'min': FRAG_INT.split('-')[0], 'max': FRAG_INT.split('-')[1]}
                }
            }
        })
        config['outbounds'].insert(0, {
            'tag': 'proxy-out',
            'protocol': 'vless',
            'settings': {
                'vnext': [{
                    'address': HOST_IP,
                    'port': int(PORT),
                    'users': [{'id': UUID, 'encryption': 'none'}]
                }]
            },
            'streamSettings': stream
        })

    if NOISE:
        config['outbounds'].insert(0, {
            'tag': 'noise-out',
            'protocol': 'noise',
            'settings': [{'type': 'udp', 'packet': NOISE_PKT, 'source': NOISE_SRC}]
        })

    os.makedirs('/etc/xray', exist_ok=True)
    with open('/etc/xray/g2ray.json', 'w') as f:
        json.dump(config, f, indent=2)

    print('Config written to /etc/xray/g2ray.json')

if __name__ == '__main__':
    main()
