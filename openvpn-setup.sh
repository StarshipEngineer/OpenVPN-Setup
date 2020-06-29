#!/bin/bash

#A handler script that wraps component scripts with whiptail GUI

SERVER_NAME=$(whiptail --inputbox "What do you want to name your server?" \
8 78 --title "Setup OpenVPN" 3>&1 1>&2 2>&3)
exitstatus=$?
if [ $exitstatus = 0 ]; then
 whiptail --title "Setup OpenVPN" --infobox "User: $SERVER_NAME" 8 78
else
 whiptail --title "Setup OpenVPN" --infobox "Cancelled" 8 78
 exit
fi

#Read local machine username from the user
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

#Read from the user the EasyRSA version to use to pass down
EASYRSA=$(whiptail --inputbox "Enter the EasyRSA version to obtain from GitHub repo (Ex: EasyRSA-3.0.7)" \
8 78 --title "Setup OpenVPN" 3>&1 1>&2 2>&3)
exitstatus=$?
if [ $exitstatus = 0 ]; then
 whiptail --title "Setup OpenVPN" --infobox "Version: $EASYRSA" 8 78
else
 whiptail --title "Setup OpenVPN" --infobox "Cancelled" 8 78
 exit
fi



#Ordering of scripts for building the server
./install-packages.sh $EASYRSA
./build-server.sh $EASYRSA $SERVER_NAME $LOCAL_USER $LOCAL_IP $CA_USER $CA_IP

#Script to build a client
./build-client.sh $CLIENT_NAME $CA_USER $CA_IP $EASYRSA #Must define client name... within script?

#Script to configure the server
./config-server.sh