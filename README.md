# Creating Cloud Formation & EKS Stack

## Prerequisites

* `kubectl` [Install Docs](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
* `aws-iam-authenticator` [Install Docs](https://docs.aws.amazon.com/eks/latest/userguide/configure-kubectl.html)
* `aws-cli` [Install Docs](https://docs.aws.amazon.com/cli/latest/userguide/installing.html)
* `jq` [Github](https://github.com/stedolan/jq)
* `yasha` [Github](https://github.com/kblomqvist/yasha)

## Deploy EKS Stack using CF
`$ ./0-deploy-stack.sh`

## Set Environment Variables for Kubernetes
`$ eval $(./setenv.sh)`

## Apply Kubernetes Map

### Manually
`$ kubectl apply -f k8s-configmap.yml`

### Automatically
Run the demo for a full deployment.

`$ ./1-demo.sh`

## Verify Deployment
> Coming Soon....

```bash
$ run commands to check nodes / services / pods
```

## Simulate Doomsday

* delete pod / pv / pvc / volume
```bash
$ kubectl delete -f statefulset.yaml
$ aws ec2 delete-volume --volume-id ${volumeID} --region=${region}
```

# Deploying Applications
> Coming Soon....

# Bring Down Stack

```bash
$ aws cloudformation delete-stack --stack-name 'eks-example'
```

# What's Happening Under the Hood
> Coming Soon...

# Troubleshooting
> Coming Soon...

# Appendix

## Inspirations
* [AWS EKS Security Groups](https://docs.aws.amazon.com/eks/latest/userguide/sec-group-reqs.html)
* [Statefulset Recovery Blog Post](https://medium.com/@joatmon08/kubernetes-statefulset-recovery-from-aws-snapshots-8a6159cda6f1)
* [AWS EKS Example](https://github.com/y13i/aws-eks-example)