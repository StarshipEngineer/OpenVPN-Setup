#!/bin/bash

CLIENT_NAME=$1 #First argument must be the name of the client to create
CA_USER=$2 #Second argument must be the user running the CA machine
CA_IP=$3 #Third argument must be the IP address of the CA machine

#Generate a request for a client
cd ~/EasyRSA-3.0.7/
./easyrsa gen-req $CLIENT_NAME nopass

#Copy the key to client directory
cp pki/private/$CLIENT_NAME.key ~/client-configs/keys/

#Transmit the request to the CA machine
scp pki/reqs/$CLIENT_NAME.req $CA_USER@$CA_IP:/tmp

#left off at tunneling back into server