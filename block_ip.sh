#!/bin/bash
#
# just a simple ipblock

iptables -A INPUT -s $1 -j DROP
if [ $? -eq 0 ];
then
    echo "Successfully blocked $1"
else
    echo "Couldn't block IP-Address"
fi
