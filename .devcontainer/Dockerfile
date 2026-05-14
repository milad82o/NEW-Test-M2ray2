FROM debian:bookworm-slim

COPY setup.sh /tmp/setup.sh
COPY config.json /etc/xray/g2ray.json

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       bash curl wget unzip ca-certificates openssl python3 \
    && rm -rf /var/lib/apt/lists/* \
    && chmod +x /tmp/setup.sh \
    && /tmp/setup.sh \
    && rm /tmp/setup.sh

COPY generate_config.py /app/generate_config.py

RUN echo 'printf "\n\033[1;32m[g2ray]\033[0m Connection string:\n"' >> /etc/bash.bashrc

EXPOSE 3000 443

CMD ["bash", "/app/startup.sh"]
