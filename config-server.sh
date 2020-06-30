#!/bin/bash

#Copy example config file
cp /usr/share/doc/openvpn/examples/sample-config-files/server.conf.gz /etc/openvpn/
gzip -d /etc/openvpn/server.conf.gz

#Enable HMAC
sed -i '/;tls-auth ta.key 0 # This file is secret/ctls-auth ta.key 0 # This file is secret' /etc/server.conf

#Edit the cryptographic cipher
sed -i '/;cipher AES-256-CBC/ccipher AES-256-CBC' /etc/server.conf

#Add HMAC algorithm
sed -i '/cipher AES-256-CBC/aauth SHA256' /etc/server.conf

#Align Diffie-Hellman filename
sed -i '/dh dh2048.pem/cdh dh.pem' /etc/server.conf

#set user and group