#!/bin/bash

# Read local machine username from the user
LOCAL_USER=$(whiptail --inputbox "Which user is the server to be run under?" \
8 78 --title "Setup OpenVPN" 3>&1 1>&2 2>&3)
exitstatus=$?
if [ $exitstatus = 0 ]; then
 whiptail --title "Setup OpenVPN" --infobox "User: $LOCAL_USER" 8 78
else
 whiptail --title "Setup OpenVPN" --infobox "Cancelled" 8 78
 exit
fi

#Read the local IP address of the server from the user
LOCAL_IP=$(whiptail --inputbox "What is your Raspberry Pi's local IP address?" \
8 78 --title "Setup OpenVPN" 3>&1 1>&2 2>&3)
exitstatus=$?
if [ $exitstatus = 0 ]; then
 whiptail --title "Setup OpenVPN" --infobox "Local IP: $LOCAL_IP" 8 78
else
 whiptail --title "Setup OpenVPN" --infobox "Cancelled" 8 78
 exit
fi

# Read CA machine username from the user
CA_USER=$(whiptail --inputbox "Which user will you be using on the CA machine?" \
8 78 --title "Setup OpenVPN" 3>&1 1>&2 2>&3)
exitstatus=$?
if [ $exitstatus = 0 ]; then
 whiptail --title "Setup OpenVPN" --infobox "User: $CA_USER" 8 78
else
 whiptail --title "Setup OpenVPN" --infobox "Cancelled" 8 78
 exit
fi

#Read the local IP address of the certificate authority machine from the user
CA_IP=$(whiptail --inputbox "What is the local IP address of the CA machine?" \
8 78 --title "Setup OpenVPN" 3>&1 1>&2 2>&3)
exitstatus=$?
if [ $exitstatus = 0 ]; then
 whiptail --title "Setup OpenVPN" --infobox "CA IP: $CA_IP" 8 78
else
 whiptail --title "Setup OpenVPN" --infobox "Cancelled" 8 78
 exit
fi

#Build the public key infrastructure
./easyrsa init-pki

#Generate a certificate request
./easyrsa gen-req server nopass #give user option to name server

#Copy private key to openvpn directory
cp ~/EasyRSA-3.0.7/pki/private/server.key /etc/openvpn/

#securely copy server.req to CA machine
scp ~/EasyRSA-3.0.7/pki/reqs/server.req $CA_USER@$CA_IP:/tmp #Whiptail in CA user and ip address

#-----------

#ON CA MACHINE:

#Import the request, sign the request, transfer signed certificate to server, and transfer CA certificate to server
ssh $CA_USER@$CA_IP "cd ~/EasyRSA-3.0.7/ && ./easyrsa import-req /tmp/server.req server && ./easyrsa sign-req server server && scp pki/issued/server.crt sammy@your_server_ip:/tmp && scp pki/ca.crt sammy@your_server_ip:/tmp"

#Replace the above command with a single execution of a script from CA-Setup

#-----------

#Copy certificates to openvpn
cp /tmp/{server.crt,ca.crt} /etc/openvpn/

#Generate Diffie-Hellman key exchange
cd ~/EasyRSA-3.0.7/
./easyrsa gen-dh

#Generate HMAC signature
openvpn --genkey --secret ta.key

#Copy files to openvpn
cp ~/EasyRSA-3.0.7/ta.key /etc/openvpn/
cp ~/EasyRSA-3.0.7/pki/dh.pem /etc/openvpn/