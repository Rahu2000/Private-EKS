# Install AWS Application Load Balancer controller

## Prerequisites

- [awscli v2](https://docs.aws.amazon.com/ko_kr/cli/latest/userguide/install-cliv2.html)
- [kubectl](https://docs.aws.amazon.com/ko_kr/eks/latest/userguide/install-kubectl.html)
- [jq](https://stedolan.github.io/jq/download/)
- [helm v3](https://helm.sh/ko/docs/intro/install/)
- [curl](https://curl.se/download.html)
- [identity provider](https://console.aws.amazon.com/iamv2/home?#/identity_providers)

## Usage

### identity provider

다음을 참고하여 identity provider를 생성</br>
[To create an IAM OIDC identity provider for your cluster with the AWS Management Console](https://docs.aws.amazon.com/eks/latest/userguide/enable-iam-roles-for-service-accounts.html)

### Install

```shell
./alb_controller_install.sh
```

### Cleanup

```shell
./alb_controller_install.sh delete
```
