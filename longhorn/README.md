# Install longhorn

At this point its safe to assume kubectl get nodes is forking fine

1. create  namespace
   
   ```shell
   kubectl create ns longhorn-system
   ```
   
   output
   
   ```shell
   namespace/longhorn-system created
   ```

2. install iscsi driver
   
   ```shell
   kubectl -n longhorn-system apply -f longhorn-iscsi-installation.yaml 
   ```
   
    output
   
   ```shell
   daemonset.apps/longhorn-iscsi-installation created
   ```

3. install nfs driver
   
   ```shell
   kubectl apply -f longhorn-nfs-installation.yaml -n longhorn-system
   ```
   
   output
   
   ```shell
   daemonset.apps/longhorn-nfs-installation created
   ```

4. install longhorn from helm chart
   
   ```shell
   helm install longhorn longhorn/longhorn --values longhorn-helm-values.yaml -n longhorn-system
   ```
   
   output 
   
   ```shell
   NAME: longhorn
   LAST DEPLOYED: Mon Feb  5 17:52:37 2024
   NAMESPACE: longhorn-system
   STATUS: deployed
   REVISION: 1
   TEST SUITE: None
   NOTES:
   Longhorn is now installed on the cluster!
   
   Please wait a few minutes for other Longhorn components such as CSI deployments, Engine Images, and Instance Managers to be initialized.
   
   Visit our documentation at https://longhorn.io/docs/
   ```

5. Change the frontend service to `LoadBalancer` type
   
   ```shell
   kubectl patch service longhorn-frontend -n longhorn-system -p '{"spec": {"type": "LoadBalancer"}}'
   ```
   
   output
   
   ```sh
   service/longhorn-frontend patched
   ```

6. Now get the loadbalancer's address
   
   ```sh
   kubectl -n longhorn-system get svc |grep frontend | awk '{print $4}'
   ```
   
   output
   
   ```sh
   a469e9831cb31483eb8a2befe8bbf4c8-280861932.us-east-1.elb.amazonaws.com
   ```
   
    Paste the above address in your browser and you should be able to aceess the longhorn dashboard.
   
   

7. Disable gp2 as a default storage class
   
   ```sh
   kubectl patch storageclass gp2 -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"false"}}}'
   ```
   
   output
   
   ```sh
   storageclass.storage.k8s.io/gp2 patched
   ```
