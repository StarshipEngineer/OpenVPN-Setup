#!/bin/bash

#Download openvpn
sudo apt-get update
sudo apt-get -y upgrade
sudo apt-get install -y openvpn

#Download and extract EasyRSA
wget -P ~/ https://github.com/OpenVPN/easy-rsa/releases/download/v3.0.7/EasyRSA-3.0.7.tgz
cd ~
tar xvf EasyRSA-unix-v3.0.6.tgz