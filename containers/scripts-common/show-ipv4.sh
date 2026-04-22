#!/bin/sh

dev_ip=$(ip a s dev $1 | grep "inet" | awk '{ print $2 }')

echo "dev $1 inet addr $dev_ip"
