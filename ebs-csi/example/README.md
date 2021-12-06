# EBS Example

## Prerequisites

```shell
export REPO_ACCOUNT_ID=<Your AWS Account ID>
export REPO_PREFIX=<path/to>
export REGION=<REGION>

aws ecr get-login-password --region ${REGION} | docker login --username AWS --password-stdin ${REPO_ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com

docker pull busybox
docker tag busybox:latest                ${REPO_ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/${REPO_PATH}/busybox:latest
aws ecr create-repository --repository-name ${REPO_PATH}/busybox
docker push ${REPO_ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/${REPO_PATH}/busybox:latest
```

## Deploy

```shell
kubectl apply -f app.yaml
```

## Verification

```shell
kubectl exec -it pod/app -- /bin/sh

cat /data/out
```