FROM ghcr.io/raspap/raspap-docker
RUN apt update && apt install -y sudo wget procps curl systemd && rm -rf /var/lib/apt/lists/*
RUN curl -sL https://install.raspap.com | bash -s -- --yes --wireguard 1 --openvpn 1 --adblock 1
