# Install traefik

To install traefik ingress controller, execute the following command

```shell
helm upgrade --install traefik traefik/traefik --values traefik-values.yaml -n traefik --create-namespace
```

output

```shell
Release "traefik" does not exist. Installing it now.
NAME: traefik
LAST DEPLOYED: Tue Feb  6 09:27:41 2024
NAMESPACE: traefik
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
Traefik Proxy v2.10.6 has been deployed successfully on traefik namespace !

🚨 When enabling persistence for certificates, permissions on acme.json can be
lost when Traefik restarts. You can ensure correct permissions with an
initContainer. See https://github.com/traefik/traefik-helm-chart/issues/396 for
more info. 🚨
```



To check if the pod is running 

```shell
kubectl -n traefik get pods
```

output

```shell
NAME                       READY   STATUS    RESTARTS   AGE
traefik-6764cf6868-9rqc8   1/1     Running   0          2m
```



Get the loadbalancer address for traefik ingress controller

```shell
kubectl -n traefik get svc |grep LoadBalancer |awk '{print $4}'
```

output

```shell
ad52f4248d7a649cb8b40741179be812-977970370.us-east-1.elb.amazonaws.com
```



Now you can map it to every subdomain that need to be handled by this ingress controller
