#!/bin/bash

# Ask user for confirmation
if (whiptail --title "Remove OpenVPN" --yesno --defaultno "Are you sure you want to remove \
OpenVPN and revert your system to its previous state?" 8 78) then
 whiptail --title "Remove OpenVPN" --infobox "OpenVPN will be removed" 8 78
else
 whiptail --title "Remove OpenVPN" --msgbox "Removal cancelled" 8 78
 exit
fi

# Read username from the user
USER=$(whiptail --inputbox "Which user is the server being run under?" \
8 78 --title "Setup OpenVPN" 3>&1 1>&2 2>&3)
exitstatus=$?
if [ $exitstatus = 0 ]; then
 whiptail --title "Setup OpenVPN" --infobox "User: $USER" 8 78
else
 whiptail --title "Setup OpenVPN" --infobox "Cancelled" 8 78
 exit
fi

# Remove openvpn
apt-get -y remove openvpn

# Remove openvpn-related directories
rm -r /etc/openvpn /home/$USER/ovpns

# Remove firewall script and reference to it in interfaces
sed -i '/firewall-openvpn-rules.sh/d' /etc/rc.local
sed -i 'sudo service openvpn start/d' /etc/rc.local
rm /etc/firewall-openvpn-rules.sh

# Disable IPv4 forwarding
sed -i '/net.ipv4.ip_forward=1/c\
#net.ipv4.ip_forward=1' /etc/sysctl.conf
sysctl -p

whiptail --title "Remove OpenVPN" --msgbox "OpenVPN has been removed and your \
previous settings have been restored. Reboot to apply changes." 8 78