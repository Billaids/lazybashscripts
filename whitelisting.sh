#!/bin/bash
#
# I love whitelisting
#
# usage: ./whitelisting Chainname Portnumber

echo "Chainname: $1"
echo "Port: $2"

iptables -N $1 # create a new chain
iptables -A $1 --src xx.xx.xx.xx -j ACCEPT  # allow 1.2.3.4
iptables -A $1 --src xx.xx.xx.xx -j ACCEPT  # allow 1.2.3.4
iptables -A $1 --src xx.xx.xx.xx -j ACCEPT  # allow 1.2.3.4
iptables -A $1 --src xx.xx.xx.xx -j ACCEPT  # allow 1.2.3.4
iptables -A $1 --src xx.xx.xx.xx -j ACCEPT  # allow 1.2.3.4
iptables -A $1 -j DROP  # drop everyone else
iptables -I INPUT -m tcp -p tcp --dport $2 -j $1  # use chain xxx for packets coming to TCP port $2
iptables -I INPUT -m udp -p udp --dport $2 -j $1  # use chain xxx for packets coming to UDP port $2
