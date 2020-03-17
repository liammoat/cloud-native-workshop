# Lab Guide - Pods, Deployments and Services

## Exercise 1 - Pods
A Pod represents a set of running containers on your cluster - it's the smallest and simplest Kubernetes object. 

### Steps

#### Creating and updating Pods

1. Using ```kubectl```, create a new Pod called 'webserver' running ```nginx``` image.

    ```bash
    kubectl run webserver --image=nginx --restart=Never
    ```

1. Get the status and IP of Pod 'webserver'.

    ```bash
    kubectl get pod webserver -o wide 
    ```

1. Get a detailed description of the pod, including related resources such as events or controllers.

    ```bash
    kubectl describe pod webserver
    ```

1. Intentionally deploy a faulty Pod:

    ```bash
    kubectl run faultywebserver --image=nnginx --restart=Never
    ```

1. Get the status of 'faultywebserver'.

    ```
    kubectl get pod faultywebserver -o wide 
    ```

    > Notice that the Pod status is "ImagePullBackOff". Something is wrong.

1. Identify, and resolve, the issue with 'faultywebserver'.
    
    ```
    kubectl describe pod faultywebserver | grep "Warning"
    kubectl set image pod faultywebserver faultywebserver=nginx
    kubectl get pod faultywebserver -o wide
    ```

1. Using YAML, create a new Pod called 'web' running ```nginx``` image.

    ```
    # use kubectl to generate web-pod.yaml
    kubectl run webserver-yaml --image=nginx --restart=Never --dry-run -o yaml > web-pod.yaml

    # view nginx-pod.yaml
    cat web-pod.yaml
    
    # apply the YAML file
    kubectl apply -f web-pod.yaml
    ```
    
    > Notice the use of ```--dry-run -o yaml``` to generate the yaml, which is then piped into web-pod.yaml. 

#### Labels and annotations

1. Using ```kubectl```, create a new Pod called 'nginx-with-labels' running ```nginx``` image. Label the Pod with 'app=v1'.

    ```bash
    kubectl run nginx-with-labels --image=nginx --restart=Never --labels=app=v1
    
    # or

    kubectl run nginx-with-labels --image=nginx --restart=Never
    kubectl label pod nginx-with-labels app=v1
    ```

1. Show all Pods in the default namespace, including the Pods' labels.

    ```bash
    kubectl get pod --show-labels
    ```

1. Show a specific Pod, with it's labels:

    ```bash
    kubectl get pods nginx-with-labels --show-labels
    ```

1. Change the label of pod 'nginx' to be 'app=v2'

    ```bash
    kubectl label pod nginx-with-labels app=v2 --overwrite
    ```

1. Get all Pods with the label 'app=v2'.

    ```bash
    kubectl get pod -l app=v2
    ```

1. Remove the 'app' label from Pod 'nginx-with-labels'.

    ```bash
    kubectl label pod nginx-with-labels app-
    ``` 

1. Annotate Pod 'nginx-with-labels' with "description='my description'".

    ```bash
    kubectl annotate pod nginx-with-labels description='my description'
    ```

#### Logs and Exec 

1. Get logs from 'webserver'.

    ```
    kubectl logs webserver 
    ```

1. Retrieve a list of all the files within the ```nginx``` container running on 'webserver' pod.

    ```
    kubectl exec webserver -- ls
    ```

## Exercise 2 - ReplicaSets
In this Exercise, you will create a ReplicaSet, which will ensure that there are always specified number of Pods running in the cluster.

### Creating Pods though a ReplicaSets

1. Take a look at 'ng-rc.yaml'

    ```bash
    code ./assets/lab-02/ng-rc.yaml
    ```

1. Use ```kubectl apply``` to create the ReplicaSet

    ```bash
    kubectl apply -f ./assets/lab-02/ng-rc.yaml
    ```

1. Run the following command to see two new Pods created by the ReplicaSet:

    ```bash
    kubectl get pods -l target=dev --show-labels
    ```

### Testing the ReplicaSets
With the Pods up and running, you will check if the ReplicaSet controller is working as expected. You will do that by removing the label (**target**) from one of Pods created by the ReplicaSet. This should immediately make ReplicaSet spin up a new Pod since **matchLabels** criteria demands a minimum two Pods with the label (**target=dev**).  

1. Remove the label from one of the deployed Pods (with label "target=dev"):

    ```bash
    kubectl label pod <POD-NAME> target-
    ```

1. Run the following command to see one new Pod created by the ReplicaSet, while an old Pod is still running:

    ```bash
    kubectl get pods --show-labels
    ```

1. You can delete the additional Pod manually, but a better way to do that is by assigning the (**target=dev**) label back to the Pod. This will make the ReplicaSet terminate one of the Pods to ensure that the total Pod count remains as two (and not three).

    ```bash
    kubectl label pod <POD-NAME> target=dev
    ```

1. Get pods again to see the third Pod being terminated.

    ```bash
    kubectl get pods --show-labels
    ```

1. Delete the ReplicaSet:

    ```bash
    kubectl delete rs nginx-replica-set
    ```

    > This will delete not only the ReplicaSet, but also all the Pods that it was controlling by using the matching label criteria. 

## Exercise 3 - Deployments
A deployment is an API object that manages a replicated application. A *Deployment controller* provides declarative updates for Pods and ReplicaSets.

### Steps

1. Create a yaml file for a Deployment running a ```nginx``` container and save it as mydeploy.yaml.

    ```bash
    kubectl create deployment mydeploy --image=nginx --dry-run -o yaml > mydeploy.yaml 
    ```

    > This is another great example where you can use ```--dry-run -o yaml``` to generate the required yaml.

1. Edit 'mydeploy.yaml' to have 5 replicas

    ```bash
    code ./mydeploy.yaml
    ```

1. Create a Deployment using mydeploy.yaml.

    ```bash
    kubectl apply -f mydeploy.yaml
    ```

1. View the Deployment 'mydeploy', the associated ReplicaSet and Pods.

    ```bash
    kubectl get deployment,rs,pod
    ```

1. Modify the image used by 'mydeploy' to use image ```nginx:1.16.0``` and observe the update as it's applied.

    ```bash
    # set the deployment image
    kubectl set image deployment mydeploy nginx=nginx:1.16.0

    # observe how the update gets applied 
    kubectl get rs -w
    ```

1. View the rollout history for 'mydeploy' and roll back to the previous revision.

    ```bash
    # view previous rollout revisions and configurations.
    kubectl rollout history deploy mydeploy
    
    # rollback to the previous rollout.
    kubectl rollout undo deploy mydeploy
    
    # observe how rollowing update gets applied 
    kubectl get rs -w
    ```

1. Scale 'mydeploy' to 2 instance. 

    ```
    kubectl scale deploy mydeploy --replicas=2
    ```

## Exercise 3 - Services
A Service is an abstract way to expose an application running on a set of Pods.

### Steps

1. Expose the deployment 'mydeploy' on port **80**. Observe that a service is created.

    ```bash
    kubectl expose deployment mydeploy --port 80
    kubectl get svc mydeploy
    ```

1. Using the Pod's Cluster IP, create a new temporary Pod using ```busybox``` and 'hit' the IP with ```wget```:

    ```bash
    # get the service's Cluster IP
    kubectl get svc mydeploy -o jsonpath='{.spec.clusterIP}'
    
    # run busybox
    kubectl run busybox --rm --image=busybox -it --restart=Never -- sh

    # from inside the container
    wget -O- <cluster-ip>:80
    exit
    ```

1. Change to service type of 'mydeploy' from the ClusterIP to LoadBalancer. Find the Public IP address and browse to the application.

    ```bash
    # edit the service
    kubectl edit svc mydeploy

    # change "type: ClusterIP" to "type: LoadBalancer"

    # get the assigned external IP
    kubectl get svc -w
    ```

    > **Note:** This may take a few minutes to complete.

___
#### Conditions and Terms of Use

Microsoft Confidential  

This training package is proprietary and confidential, and is intended only for uses described in the training materials. Content and software is provided to you under a Non-Disclosure Agreement and cannot be distributed. Copying or disclosing all or any portion of the content and/or software included in such packages is strictly prohibited.
The contents of this package are for informational and training purposes only and are provided "as is" without warranty of any kind, whether express or implied, including but not limited to the implied warranties of merchantability, fitness for a particular purpose, and non-infringement.

Training package content, including URLs and other Internet Web site references, is subject to change without notice. Because Microsoft must respond to changing market conditions, the content should not be interpreted to be a commitment on the part of Microsoft, and Microsoft cannot guarantee the accuracy of any information presented after the date of publication. Unless otherwise noted, the companies, organizations, products, domain names, e-mail addresses, logos, people, places, and events depicted herein are fictitious, and no association with any real company, organization, product, domain name, e-mail address, logo, person, place, or event is intended or should be inferred. 

© 2017 Microsoft Corporation. All rights reserved

For more information, see Use of Microsoft Copyrighted Content at
http://www.microsoft.com/en-us/legal/intellectualproperty/permissions/default.aspx
