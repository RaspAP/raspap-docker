# raspap-docker
A community-led docker container for RaspAP

## Tested with : 
 - Raspberry Pi 4 B - 2 GB
 - Raspbian Buster
 - RaspAP v2.6.5

## TODO : 
 - Volumes
 - Handle reboot
 - Full stack with every service?
 - OpenVPN feature
 - AdBlocking feature

## Requirements : 
 - Docker
 - Compose

## Usage
```bash
sudo ./build.sh
sudo ./ap.sh start wlan0
sudo ./ap.sh stop wlan0
```
