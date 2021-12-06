# EBS Example

## Prerequisites

### EFS

다음을 참고하여 EFS 파일 시스템을 생성
[Create an Amazon EFS file system](https://docs.aws.amazon.com/eks/latest/userguide/efs-csi.html)

### Docker image for Test app

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
kubectl apply -f storage.yaml
kubectl apply -f pv.yaml
kubectl apply -f claim.yaml
kubectl apply -f pod.yaml
```

## Verification

```shell
kubectl exec -it efs-pod/app -- /bin/sh

cat /data/out
```