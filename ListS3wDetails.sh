#!/bin/bash
# set -x
##Removes Default VPC's in each Region.
##Created by Christopher Welle Email:cjwelle@gmail.com
##Usage of this command is the following: $./ListS3wDetails.sh profile (e.g. $./ListS3wDetails.sh default)
profile="$1"

function s3 {
  s31=$(aws --profile $profile s3api list-buckets --query 'Buckets[*].Name' --output text )
  if [[ -z "$s31" ]]; then
    echo 'No S3s Here.'
    break
  else
    s3=$s31
  fi
}

function s3loc {
  s3loc=$(aws --profile $profile s3api get-bucket-location --bucket $s --output text)
}

function cals3 {
  cals3a=$(aws --profile $profile s3 ls --summarize --human-readable --recursive s3://$s/ | sed '$!d')
}

s3
echo -e 'S3 Bucket Name: \t AWS Region: \t Bucket Size:'
for s in $s3; do
  s3loc
  cals3
  echo -e ''$s'\t'$s3loc'\t'$cals3a''
done
