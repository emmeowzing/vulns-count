#! /bin/bash

hostnamectl set-hostname "amazon-linux-1-vulns"

yum update -y

# Following are just from the UI.

cat <<TS > /etc/yum.repos.d/threatstack.repo
[threatstack]
name=Threat Stack Package Repository
baseurl=https://pkg.threatstack.com/v2/Amazon/1
enabled=1
gpgcheck=1
TS

wget https://app.threatstack.com/RPM-GPG-KEY-THREATSTACK -O /etc/pki/rpm-gpg/RPM-GPG-KEY-THREATSTACK
rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-THREATSTACK

yum install -y threatstack-agent &&\
tsagent setup --deploy-key=01d435299b6c2caf585d1af54ffcf07473a6c9eef88d157f46a1753ac5acc78a --ruleset="Base Rule Set" && \
tsagent start