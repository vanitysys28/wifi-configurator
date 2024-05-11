#!/bin/bash

echo "Scan for nearby networks? (y/n)"
read scan

if [ $scan = "y" ]; then
    wpa_cli scan > /dev/null;
    wpa_cli scan_results
fi

echo "Please enter the network SSID:"
read SSID

if grep -w $SSID'"' /etc/wpa_supplicant/wpa_supplicant.conf > /dev/null; then 
    echo "SSID already saved in the configuration. Do you want to update the network password? (y/n)"
    read update
    
    if [ "$update" == "n" ]; then
	exit
    fi

    cat /etc/wpa_supplicant/wpa_supplicant.conf | tr '\n' '|' > tmp;
    sed -i 's/||network/\n\nnetwork/g;s/}|/}\n/g' tmp;
    sed "/$SSID/d" tmp | tr '|' '\n' | tee /etc/wpa_supplicant/wpa_supplicant.conf > /dev/null

fi

echo "Please enter the network password:"
read password

echo "Encrypt network password? (y/n)"
read encrypt

if [ $encrypt = "y" ]; then
    wpa_passphrase $SSID $password | tee -a /etc/wpa_supplicant/wpa_supplicant.conf > /dev/null
    exit
fi

echo "network={" >> /etc/wpa_supplicant/wpa_supplicant.conf
echo -e "\tssid=\"$SSID\"" >> /etc/wpa_supplicant/wpa_supplicant.conf
echo -e "\tpsk=\"$password\"" >> /etc/wpa_supplicant/wpa_supplicant.conf
echo -e "\tpriority=50" >> /etc/wpa_supplicant/wpa_supplicant.conf
echo "}" >> /etc/wpa_supplicant/wpa_supplicant.conf
