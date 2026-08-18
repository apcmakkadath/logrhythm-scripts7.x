#!/bin/sh
### Verify nodes.txt exists with all node's ip info ###
if test -f ./nodes.txt; then
  echo "File exists."
  echo "Nodes found"
  cat nodes.txt
  echo "==========="
  for i in $(cat nodes.txt); do ssh -q logrhythm@$i "sudo mv /etc/yum.repos.d/rocky*repo /tmp/ && sudo systemctl start firewalld && sudo systemctl daemon-reload"; done
else
  echo "Make sure that nodes.txt exists with all nodes ip address
