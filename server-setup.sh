#!/bin/bash

#Download openvpn
apt-get update
apt-get -y upgrade
apt-get install -y openvpn

#Download and extract EasyRSA
wget -P ~/ https://github.com/OpenVPN/easy-rsa/releases/download/v3.0.7/EasyRSA-3.0.7.tgz
cd ~ #find a better way to get latest version of easyrsa
tar xvf EasyRSA-3.0.7.tgz #automate extraction
cd EasyRSA-3.0.7

#Build the public key infrastructure
./easyrsa init-pki

#Generate a certificate request
./easyrsa gen-req server nopass #give user option to name server

#Copy private key to openvpn directory
cp ~/EasyRSA-3.0.7/pki/private/server.key /etc/openvpn/

#Break in script: securely copy server.req to CA machine
scp ~/EasyRSA-3.0.7/pki/reqs/server.req sammy@your_CA_ip:/tmp #Whiptail in CA user and ip address

