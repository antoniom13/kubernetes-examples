#!/bin/bash
VARSFILE=./vars.yml
CONTINUE_MSG="Press any key to continue..."
region=us-east-1

spacer() {
  echo
  echo $1
  echo
}

pause() {
  input=
  spacer
  echo $1
  echo -n $CONTINUE_MSG
  while [[ $input = "" ]]; do
    read -n1 -t1 input
    if [[ $input = "" ]]; then
      echo -n '.'
    else
      echo
      break
    fi
  done
}

pause

echo > $VARSFILE

echo "(kubectl) Applying k8s-configmap"
kubectl apply -f k8s-configmap.yml --wait

echo "(kubectl) Applying statefulset-init & waiting"
kubectl apply -f statefulset-init --wait

spacer "--- Variables ---"

volume=$(kubectl get pvc | grep hello | tail -n 1 | cut -d' ' -f8)
pvc=$(kubectl get pvc | grep hello | tail -n 1 | cut -d' ' -f1)
pod=$(kubectl get pods | grep hello | cut -d' ' -f1)

echo "volume: $volume"
echo "persistentVolumeClaim: $pvc"
echo "pod: $pod"

pause "Create AWS EBS Snapshot from volumeID ${volumeID}?"

#region=$(kubectl get pv ${volume} -o jsonpath='{.spec.awsElasticBlockStore.volumeID}' | cut -d'/' -f3)
volumeID=$(kubectl get pv ${volume} -o jsonpath='{.spec.awsElasticBlockStore.volumeID}' | cut -d'/' -f4)
snapshotID=$(aws ec2 create-snapshot --volume-id ${volumeID} --region=${region} \
  --description 'k8s StatefulSet App Restore Example Snapshot' \
  --tag-specifications 'ResourceType=snapshot,Tags=[{Key=name,Value=k8s-stateful-restore}]' \
  | jq -r .SnapshotId)

echo "region: $region"
echo "volumeID: $volumeID"
echo "snapshotID: $snapshotID"

echo "volumeID: ${volumeID}" >> $VARSFILE
echo "region: ${region}" >> $VARSFILE
echo "snapshotID: ${snapshotID}" >> $VARSFILE

pause "Remove StatefulSet?"
kubectl delete -f statefulset-init --wait

pause "Delete AWS EBS Volume with volumeID ${volumeID}?"
aws ec2 delete-volume --volume-id ${volumeID} --region=${region}

# TO DO
## Pass this volumeID's to the j2 templates
## Create the .yml files
## Bring up the 3 configs in statefulset-restore

exit 0