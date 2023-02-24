# Analysis playground

In this repo you will find a quick and self contained deployment of the analysis infrastructure for SOSC that can be reproduced on any kubernetes cluster.
The deployment will include:

- An object storage instance where to store user data
- A jupyterHUB instance where users can signUp with a username and pwd
  - once approved by the admin your environment will be ready to get started
- The JupyterLAB environment that is proposed will allow users to use data science python libraries and to scale them over the cluster nodes via DASK.

## Requirements

- Kubernetes cluster with at least master node with a "public" IP and 443 port open.
  - if you are familiar with RKE. You can find in `./rke` a configuration file valid for a single VM that you have access to.
- kubectl
- krew kubectl plugin manager installed
- helm client
- python packages: requests and pandas

## Cluster preparation

### Install nginx ingress controller

```
helm install -n nginx --create-namespace nginx ingress-nginx/ingress-nginx --values ./manifests/helm/nginx-values.yaml
```

### Install cert-manager

```
helm install  --create-namespace -n cert-manager cert-manager jetstack/cert-manager --set installCRDs=true
```

### Install Dask operator

```
helm install --repo https://helm.dask.org --create-namespace -n dask-operator --generate-name dask-kubernetes-operator
```

### Install Minio operator

```
kubectl krew update
kubectl krew install minio

kubectl minio init
```

## Installation

If every previous step has been completed with success, you can install all the needed software via kustomize configuration with:

```
kubectl apply -k ./manifests/kustomizations
```

You might have to trigger the command more than one time if you get dependency/crd errors.

N.B. the system can take some time to converge toward a stable completion of all the components. Pay attention only to persistent errors.
## Post-installation

Create entries in your `/etc/hosts` file with the following name:

```bash
<IP of your master/public entrypoint of you nginx ingress> jhub.example.com
<IP of your master/public entrypoint of you nginx ingress> console.example.com
<IP of your master/public entrypoint of you nginx ingress> minio.example.com
```

## Object Storage instance

You should now be able to see the Minio Console at: https://console.example.com

The defualt admin credentials for the minio tenant should be:
```
N90B4VA87L9SBZM0UEUP
iyhBbZEhvPlGXYaqsMVCIJBWLiEaEKFJNQlaQprI
```

## How to use user syncronization script

Each time a new user register, you have to authorize it to the cluster via the authorize tab in jupyterHUB. After that to create the correct Dask permissions and Minio bucket you should be able to sync everything via the following procedure.

Copy the list of users from https://jhub.example.com/authorize and paste it into `sync_scripts/user_list.csv`.

You should obtain something like:

```csv
dciangot	False	Yes			
test	False	Yes			
dspiga	False	Yes			
landerli	False	Yes			
davide	False	Yes			
gsavares	False	Yes			
gabriele.infante	False	Yes			
am980009	False	Yes			
enrica82	False	Yes			
apascolini	False	Yes			
marcato	False	Yes			
dlattanzio	False	Yes			
lucascr	False	Yes			
mbarbetti	False	Yes
```

Then move in `sync_scripts` folders and run: `JHUB_TOKEN=<JHUB_TOKEN> python3 get_users.py` where you can create a valid JHUB_TOKEN at `https://jhub.example.com/hub/token`

## Docker images and examples

In `./docker` you can find the Dockerfile for the Jupyter and Dask images.

Also in `./example` you can find an example notebook to verify that everything is working.