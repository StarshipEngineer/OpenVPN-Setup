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

# Update packages and install openvpn
echo "Updating, Upgrading, and Installing..."
apt-get update
apt-get -y upgrade
apt-get -y install openvpn

# Read the local and public IP addresses from the user
LOCALIP=$(whiptail --inputbox "What is your Raspberry Pi's local IP address?" \
8 78 --title "Setup OpenVPN" 3>&1 1>&2 2>&3)
exitstatus=$?
if [ $exitstatus = 0 ]; then
 whiptail --title "Setup OpenVPN" --infobox "Local IP: $LOCALIP" 8 78
else
 whiptail --title "Setup OpenVPN" --infobox "Cancelled" 8 78
 exit
fi

PUBLICIP=$(whiptail --inputbox "What is the public IP address of network the \
Raspberry Pi is on?" 8 78 --title "OpenVPN Setup" 3>&1 1>&2 2>&3)
exitstatus=$?
if [ $exitstatus = 0 ]; then
 whiptail --title "Setup OpenVPN" --infobox "PUBLIC IP: $PUBLICIP" 8 78
else
 whiptail --title "Setup OpenVPN" --infobox "Cancelled" 8 78
 exit
fi

# Ask user for desired level of encryption
ENCRYPT=$(whiptail --title "Setup OpenVPN" --menu "Choose your desired level \
of encryption:" 8 78 2 \
"1024" "Use 1024-bit encryption. This is faster to set up, but less secure." \
"2048" "Use 2048-bit encryption. This is much slower to set up, but more secure." \
3>&2 2>&1 1>&3)

# Copy the easy-rsa files to a directory inside the new openvpn directory
cp -r /usr/share/easy-rsa /etc/openvpn

# Edit the EASY_RSA variable in the vars file to point to the new easy-rsa directory,
# And change from default 1024 encryption if desired
cd /etc/openvpn/easy-rsa
sed -i 's:"`pwd`":"/etc/openvpn/easy-rsa":' vars
if [ $ENCRYPT = 2048 ]; then
 sed -i 's:KEY_SIZE=1024:KEY_SIZE=2048:' vars
fi

# source the vars file just edited
source ./vars

# Remove any previous keys
./clean-all

# Build the certificate authority
./build-ca < /home/pi/OpenVPN-Setup/ca_info.txt

whiptail --title "Setup OpenVPN" --msgbox "You will now be asked for identifying \
information for the server. Press 'Enter' to skip a field." 8 78

# Build the server
./build-key-server server

# Generate Diffie-Hellman key exchange
./build-dh

# Generate static HMAC key to defend against DDoS
openvpn --genkey --secret keys/ta.key

# Write config file for server using the template .txt file
sed 's/LOCALIP/'$LOCALIP'/' </home/pi/OpenVPN-Setup/server_config.txt >/etc/openvpn/server.conf
if [ $ENCRYPT = 2048 ]; then
 sed -i 's:dh1024:dh2048:' /etc/openvpn/server.conf
fi

# Enable forwarding of internet traffic
sed -i '/#net.ipv4.ip_forward=1/c\
net.ipv4.ip_forward=1' /etc/sysctl.conf
sudo sysctl -p

# Write script to allow openvpn through firewall on boot using the template .txt file
sed 's/LOCALIP/'$LOCALIP'/' </home/pi/OpenVPN-Setup/firewall-openvpn-rules.txt >/etc/firewall-openvpn-rules.sh
sudo chmod 700 /etc/firewall-openvpn-rules.sh
sudo chown root /etc/firewall-openvpn-rules.sh
sed -i '/gateway/a \
	pre-up /etc/firewall-openvpn-rules.sh' /etc/network/interfaces

# Write default file for client .ovpn profiles, to be used by the MakeOVPN script, using template .txt file
sed 's/PUBLICIP/'$PUBLICIP'/' </home/pi/OpenVPN-Setup/Default.txt >/etc/openvpn/easy-rsa/keys/Default.txt

# Make directory under home directory for .ovpn profiles
mkdir /home/pi/ovpns
chmod 777 -R /home/pi/ovpns

# Make other scripts in the package executable
cd /home/pi/OpenVPN-Setup
sudo chmod +x MakeOVPN.sh
sudo chmod +x remove.sh

whiptail --title "Setup OpenVPN" --msgbox "Configuration complete. Restart \
system to apply changes and start VPN server." 8 78
