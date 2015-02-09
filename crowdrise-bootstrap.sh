#!/bin/bash
exec 2>&1
exec 1>/var/log/bootstrap-debug.log
ps auxwwef
sleep 120
echo after sleep
ps auxwwef
userdel ubuntu
groupdel ubuntu
rm -f /var/lib/dpkg/lock
mkdir -p /var/lib/cloud/data
hostname | tee /var/lib/cloud/data/previous-hostname
export DEBIAN_FRONTEND=noninteractive
curl -L https://bootstrap.pypa.io/get-pip.py | python
sleep 5s
pip install pyrax
curl -L https://bootstrap.saltstack.com | sh -s -- -A master1.salt.prod1.crowdrise.io -U -P git 2015.2 2>&1 | tee -a /var/log/bootstrap.log
sleep 1m
service salt-minion restart
( salt-call saltutil.sync_all || true ) | tee -a /var/log/bootstrap.log
( salt-call state.top tops/mintop.sls || true ) | tee -a /var/log/bootstrap.log
( salt-call state.highstate || true ) | tee -a /var/log/bootstrap.log
service salt-minion stop
rm -rf /var/cache/salt
service salt-minion start
( salt-call state.highstate || true ) | tee -a /var/log/bootstrap.log
( salt-call state.highstate || true ) | tee -a /var/log/bootstrap.log
if ! [ -f /var/log/firstboot ]; then
  touch /var/log/firstboot
  reboot
fi
