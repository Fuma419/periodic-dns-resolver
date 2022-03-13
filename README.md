# Periodic DNS resolver
a system enabled service to periodically update ufw rules based on one or many dns address's ip resolution
## Disclaimer
There is no warranty for the function of this script. Use it at your own risk. Validate proper function.
## How it works?
todo
## Setup

1. Preconditions - enable ufw
```
sudo ufw enable
```

2. On the server select folder which will contain the script
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
dns_address[your-node1-location]=<your-nodes-dns-address>
dns_port=<your-nodes-dns-port>
```

6. Validate function of dns-ipcheck.sh
```
sudo /usr/sbin/ufw allow proto tcp from 192.168.68.101 to any port 6000 comment "<your-nodes-dns-address>"
sudo ./dns-ipcheck.sh
cat dns_<your-nodes-dns-address>*
```

7. Create a Service which calls the script every minute
```
cd /etc/systemd/system
sudo wget https://raw.githubusercontent.com/Fuma419/periodic-dns-resolver/main/service/dns-ipcheck.service
sudo wget https://raw.githubusercontent.com/Fuma419/periodic-dns-resolver/main/service/dns-ipcheck.timer
```
If you customized the paths you need to change them in dns-ipcheck.service as well
Then enable the Service
```
sudo systemctl enable dns-ipcheck.service
sudo systemctl start dns-ipcheck.service

sudo systemctl enable dns-ipcheck.timer
sudo systemctl start dns-ipcheck.timer
```
Check if the service is ACTIVE
```
sudo systemctl status dns-ipcheck.service
```

8. Final check



9. Debugging
To see what happens you can take a look on the Logs of crontab
```
sudo journalctl -u dns-ipcheck -b
```

10. Enable the failover service on STANDBY
```
sudo systemctl enable dns-ipcheck.service
sudo systemctl start dns-ipcheck.service

sudo systemctl enable dns-ipcheck.timer
sudo systemctl start dns-ipcheck.timer

sudo systemctl daemon-reload
