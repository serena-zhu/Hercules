#!/bin/bash
apt-get install at
systemctl enable --now atd.service
#timedatectl set-timezone America/Los_Angeles
at -f ./script.sh 08:42AM Dec 21
