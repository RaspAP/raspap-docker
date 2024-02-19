![raspap-docker-repository](https://github.com/RaspAP/raspap-docker/assets/229399/c055fa68-ec85-4eb8-9bd2-4f793744bbfc)

# raspap-docker
A community-led docker container for RaspAP. Read the [documentation](https://docs.raspap.com/docker/) or jump straight into the usage notes.

# Usage
```
docker run --name raspap -it -d --privileged --network=host -v /sys/fs/cgroup:/sys/fs/cgroup:ro --cap-add SYS_ADMIN ghcr.io/raspap/raspap-docker:latest
```
Web GUI should be accessible on http://localhost by default

## Workaround for ARM devices
To use this container on ARM devices you have to make cgroups writable:
```
docker run --name raspap -it -d --privileged --network=host --cgroupns=host -v /sys/fs/cgroup:/sys/fs/cgroup:rw --cap-add SYS_ADMIN ghcr.io/raspap/raspap-docker:latest
```
Web GUI should be accessible on http://localhost by default

## Allow WiFi-clients to connect to LAN and internet
Because of docker isolation and security defaults the following rules must be added on the docker host:
```
iptables -I DOCKER-USER -i src_if -o dst_if -j ACCEPT
iptables -t nat -C POSTROUTING -o eth0 -j MASQUERADE || iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
iptables -C FORWARD -i eth0 -o wlan0 -m state --state RELATED,ESTABLISHED -j ACCEPT || iptables -A FORWARD -i eth0 -o wlan0 -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -C FORWARD -i wlan0 -o eth0 -j ACCEPT || iptables -A FORWARD -i wlan0 -o eth0 -j ACCEPT
iptables-save
```
## Deploying using docker-compose
Use the `docker-compose.yaml` file to deploy RaspAP using docker compose.
**Do not use `docker-compose` but rather `docker compose`**. For ARM devices, be sure to uncomment the `cgroup: host` line before executing `docker compose`:
```bash
git clone https://github.com/RaspAP/raspap-docker.git
cd raspap-docker
docker compose up -d
```

## Environment Variables
Several environment variables are made available in this docker image to aid in configuration.

| Environment Variable   | Description                                      | Default       |
|------------------------|--------------------------------------------------|---------------|
| RASPAP_SSID            | The SSID name                                    | raspap-webgui |
| RASPAP_SSID_PASS       | The SSID password                                | ChangeMe      |
| RASPAP_COUNTRY         | The SSID country code                            | GB            |
| RASPAP_WEBGUI_USER     | The admin username for the RaspAP user interface | admin         |
| RASPAP_WEBGUI_PASSWORD | The admin password for the RaspAP user interface | secret        |
| RASPAP_WEBGUI_PORT     | The RaspAP web user interface port               | 80            |

Some further configuration is also possible through the use of the following prefixed environment variables, in the form RASAPAP_\[target]_\[key]

| Environment Variable Prefix | Target File                    |
|-----------------------------|--------------------------------|
| RASPAP_hostapd_             | /etc/hostapd/hostapd.conf      |
| RASPAP_raspap_              | /etc/dnsmasq.d/090_raspap.conf |
| RASPAP_wlan0_               | /etc/dnsmasq.d/090_wlan0.conf  |

For example, `RASPAP_hostapd_driver` would set the `driver` value in `/etc/hostapd/hostapd.conf`
