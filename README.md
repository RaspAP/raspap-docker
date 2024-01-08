![raspap-docker-repository](https://user-images.githubusercontent.com/229399/111151581-edb7df00-858f-11eb-8e3a-3ac11c3c04b7.png)


# raspap-docker
A community-led docker container for RaspAP

# Usage
```
docker run --name raspap -it -d --privileged --network=host -v /sys/fs/cgroup:/sys/fs/cgroup:ro --cap-add SYS_ADMIN ghcr.io/raspap/raspap-docker:latest
docker exec -it raspap bash
$ ./setup.sh
docker restart raspap
Web GUI should be accessible on http://localhost by default
```
## Workaround for arm devices
To use this container on arm devices you have to make cgroups writable:
```
docker run --name raspap -it -d --privileged --network=host --cgroupns=host -v /sys/fs/cgroup:/sys/fs/cgroup:rw --cap-add SYS_ADMIN ghcr.io/raspap/raspap-docker:latest
docker exec -it raspap bash
$ ./setup.sh
docker restart raspap
Web GUI should be accessible on http://localhost by default
```
## Allow WiFi-clients to connect to LAN and internet
Because of docker isolation and security defaults the following rules must be added in the docker container:
```
iptables -I DOCKER-USER -i src_if -o dst_if -j ACCEPT
iptables -t nat -C POSTROUTING -o eth0 -j MASQUERADE || iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
iptables -C FORWARD -i eth0 -o wlan0 -m state --state RELATED,ESTABLISHED -j ACCEPT || iptables -A FORWARD -i eth0 -o wlan0 -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -C FORWARD -i wlan0 -o eth0 -j ACCEPT || iptables -A FORWARD -i wlan0 -o eth0 -j ACCEPT
iptables-save
```
