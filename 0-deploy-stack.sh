#!/bin/bash

STACKNAME='eks-example'

CFFILE=./cloudfront-config/cfn.yml
SETENVFILE='./setenv.sh'
KUBECONFIG='./k8s-config.yml'
KUBECONFIGTEMPLATE='./kube-configs/k8s-config.yml.j2'

KUBECONFIGMAP='./k8s-configmap-aws.yml'
KUBECONFIGMAPTEMPLATE='./kube-configs/k8s-configmap-aws.yml.j2'

AWSBIN=$(which aws)
YASHABIN=$(which yasha)
JQ=$(which jq)

#$AWSBIN cloudformation deploy \
#  --template-file $CFFILE \
#  --capabilities CAPABILITY_IAM \
#  --stack-name $STACKNAME
#
#echo

OUTPUT=$($AWSBIN cloudformation describe-stacks \
  --stack-name $STACKNAME \
  --query Stacks[0].Outputs)

printf "Getting information to bootstrap Kubernetes... \n\n"

server=$(echo $OUTPUT | jq '.[0].OutputValue')
clusterName=$(echo $OUTPUT | jq '.[1].OutputValue')
roleARN=$(echo $OUTPUT | jq '.[2].OutputValue')
certificateAuthorityData=$(echo $OUTPUT | jq '.[3].OutputValue')

echo "Generating Kubernetes (k8s) Configuration YAML file with the following data: "

echo "server: $server"
echo "clusterName: $clusterName"
echo "roleARN: $roleARN"
echo "certificateAuthorityData: $certificateAuthorityData"

yasha --server=$server \
  --clusterName=$clusterName \
  --roleARN=$roleARN \
  --certificateAuthorityData=$certificateAuthorityData \
  -o $KUBECONFIG \
  $KUBECONFIGTEMPLATE

echo "Generating Kubernetes (k8s) Configuration Map for AWS"
yasha --roleARN=$roleARN \
  --EC2PrivateDNSName='{{EC2PrivateDNSName}}' \
  -o $KUBECONFIGMAP \
  $KUBECONFIGMAPTEMPLATE

echo "Setting up env file for exports..."
echo
echo "echo export KUBECONFIG=$KUBECONFIG" > $SETENVFILE
echo
echo "Please run the following in your terminal to finish:

$ eval ${SETENVFILE}

"

exit 0