#!/bin/bash

SERVER_NAME=$1 #First argument must be the name of the server

#Copy example config file
cp /usr/share/doc/openvpn/examples/sample-config-files/server.conf.gz /etc/openvpn/
gzip -d /etc/openvpn/server.conf.gz

#Enable HMAC
sed -i '/;tls-auth ta.key 0 # This file is secret/ctls-auth ta.key 0 # This file is secret' /etc/server.conf

#Edit the cryptographic cipher
sed -i '/;cipher AES-256-CBC/ccipher AES-256-CBC' /etc/server.conf

#Add HMAC algorithm
sed -i '/cipher AES-256-CBC/aauth SHA256' /etc/server.conf

#Align Diffie-Hellman filename in conf file, if it is not correct
sed -i '/dh dh2048.pem/cdh dh.pem' /etc/server.conf

#Set user and group
sed -i '/;user nobody/cuser nobody' /etc/server.conf
sed -i '/;group nogroup/cgroup nogroup' /etc/server.conf

#Push DNS settings to clients to route all traffic through VPN
sed -i '/;push "redirect-gateway def1 bypass-dhcp"/cpush "redirect-gateway def1 bypass-dhcp"' /etc/server.conf
sed -i '/;push "dhcp-option DNS 208.67.222.222"/cpush "dhcp-option DNS 208.67.222.222"' /etc/server.conf
sed -i '/;push "dhcp-option DNS 208.67.220.220"/cpush "dhcp-option DNS 208.67.220.220"' /etc/server.conf

#In the future, may include here the option to change port and protocol. For now, that must be done manually if desired.

#Point conf file to the right key and crt for the server name
sed -i s/'server.crt'/$SERVER_NAME.crt /etc/server.conf
sed -i s/'server.key'/$SERVER_NAME.key /etc/server.conf

#Enable IP forwarding
sed -i '/#net.ipv4.ip_forward=1/cnet.ipv4.ip_forward=1' /etc/sysctl.conf
sysctl -p



