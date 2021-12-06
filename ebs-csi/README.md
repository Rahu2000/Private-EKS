# Install AWS EBS CSI Driver

## Prerequisites

- [awscli v2](https://docs.aws.amazon.com/ko_kr/cli/latest/userguide/install-cliv2.html)
- [kubectl](https://docs.aws.amazon.com/ko_kr/eks/latest/userguide/install-kubectl.html)
- [jq](https://stedolan.github.io/jq/download/)
- [helm v3](https://helm.sh/ko/docs/intro/install/)
- [curl](https://curl.se/download.html)
- aws account
- 외부망

## Usage

### Add docker image to ECR

```shell
export REPO_ACCOUNT_ID=<Your AWS Account ID>
export REPO_PREFIX=<path/to>
export REGION=<REGION>

aws ecr get-login-password --region ${REGION} | docker login --username AWS --password-stdin ${REPO_ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com

docker pull k8s.gcr.io/sig-storage/csi-provisioner:v2.1.1
docker pull k8s.gcr.io/sig-storage/csi-attacher:v3.1.0
docker pull k8s.gcr.io/sig-storage/csi-snapshotter:v3.0.3
docker pull k8s.gcr.io/sig-storage/livenessprobe:v2.2.0
docker pull k8s.gcr.io/sig-storage/csi-resizer:v1.0.0
docker pull k8s.gcr.io/sig-storage/csi-node-driver-registrar:v2.1.0

docker tag k8s.gcr.io/sig-storage/csi-provisioner:v2.1.1                    ${REPO_ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/${REPO_PREFIX}/csi-provisioner:v2.1.1
docker tag k8s.gcr.io/sig-storage/csi-attacher:v3.1.0                       ${REPO_ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/${REPO_PREFIX}/csi-attacher:v3.1.0
docker tag k8s.gcr.io/sig-storage/csi-snapshotter:v3.0.3                    ${REPO_ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/${REPO_PREFIX}/csi-snapshotter:v3.0.3
docker tag k8s.gcr.io/sig-storage/livenessprobe:v2.2.0                      ${REPO_ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/${REPO_PREFIX}/livenessprobe:v2.2.0
docker tag k8s.gcr.io/sig-storage/csi-resizer:v1.0.0                        ${REPO_ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/${REPO_PREFIX}/csi-resizer:v1.0.0
docker tag k8s.gcr.io/sig-storage/csi-node-driver-registrar:v2.1.0          ${REPO_ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/${REPO_PREFIX}/csi-node-driver-registrar:v2.1.0

aws ecr create-repository --repository-name ${REPO_PREFIX}/csi-provisioner
aws ecr create-repository --repository-name ${REPO_PREFIX}/csi-attacher
aws ecr create-repository --repository-name ${REPO_PREFIX}/csi-snapshotter
aws ecr create-repository --repository-name ${REPO_PREFIX}/livenessprobe
aws ecr create-repository --repository-name ${REPO_PREFIX}/csi-resizer
aws ecr create-repository --repository-name ${REPO_PREFIX}/csi-node-driver-registrar

docker push ${REPO_ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/${REPO_PREFIX}/csi-provisioner:v2.1.1
docker push ${REPO_ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/${REPO_PREFIX}/csi-attacher:v3.1.0
docker push ${REPO_ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/${REPO_PREFIX}/csi-snapshotter:v3.0.3
docker push ${REPO_ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/${REPO_PREFIX}/livenessprobe:v2.2.0
docker push ${REPO_ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/${REPO_PREFIX}/csi-resizer:v1.0.0
docker push ${REPO_ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/${REPO_PREFIX}/csi-node-driver-registrar:v2.1.0
```

### Install

```shell
./ebs_csi_installer.sh
```

### Cleanup

```shell
./ebs_csi_installer.sh delete
```
