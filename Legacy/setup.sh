#!/bin/bash

askreboot() {
	if (whiptail --title "Reboot" --yesno --defaultno "Would you like to reboot now?" 8 78) then
		whiptail --title "Reboot" --msgbox "The system will reboot." 8 78
		reboot
	fi
}


exitstatus=0
while [ $exitstatus = 0 ]
do
	CHOICE=$(whiptail --title "OpenVPN-Setup" --menu "Setup options:" 16 78 3 \
	"01" "Setup OpenVPN on your system" \
	"02" "Generate a client profile with MakeOVPN" \
	"03" "Remove OpenVPN and revert your system to a pre-installation state" 3>&2 2>&1 1>&3)

	case "${CHOICE}" in
		01)
			sudo chmod +x install.sh
			sudo ./install.sh
			askreboot
		;;
		02)
			./MakeOVPN.sh
		;;
		03)
			sudo ./remove.sh
			askreboot
		;;
		*)
			exitstatus=1
			exit
		;;
	esac
done
