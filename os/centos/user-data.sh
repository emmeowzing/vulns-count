#! /bin/bash

hostnamectl set-hostname "centos7-vulns"

yum update

# Following are just from the UI.

cat <<TS > /etc/yum.repos.d/threatstack.repo
[threatstack]
name=Threat Stack Package Repository
baseurl=https://pkg.threatstack.com/v2/EL/7
enabled=1
gpgcheck=1
TS

rpm --import https://app.threatstack.com/RPM-GPG-KEY-THREATSTACK

yum install threatstack-agent -y
tsagent setup --deploy-key=01d435299b6c2caf585d1af54ffcf07473a6c9eef88d157f46a1753ac5acc78a --ruleset="Custom Rule Set"
systemctl start threatstack