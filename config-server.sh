#!/bin/bash

#Copy example config file
cp /usr/share/doc/openvpn/examples/sample-config-files/server.conf.gz /etc/openvpn/
gzip -d /etc/openvpn/server.conf.gz

#edit HMAC
#edit cipher
#add HMAC algorithm
#align dh parameter
#set user and group