#!/bin/bash
set -e

# Flush existing nftables rules
nft flush ruleset

# Apply new nftables rules
nft add table inet filter

# Define filter chains
nft add chain inet filter input { type filter hook input priority 0 \; policy accept \; }
nft add chain inet filter forward { type filter hook forward priority 0 \; policy accept \; }
nft add chain inet filter output { type filter hook output priority 0 \; policy accept \; }

# Allow established and related connections
nft add rule inet filter forward ct state related,established accept

# Allow forwarding between wlan0 and eth0
nft add rule inet filter forward iifname "wlan0" oifname "eth0" accept
nft add rule inet filter forward iifname "eth0" oifname "wlan0" accept

# NAT table
nft add table inet nat
nft add chain inet nat prerouting { type nat hook prerouting priority 0 \; }
nft add chain inet nat postrouting { type nat hook postrouting priority 100 \; }

# Masquerade outgoing traffic on eth0
nft add rule inet nat postrouting oifname "eth0" masquerade

echo "nftables firewall rules applied successfully."

