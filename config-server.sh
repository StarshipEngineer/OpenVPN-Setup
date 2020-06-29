#!/bin/bash

#Copy example config file
cp /usr/share/doc/openvpn/examples/sample-config-files/server.conf.gz /etc/openvpn/
gzip -d /etc/openvpn/server.conf.gz

#edit HMAC
sed -i '/;tls-auth ta.key 0 # This file is secret/ctls-auth ta.key 0 # This file is secret' /etc/server.conf


#edit cipher
#add HMAC algorithm

#Align Diffie-Hellman filename
sed -i '/dh dh2048.pem/cdh dh.pem' /etc/server.conf

#set user and group