FROM jrei/systemd-debian:10
RUN apt update && apt install -y sudo wget procps curl systemd && rm -rf /var/lib/apt/lists/*
COPY setup.sh .
