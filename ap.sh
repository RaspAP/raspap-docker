#!/usr/bin/env bash

set -e # Stop the script on errors
set -u # Unset variables are an error

# Check the script is run as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit 1
fi

this_script_path=$(cd "$(dirname "$0")" && pwd) # Relative, Absolutized and normalized
if [ -z "$this_script_path" ]; then # Error, for some reason, the path is not accessible to the script (e.g. permissions re-evalued after suid)
  exit 1
fi

cd "$this_script_path" || exit 1

IP_AP="10.3.141.1/24"

MAGENTA='\e[0;35m'
RED='\e[0;31m'
GREEN='\e[0;32m'
BLUE='\e[0;34m'
NC='\e[0m'

print_banner() {
  echo -e "${MAGENTA} ____             _               ____                   _    ____  ${NC}"
  echo -e "${MAGENTA}|  _ \  ___   ___| | _____ _ __  |  _ \ __ _ ___ _ __   / \  |  _ \ ${NC}"
  echo -e "${MAGENTA}| | | |/ _ \ / __| |/ / _ \ '__| | |_) / _ \`/___| '_ \ / _ \ | |_) |${NC}"
  echo -e "${MAGENTA}| |_| | (_) | (__|   <  __/ |    |  _ < (_| \__ \ |_) / ___ \|  __/ ${NC}"
  echo -e "${MAGENTA}|____/ \___/ \___|_|\_\___|_|    |_| \_\____|___/ .__/_/   \_\_|    ${NC}"
  echo -e "${MAGENTA}                                                |_|                 ${NC}"
  echo -e "${MAGENTA}                                                           by noxPHX${NC}"
}

init() {

  # Check that the requested interface is available
  if ! [ -e /sys/class/net/"$1" ]; then
    echo -e "${RED}[ERROR]${NC} The interface provided does not exist. Exiting..."
    exit 1
  fi

  # Checking if the docker image has been built
  if [ "$(docker images -q raspap)" == "" ]; then
    echo -e "${RED}[ERROR]${NC} Docker image ${RED}raspap${NC} not found. Exiting..."
    exit 1
  fi

  # Unblock wifi in case of soft lock
  echo -ne "Unblocking wifi as it may be soft locked..."
  rfkill unblock wifi
  echo -e "${GREEN}done${NC}"
}

service_start() {

  # Start the container
  docker-compose up -d

  echo -ne "Preparing network namespace..."

  # Retrieve the docker network namespace and bind it to be able to use it
  pid=$(docker inspect -f '{{.State.Pid}}' "raspap")
  mkdir -p /var/run/netns
  ln -s /proc/"$pid"/ns/net /var/run/netns/raspap

  # Find the physical interface for the given wireless interface and set it in the new network namespace
  iw phy "$(cat /sys/class/net/"$1"/phy80211/name)" set netns name raspap

  # Assign an IP to the wifi interface
  ip netns exec raspap ip a flush dev "$1"
  ip netns exec raspap ip a add "$IP_AP" dev "$1"
  ip netns exec raspap ip l set "$1" up

  # Iptables rules for NAT
  ip netns exec raspap iptables -t nat -A POSTROUTING -j MASQUERADE
  ip netns exec raspap iptables -t nat -A POSTROUTING -s 192.168.50.0/24 ! -d 192.168.50.0/24 -j MASQUERADE

  echo -e "${GREEN}done"
  echo -e "Interface ${GREEN}$1${NC} with IP address ${GREEN}$IP_AP${NC} ready"

  # Start hostapd and dnsmasq in the container
  echo -e "Starting ${GREEN}hostapd${NC}, ${GREEN}dnsmasq${NC} and ${GREEN}wpa_supplicant${NC}"
  docker-compose exec raspap service hostapd start
  docker-compose exec raspap service dnsmasq start
  # FIXME needed to be fully functionnal but for some reason block AP ?
  # docker-compose exec raspap wpa_supplicant -i wlan0 -c /etc/wpa_supplicant/wpa_supplicant.conf -B
}

service_stop() {

  # Remove symbolic link
  rm -f /var/run/netns/raspap
  docker-compose down
  # Flush wlan0 IP address
  ip a flush dev "$1"
}

if [ "$#" -eq 0 ] || [ "$#" -gt 2 ] || [ "$1" == "help" ]; then
  echo "Usage: $0 { start | stop } [ interface ]"
  exit 1
fi

if [ "$1" == "start" ]; then

  if [[ -z "$2" ]]; then
    echo -e "${RED}[ERROR]${NC} No interface provided. Exiting..."
    exit 1
  fi

  service_stop "${2}"
  print_banner
  init "${2}"
  service_start "${2}"

elif [ "$1" == "stop" ]; then

  if [[ -z "$2" ]]; then
    echo -e "${RED}[ERROR]${NC} No interface provided. Exiting..."
    exit 1
  fi

  service_stop "${2}"

else
  echo "Usage: $0 { start | stop } [ interface ]"
fi
