# Periodic DNS resolver
A system service to periodically check a dns address's ip resolution against the the current firewall rules.
## Disclaimer
There is no warranty for the function of this script. Use it at your own risk. Validate proper function.
## How it works?
This tool will periodically check a DNS's ip address and check to see if it has changed. This is an infrequent but 
inevitable issue when hosting a server with an ISP that does not offer a static public IP address, and will cause
unexpected connectivity issues between nodes.

When first setting up:

## Setup

1. Preconditions - enable ufw
```
sudo ufw enable
```
2. On the cnode select folder which will contain the script
```
cd /opt/cardano/cnode/scripts
```
3. Download the files and make them executeable
```
wget https://raw.githubusercontent.com/Fuma419/periodic-dns-resolver/main/script/dns-ipcheck.sh
wget https://raw.githubusercontent.com/Fuma419/periodic-dns-resolver/main/script/tellegram_allert.sh

sudo chmod +x dns-ipcheck.sh
sudo chmod +x tellegram_allert.sh
```
4. Customize the variables in dns-ipcheck.sh
```
sudo nano dns-ipcheck.sh
```
        dns_address[your-node1-location]=<your-nodes-dns-address>
        dns_port=<your-nodes-dns-port>

5. Customize the variables in tellegram_allert.sh (optional)
```
sudo nano tellegram_allert.sh
```
        #GROUP_ID=<group_id>
        #BOT_TOKEN=<bot_token>

6. Validate function of dns-ipcheck.sh (if telegram is configured you should recieve a bot message as well)
```
sudo ./opt/cardano/cnode/scripts/dns-ipcheck.sh
cat /opt/cardano/cnode/logs/dns-ipcheck.log
```

7. Create a Service which calls the script every 15 minutes (periodicity adjustment in dns-ipcheck.timer)
```
cd /etc/systemd/system
sudo wget https://raw.githubusercontent.com/Fuma419/periodic-dns-resolver/main/service/dns-ipcheck.service
sudo wget https://raw.githubusercontent.com/Fuma419/periodic-dns-resolver/main/service/dns-ipcheck.timer
```

8. Then enable the service and check status
```
sudo systemctl enable dns-ipcheck.service
sudo systemctl start dns-ipcheck.service

sudo systemctl enable dns-ipcheck.timer
sudo systemctl start dns-ipcheck.timer

sudo systemctl status dns-ipcheck
```

8. Final check



9. Debugging
To see what happens you can take a look on the Logs of crontab
```
sudo journalctl -u dns-ipcheck -b
```

10. This tool sucks and I want it gone
```
sudo systemctl stop dns-ipcheck.timer
sudo systemctl disable dns-ipcheck.timer

sudo systemctl stop dns-ipcheck.service
sudo systemctl disable dns-ipcheck.service

sudo rm /etc/systemd/system/dns-*
sudo rm /opt/cardano/cnode/scripts/dns-*
sudo rm /opt/cardano/cnode/scripts/tellegram_allert.sh
sudo rm /opt/cardano/cnode/logs/dns-ipcheck.log
