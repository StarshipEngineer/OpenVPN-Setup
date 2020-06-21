#!/bin/bash 
 
# Default Variable Declarations 
DEFAULT="default.txt" 
FILEEXT=".ovpn" 
CRT=".crt" 
OKEY=".key"
KEY=".3des.key" 
CA="ca.crt" 
TA="ta.key"
CRTPATH="pki/issued/"
KEYPATH="pki/private/"

#Ask for a Client name
NAME=$(whiptail --inputbox "Please enter a Name for the Client:" \
8 78 --title "MakeOVPN" 3>&1 1>&2 2>&3)
exitstatus=$?
if [ $exitstatus = 0 ]; then
 whiptail --title "MakeOVPN" --infobox "Name: $NAME" 8 78
else
 whiptail --title "MakeOVPN" --infobox "Cancelled" 8 78
 exit
fi

#Major changes to paths for requisite files are needed
#Possible solution- define filepath variables for pki (ca.crt), private (client.key, ta.key), issued (client.crt) directores
 
#Build the client key and then encrypt the key
chmod 777 -R /etc/openvpn
cd /etc/openvpn/easy-rsa
#change following
#./build-key-pass $NAME
./easyrsa build-client-full $NAME #changed
cd pki/private #changed
openssl rsa -in $NAME$OKEY -des3 -out $NAME$KEY
 
#1st Verify that client�s Public Key Exists 
if [ ! -f $NAME$CRT ]; then 
 echo "[ERROR]: Client Public Key Certificate not found: $NAME$CRT" 
 exit 
fi 
echo "Client�s cert found: $NAME$CR" 
 
#Then, verify that there is a private key for that client 
if [ ! -f $NAME$KEY ]; then 
 echo "[ERROR]: Client 3des Private Key not found: $NAME$KEY" 
 exit 
fi 
echo "Client�s Private Key found: $NAME$KEY"
 
#Confirm the CA public key exists 
if [ ! -f $CA ]; then 
 echo "[ERROR]: CA Public Key not found: $CA" 
 exit 
fi 
echo "CA public Key found: $CA" 
 
#Confirm the tls-auth ta key file exists 
if [ ! -f $TA ]; then 
 echo "[ERROR]: tls-auth Key not found: $TA" 
 exit 
fi 
echo "tls-auth Private Key found: $TA" 
 
#Ready to make a new .opvn file - Start by populating with the 
#default file 
cat $DEFAULT > $NAME$FILEEXT 
 
#Now, append the CA Public Cert 
echo "<ca>" >> $NAME$FILEEXT 
cat $CA >> $NAME$FILEEXT 
echo "</ca>" >> $NAME$FILEEXT
 
#Next append the client Public Cert 
echo "<cert>" >> $NAME$FILEEXT 
cat $NAME$CRT | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' >> $NAME$FILEEXT 
echo "</cert>" >> $NAME$FILEEXT 
 
#Then, append the client Private Key 
echo "<key>" >> $NAME$FILEEXT 
cat $NAME$KEY >> $NAME$FILEEXT 
echo "</key>" >> $NAME$FILEEXT 
 
#Finally, append the TA Private Key 
echo "<tls-auth>" >> $NAME$FILEEXT 
cat $TA >> $NAME$FILEEXT 
echo "</tls-auth>" >> $NAME$FILEEXT 

# Copy the .ovpn profile to the home directory for convenient remote access
cp /etc/openvpn/easy-rsa/pki/$NAME$FILEEXT /home/pi/ovpns/$NAME$FILEEXT
chmod 600 -R /etc/openvpn
echo "$NAME$FILEEXT moved to home directory."
whiptail --title "MakeOVPN" --msgbox "Done! $NAME$FILEEXT successfully created and \
moved to directory /home/pi/ovpns." 8 78
 
# Based upon original script written by Eric Jodoin.

#alter for any user
