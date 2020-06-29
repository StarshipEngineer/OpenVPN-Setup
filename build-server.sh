#!/bin/bash

EASYRSA=$1 #First argument must be the version of EasyRSA
SERVER_NAME=$2 #Second argument must be the name of the server
LOCAL_USER=$3 #Third argument must be the user running the server on local machine
LOCAL_IP=$4 #Fourth argument must be the local IP address of the server
CA_USER=$5 #Fifth argument must be the user running the certificate authority
CA_IP=$6 #Sixth argument must be the local IP address of the CA machine



#Build the public key infrastructure
cd $EASYRSA
./easyrsa init-pki

#Generate a certificate request
./easyrsa gen-req $SERVER_NAME nopass

#Copy private key to openvpn directory
cp ~/$EASYRSA/pki/private/$SERVER_NAME.key /etc/openvpn/

#securely copy server.req to CA machine
scp ~/$EASYRSA/pki/reqs/$SERVER_NAME.req $CA_USER@$CA_IP:/tmp

#Invoke CA-Setup to sign the key and transfer it back to the server, as well as CA certificate
ssh $CA_USER@$CA_IP "cd ~/CA-Setup && ./sign-req.sh $LOCAL_USER $LOCAL_IP server $SERVER_NAME && ./get-ca-cert.sh $LOCAL_USER $LOCAL_IP"

#Copy certificates to openvpn
cp /tmp/{$SERVER_NAME.crt,ca.crt} /etc/openvpn/

#Generate Diffie-Hellman key exchange
cd ~/$EASYRSA/
./easyrsa gen-dh

#Generate HMAC signature
openvpn --genkey --secret ta.key

#Copy files to openvpn
cp ~/$EASYRSA/ta.key /etc/openvpn/
cp ~/$EASYRSA/pki/dh.pem /etc/openvpn/

#The next few steps prepare the server for generating client keys

#Make directory for client keys and set permissions to restrict access
cd ~
mkdir -p ~/client-configs/keys
chmod -R 700 ~/client-configs

#Copy CA certificate and the HMAC signature to the client-configs folder
cp ~/$EASYRSA/ta.key ~/client-configs/keys/
cp /etc/openvpn/ca.crt ~/client-configs/keys/