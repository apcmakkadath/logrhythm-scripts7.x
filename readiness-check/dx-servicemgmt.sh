: '
Script written by Aravind for LogRhythm related service/daemon administration
!!!!! Version check has not been done for this script other than 7.8,7.9,7.10
!!!!! Tested on CentOS 7.X RHEL 7.X
Send your feedbacks to apcmakkadath@gmail.com

Black        0;30     Dark Gray     1;30
Red          0;31     Light Red     1;31
Green        0;32     Light Green   1;32
Brown/Orange 0;33     Yellow        1;33
Blue         0;34     Light Blue    1;34
Purple       0;35     Light Purple  1;35
Cyan         0;36     Light Cyan    1;36
Light Gray   0;37     White         1;37
'

clear
echo Data indexer service management

if [[ ${USER} != "root" ]]
then
    echo "*********************************************************"
    echo "* script must be run as root             *"
    echo "*********************************************************"
    exit 1
fi

if [[ -z ${SUDO_USER} ]]
then
    echo "*********************************************************"
    echo "* script  must run with sudo           *"
    echo "*********************************************************"
    exit 1
fi

echo "1. [start]Start LogRhythm services"
echo "2. [stop]Stop LogRhythm services"
echo "3. [status]Show Status of LogRhythm Services"
read -p "Please make a selection(start,stop,status)" action


for i in elasticsearch watchtower carpenter columbo bulldozer transporter gomaintain LogRhythmAPIGateway LogRhythmServiceRegistry LogRhythmMetricsCollection
do
    echo -e "\e[1;35m$action  ${i}\e[0m"
    sudo SYSTEMD_COLORS=1 systemctl $action ${i} | grep Active:
    echo -e "------------------------------------------------------------------"
done