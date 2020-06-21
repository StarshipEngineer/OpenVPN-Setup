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

#Step 4A Install openvpn
echo "Installing openvpn"
apt-get -y install openvpn

#Step 4B Install and prepare Easy RSA
VER=2 # Easy-RSA version number
cd /etc/openvpn
mkdir easy-rsa
wget https://github.com/OpenVPN/easy-rsa/archive/release/$VER.x.zip
unzip $VER.x.zip
rm $VER.x.zip

# Step 5 Copy the easy-rsa files to a directory inside the new openvpn directory
cp -r /etc/openvpn/easy-rsa-release-$VER.x/easy-rsa/2.0/* /etc/openvpn/easy-rsa

#Step 6 Go to new easy-rsa directory
cd /etc/openvpn/easy-rsa

#Step 7 Edit vars
#Edit the EASY_RSA variable in the vars file to point to the new easy-rsa directory,
#And change from default 1024 encryption if desired
cp vars vars.backup
sed -i 's:"`pwd`":"/etc/openvpn/easy-rsa":' vars
if [ $ENCRYPT = 1024 ]; then
 sed -i 's:KEY_SIZE=2048:KEY_SIZE=1024:' vars
fi

#Step 8 Source vars file and build the CA
source ./vars
./clean-all
./build-ca

#Step 9 Build server key pair
./build-key-server server

#Step 12 Generate Diffie-Hellman exchange
./build-dh

#Step 13 Generate HMAC key
openvpn --genkey --secret keys/ta.key

#Step 14 Edit server.conf
# Write config file for server using the template .txt file
sed 's/LOCALIP/'$LOCALIP'/' </home/pi/OpenVPN-Setup/server_config.txt >/etc/openvpn/server.conf
if [ $ENCRYPT = 2048 ]; then
 sed -i 's:dh1024:dh2048:' /etc/openvpn/server.conf
fi

# Enable forwarding of internet traffic
sed -i '/#net.ipv4.ip_forward=1/c\
net.ipv4.ip_forward=1' /etc/sysctl.conf
sudo sysctl -p

# Write script to run openvpn and allow it through firewall on boot using the template .txt file
sed 's/LOCALIP/'$LOCALIP'/' </home/pi/OpenVPN-Setup/firewall-openvpn-rules.txt >/etc/firewall-openvpn-rules.sh
sudo chmod 700 /etc/firewall-openvpn-rules.sh
sudo chown root /etc/firewall-openvpn-rules.sh
sed -i -e '$i \/etc/firewall-openvpn-rules.sh\n' /etc/rc.local
sed -i -e '$i \sudo service openvpn start\n' /etc/rc.local

# Write default file for client .ovpn profiles, to be used by the MakeOVPN script, using template .txt file
sed 's/PUBLICIP/'$PUBLICIP'/' </home/pi/OpenVPN-Setup/Default.txt >/etc/openvpn/easy-rsa/keys/default.txt

# Make directory under home directory for .ovpn profiles
mkdir /home/pi/ovpns
chmod 777 -R /home/pi/ovpns

# Make other scripts in the package executable
cd /home/pi/OpenVPN-Setup
chmod +x MakeOVPN.sh
chmod +x remove.sh
chmod +x clean-ovpns.sh

whiptail --title "Setup OpenVPN" --msgbox "Configuration complete. Restart \
system to apply changes and start VPN server." 8 78
