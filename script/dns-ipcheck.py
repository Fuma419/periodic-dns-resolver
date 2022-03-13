#!/bin/bash
declare -A dns_address

###############################################
# uncomment and update with addresses to allow
###############################################

#dns_address[your-node1-location]=<your-nodes-dns-address>
#dns_address[your-node2-location]=<your-nodes-dns-address>
#dns_address[your-node3-location]=<your-nodes-dns-address>
#dns_address[your-node4-location]=<your-nodes-dns-address>

dns_port=6000

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
    else
        if [ -n "$old_ip" ] ; then
            /usr/sbin/ufw delete allow proto tcp from $old_ip to any port $dns_port
        fi
        /usr/sbin/ufw allow proto tcp from $new_ip to any port $dns_port comment $i
        echo "ip updated from $old_ip to $new_ip: "$(date '+%B %d %Y %r') >> /opt/cardano/cnode/scripts/dns-ipcheck.log
    fi
done