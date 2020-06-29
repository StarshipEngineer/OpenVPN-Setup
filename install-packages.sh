#!/bin/bash

EASYRSA=$1 #First argument must be the version of EasyRSA to use

#Download openvpn
apt-get update
apt-get -y upgrade
apt-get install -y openvpn

#Download and extract EasyRSA
wget -P ~/ https://github.com/OpenVPN/easy-rsa/releases/download/v3.0.7/$EASYRSA.tgz
cd ~
tar xvf $EASYRSA.tgz #tie this into other scripts? Pipe it from a handler script?