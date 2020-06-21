#!/bin/bash

if (whiptail --title "Setup OpenVPN" --yesno "You are about to configure your \
Raspberry Pi as a VPN server running OpenVPN. Are you sure you want to \
continue?" 8 78) then
 whiptail --title "Setup OpenVPN" --infobox "OpenVPN will be installed and \
 configured." 8 78
else
 whiptail --title "Setup OpenVPN" --msgbox "Cancelled" 8 78
 exit
fi

#DOWNLOAD/INSTALL OPENVPN & EASY-RSA
#Install openvpn
echo "Updating, Upgrading, and Installing..."
apt-get -y install openvpn

#Install easy-rsa v3.0.5
cd /etc/openvpn
mkdir easy-rsa
wget https://github.com/OpenVPN/easy-rsa/archive/v3.0.5.zip
unzip v3.0.5.zip
rm v3.0.5.zip
cp -r /etc/openvpn/easy-rsa-3.0.5/easyrsa3/. /etc/openvpn/easy-rsa

#ACCEPT CONFIGURATION INPUT FROM USER
# Read username from the user
USER=$(whiptail --inputbox "Which user is the server to be run under?" \
8 78 --title "Setup OpenVPN" 3>&1 1>&2 2>&3)
exitstatus=$?
if [ $exitstatus = 0 ]; then
 whiptail --title "Setup OpenVPN" --infobox "User: $USER" 8 78
else
 whiptail --title "Setup OpenVPN" --infobox "Cancelled" 8 78
 exit
fi

#Read server's local IP address from the user
LOCALIP=$(whiptail --inputbox "What is your Raspberry Pi's local IP address?" \
8 78 --title "Setup OpenVPN" 3>&1 1>&2 2>&3)
exitstatus=$?
if [ $exitstatus = 0 ]; then
 whiptail --title "Setup OpenVPN" --infobox "Local IP: $LOCALIP" 8 78
else
 whiptail --title "Setup OpenVPN" --infobox "Cancelled" 8 78
 exit
fi

#Read server's public IP address from the user
PUBLICIP=$(whiptail --inputbox "What is the public IP address of network the \
Raspberry Pi is on?" 8 78 --title "OpenVPN Setup" 3>&1 1>&2 2>&3)
exitstatus=$?
if [ $exitstatus = 0 ]; then
 whiptail --title "Setup OpenVPN" --infobox "PUBLIC IP: $PUBLICIP" 8 78
else
 whiptail --title "Setup OpenVPN" --infobox "Cancelled" 8 78
 exit
fi

#Ask user for desired level of encryption
ENCRYPT=$(whiptail --title "Setup OpenVPN" --menu "Choose your desired level \
of encryption:" 8 78 2 \
"1024" "Use 1024-bit encryption. This is faster to set up, but less secure." \
"2048" "Use 2048-bit encryption. This is much slower to set up, but more secure." \
3>&2 2>&1 1>&3)


#EASY-RSA SETUP
cd /etc/openvpn/easy-rsa
cp vars.example vars

#sed -i '/#set_var EASYRSA        "${0%/*}"/ c\ 
#set_var EASYRSA	"/etc/openvpn/easy-rsa"' vars #not working

#Set the key size
if [ $ENCRYPT = 1024 ]; then 
 sed -i '/EASYRSA_KEY_SIZE/ c\
set_var EASYRSA_KEY_SIZE	 1024' vars
fi

#Clean any previous PKI & build the CA
./easyrsa init-pki
./easyrsa build-ca

whiptail --title "Setup OpenVPN" --msgbox "You will now be asked for identifying \
information for the server. Press 'Enter' to skip a field." 8 78

#Build server key pair
./easyrsa build-server-full server #error messages appear here re index.txt

#Generate Diffie-Hellman exchange
./easyrsa gen-dh

#Generate HMAC key
openvpn --genkey --secret pki/ta.key

#SETUP OPENVPN SERVER
#Write config file for server using the template .txt file
cp /home/$USER/OpenVPN-Setup/server_config.txt /etc/openvpn/server/server.conf
sed -i 's/LOCALIP/'$LOCALIP'/' /etc/openvpn/server/server.conf

# Enable forwarding of internet traffic
sed -i '/#net.ipv4.ip_forward=1/c\
net.ipv4.ip_forward=1' /etc/sysctl.conf
sysctl -p

# Write script to run openvpn and allow it through firewall on boot using the template .txt file
sed 's/LOCALIP/'$LOCALIP'/' </home/$USER/OpenVPN-Setup/firewall-openvpn-rules.txt >/etc/firewall-openvpn-rules.sh
chmod 700 /etc/firewall-openvpn-rules.sh
chown root /etc/firewall-openvpn-rules.sh
sed -i -e '$i \/etc/firewall-openvpn-rules.sh\n' /etc/rc.local
sed -i -e '$i \sudo service openvpn start\n' /etc/rc.local

# Write default file for client .ovpn profiles, to be used by the MakeOVPN script, using template .txt file
#sed 's/PUBLICIP/'$PUBLICIP'/' </home/$USER/OpenVPN-Setup/Default.txt >/etc/openvpn/easy-rsa/pki/Default.txt
cp /home/$USER/OpenVPN-Setup/default.txt /etc/openvpn/easy-rsa/pki/private/default.txt
sed -i 's/PUBLICIP/'$PUBLICIP'/' /etc/openvpn/easy-rsa/pki/private/default.txt

# Make directory under home directory for .ovpn profiles
mkdir /home/$USER/ovpns
chmod 777 -R /home/$USER/ovpns

# Make other scripts in the package executable
cd /home/$USER/OpenVPN-Setup
chmod +x MakeOVPN.sh
chmod +x remove.sh
chmod +x clean-ovpns.sh

whiptail --title "Setup OpenVPN" --msgbox "Configuration complete. Restart \
system to apply changes and start VPN server." 8 78
