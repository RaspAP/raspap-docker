#!/usr/bin/env bash

# Check the script is run as by a user with docker's rights
if [ "$EUID" -ne 0 ]; then
  if ! id -nGz "$USER" | grep -qzxF docker; then
    echo "Please run with docker's rights (either run as root or add yourself to the docker group)"
    exit 1
  fi
fi

this_script_path=$(cd "$(dirname "$0")" && pwd) # Relative, Absolutized and normalized
if [ -z "$this_script_path" ]; then # Error, for some reason, the path is not accessible to the script (e.g. permissions re-evalued after suid)
  exit 1
fi

cd "$this_script_path" || exit 1

force=0
while getopts "f" option; do
  case $option in
  f)
    force=1
    ;;
  *) ;;
  esac
done

# echo "denyinterfaces wlan0" >> /etc/dhcpcd.conf

if [ "$force" = "1" ]; then
  docker-compose build --no-cache
else
  docker-compose build
fi
