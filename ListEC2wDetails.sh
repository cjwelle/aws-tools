#!/bin/bash
#set -x
##Gets information of EC2 in each Region.
##Created by Christopher Welle Email:cjwelle@gmail.com
##Usage of this command is the following: $./ListEC2wDetails.sh profile (e.g. $./ListEC2wDetails.sh default)
regions=$(aws ec2 describe-regions --output text | cut -f4) #pulls all regions that are available to that profile and parses the region name.
# regions=us-west-2
profile="$1"

function ec2 {
  ec21=$(aws --profile $profile --region $r ec2 describe-instances --output text  --query "Reservations[*].Instances[*].InstanceId")
  if [[ -z "$ec21" ]]; then
    echo 'No EC2s Here.'
    echo ''
  else
    ec2=$ec21
  fi
}

function ec2dets-name {
  ec2name1=$(aws --profile $profile --region $r ec2 describe-instances --filters "Name=instance-id,Values=$e" --output text --query "Reservations[*].Instances[*].[Tags[?Key=='Name'].Value]")
  if [[ -z "$ec2name1" ]]; then
    ec2name='No EC2 Name.'
  else
    ec2name=$ec2name1
  fi
}

function ec2dets-instype {
  ec2type=$(aws --profile $profile --region $r ec2 describe-instances --filters "Name=instance-id,Values=$e" --output text --query "Reservations[*].Instances[*].InstanceType")
}

function ec2dets-az {
  ec2az=$(aws --profile $profile --region $r ec2 describe-instances --filters "Name=instance-id,Values=$e" --output text --query "Reservations[*].Instances[*].Placement.AvailabilityZone")
}

function ec2dets-state {
  ec2state=$(aws --profile $profile --region $r ec2 describe-instances --filters "Name=instance-id,Values=$e" --output text --query "Reservations[*].Instances[*].State.Name")
}

function ec2dets-ip4priv {
  ec2ip4priv=$(aws --profile $profile --region $r ec2 describe-instances --filters "Name=instance-id,Values=$e" --output text --query "Reservations[*].Instances[*].PrivateIpAddress")
}

function ec2dets-ip4pubdns {
  ec2ip4pubdns=$(aws --profile $profile --region $r ec2 describe-instances --filters "Name=instance-id,Values=$e" --output text --query "Reservations[*].Instances[*].NetworkInterfaces[*].PrivateIpAddresses[*].Association.PublicDnsName")
}

function ec2dets-ip4pub {
  ec2ip4pub=$(aws --profile $profile --region $r ec2 describe-instances --filters "Name=instance-id,Values=$e" --output text --query "Reservations[*].Instances[*].NetworkInterfaces[*].PrivateIpAddresses[*].Association.PublicIp")
}

function ec2dets-keyname {
  ec2keyname=$(aws --profile $profile --region $r ec2 describe-instances --filters "Name=instance-id,Values=$e" --output text --query "Reservations[*].Instances[*].KeyName")
}

function ec2dets-launchtime {
  ec2launchtime=$(aws --profile $profile --region $r ec2 describe-instances --filters "Name=instance-id,Values=$e" --output text --query "Reservations[*].Instances[*].LaunchTime")
}

function ec2dets-secgroup {
  ec2secgroup=$(aws --profile $profile --region $r ec2 describe-instances --filters "Name=instance-id,Values=$e" --output text --query "Reservations[*].Instances[*].NetworkInterfaces[*].Groups" )
}

function ec2dets-vpcid {
  ec2vpcid=$(aws --profile $profile --region $r ec2 describe-instances --filters "Name=instance-id,Values=$e" --output text --query "Reservations[*].Instances[*].VpcId")
}

function ec2dets-subnetid {
  ec2subnetid=$(aws --profile $profile --region $r ec2 describe-instances --filters "Name=instance-id,Values=$e" --output text --query "Reservations[*].Instances[*].SubnetId")
}

#aws --profile cc-net --region us-west-2 ec2 describe-instances --filters "Name=instance-id,Values=i-06883e36b44fc6faa" --output text --query "Reservations[*].Instances[*].State.Name"

function ebsdets {
  ebs=$(aws --profile $profile --region $r ec2 describe-instances --filters "Name=instance-id,Values=$e" --output text --query "Reservations[*].Instances[*].BlockDeviceMappings[*].Ebs.VolumeId")
  for eb in $ebs; do
    device=$(aws --profile $profile --region $r ec2 describe-volumes --volume-ids $eb --output text --query "Volumes[*].Attachments[*].Device")
    encrypted=$(aws --profile $profile --region $r ec2 describe-volumes --volume-ids $eb --output text --query "Volumes[*].Encrypted")
    size=$(aws --profile $profile --region $r ec2 describe-volumes --volume-ids $eb --output text --query "Volumes[*].Size")
    iops=$(aws --profile $profile --region $r ec2 describe-volumes --volume-ids $eb --output text --query "Volumes[*].Iops")
    type=$(aws --profile $profile --region $r ec2 describe-volumes --volume-ids $eb --output text --query "Volumes[*].VolumeType")
    echo '"Volume-ID: '$eb', Mount Point: '$device', Disk Size: '$size', IOPS: '$iops', Volume Type: '$type', Encrypted?: '$encrypted'"'
  done
}
#aws --profile cc-net --region us-west-2 ec2 describe-volumes --volume-ids vol-047454e0551898be7 --output text --query "Volumes[*].VolumeType"


for r in $regions; do
  echo $r
  echo -e "Name: \t InstanceId: \t InstanceType: \t AvailabilityZone: \t InstanceSize: \t InstanceState: \t IPv4PrivateIP: \t PublicDNS(IP4): \t IPV4PublicIP: \t KeyName: \t LaunchTime: \t SecurityGroup: \t VPCId: \t SubnetId: \t EBSVol: \t Notes: \t "
  ec2
  for e in $ec2; do
    ec2dets-name
    ec2dets-instype
    ec2dets-az
    ec2dets-state
    ec2dets-ip4priv
    ec2dets-ip4pubdns
    ec2dets-ip4pub
    ec2dets-keyname
    ec2dets-launchtime
    ec2dets-secgroup
    ec2dets-vpcid
    ec2dets-subnetid
    echo -e ''$ec2name'\t'$e' \t '$ec2type'\t'$ec2az'\t'$ec2type'\t'$ec2state'\t'$ec2ip4priv'\t'$ec2ip4pubdns'\t'$ec2ip4pub'\t'$ec2keyname'\t'$ec2launchtime'\t"'$ec2secgroup'"\t'$ec2vpcid'\t'$ec2subnetid'\t'
    ebsdets
    unset -v e
  done
  echo -e ''
  unset -v ec2
  echo -e "Currently purchased Reserved Instances"
  aws --profile $profile ec2 describe-reserved-instances --output yaml
  echo $ec2
done
