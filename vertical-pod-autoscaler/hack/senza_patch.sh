#!/bin/bash
until kubectl get mutatingwebhookconfigurations vpa-webhook-config
do
   echo "Waiting for initial vpa-webhook-config mutatingwebhookconfigurations to be created"
   sleep 10
done
kubectl patch deployment -n kube-system vpa-admission-controller --patch '{ "spec": { "template": { "spec": { "containers": [ { "name": "admission-controller", "args": [ "--v=4", "--vpa-object-namespace=hyperscale", "--register-webhook=false" ] } ] } } } }'
kubectl patch MutatingWebhookConfiguration vpa-webhook-config --patch '{ "webhooks": [ { "name": "vpa.k8s.io", "namespaceSelector": { "matchExpressions": [ { "key": "kubernetes.io/metadata.name", "operator": "In", "values": [ "hyperscale" ] } ] } } ] }'
kubectl patch deployment -n kube-system vpa-recommender --patch '{ "spec": { "template": { "spec": { "containers": [ { "name": "recommender", "args": [ "--v=4", "--vpa-object-namespace=hyperscale" ] } ] } } } }'
kubectl patch deployment -n kube-system vpa-updater --patch '{ "spec": { "template": { "spec": { "containers": [ { "name": "updater", "args": [ "--v=4", "--vpa-object-namespace=hyperscale" ] } ] } } } }'
