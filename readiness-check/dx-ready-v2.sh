: '
Script written by Aravind for reading, highlighting and setting values for optimized LogRhythm DataIndexer
!!!!! Works for CentOS 7, 8, RHEL 7,8, Rocky 9, RHEL 9
Send your feedbacks to apcmakkadath@gmail.com
'


#!/bin/sh

line_separator () {
echo --------------------
#read -p "Continue..."
echo " "
#clear
}

clear

### User Configuration ###
adduser logrhythm
passwd logrhythm
usermod -aG wheel logrhythm
echo "logrhythm  ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
echo "PermitRootLogin yes" >> /etc/ssh/sshd_config
line_separator

### Server Details ###
hostn=`hostname`
tput setaf 2;echo "Hostname :"$hostn;tput sgr0
line_separator

### Pinging hostname ###
tput setaf 2; echo "Pinging hostname";tput sgr0
ping -c 4 $hostn
echo ---------------------------
line_separator

tput setaf 1;echo "Finding NICs configured with DHCP";tput sgr0
find /etc/sysconfig/network-scripts/ifcfg-* -exec grep -ilR dhcp '{}'  \;
find /etc/NetworkManager/system-connections/ -type f -exec grep -ilR method=auto '{}'  \;
line_separator

tput setaf 2;echo "host file entries";tput sgr0
echo /etc/hosts entries
cat /etc/hosts
line_separator

tput setaf 2;echo "Date & Timezone(Verify timezone, time with other LR Components)";tput sgr0
date
line_separator

tput setaf 2;echo "LR host file entries";tput sgr0
mkdir /home/logrhythm/Soft
touch /home/logrhythm/Soft/hosts
echo /home/logrhythm/Soft/hosts entries
cat /home/logrhythm/Soft/hosts
echo Format to add entries:
echo 1.1.1.1 hostname boxtype
line_separator

tput setaf 2;echo "OS release";tput sgr0
cat /etc/os-release | grep -i 'NAME="'
cat /etc/redhat-release
line_separator
tput setaf 2;echo "resolv.conf";tput sgr0
cat /etc/resolv.conf
line_separator
tput setaf 2;echo "IP addresses";tput sgr0
ip a
line_separator
tput setaf 6;echo "Disks";tput sgr0
lsblk
line_separator
tput setaf 6;echo "Storage";tput sgr0

df -h | grep usr
line_separator
tput setaf 1;echo "Firewall status";tput sgr0
firewall-cmd --state
firewall-cmd --list-all

line_separator
tput setaf 1;echo "umask value in /etc/bashrc";tput sgr0
cat /etc/bashrc | grep -C 4 umask --color
line_separator
tput setaf 1;echo "umask value in /etc/profile";tput sgr0
cat /etc/profile | grep -C 4 umask --color
umask

line_separator
tput setaf 1;echo "SE status";tput sgr0
### editing /etc/sysconfig/selinux ###
sed 's/\=enforcing/\=permissive/g' /etc/sysconfig/selinux
sestatus 

line_separator
tput setaf 1;echo "Check mount is read write";tput sgr0
mount | grep /usr/local

line_separator
### Removing ACL 
setfacl -b -R /usr/local/
setfacl -b -R /etc/elasticsearch
setfacl -b -R /home/logrhythm
setfacl -b -R /srv
tput setaf 1;echo "Removing ACL";tput sgr0
chown -R logrhythm:logrhythm /home/logrhythm
chown -R logrhythm:logrhythm /usr/local/logrhythm

line_separator
### Turning swap off 
touch /home/logrhythm/swapoff.sh
echo "sudo swapoff -a" > /home/logrhythm/swapoff.sh
touch /home/logrhythm/drop_caches.sh
echo "sudo sync; echo 3 > /proc/sys/vm/drop_caches" > /home/logrhythm/drop_caches.sh
chmod +x /home/logrhythm/swapoff.sh
chmod +x /home/logrhythm/drop_caches.sh
echo "chown -R logrhythm:logrhythm /home/logrhythm" >> /home/logrhythm/set-perms.sh
echo "chown -R logrhythm:logrhythm /usr/local/logrhythm" >> /home/logrhythm/set-perms.sh
(crontab -l 2>/dev/null; echo "@reboot /home/logrhythm/swapoff.sh") | crontab -
tput setaf 1;echo "Swap to OFF";tput sgr0

### logrhythm user ###
tput setaf 2;echo "Checking logrhythm user account";tput sgr0;tput sgr0
cat /etc/passwd | grep logrhythm --color=auto
line_separator
tput setaf 2;echo "Checking logrhythm group membership";tput sgr0
groups logrhythm 
line_separator
tput setaf 2;echo "Checking visudo";tput sgr0
cat /etc/sudoers | grep logrhythm --color=auto
line_separator
tput setaf 2;echo "Checking ansible compatibility";tput sgr0
cat /etc/sudoers | grep PermitRootLogin --color=auto
line_separator
tput setaf 2;echo "Adding command aliases";tput sgr0;tput sgr0
### for user root
echo "alias chs='curl localhost:9200/_cluster/health?pretty'" >> /root/.bashrc
echo "alias cns='curl localhost:9200/_cat/nodes?v'" >> /root/.bashrc
### for user logrhythm
echo "alias chs='curl localhost:9200/_cluster/health?pretty'" >> /home/logrhythm/.bashrc
echo "alias cns='curl localhost:9200/_cat/nodes?v'" >> /home/logrhythm/.bashrc
source ~/.bashrc
line_separator

### Package installation ###
tput setaf 6;echo "Trying to install essential packages";tput sgr0

tput setaf 2;echo "checking firewalld";tput sgr0
#yum -y install firewalld
rpm -qa firewalld

tput setaf 2;echo "checking openssh";tput sgr0
#yum -y install openssh
rpm -qa openssh

tput setaf 2;echo "checking tar";tput srg0
rpm -qa tar

tput setaf 2;echo "checking nc";tput sgr0
#yum -y install nc
rpm -qa nc

tput setaf 2;echo "checking chrony";tput sgr0
#yum -y install chrony
rpm -qa chrony

tput setaf 2;echo "checking yum-utils";tput sgr0
#yum -y install yum-utils
rpm -qa yum-utils 


tput setaf 2;echo "checking sshpass";tput sgr0
#yum -y install sshpass
rpm -qa sshpass

tput setaf 2;echo "checking unzip";tput sgr0
#yum -y install unzip
rpm -qa unzip

tput setaf 2;echo "checking systat";tput sgr0
#yum -y install sysstat
rpm -qa systat


tput setaf 2;echo "checking telnet";tput sgr0
#yum -y install telnet
rpm -qa telnet
yum-complete-transaction --cleanup-only
systemctl restart systemd-journald.socket

### Disable repo manually for DX installation
tput setaf 1; echo "Edit to enabled=0 on Base Repo & rocky.repo in /etc/yum.repos.d/";tput sgr0
find /etc/yum.repos.d/ -type f -exec  grep -ilR enabled=1 '{}' \;
find /etc/yum.repos.d/ -type f -exec sed -i 's/enabled\=1/enabled\=0/g' '{}' \;
systemctl daemon-reload

tput setaf 2;echo "Finished basic checks. Reboot the system";tput sgr0
