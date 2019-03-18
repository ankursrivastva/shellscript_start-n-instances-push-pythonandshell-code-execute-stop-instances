#!/bin/bash

#sudo apt  install awscli  - for installing awscli
#aws configure for configuring secret and access key

read -p "enter number of instances" number_instances
echo "enter instance ids"
i=0 
while [ $i -lt $number_instances ]
do
    # To input from user
    read a[$i]

    # Increment the i = i + 1
    i=`expr $i + 1`
done
read -p "enter shell scriptcode file name\t" shellcode
read -p "enter pythonfile name\t" pythonfile
read -p "enter key file\t" keyfile
for elem in ${a[@]}
do
  aws ec2 start-instances --instance-ids $elem
done

sleep 180


for elem1 in ${a[@]}
do
elem2=$(aws ec2 describe-instances --instance-id $elem1 --query 'Reservations[].Instances[].PublicIpAddress')
scp -i $keyfile $shellcode ubuntu@$elem2:/home/ubuntu
scp -i $keyfile $pythonfile ubuntu@$elem2:/home/ubuntu
ssh -i $keyfile ubuntu@$elem2 'chmod 700 /home/ubuntu/$shellcode'
ssh -i $keyfile ubuntu@$elem2 'sh /home/ubuntu/$shellcode >> shout.txt'
ssh -i $keyfile ubuntu@$elem2 'chmod 700 /home/ubuntu/$pythonfile'
ssh -i $keyfile ubuntu@$elem2 'sudo apt-get -y update'
ssh -i $keyfile ubuntu@$elem2 "sudo apt-get install -y python"
ssh -i $keyfile ubuntu@$elem2 "/usr/bin/python /home/ubuntu/$pythonfile >> pyout.txt"
done

for elem in ${a[@]}
do
  aws ec2 stop-instances --instance-ids $elem
done
