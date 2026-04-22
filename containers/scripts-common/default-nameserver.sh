#!/bin/sh

echo "nameserver $1" > /etc/resolv.conf

echo "nameserver set to $1"
