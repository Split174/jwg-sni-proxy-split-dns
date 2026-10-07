FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    wget \
    ca-certificates \
    iproute2 \
    nftables \
    iptables \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /usr/local/bin

RUN wget https://raw.githubusercontent.com/Jipok/jwg/refs/heads/master/amneziawg-go && \
    chmod +x amneziawg-go

# Pin jwg. Releases <= 2.2.0 cannot configure the AmneziaWG 3.0/3.1 kernel
# module: it fails with "Failed to configure WireGuard device: invalid
# argument". 2.3.0 adds AmneziaWG 3.0/3.1 support (version-aware handling).
ARG JWG_VERSION=2.3.0
RUN wget "https://github.com/Jipok/jwg/releases/download/${JWG_VERSION}/jwg" -O jwg && \
    chmod +x jwg

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
