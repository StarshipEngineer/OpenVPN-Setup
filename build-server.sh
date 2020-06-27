#!/bin/bash

SERVER_NAME=$1 #First argument must be the name of the server
LOCAL_USER=$2 #Second argument must be the user running the server on local machine
LOCAL_IP=$3 #Third argument must be the local IP address of the server
CA_USER=$4 #Fourth argument must be the user running the certificate authority
CA_IP=$5 #Fifth argument must be the local IP address of the CA machine


#Build the public key infrastructure
cd EasyRSA-3.0.7
./easyrsa init-pki

#Generate a certificate request
./easyrsa gen-req $SERVER_NAME nopass

#Copy private key to openvpn directory
cp ~/EasyRSA-3.0.7/pki/private/$SERVER_NAME.key /etc/openvpn/

#securely copy server.req to CA machine
scp ~/EasyRSA-3.0.7/pki/reqs/$SERVER_NAME.req $CA_USER@$CA_IP:/tmp

#Invoke CA-Setup to sign the key and transfer it back to the server, as well as CA certificate
ssh $CA_USER@$CA_IP "cd ~/CA-Setup && ./sign-req.sh $LOCAL_USER $LOCAL_IP $SERVER_NAME server && ./get-ca-cert.sh $LOCAL_USER $LOCAL_IP"

#Copy certificates to openvpn
cp /tmp/{$SERVER_NAME.crt,ca.crt} /etc/openvpn/

#Generate Diffie-Hellman key exchange
cd ~/EasyRSA-3.0.7/
./easyrsa gen-dh

#Generate HMAC signature
openvpn --genkey --secret ta.key

#Copy files to openvpn
cp ~/EasyRSA-3.0.7/ta.key /etc/openvpn/
cp ~/EasyRSA-3.0.7/pki/dh.pem /etc/openvpn/

#Make directory for client keys and set permissions to restrict access
cd ~
mkdir -p ~/client-configs/keys
chmod -R 700 ~/client-configs