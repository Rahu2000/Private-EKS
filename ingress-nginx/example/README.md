# Nginx ingress example

## Prerequisite

- 외부망 연결 가능
- Docker 실행 환경
- AWS 계정
- aws-cli v2
- aws subnet 및 [subnet tag](https://docs.aws.amazon.com/ko_kr/eks/latest/userguide/alb-ingress.html)

## Add docker image to ECR

```shell
export REGION=<Region>
export REPOSITORY_NAME=<EXAMPLE IMAGE REPOSITORY>
export ACCOUNT_ID=<AWS Account ID>

# Create ecr registory
aws ecr create-repository --repository-name ${REPOSITORY_NAME} --region ${REGION}
# Login to ecr
aws ecr get-login-password --region ${REGION} | docker login --username AWS --password-stdin ${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com

# docker image pull
docker pull mcr.microsoft.com/azuredocs/aks-helloworld:v1
# tagging for docker push
docker tag mcr.microsoft.com/azuredocs/aks-helloworld:v1 ${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/${REPOSITORY_NAME}:latest
# push docker image to your ecr
docker push ${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/${REPOSITORY_NAME}:latest
```

## Deploy

### Edit helloworld.yaml

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: aks-helloworld
spec:
  replicas: 1
  selector:
    matchLabels:
      app: aks-helloworld
  template:
    metadata:
      labels:
        app: aks-helloworld
    spec:
      containers:
      - name: aks-helloworld
        image: ${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/${REPOSITORY_NAME}:latest  # Replace your image repo
        ports:
        - containerPort: 80
        env:
        - name: TITLE
          value: "Welcome to Azure Kubernetes Service (AKS)"
---
apiVersion: v1
kind: Service
metadata:
  name: aks-helloworld
spec:
  type: ClusterIP
  ports:
  - port: 80
  selector:
    app: aks-helloworld
```

### Edit ingress-demo.yaml

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ingress-demo
spec:
  replicas: 1
  selector:
    matchLabels:
      app: ingress-demo
  template:
    metadata:
      labels:
        app: ingress-demo
    spec:
      containers:
      - name: ingress-demo
        image: ${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/${REPOSITORY_NAME}:latest # Replace your image repo
        ports:
        - containerPort: 80
        env:
        - name: TITLE
          value: "AKS Ingress Demo"
---
apiVersion: v1
kind: Service
metadata:
  name: ingress-demo
spec:
  type: ClusterIP
  ports:
  - port: 80
  selector:
    app: ingress-demo
```

### Apply

```shell
kubectl apply -f helloworld.yaml
kubectl apply -f ingress-demo.yaml
kubectl apply -f ingress.yaml
```

## Verification

내부망에 생성한 VM 또는 Pod에서 다음을 실행한다.

```shell
SERVICE=$(kuberctl get svc -n ingress-nginx -ojson | jq -r '.items[0].status.loadBalancer.ingress[0].hostname')
curl -L http://${SERVICE}
curl -L http://${SERVICE}/hello-world-one
curl -L http://${SERVICE}/hello-world-two
```
