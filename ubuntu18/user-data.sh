#! /bin/bash

hostnamectl set-hostname "ubuntu18-vulns"

# Following are just from the UI.

curl https://app.threatstack.com/APT-GPG-KEY-THREATSTACK | apt-key add -

echo "deb https://pkg.threatstack.com/v2/Ubuntu `lsb_release -c | cut -f2` main" | tee /etc/apt/sources.list.d/threatstack.list > /dev/null
apt update
apt-get install threatstack-agent curl htop -y
tsagent setup --deploy-key=01d435299b6c2caf585d1af54ffcf07473a6c9eef88d157f46a1753ac5acc78a --ruleset="Custom Rule Set"
systemctl start threatstack