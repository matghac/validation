#!/bin/bash

create_aws_instance () {
  aws ec2 run-instances --image-id ami-0fb391cce7a602d1f --count 1 --instance-type t3.micro --key-name awesome-key --security-group-ids sg-0f8fb17640e11c207 --subnet-id subnet-056b4e01bb0b4f73b --region eu-west-2
}

get_running_instance_dns_name () {
	aws ec2 describe-instances --query 'Reservations[*].Instances[?State.Name==`running`].PublicDnsName' --output text
}


publicdns=$(get_running_instance_dns_name)

if test -z "$publicdns"; then
  create_aws_instance $> /dev/null;
fi

while test -z "$publicdns"; do
publicdns=$(get_running_instance_dns_name)
done

ssh -q ubuntu@"${publicdns}" exit
retVal=$?
while [ $retVal -ne 0 ]; do
  ssh -o ConnectTimeOut=2 -q ubuntu@"${publicdns}" exit
  retVal=$?
  done
         
echo "${publicdns}"
