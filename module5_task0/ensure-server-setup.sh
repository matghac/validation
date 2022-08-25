#!/bin/bash

user=ubuntu

remotesudo="ssh $user@$1 sudo --"

ssh -o ConnectTimeOut=2 -q "$user"@"$1" exit

retArg=$?

if [ "$retArg" -eq "0" ]; then
   echo "can ssh"
   ${remotesudo} "apt update"
   ${remotesudo} "apt -y full-upgrade"
   sudoretArg=$?
   if [ "$sudoretArg" -eq "0" ]; then
    ${remotesudo} ""which docker""
     sudoretArg=$?
     if [ "$sudoretArg" -eq "1" ]; then
       ${remotesudo} "apt-get install -y \
                      ca-certificates \
                      curl \
		      gnupg \
                      lsb-release \
		      uidmap"
       ${remotesudo} "mkdir -p /etc/apt/keyrings"
       ${remotesudo} "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg"
       ${remotesudo} "echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
                     $(lsb_release -cs) stable"| sudo tee /etc/apt/sources.list.d/docker.list > /dev/null"
       ${remotesudo} "apt-get update"
       ${remotesudo} "apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin"
       ${remotesudo} "docker run hello-world"
       ${remotesudo} "sudo usermod -aG docker $user"
     elif [ "$sudoretArg" -eq "0" ]; then
	echo "docker is installed"
     else
       echo "$sudoretArg"
      fi  
   fi
else
  echo "unable to ssh to $1"
  exit 1
fi


