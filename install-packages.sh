#!/bin/bash

#For now, enter: EasyRSA-3.0.7
EASYRSA=$(whiptail --inputbox "Enter the EasyRSA version to obtain from GitHub repo (Ex: EasyRSA-3.0.7)" \
8 78 --title "Setup OpenVPN" 3>&1 1>&2 2>&3)
exitstatus=$?
if [ $exitstatus = 0 ]; then
 whiptail --title "Setup OpenVPN" --infobox "User: $EASYRSA" 8 78
else
 whiptail --title "Setup OpenVPN" --infobox "Cancelled" 8 78
 exit
fi

#Download openvpn
apt-get update
apt-get -y upgrade
apt-get install -y openvpn

#Download and extract EasyRSA
wget -P ~/ https://github.com/OpenVPN/easy-rsa/releases/download/v3.0.7/$EASYRSA.tgz
cd ~
tar xvf $EASYRSA.tgz #tie this into other scripts? Pipe it from a handler script?