# AWS Load Balance Controller example

## Prerequisite

- 외부망 연결 가능
- Docker 실행 환경
- AWS 계정
- aws-cli v2
- aws subnet 및 [subnet tag](https://docs.aws.amazon.com/ko_kr/eks/latest/userguide/alb-ingress.html)

## Add docker image to ECR

```shell
# Create ecr registory
aws ecr create-repository --repository-name ${REPOSITORY_NAME} --region ${REGION}
# Login to ecr
aws ecr get-login-password --region ${REGION} | docker login --username AWS --password-stdin ${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com

# docker image pull
docker pull alexwhen/docker-2048
# tagging for docker push
docker tag alexwhen/docker-2048 ${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/${REPOSITORY_NAME}:latest
# push docker image to your ecr
docker push ${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/${REPOSITORY_NAME}:latest
```

## Edit 2048_app.yaml

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  namespace: game-2048
  name: deployment-2048
spec:
  selector:
    matchLabels:
      app.kubernetes.io/name: app-2048
  replicas: 2
  template:
    metadata:
      labels:
        app.kubernetes.io/name: app-2048
    spec:
      containers:
      - image: ${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/${REPOSITORY_NAME} # modify
        imagePullPolicy: Always
        name: app-2048
        ports:
        - containerPort: 80
```

## Edit 2048_ingress.yaml

자세한 `alb annotation`에 대해서는 다음 사이트 참조 </br>
<https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.2/guide/ingress/annotations/>

alb controller를 적용하기 위해서는 반드시 subnet에 `kubernetes.io/role/internal-elb`(내부망) 또는 `kubernetes.io/role/elb`(외부망)이 있어야 한다.

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  namespace: game-2048
  name: ingress-2048
  annotations:
    kubernetes.io/ingress.class: alb                                                # alb class name
    alb.ingress.kubernetes.io/scheme: internal                                      # internal(내부망) or internet-facing (외부망)
    alb.ingress.kubernetes.io/target-type: ip
    alb.ingress.kubernetes.io/inbound-cidrs: 192.168.0.0/16                         # alb security group inbound cidrs
    alb.ingress.kubernetes.io/tags: env=dev, owner=psa, Name=game-2048-ingress      # add tags to AWS Resouces(alb, security group)
    # alb.ingress.kubernetes.io/listen-ports: '[{"HTTP": 80}, {"HTTPS": 443}]'      # listen-ports
    # alb.ingress.kubernetes.io/actions.redirect-to-https: >
    #   {"Type":"redirect","RedirectConfig":{"Port":"443","Protocol":"HTTPS","StatusCode":"HTTP_302"}}  # https -> http redirect
    # alb.ingress.kubernetes.io/certificate-arn: arn:aws:acm:ap-northeast-2:${ACCOUNT}:certificate/xxxxxxxx-xxxx-xxxx-xxxx-ac096b5f7def # ACM ARN for HTTPS
spec:
  rules:
    - http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: service-2048
                port:
                  number: 80
```

## Deploy

```shell
kubectl apply -f 2048_app.yaml
kubectl apply -f 2048_ingress.yaml
```

## Verification

```shell
kubectl get ingress -n game-2048
```
