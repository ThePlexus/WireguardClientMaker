# WireguardClientMaker
Generate a wireguard client config and server peer config, without saving any keys to disk or tmpfs (swap file leak risk). The way this is achieved is by using ramfs and clearing the only visual output of the keys (QRcode) once you have scanned the QRcode on the device) 

This script is expecially useful if you have a airgapped machine or machine with specific random number generator (or combo of) which you would like to use to generate wireguard client keys and not have anything written to disk 

The keys will still reside in the device you use to scan the QR code, of course. 

To use, edit the variables at the top of the script 
```
ENDPOINT=your_server_ip:your_server_port
SERVERPUB=your_wireguard_servers_public_key
CLIENTIPADDR=the_internal_wireguard_ip_address_your_client_will_have
CLIENTDNS=the_ip_address_of_the_dns_server_your_client_will_user
```
like so
```
ENDPOINT=123.123.123.123:12312
SERVERPUB=kzmtRwNGgeMdrrwLiZx5KanzsPwlECNmARxu6N1ib1o=
CLIENTIPADDR=192.168.1.2
CLIENTDNS=192.168.1.1
```

You should run the script as root/sudo in order to use the mount command and create a ramfs. This means you should *inspect this script in full before execution* and ensure it will do only the expected actions. You could also just copy/paste the actions inside. 

```
./makewireguard.sh
```

