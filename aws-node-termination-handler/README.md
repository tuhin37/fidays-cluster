# Install aws-node-termination handler

To install node nermination handler, execute the following statement

```shell
kubectl apply -f all-resources.yaml 
```

output

```shell
Warning: policy/v1beta1 PodSecurityPolicy is deprecated in v1.21+, unavailable in v1.25+
podsecuritypolicy.policy/aws-node-termination-handler created
serviceaccount/aws-node-termination-handler created
clusterrole.rbac.authorization.k8s.io/aws-node-termination-handler created
clusterrolebinding.rbac.authorization.k8s.io/aws-node-termination-handler created
role.rbac.authorization.k8s.io/aws-node-termination-handler-psp created
rolebinding.rbac.authorization.k8s.io/aws-node-termination-handler-psp created
daemonset.apps/aws-node-termination-handler created
daemonset.apps/aws-node-termination-handler-win created
```



chek if the pod is running 

```shell
kubectl -n kube-system get pods |grep termination
```

output

```shell
aws-node-termination-handler-6rqnj   1/1     Running   0          67s
```


