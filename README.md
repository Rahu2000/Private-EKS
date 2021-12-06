# Private-EKS
How to Install EKS in a private VPC

## Prerequisites

- [eksctl](https://docs.aws.amazon.com/ko_kr/eks/latest/userguide/eksctl.html)

## Notice

- 이미 생성된 프라이빗 vpc에 eksctl을 적용할 경우 2개 이상의 라우팅 테이블(전체 서브넷, 각각의 프라이빗 서브넷)이 필요
- vpc내에 ecr.api, ecr.dkr. ec2, s3, sts, logs에 대한 endpoints가 이미 존재할 경우 중복 생성 오류 발생
- eks 클러스터를 eksctl로 생성하지 않은 경우 eksctl을 통해 nodegroup 생성 불가

## Usage

### Create cluster

```shell
eksctl create cluster -f create-eks-only.yaml
```

### Create Nodegroup

```shell
eksctl create nodegroup -f create-nodegroups.yaml
```

### Delete cluster

```shell
eksctl delete cluster --name {EKS_CLUSTER_NAME} --force --wait
```

## EKSCTL Schema

eksctl의 프로퍼티에서 대해서는 다음을 참조
https://eksctl.io/usage/schema/