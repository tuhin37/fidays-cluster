# Install metrics server

To install metrics server execute the following

```shell
kubectl apply -f components.yaml 
```

output

```shell
serviceaccount/metrics-server created
clusterrole.rbac.authorization.k8s.io/system:aggregated-metrics-reader created
clusterrole.rbac.authorization.k8s.io/system:metrics-server created
rolebinding.rbac.authorization.k8s.io/metrics-server-auth-reader created
clusterrolebinding.rbac.authorization.k8s.io/metrics-server:system:auth-delegator created
clusterrolebinding.rbac.authorization.k8s.io/system:metrics-server created
service/metrics-server created
deployment.apps/metrics-server created
apiservice.apiregistration.k8s.io/v1beta1.metrics.k8s.io created
```



To chek if the metrics-server pod is running 

```shell
kubectl -n kube-system get pods |grep metrics
```

output

```shell
metrics-server-665f75b864-7lmqq   1/1     Running   0          5m48s
```


