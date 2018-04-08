#!/bin/bash
apt-get -y update && apt-get install -y openssh-server

sed -i.backup 's/#Port 22/Port 65535' /etc/ssh/sshd_config

service ssh restart

#VBoxManage modifyvm Debian --natpf1 "ssh,tcp,,65535,,65535"
