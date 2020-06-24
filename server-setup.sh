#!/bin/bash

#User interface code
#Read the local IP address of the server from the user
LOCALIP=$(whiptail --inputbox "What is your Raspberry Pi's local IP address?" \
8 78 --title "Setup OpenVPN" 3>&1 1>&2 2>&3)
exitstatus=$?
if [ $exitstatus = 0 ]; then
 whiptail --title "Setup OpenVPN" --infobox "Local IP: $LOCALIP" 8 78
else
 whiptail --title "Setup OpenVPN" --infobox "Cancelled" 8 78
 exit
fi

#Read the local IP address of the certificate authority machine from the user
CA_IP=$(whiptail --inputbox "What is the local IP address of the CA machine?" \
8 78 --title "Setup OpenVPN" 3>&1 1>&2 2>&3)
exitstatus=$?
if [ $exitstatus = 0 ]; then
 whiptail --title "Setup OpenVPN" --infobox "CA IP: $CAIP" 8 78
else
 whiptail --title "Setup OpenVPN" --infobox "Cancelled" 8 78
 exit
fi

# Read username from the user
CA_USER=$(whiptail --inputbox "Which user is the server to be run under?" \
8 78 --title "Setup OpenVPN" 3>&1 1>&2 2>&3)
exitstatus=$?
if [ $exitstatus = 0 ]; then
 whiptail --title "Setup OpenVPN" --infobox "User: $CA_USER" 8 78
else
 whiptail --title "Setup OpenVPN" --infobox "Cancelled" 8 78
 exit
fi



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

#-----------

#Place the below steps into another script file?

#Break in script: securely copy server.req to CA machine
scp ~/EasyRSA-3.0.7/pki/reqs/server.req $CA_USER@$CA_IP:/tmp #Whiptail in CA user and ip address

#Break in script: perform CA signing on CA machine
cp /tmp/{server.crt,ca.crt} /etc/openvpn/

#-----------

cd ~/EasyRSA-3.0.7/

#Generate Diffie-Hellman key exchange
./easyrsa gen-dh

#Generate HMAC signature
openvpn --genkey --secret ta.key

cp ~/EasyRSA-3.0.7/ta.key /etc/openvpn/
cp ~/EasyRSA-3.0.7/pki/dh.pem /etc/openvpn/

#End server side setup