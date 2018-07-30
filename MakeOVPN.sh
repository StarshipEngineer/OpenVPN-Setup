#!/bin/bash 
 
# Default Variable Declarations 
DEFAULT="default.txt" 
FILEEXT=".ovpn" 
CRT=".crt" 
OKEY=".key"
KEY=".3des.key" 
CA="ca.crt" 
TA="ta.key"
PUBPATH="pki/" #new
CRTPATH="pki/issued/" #new
KEYPATH="pki/private/" #new

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
./easyrsa build-client-full $NAME
openssl rsa -in $KEYPATH$NAME$OKEY -des3 -out $KEYPATH$NAME$KEY
 
#First Verify that client�s Public Key Exists 
if [ ! -f $CRTPATH$NAME$CRT ]; then 
 echo "[ERROR]: Client Public Key Certificate not found: $CRTPATH$NAME$CRT" 
 exit 
fi 
echo "Client�s cert found: $CRTPATH$NAME$CR" 
 
#Then, verify that there is a private key for that client 
if [ ! -f $KEYPATH$NAME$KEY ]; then 
 echo "[ERROR]: Client 3des Private Key not found: $KEYPATH$NAME$KEY" 
 exit 
fi 
echo "Client�s Private Key found: $KEYPATH$NAME$KEY"
 
#Confirm the CA public key exists 
if [ ! -f $PUBPATH$CA ]; then 
 echo "[ERROR]: CA Public Key not found: $PUBPATH$CA" 
 exit 
fi 
echo "CA public Key found: $PUBPATH$CA" 
 
#Confirm the tls-auth ta key file exists 
if [ ! -f $PUBPATH$TA ]; then 
 echo "[ERROR]: tls-auth Key not found: $PUBPATH$TA" 
 exit 
fi 
echo "tls-auth Private Key found: $PUBPATH$TA" 
 
#Ready to make a new .opvn file - Start by populating with the
#default file 
cat $KEYPATH$DEFAULT > $NAME$FILEEXT 
 
#Now, append the CA Public Cert
echo "<ca>" >> $NAME$FILEEXT
cat $PUBPATH$CA >> $NAME$FILEEXT
echo "</ca>" >> $NAME$FILEEXT
 
#Next append the client Public Cert
echo "<cert>" >> $NAME$FILEEXT
cat $CRTPATH$NAME$CRT | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' >> $NAME$FILEEXT
echo "</cert>" >> $NAME$FILEEXT
 
#Then, append the client Private Key 
echo "<key>" >> $NAME$FILEEXT
cat $KEYPATH$NAME$KEY >> $NAME$FILEEXT
echo "</key>" >> $NAME$FILEEXT
 
#Finally, append the TA Private Key 
echo "<tls-auth>" >> $NAME$FILEEXT 
cat $PUBPATH$TA >> $NAME$FILEEXT 
echo "</tls-auth>" >> $NAME$FILEEXT 

# Copy the .ovpn profile to the home directory for convenient remote access - something here is broken, other than pi folder
cp /etc/openvpn/easy-rsa/$KEYPATH$NAME$FILEEXT /home/pi/ovpns/$NAME$FILEEXT
chmod 600 -R /etc/openvpn
echo "$NAME$FILEEXT moved to ovpns directory."
whiptail --title "MakeOVPN" --msgbox "Done! $NAME$FILEEXT successfully created and \
moved to directory /home/pi/ovpns." 8 78
 
# Based upon original script written by Eric Jodoin.

#alter for any user