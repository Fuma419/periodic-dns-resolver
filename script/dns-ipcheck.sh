#!/bin/bash


###############################################
# uncomment and update with addresses to allow
###############################################

PASSIVE_MODE="true"

declare -A dns_address

dns_address[your-node1-location]=google.com
#dns_address[your-node2-location]=<your-nodes-dns-address>
#dns_address[your-node3-location]=<your-nodes-dns-address>
#dns_address[your-node4-location]=<your-nodes-dns-address>

dns_port=6000

#https://api.telegram.org/bot<YourBOTToken>/getUpdates

###############################################
# Do not modify bellow this line
###############################################

for i in "${dns_address[@]}"
do
   : 
    if [[ $EUID -ne 0 ]]; then
    echo This script must be run as root: $(date '+%A %B %d %Y %r')
    exit 1
    fi

    new_ip=$(host $i | head -n1 | cut -f4 -d ' ')
    old_ip=$(/usr/sbin/ufw status | grep $i | head -n1 | tr -s ' ' | cut -f3 -d ' ')

    if [ "$new_ip" = "$old_ip" ] ; then
        echo $i ip check: $(date '+%B %d %Y %r')
        if [ $PASSIVE_MODE == "true" ] ; then
           ./tellegram_allert.sh "Passive mode"
        else
            ./tellegram_allert.sh "Active mode"
        fi
    else
        if [ -n "$old_ip" ] ; then
            /usr/sbin/ufw delete allow proto tcp from $old_ip to any port $dns_port
        fi
        if [ $PASSIVE_MODE == "true" ] ; then
            ./tellegram_allert.sh "ip address change detected on $i from $old_ip to $new_ip! Firewall NOT updated. Update firewall asap!"
        else
            ./tellegram_allert.sh "ip address change detected at $i! Performing ufw update now!"
            /usr/sbin/ufw allow proto tcp from $new_ip to any port $dns_port comment $i
            ./tellegram_allert.sh "ufw changed from $old_ip to $new_ip"
            echo "ip updated from $old_ip to $new_ip: "$(date '+%B %d %Y %r') >> /opt/cardano/cnode/scripts/dns-ipcheck.log
        fi
    fi
done