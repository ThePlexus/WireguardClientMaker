#!/bin/bash
#Edit these varaibles as needed

#ENDPOINT=your_server_ip:your_server_port
ENDPOINT=

#SERVERPUB=your_wireguard_servers_public_key
SERVERPUB=

#CLIENTIPADDR=the_internal_wireguard_ip_address_your_client_will_have
CLIENTIPADDR=

#CLIENTDNS=the_ip_address_of_the_dns_server_your_client_will_user
CLIENTDNS=

#No need to edit anything below here

if [ -z "$ENDPOINT" ]; then
    echo "Please edit this file and specify your server endpoint IP and port in format 1.2.3.4:1234"
    exit 1;
fi
if [ -z "$SERVERPUB" ]; then
    echo "Please edit this file and specify your wireguard server public key"
    exit 1;
fi
if [ -z "$CLIENTIPADDR" ]; then
    echo "Please edit this file and specify the private IP of your new client"
    exit 1;
fi
if [ -z "$CLIENTDNS" ]; then
    echo "Please edit this file and specify the DNS server the client should use"
    exit 1;
fi

if ! command -v wg &> /dev/null
then
    echo "Please install wireguard-tools first"
    exit
fi
if ! command -v qrencode &> /dev/null
then
    echo "Please install qrencode"
    exit
fi
if [ "$EUID" -ne 0 ]
  then echo "Please run as root in order to make and mount a ramfs to ensure no keys are kept on disk"
  exit
fi

WORKDIR=$(mktemp -d)
mount -t ramfs -o size=2m ramfs $WORKDIR
CLIENTKEY=$(wg genkey)
CLIENTPUB=$(echo $CLIENTKEY | wg pubkey)
PSKEY=$(wg genpsk)

/bin/cat <<EOF > $WORKDIR/client.conf
[Interface]
PrivateKey = $CLIENTKEY
Address = $CLIENTIPADDR/32
DNS = $CLIENTDNS

[Peer]
PublicKey = $SERVERPUB
AllowedIPs = 0.0.0.0/0
Endpoint = $ENDPOINT
PreSharedKey = $PSKEY
EOF

qrencode -t ansiutf8 < $WORKDIR/client.conf

echo 
echo "Please scan the above on your client device"
echo "Please add the following to your server wireguard config and reload server wireguard config"
echo
echo "[Peer]"
echo "PublicKey = $CLIENTPUB"
echo "AllowedIPs = $CLIENTIPADDR/32"
echo "PreSharedKey = $PSKEY"

rm -r $WORKDIR/*
umount $WORKDIR
rm -r $WORKDIR

echo 
read -p "Once you have set up the device and installed the server [Peer] entry, please press enter to blank the screen"
clear
