: '
Script written by Aravind for reading, highlighting and setting values for optimized LogRhythm DataIndexer
!!!!! Version check has not been done for this script other than 7.8,7.9,7.10
!!!!! Works for CentOS 7, 8, RHEL 7,8
Send your feedbacks to apcmakkadath@gmail.com
'


#!/bin/sh

line_separator () {
echo --------------------
read -p "Continue..."
echo " "
clear
}

clear

### User Configuration ###
adduser logrhythm
passwd logrhythm
usermod -aG wheel logrhythm
echo "logrhythm  ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers 
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
line_separator

tput setaf 2;echo "host file entries";tput sgr0
echo /etc/hosts entries
cat /etc/hosts
line_separator

tput setaf 2;echo "Date & Timezone(Verify timezone, time with other LR Components)";tput sgr0
date
line_separator

tput setaf 2;echo "LR host file entries";tput sgr0
echo /home/logrhythm/Soft/hosts entries
cat /home/logrhythm/Soft/hosts
line_separator

tput setaf 2;echo "OS release";tput sgr0
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
### edit /etc/sysconfig/selinux ###
sed 's/\=enforcing/\=permissive/g' /etc/sysconfig/selinux
sestatus 

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

### Package installation ###
tput setaf 6;echo "Trying to install essential packages";tput sgr0

tput setaf 2;echo "checking firewalld";tput sgr0
yum -y install firewalld
rpm -qa firewalld
line_separator

tput setaf 2;echo "checking openssh";tput sgr0
yum -y install openssh
rpm -qa openssh
line_separator

tput setaf 2;echo "checking nc";tput sgr0
yum -y install nc
rpm -qa nc
line_separator

tput setaf 2;echo "checking chrony";tput sgr0
yum -y install chrony
rpm -qa chrony

tput setaf 2;echo "checking yum-utils";tput sgr0
yum -y install yum-utils
rpm -qa yum-utils 
line_separator

tput setaf 2;echo "checking sshpass";tput sgr0
yum -y install sshpass
rpm -qa sshpass
line_separator

tput setaf 2;echo "checking telnet";tput sgr0
yum -y install unzip
rpm -qa telnet
line_separator

tput setaf 2;echo "checking telnet";tput sgr0
yum -y install sysstat
rpm -qa telnet
line_separator

tput setaf 2;echo "checking telnet";tput sgr0
yum -y install telnet
rpm -qa telnet
yum-complete-transaction --cleanup-only
systemctl restart systemd-journald.socket

tput setaf 2;echo "Finished basic checks. Reboot the system";tput sgr0


