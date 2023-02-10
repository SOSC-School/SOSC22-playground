#!/bin/bash
helm install --repo https://helm.dask.org --create-namespace -n dask-operator --generate-name dask-kubernetes-operator