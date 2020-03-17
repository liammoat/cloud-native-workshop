# Lab Guide - State, config and jobs

## Exercise 1 - State Persistance
The Kubernetes Volume is simply a directory on disk mapped to the pod that allows you to store and share data usually beyond the lifetime of a pod.

### Mounting emptyDir

1. Create busyboxvol pod with two containers (c1 and c2), each one will have the image busybox and will run the 'sleep 3600' command. Make both containers mount an emptyDir at '/etc/foo'.

    ```bash
    # review the manifest file - look how Volume and Volume mounts are performed
    cat ./assets/lab-03/state-emptyDir.yaml

    # Create Pod from the script file
    kubectl apply -f ./assets/lab-03/state-emptyDir.yaml
    ```

1. Connect to the first container ```c1```  , write current date time in the file ```/etc/foo/mydata.txt```

    ```bash
    kubectl exec -it busyboxvol -c c1 -- /bin/sh
    ls /etc/foo/ # confirm dir is empty
    echo $(date) > /etc/foo/mydata.txt
    cat /etc/foo/mydata.txt # confirm that stuff has been written successfully
    exit
    ```

    > Notice ```/etc/foo/``` directory has been mounted onto the container

1. Connect to the second container ```c2``` and read ```/etc/foo/mydata.txt``` file to standard output.

    ```bash
    kubectl exec -it busyboxvol -c c2 -- /bin/sh
    cat /etc/foo/mydata.txt
    exit
    ```

    > Notice that two containers within pod busyboxvol share the directory

### Storage Classes

1. List all the storage class available on your cluster

    ```bash
    kubectl get sc
    ```

1. Create a PersistentVolumeClaim for azure storage class ```default```, called ```mypvc```, a request of 1Gi with an access mode of ReadWriteOnce.

    ```bash
    # review the manifest and look how PersistentVolumeClaim is written
    cat ./assets/lab-03/state-mypvc.yaml

    # create PersistentVolumeClaim from the script file
    kubectl apply -f ./assets/lab-03/state-mypvc.yaml
    ```

1. Show the PersistentVolumes and PersistentVolumeClaims of the cluster

    ```bash
    # creation can take time, press ctrl+c to exit watch loop once pv and pvc are created
    kubectl get pv
    kubectl get pvc -w
    ```

1. Create a ```nginxvol``` pod running nginx image and Mount the PersistentVolumeClaim to '/etc/foo'.

    ```bash
    # review the manifest and look how Volume and Volume mounts are performed
    cat ./assets/lab-03/state-mount-pvc.yaml
    
    # Create Pod from the script file
    kubectl apply -f ./assets/lab-03/state-mount-pvc.yaml
    ```

1. Connect to the 'nginxvol' pod, and copy the '/etc/passwd' file to '/etc/foo'

    ```bash
    kubectl exec nginxvol -it -- cp /etc/passwd /etc/foo/passwd
    kubectl exec nginxvol -it -- cat /etc/foo/passwd
    ```

1. Delete ```nginxvol``` pod

    ```bash
    kubectl delete po nginxvol
    ```

1. Recreate ```nginxvol``` pod running nginx image and Mount the PersistentVolumeClaim to '/etc/foo'.

    ```bash
    # create Pod from the script file
    kubectl apply -f ./assets/lab-03/state-mount-pvc.yaml
    ```

1. Connect to the 'nginxvol' pod, and list all files in '/etc/foo'

    ```bash
    kubectl exec nginxvol -it -- ls /etc/foo
    kubectl exec nginxvol -it -- cat /etc/foo/passwd
    ```

    > Notice files persisted, even after pod was deleted and recreated.

## Exercise 2 - Config and Secrets

### Steps

1. Create a configmap named myconfig with values foo=lala,foo2=lolo

    ```bash
    kubectl create configmap myconfig --from-literal=foo=lala --from-literal=foo2=lolo
    ```

1. Create a secret called mysecret with the values password=mypass

    ```bash
    kubectl create secret generic mysecret --from-literal=password=mypass
    ```

1. Create a new nginx pod that loads the value from configmap ```myconfig``` ->  ```foo``` in an env variable called 'option'. Also load secret 'mysecret' as a volume inside an nginx pod on path ```/etc/secrets```.

    ```bash
    # review the manifest and look how the configMap and secret is referenced
    cat ./assets/lab-03/state-configs.yaml

    # Create Pod from the script file
    kubectl apply -f ./assets/lab-03/state-configs.yaml
    ```

1. Check environment variable ```option``` and ```/etc/secrets``` has expected values

    ```bash
    kubectl exec -it nginx -- env | grep option
    kubectl exec -it nginx -- ls /etc/secrets
    ```

## Exercise 3 - Jobs

### Steps

1. Create CronJob called sleepycron that runs pod busy box with ```sleep 5``` command every minute

    ```bash
    kubectl create ns my-cron-job
    kubectl create cronjob sleepycron --image=busybox -n my-cron-job --schedule "*/1 * * * *" -- sleep 5
    ```

1. List all the CronJob, Jobs and Pods

    ```bash
    kubectl get cj,job,pod
    # observe every minute job and pods will be created
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
