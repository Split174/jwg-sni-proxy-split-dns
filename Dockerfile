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

RUN wget https://github.com/Jipok/jwg/releases/latest/download/jwg && \
    chmod +x jwg

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
