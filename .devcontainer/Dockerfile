FROM debian:bookworm-slim

COPY install.sh /app/install.sh

WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends \
    bash git curl wget unzip tzdata openssl ca-certificates python3 \
    && rm -rf /var/lib/apt/lists/*

RUN chmod +x /app/install.sh && /app/install.sh

COPY config-template.json /app/config-template.json
COPY generate_config.py /app/generate_config.py
COPY startup.sh /app/startup.sh

CMD ["bash", "/app/startup.sh"]
