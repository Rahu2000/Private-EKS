##############################################################
# AWS LOAD BALANCER CONTROLLER INSTALLER
#
# Required tools
# - helm v3+ (https://get.helm.sh/helm-v3.6.3-linux-amd64.tar.gz)
# - yq 1.5.1 (sudo yum install jq)
# - kubectl 1.21 (curl -o kubectl https://amazon-eks.s3.${REGION}.amazonaws.com/1.21.2/2021-07-05/bin/linux/amd64/kubectl)
#
# Tested version
#   v0.1
#     EKS v1.19
#     cert-manager v1.0.2
#     aws-load-balancer-controller v2.1.3
#   v0.2
#     EKS v1.21
#     cert-manager v1.3.1
#     aws-load-balancer-controller v2.2.1 (chart: 1.2.3)
##############################################################
#!/bin/bash
export CLUSTER_NAME="eksworkshop"
export RELEASE_NAME="aws-load-balance-controller"
export IAM_POLICY_NAME="AmazonEKS_Load_Balancer_Controller_Policy"
export IAM_ROLE_NAME="AmazonEKS_Load_Balancer_Controller_Role"
export ALBC_CHART_VERSION="1.2.3"
export SERVICE_ACCOUNT="aws-load-balancer-controller"
export NAMESPACE="kube-system"
export REGION="ap-northeast-2"
export REPLIACS=1
export ENABLE_CERT_MANAGER=false
export CERT_MANGER_VERSION="v1.3.1"
export CERT_NAMESPACE="cert-manager"
export CERT_RELEASE_NAME="cert-manager"
export ENABLE_PROMETHUES_MONITORING=false

export CREATE_ELB_ENDPOINT=true
export SUBNET_IDS="subnet-0117be75a582cb7ee subnet-047928ac813390648"
export SG_ID="sg-067e493498af9b010"

source ../common/utils.sh

##############################################################
# Delete release
##############################################################
if [ "delete" == "$1" ]; then
  helm delete ${RELEASE_NAME} --namespace ${NAMESPACE}
  kubectl delete --ignore-not-found cm/aws-load-balancer-controller-leader --namespace ${NAMESPACE}

  if "$ENABLE_CERT_MANAGER"; then
    helm delete ${CERT_RELEASE_NAME} --namespace ${CERT_NAMESPACE}
    kubectl delete --ignore-not-found cm/cert-manager-cainjector-leader-election --namespace ${NAMESPACE}
    kubectl delete --ignore-not-found cm/cert-manager-cainjector-leader-election-core --namespace ${NAMESPACE}
    kubectl delete --ignore-not-found cm/cert-manager-controller --namespace ${NAMESPACE}
    kubectl delete ns ${CERT_NAMESPACE}

    kubectl delete --ignore-not-found customresourcedefinitions\
      certificaterequests.cert-manager.io\
      certificates.cert-manager.io\
      challenges.acme.cert-manager.io\
      clusterissuers.cert-manager.io\
      issuers.cert-manager.io\
      orders.acme.cert-manager.io
  fi
  exit 0
fi

DIR=(`date "+%Y-%m-%d-%H%M%S"`)
mkdir -p /tmp/$DIR
cp ./templates/*.values.yaml /tmp/${DIR}/

LOCAL_OS_KERNEL="$(uname -a | awk -F ' ' ' {print $1} ')"
##############################################################
# Install the cert-manager
##############################################################
## Install the cert-manager CRD
if "$ENABLE_CERT_MANAGER"; then
  kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/"${CERT_MANGER_VERSION}"/cert-manager.crds.yaml

  ## Add the Jetstack Helm repository
  if [ -z "$(helm repo list | grep https://charts.jetstack.io)" ]; then
    helm repo add jetstack https://charts.jetstack.io
  fi
  helm repo update

  if [ "Darwin" == "$LOCAL_OS_KERNEL" ]; then
    sed -i.bak "s|CERT_MANGER_VERSION|${CERT_MANGER_VERSION}|g" /tmp/${DIR}/cert-manager.values.yaml
    sed -i '' "s|ENABLE_PROMETHUES_MONITORING|${ENABLE_PROMETHUES_MONITORING}|g" /tmp/${DIR}/cert-manager.values.yaml
  else
    sed -i.bak "s/CERT_MANGER_VERSION/${CERT_MANGER_VERSION}/g" /tmp/${DIR}/cert-manager.values.yaml
    sed -i "s/ENABLE_PROMETHUES_MONITORING/${ENABLE_PROMETHUES_MONITORING}/g" /tmp/${DIR}/cert-manager.values.yaml
  fi

  ## Install the cert-manager helm chart
  helm upgrade --install \
    ${CERT_RELEASE_NAME} jetstack/cert-manager \
    --namespace ${CERT_NAMESPACE} \
    --version "${CERT_MANGER_VERSION}" \
    --create-namespace \
    -f /tmp/${DIR}/cert-manager.values.yaml \
    --wait
fi

##############################################################
# Create IAM Role for a aws-load-balancer-controller ServiceAccount
##############################################################
## download a latest policy for Aws Load Balancer controller from kubernetes-sigs
# curl -o iam_policy.json https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/main/docs/install/iam_policy.json

## create a policy
IAM_POLICY_ARN=$(aws iam list-policies --scope Local 2> /dev/null | jq -c --arg policyname $IAM_POLICY_NAME '.Policies[] | select(.PolicyName == $policyname)' | jq -r '.Arn')
if [ -z "$IAM_POLICY_ARN" ]; then
  IAM_POLICY_ARN=$(aws iam create-policy --policy-name ${IAM_POLICY_NAME} --policy-document file://./templates/iam_policy.json | jq -r .Policy.Arn)
fi

IAM_ROLE_ARN=$(createRole "$CLUSTER_NAME" "$NAMESPACE" "$SERVICE_ACCOUNT" "$IAM_ROLE_NAME" "$IAM_POLICY_ARN")

##############################################################
# Install the aws-load-balancer-controller
##############################################################
## Add the Jetstack Helm repository
# if [ -z "$(helm repo list | grep https://aws.github.io/eks-charts)" ]; then
#   helm repo add eks https://aws.github.io/eks-charts
# fi
# helm repo update

VPC_ID="$(aws eks describe-cluster --name $CLUSTER_NAME --region $REGION | jq -r .cluster.resourcesVpcConfig.vpcId)"

if "$CREATE_ELB_ENDPOINT"; then
  aws ec2 create-vpc-endpoint \
  --vpc-id ${VPC_ID} \
  --vpc-endpoint-type Interface \
  --service-name com.amazonaws.${REGION}.elasticloadbalancing \
  --subnet-ids ${SUBNET_IDS} \
  --security-group-id ${SG_ID}
fi

# Modify cluster name and resource.requests.memory (to avoid OOM)
if [ "Darwin" == "$LOCAL_OS_KERNEL" ]; then
  sed -i.bak "s|REPLIACS|${REPLIACS}|g" /tmp/${DIR}/alb-controller.values.yaml
  sed -i '' "s|RELEASE_NAME|${RELEASE_NAME}|g" /tmp/${DIR}/alb-controller.values.yaml
  sed -i '' "s|CLUSTER_NAME|${CLUSTER_NAME}|g" /tmp/${DIR}/alb-controller.values.yaml
  sed -i '' "s|IAM_ROLE_ARN|${IAM_ROLE_ARN}|g" /tmp/${DIR}/alb-controller.values.yaml
  sed -i '' "s|SERVICE_ACCOUNT|${SERVICE_ACCOUNT}|g" /tmp/${DIR}/alb-controller.values.yaml
  sed -i '' "s|REGION|${REGION}|g" /tmp/${DIR}/alb-controller.values.yaml
  sed -i '' "s|VPC_ID|${VPC_ID}|g" /tmp/${DIR}/alb-controller.values.yaml
  sed -i '' "s|ENABLE_CERT_MANAGER|${ENABLE_CERT_MANAGER}|g" /tmp/${DIR}/alb-controller.values.yaml
else
  IAM_ROLE_ARN=$(echo ${IAM_ROLE_ARN} | sed 's|\/|\\/|')
  sed -i "s/REPLIACS/${REPLIACS}/g" /tmp/${DIR}/alb-controller.values.yaml
  sed -i "s/RELEASE_NAME/${RELEASE_NAME}/g" /tmp/${DIR}/alb-controller.values.yaml
  sed -i "s/CLUSTER_NAME/${CLUSTER_NAME}/g" /tmp/${DIR}/alb-controller.values.yaml
  sed -i "s/IAM_ROLE_ARN/${IAM_ROLE_ARN}/g" /tmp/${DIR}/alb-controller.values.yaml
  sed -i "s/SERVICE_ACCOUNT/${SERVICE_ACCOUNT}/g" /tmp/${DIR}/alb-controller.values.yaml
  sed -i "s/REGION/${REGION}/g" /tmp/${DIR}/alb-controller.values.yaml
  sed -i "s/VPC_ID/${VPC_ID}/g" /tmp/${DIR}/alb-controller.values.yaml
  sed -i "s/ENABLE_CERT_MANAGER/${ENABLE_CERT_MANAGER}/g" /tmp/${DIR}/alb-controller.values.yaml
fi

## Install the aws-load-balance-controller helm chart
helm upgrade --install \
  ${RELEASE_NAME} ./../helm-charts/eks-charts-0.0.61/aws-load-balancer-controller \
  --set image.repository=602401143452.dkr.ecr.${REGION}.amazonaws.com/amazon/aws-load-balancer-controller \
  --namespace ${NAMESPACE} \
  --version "${ALBC_CHART_VERSION}" \
  -f /tmp/${DIR}/alb-controller.values.yaml \
  --wait