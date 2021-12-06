# Install Ingress NGINX

## Prerequisites

- [awscli v2](https://docs.aws.amazon.com/ko_kr/cli/latest/userguide/install-cliv2.html)
- [kubectl](https://docs.aws.amazon.com/ko_kr/eks/latest/userguide/install-kubectl.html)
- [helm v3](https://helm.sh/ko/docs/intro/install/)
- [aws-load-balance-controller](https://github.com/kubernetes-sigs/aws-load-balancer-controller)

## Usage

### Add docker image to ECR

```shell
export REPO_ACCOUNT_ID=<Your AWS Account ID>
export REPO_PATH=<path/to>
export REGION=<REGION>

aws ecr get-login-password --region ${REGION} | docker login --username AWS --password-stdin ${REPO_ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com

# image pull
docker pull k8s.gcr.io/ingress-nginx/controller:v1.0.1

# tagging
docker tag k8s.gcr.io/ingress-nginx/controller:v1.0.1                    ${REPO_ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/${REPO_PATH}/ingress-nginx:v1.0.1

# ecr 생성
aws ecr create-repository --repository-name ${REPO_PATH}/ingress-nginx

# image push
docker push ${REPO_ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/${REPO_PATH}/ingress-nginx:v1.0.1
```

### Install

```shell
./ingress_nginx_controller.sh
```

### Cleanup

```shell
./ingress_nginx_controller.sh delete
```

## Reference

### ingress-nginx

<https://kubernetes.github.io/ingress-nginx/>

### ingress-nginx-nlb

<https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.2/guide/service/annotations/>
