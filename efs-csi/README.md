# Install AWS EFS CSI Driver

## Prerequisites

- [awscli v2](https://docs.aws.amazon.com/ko_kr/cli/latest/userguide/install-cliv2.html)
- [kubectl](https://docs.aws.amazon.com/ko_kr/eks/latest/userguide/install-kubectl.html)
- [jq](https://stedolan.github.io/jq/download/)
- [helm v3](https://helm.sh/ko/docs/intro/install/)
- [curl](https://curl.se/download.html)
- aws account
- 외부망
- docker 환경

## Usage

### Add docker image to ECR

```shell
export REPO_ACCOUNT_ID=<Your AWS Account ID>
export REPO_PREFIX=<path/to>
export REGION=<REGION>

aws ecr get-login-password --region ${REGION} | docker login --username AWS --password-stdin ${REPO_ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com

# image pull
docker pull public.ecr.aws/eks-distro/kubernetes-csi/external-provisioner:v2.1.1-eks-1-18-2
docker pull public.ecr.aws/eks-distro/kubernetes-csi/livenessprobe:v2.2.0-eks-1-18-2
docker pull public.ecr.aws/eks-distro/kubernetes-csi/node-driver-registrar:v2.1.0-eks-1-18-2

# tagging
docker tag public.ecr.aws/eks-distro/kubernetes-csi/external-provisioner:v2.1.1-eks-1-18-2                    ${REPO_ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/${REPO_PATH}/csi-provisioner:v2.1.1-eks-1-18-2
docker tag public.ecr.aws/eks-distro/kubernetes-csi/livenessprobe:v2.2.0-eks-1-18-2                      ${REPO_ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/${REPO_PATH}/livenessprobe:v2.2.0-eks-1-18-2
docker tag public.ecr.aws/eks-distro/kubernetes-csi/node-driver-registrar:v2.1.0-eks-1-18-2          ${REPO_ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/${REPO_PATH}/csi-node-driver-registrar:v2.1.0-eks-1-18-2

# ebs용으로 생성한 경우 생략
aws ecr create-repository --repository-name ${REPO_PREFIX}/csi-provisioner
aws ecr create-repository --repository-name ${REPO_PREFIX}/livenessprobe
aws ecr create-repository --repository-name ${REPO_PREFIX}/csi-node-driver-registrar

# image push
docker push ${REPO_ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/${REPO_PATH}/csi-provisioner:v2.1.1-eks-1-18-2
docker push ${REPO_ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/${REPO_PATH}/livenessprobe:v2.2.0-eks-1-18-2
docker push ${REPO_ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/${REPO_PATH}/csi-node-driver-registrar:v2.1.0-eks-1-18-2
```

### Install

```shell
./efs_csi_installer.sh
```
