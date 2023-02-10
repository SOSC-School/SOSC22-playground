#!/bin/bash
export JHUB_USERNAME=$1
export USER_PASSWORD=$2
export KUBECONFIG=$PWD/kube_config_rke_rendered.yaml

export JHUB_USERNAME=`echo  $JHUB_USERNAME | sed 's/\./-/g'`

echo $JHUB_USERNAME

#MINIO → mc → create users + bucket + policy + credentials
cat templates/minio/policy-template.json | envsubst > /tmp/policy.json
cat templates/minio/credential_secret-template.yaml | envsubst > /tmp/credential_secret.yaml

echo "mc admin user add minio ${JHUB_USERNAME} ${USER_PASSWORD}"
mc admin user add minio ${JHUB_USERNAME} ${USER_PASSWORD}

mc ls minio/${JHUB_USERNAME} || mc mb minio/${JHUB_USERNAME}

mc admin policy add minio ${JHUB_USERNAME} /tmp/policy.json
mc admin policy set minio ${JHUB_USERNAME} user=${JHUB_USERNAME}

# Create minio secret for argo
kubectl -n user-${JHUB_USERNAME} create secret generic ${JHUB_USERNAME}-minio \
    --from-literal=accessKey=${JHUB_USERNAME} \
    --from-literal=secretKey=${USER_PASSWORD}

kubectl create namespace user-${JHUB_USERNAME} || echo "--> namespace exists"
kubectl create sa ${JHUB_USERNAME} || echo "--> service account exists"
kubectl apply -f /tmp/credential_secret.yaml

#ARGO → argo namespaced + create sa + minio bucket artifacts
cat templates/argo/argo_values.yaml | envsubst > /tmp/argo_values.yaml
cat templates/argo/user_secret.yaml | envsubst > /tmp/user_secret.yaml

#kubectl apply -f /tmp/user_secret.yaml
helm delete --namespace user-${JHUB_USERNAME} argo-wf 
helm upgrade --install --namespace user-${JHUB_USERNAME} argo-wf argo/argo-workflows \
  --create-namespace --values /tmp/argo_values.yaml

kubectl create clusterrolebinding ${JHUB_USERNAME}-argo-default --clusterrole=argo-cluster-role --serviceaccount=user-${JHUB_USERNAME}:default
kubectl create clusterrolebinding ${JHUB_USERNAME}-dask-default --clusterrole=dask-cluster-role --serviceaccount=user-${JHUB_USERNAME}:default

#DASK -> svc
cat templates/dask/ingress.yaml | envsubst > /tmp/ingress.yaml

kubectl apply -f /tmp/ingress.yaml
