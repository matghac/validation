#!/bin/bash

create_aws_instance () {
  aws ec2 run-instances --image-id ami-0fb391cce7a602d1f --count 1 --instance-type t3.micro --key-name awesome-key --security-group-ids sg-0f8fb17640e11c207 --subnet-id subnet-056b4e01bb0b4f73b --region eu-west-2
}

get_running_instance_dns_name () {
  aws ec2 describe-instances --query 'Reservations[*].Instances[?State.Name==`running`].PublicDnsName' --output text
}


publicdns=$(get_running_instance_dns_name)

if test -z "$publicdns"
then
	echo "no running instance found, creating one"; create_aws_instance $> /dev/null; sleep 10; publicdns=$(get_running_instance_dns_name); echo "instance created: ""${publicdns}"
else
echo "running instance found -" "${publicdns}"
fi


ssh -q ubuntu@"${publicdns}" exit
retVal=$?
if [ $retVal -ne 0 ]; then
	echo "ssh not working"
  else 
    echo "ssh ok"
fi


