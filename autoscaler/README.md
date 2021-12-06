# Install AWS Cluster Autoscaler controller

## Prerequisites

- [awscli v2](https://docs.aws.amazon.com/ko_kr/cli/latest/userguide/install-cliv2.html)
- [kubectl](https://docs.aws.amazon.com/ko_kr/eks/latest/userguide/install-kubectl.html)
- [jq](https://stedolan.github.io/jq/download/)
- [helm v3](https://helm.sh/ko/docs/intro/install/)

## Usage

### Add docker image to ECR

```shell
export REPO_ACCOUNT_ID=<Your AWS Account ID>
export REPO_PATH=<path/to>
export REGION=<REGION>
export EKS_VERSION=<VERSION> # e.g. 1.21

aws ecr get-login-password --region ${REGION} | docker login --username AWS --password-stdin ${REPO_ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com

# image pull
docker pull k8s.gcr.io/autoscaling/cluster-autoscaler

# tagging
docker tag k8s.gcr.io/autoscaling/cluster-autoscaler:v${EKS_VERSION}.0                    ${REPO_ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/${REPO_PATH}/cluster-autoscaler:v${EKS_VERSION}.0

# ecr 생성
aws ecr create-repository --repository-name ${REPO_PATH}/cluster-autoscaler

# image push
docker push ${REPO_ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/${REPO_PATH}/cluster-autoscaler:v${EKS_VERSION}.0
```

### Install

```shell
./cluster_autoscaler_installer.sh
```

### Uninstall

```shell
./cluster_autoscaler_installer.sh delete
```

## Reference

<https://docs.aws.amazon.com/eks/latest/userguide/cluster-autoscaler.html>
