# Lab Guide - Kubernetes Best Practices

## Exercise 1 - Resource Management

### Resource Quota

1. Create a namesapce called "bp-rq"

    ```bash
    kubectl create ns bp-rq
    ```

2. Apply the Resource Quota

    ```bash
    kubectl apply -f ./assets/lab-05/resource-quota.yaml -n bp-rq
    ```

3. Verify that ```Used``` is 0. 

    ```bash
    kubectl describe quota -n bp-rq
    ```

4. Create a ```high-priority``` pod

    ```bash
    kubectl apply -f ./assets/lab-05/high-priority-pod.yml -n bp-rq
    ```

5. Verify that the quote has updated

    ```bash
    kubectl describe quota -n bp-rq
    ```

### Limit Ranges

1. Create a namesapce called "bp-lr"

    ```bash
    kubectl create ns bp-lr
    ``` 

2. Apply the Limit Range

    ```bash
    kubectl apply -f ./assets/lab-05/limit-range.yaml -n bp-lr
    ```

3. Describe the Limit Range

    ```bash
    kubectl describe limitrange/limit-mem-cpu-per-container -n bp-lr
    ```

4. Create a Pod which define some resource

    ```bash
    kubectl apply -f ./assets/lab-05/resourced-pod.yaml -n bp-lr
    ```

5. Review each container in turn

    ```bash
    kubectl describe po/busybox1 -n bp-lr
    ```

## Exercise 2 - Auto Scaler

### Cluster Autoscaler

1. Update your AKS cluster to enable the Cluster Autoscaler.

    ```bash
    az aks update \
    --resource-group <aks-resource-group> \
    --name <aks-cluster-name> \
    --enable-cluster-autoscaler \
    --min-count 2 \
    --max-count 5
    ```

### HPA

1. Create a namespace called 'wordpress'

    ```bash
    kubectl create ns wordpress
    ```

1. Deploy wordpress using Helm:

    ```bash
    helm install wp-release stable/wordpress --namespace wordpress
    ```

    > We will explore Helm in detail tomorrow.

2. Enable autoscaling:

    ```bash
    kubectl autoscale deployment wp-release-wordpress --cpu-percent=50 --min=1 --max=3 -n wordpress
    ```

3. Review HPA:

    ```bash
    kubectl get hpa -n wordpress
    ```

## Exercise 3 - Backup Your Volumes

### Dynamic Provisioning

1. Create new namespace:

    ```bash
    kubectl create ns bp-pvc
    ```

2. Create a PVC using default storage class, and a pod:

    ```bash
    kubectl apply -f ./assets/lab-05/pvc.yaml -n bp-pvc
    ```

3. Show disk created in Azure portal

4. Create a pod, and mount the disk.

5. Get a shell running, and create a new file in the mounted volume:

    ```bash
    kubectl exec -it mypod2 -n bp-pvc -- /bin/bash
    cd /mnt/mydemo
    hostname >> host.txt
    cat host.txt
    ```

6. Exit the shell, and delete the Pod.

    ```bash
    kubectl delete pod mypod2 -n bp-pvc
    ```

7. Recreate the pod

    ```bash
    kubectl apply -f ./assets/lab-05/pvc.yaml -n bp-pvc
    ```

8. Verify the file still exists:

    ```bash
    kubectl exec -it mypod2 -n bp-pvc -- /bin/bash
    cd /mnt/mydemo
    ls
    cat host.txt
    ```

### Back up a persistent volume

1. Get the volume

    ```bash
    kubectl get pvc my-data-store2 -n bp-pvc
    ```

1. Query for the disk Id

    ```bash
    az disk list --query '[].id | [?contains(@,`pvc-7f700aa1-a3bd-4017-971c-ee054c3cf26a`)]' -o tsv
    ```

1. Create a snapshot:

    ```bash
    az snapshot create \
        --resource-group <cluster-mv-resource-group> \
        --name pvcSnapshot \
        --source <disk-id>
    ```

### Restore and use a snapshot

1. Create a new disk

    ```bash
    az disk create --resource-group <cluster-mv-resource-group> --name pvcRestored --source pvcSnapshot
    ```

1. Get the disk ID

    ```bash
    az disk show --resource-group <cluster-mv-resource-group> --name pvcRestored --query id -o tsv
    ```

1. Update "restored-disk.yaml" with the disk ID. Create a pod, mounting the restored disk:

    ```bash
    code ./assets/lab-05/restored-disk.yaml
    kubectl apply -f ./assets/lab-05/restored-disk.yaml -n bp-pvc
    ```

1. Verify the file still exists:

    ```bash
    kubectl exec -it mypodrestored -n bp-pvc -- /bin/bash
    cd /mnt/mydemo
    ls
    cat host.txt
    ```

___
#### Conditions and Terms of Use

Microsoft Confidential  

This training package is proprietary and confidential, and is intended only for uses described in the training materials. Content and software is provided to you under a Non-Disclosure Agreement and cannot be distributed. Copying or disclosing all or any portion of the content and/or software included in such packages is strictly prohibited.
The contents of this package are for informational and training purposes only and are provided "as is" without warranty of any kind, whether express or implied, including but not limited to the implied warranties of merchantability, fitness for a particular purpose, and non-infringement.

Training package content, including URLs and other Internet Web site references, is subject to change without notice. Because Microsoft must respond to changing market conditions, the content should not be interpreted to be a commitment on the part of Microsoft, and Microsoft cannot guarantee the accuracy of any information presented after the date of publication. Unless otherwise noted, the companies, organizations, products, domain names, e-mail addresses, logos, people, places, and events depicted herein are fictitious, and no association with any real company, organization, product, domain name, e-mail address, logo, person, place, or event is intended or should be inferred. 

© 2017 Microsoft Corporation. All rights reserved

For more information, see Use of Microsoft Copyrighted Content at
http://www.microsoft.com/en-us/legal/intellectualproperty/permissions/default.aspx