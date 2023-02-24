#!/bin/bash
export JHUB_USERNAME=$1
export USER_PASSWORD=$2
#export KUBECONFIG=$PWD/kube_config_rke_rendered.yaml

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

kubectl create clusterrolebinding ${JHUB_USERNAME}-dask-default --clusterrole=dask-cluster-role --serviceaccount=user-${JHUB_USERNAME}:default

#DASK -> svc
#cat templates/dask/ingress.yaml | envsubst > /tmp/ingress.yaml
#kubectl apply -f /tmp/ingress.yaml
