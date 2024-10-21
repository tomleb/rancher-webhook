#!/bin/sh

tag=$(echo $TILT_IMAGE_0 | rev | cut -d: -f1 | rev)
repository=$(echo $TILT_IMAGE_0 | sed "s|:$tag||")

kubectl -n cattle-system create configmap rancher-config &>/dev/null
kubectl -n cattle-system patch configmap rancher-config \
	--patch '{"data":{"rancher-webhook":"image:\n  repository: '$repository'\n  tag: '$tag'"}}' -o yaml
echo "---"
kubectl -n cattle-system get deployment rancher-webhook -o yaml
