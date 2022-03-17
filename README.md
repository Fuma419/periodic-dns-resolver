# Periodic DNS resolver
A system service to periodically check a dns address's ip resolution against the the current firewall rules.
## Disclaimer
There is no warranty for the function of this script. Use it at your own risk. Validate proper function.
## How it works?
This tool will periodically (default periodicity is 5 min) check a DNS's ip address and determine if it has changed. This is an infrequent but inevitable issue when hosting a server with an ISP that does not offer a static public IP address (most residential internet services), and will cause unexpected connectivity failures between nodes.

By default this tool will run in Passive Mode, and will NOT automatically update your firewall settings when a DNS's corresponding IP address has changed. This tools will however send a notification to a telegram bot notifying the operator that an IP address change has been detected, as well as document the change in a log file (dns-ipcheck.log), and prompt the user to force the Firewall change with CLI command "sudo ./dns-ipcheck.sh -f". 

In Active Mode the tool will automatically update the firewall rules when a DNS's corresponding IP address is changed. Although this feature will maximize node connectivity it has inherent security risks, as you are allowing an external dependency to dictate an internal firewall rule change. This is an advanced feature and it is highly recommended that the user carefully consider, understand, and mitigate the risks if you chose to run this tool in active mode. Some recommended measures include storing all cold keys in an air-gapped machine, running a standby core node in a failover configuration, not storing any wallet keys (even encrypted keys) on the node, abstaining from submitting any transactions from this node (pool updates, paper wallet tx, HW wallet tx). While these are all recommended security measures regardless of this tools installation, it must be stated that Active mode is an advanced feature and is not enabled by default for good reason!

## Setup

1. Preconditions
```
    - A core (BP) Cardano node built with Cntools (https://cardano-community.github.io/guild-operators/)
    - UFW - Uncomplicated Firewall enabled (Included in Ubuntu 20.04 LTS)
    - Manual removal of existing node ufw entries that you would like this tool to manage (These will be added back during setup)
```
2. Use BotFather on your telegram account to create a Telegram Bot Token (optional but recomended)
```
https://t.me/botfather

example: 5137992803:AAHUtQzdUbyS8LXDFftFYJ4c-J-n052OyRg
```
3. Use this website (with your token) to aquire your chat ID
```
https://api.telegram.org/bot<your bot token>/getUpdates
```
        example -> "my_chat_member":{"chat":{"id":-937568173 <--- your chat ID>

4. On the cnode navigate to the folder which will contain the scripts
```
cd /opt/cardano/cnode/scripts
```
5. Download the files and make them executable
```
wget https://raw.githubusercontent.com/Fuma419/periodic-dns-resolver/main/script/dns-ipcheck.sh
wget https://raw.githubusercontent.com/Fuma419/periodic-dns-resolver/main/script/telegram-allert.sh

sudo chmod +x dns-ipcheck.sh
sudo chmod +x telegram-allert.sh
```
6. Customize the variables in dns-ipcheck.sh
```
sudo nano dns-ipcheck.sh
```
        dns_address[your-node1-location]=<your-nodes-dns-address>
        dns_port=<your-nodes-dns-port>

7. Customize the variables in telegram-allert.sh (optional)
```
sudo nano telegram_allert.sh
```
        #GROUP_ID=<group_id>
        #BOT_TOKEN=<bot_token>

8. Validate function of dns-ipcheck.sh (if telegram is configured you should receive a bot message as well)
```
sudo ./dns-ipcheck.sh
cat ../logs/dns-ipcheck.log
```

9. Update the existing firewall rules to allow incoming peer. Verify rule creation.
```
sudo ./dns-ipcheck.sh -f
sudo ufw status
```

10. Create a Service which calls the script every 5 minutes (periodicity adjustment in dns-ipcheck.timer)
```
cd /etc/systemd/system
sudo wget https://raw.githubusercontent.com/Fuma419/periodic-dns-resolver/main/service/dns-ipcheck.service
sudo wget https://raw.githubusercontent.com/Fuma419/periodic-dns-resolver/main/service/dns-ipcheck.timer
```

11. Enable the service and check status
```
sudo systemctl enable dns-ipcheck.service
sudo systemctl start dns-ipcheck.service

sudo systemctl enable dns-ipcheck.timer
sudo systemctl start dns-ipcheck.timer

sudo systemctl status dns-ipcheck
```

12. Test and Verify Functionality

- An easy but incomplete test would be to:
1. Remove the ufw entries created in step 7.
2. Add a dummy IP address to your rule set that is tagged with the DNS address configured in step 4
```
sudo /usr/sbin/ufw allow proto tcp from 192.168.68.100 to any port 6000 comment <your-nodes-dns-address>
```
3. Wait until the tool is called and verify that it has detected that change and was able to send the Telegram notification. Following the instruction to update your ufw rules. Then verify input connections are available in gliveView
```
cd /opt/cardano/cnode/scripts/
./gLiveView.sh
```
- The best test would be to request a new public IP address from your ISP. This may be as simple as powering off your modem for 60 seconds and powering back on, or may require a phone call with your ISP's technical support. Then verify input connections are available in gliveView

13. Debugging
```
sudo systemctl status dns-ipcheck
```
```
sudo journalctl -u dns-ipcheck -b
```

14. This tool sucks and I want it gone!
```
sudo systemctl stop dns-ipcheck.timer
sudo systemctl disable dns-ipcheck.timer

sudo systemctl stop dns-ipcheck.service
sudo systemctl disable dns-ipcheck.service

sudo rm /etc/systemd/system/dns-*
sudo rm /opt/cardano/cnode/scripts/dns-*
sudo rm /opt/cardano/cnode/scripts/telegram-allert.sh
sudo rm /opt/cardano/cnode/logs/dns-ipcheck.log

