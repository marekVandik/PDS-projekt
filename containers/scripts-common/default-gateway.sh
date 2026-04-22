#!/bin/sh

ip route delete default
ip route add default via $1 dev eth0

echo "default gateway set to $1"
