#!/bin/sh -e


randomMAC(){
    FIRST_OCTET=$((64 + $[RANDOM%128]))

    if [[ $((FIRST_OCTET % 2)) -ne 0 ]]; then
        FIRST_OCTET=$((FIRST_OCTET - 1))
    fi
    MAC_ADDRESS=$(printf "%02X:%02X:%02X:%02X:%02X:00" \
        $FIRST_OCTET \
        $[RANDOM%64] \
        $[RANDOM%64] \
        $[RANDOM%64] \
        $[RANDOM%64] \
    )
    echo $MAC_ADDRESS
}

MAC=$(randomMAC)
echo "wireless mac address: ${MAC}"
echo "$MAC" > /etc/ryor/wifi-mac

