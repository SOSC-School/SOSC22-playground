#!/bin/sh

kubectl minio tenant create                                \
                     minio-sosc22-users                        \
                     --capacity 250Gi                       \
                     --servers 1                           \
                     --volumes 1                          \
                     --namespace minio         \
                     --image quay.io/minio/minio \
                     --prometheus-storage-class openebs-hostpath \
                     --audit-logs-storage-class openebs-hostpath \
                     --storage-class openebs-device -o > tenant.yaml

kubectl edit  -n statefulset minio minio-sosc22-users-ss-0

    # spec:
    #   affinity:
    #     nodeAffinity:
    #       requiredDuringSchedulingIgnoredDuringExecution:
    #         nodeSelectorTerms:
    #         - matchExpressions:
    #           - key: kubernetes.io/hostname
    #             operator: In
    #             values:
    #             - 192.168.1.22
    #     podAntiAffinity:
    #       requiredDuringSchedulingIgnoredDuringExecution:
    #       - labelSelector:
    #           matchExpressions:
    #           - key: v1.min.io/tenant
    #             operator: In
    #             values:
    #             - minio-sosc22-users
    #         topologyKey: kubernetes.io/hostname

#kubectl modify-secret -n minio minio-sosc22-users-env-configuration
#export MINIO_SERVER_URL=https://minio.131.154.96.201.myip.cloud.infn.it

