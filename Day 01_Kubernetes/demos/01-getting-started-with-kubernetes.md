# Demo Guide - Getting Started with Kubernetes

## Demo 1 - Kubernetes Introduction

### Steps [LIAM]

1. Show Kubernetes in Azure Portal

1. Show infra management Resource Group

1. Use the Azure CLI to connect to Kubernetes

1. Use ```kubectl``` to explore cluster information:

    ```bash
    kubectl cluster-info
    kubectl get nodes
    kubectl describe node <node-name>
    ```

1. Kubernetes dashboard:

    ```bash
    az aks browse --resource-group <group-name> --name <cluster-name>
    ```

## Demo 2 - Getting Started with Kubernetes

### Steps [SUREN]

1. Using the CLI to deploy a pod

    ```bash
    kubectl run webserver --image nginx --restart=Never
    ```

1. Generate YAML, and deploy.

    ```bash
    kubectl run webserver-yaml --image nginx --restart=Never --dry-run -o yaml > pod.yaml
    kubectl apply -f pod.yaml
    ```

1. Use explain to understand YAML specification

    ```bash
    kubectl explain pods
    kubectl explain pods.spec.containers
    ```

## Demo 3 - Workloads on Kubernetes

### Pods [SUREN]

1. Create a namespace

    ```bash
    kubectl create ns workloads
    ```

1. Deploy two pods

    ```bash
    kubectl run webserver --image=nginx --restart=Never -n workloads
    kubectl run faultywebserver --image=nnginx --restart=Never -n workloads
    ```

1. List pods

    ```bash
    kubectl get pod -n workloads -o wide
    ```

    > Notice that the Pod status is "ImagePullBackOff". Something is wrong.

1. Identify, and resolve, the issue with 'faultywebserver'.
    
    ```bash
    kubectl describe pod faultywebserver -n workloads
    kubectl set image pod faultywebserver faultywebserver=nginx -n workloads
    kubectl get pod faultywebserver -o wide -n workloads
    ```

1. Create a Pod with a label

    ```bash
    kubectl run webserver-with-labels --image=nginx --restart=Never --labels=app=v1 -n workloads
    ```

1. Show all Pods, with label:

    ```bash
    kubectl get pod --show-labels -n workloads
    ```

1. Get Pods, with label selector:

    ```bash
    kubectl get pod -l app=v1 -n workloads
    ```

### Logs and Exec [SUREN]

1. Get logs from 'webserver'.

    ```bash
    kubectl logs webserver -n workloads
    ```

1. Run some command within the ```nginx``` container running on 'webserver' pod.

    ```bash
    kubectl exec webserver -n workloads -- echo "Hello World"
    kubectl exec webserver -n workloads -- ls
    ```

### Deployments [LIAM]

1. Create a deployment manifest using ```kubectl```

    ```bash
    kubectl create deployment mydeploy --image=nginx --dry-run -o yaml > mydeploy.yaml 
    ```

1. Edit 'mydeploy.yaml' to have 5 replicas

    ```bash
    code ./mydeploy.yaml
    ```

1. Create a Deployment using mydeploy.yaml.

    ```bash
    kubectl apply -f mydeploy.yaml -n workloads
    ```

1. View the Deployment 'mydeploy', the associated ReplicaSet and Pods.

    ```bash
    kubectl get deployment,rs,pod -n workloads
    ```

1. Scale 'mydeploy' to 2 instance. 

    ```
    kubectl scale deploy mydeploy --replicas=2 -n workloads
    kubectl get deployment,rs,pod -n workloads
    ```

1. Update Deployment to use ```nginx```

    ```bash
    # in right pane
    kubectl get rs -w -n workloads

    # apply update
    kubectl set image deployment mydeploy nginx=nginx:1.16.0 -n workloads
    ```

1. View the rollout history for 'mydeploy' and roll back to the previous revision.

    ```bash
    # view previous rollout revisions and configurations.
    kubectl rollout history deploy mydeploy -n workloads
    
    # rollback to the previous rollout.
    kubectl rollout undo deploy mydeploy -n workloads
    
    # observe how rollowing update gets applied 
    kubectl get rs -w
    ```

### Testing the ReplicaSets [LIAM]

1. Remove the label from one of the deployed Pods (with label "target=dev"):

    ```bash
    kubectl label pod <POD-NAME> app- -n workloads
    ```

1. See new Pod created by the ReplicaSet, while an old Pod is still running:

    ```bash
    kubectl get pods --show-labels -n workloads
    ```

1. Assign the (**target=dev**) label back to the Pod. This will make the ReplicaSet terminate one of the Pods to ensure that the total Pod count remains as two (and not three).

    ```bash
    kubectl label pod <POD-NAME> app=mydeploy -n workloads
    ```

1. Get pods again to see the third Pod being terminated.

    ```bash
    kubectl get pods --show-labels -n workloads
    ```

### Services [LIAM]

1. Expose the deployment 'mydeploy' on port **80**. Observe that a service is created.

    ```bash
    kubectl expose deployment mydeploy --port 80 -n workloads
    kubectl get svc mydeploy -n workloads
    ```

1. Using the Pod's Cluster IP, create a new temporary Pod using ```busybox``` and 'hit' the IP with ```wget```:

    ```bash
    # get the service's Cluster IP
    kubectl get svc mydeploy -n workloads -o jsonpath='{.spec.clusterIP}'

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
    kubectl get svc -w -n workloads
    ```

    > **Note:** This may take a few minutes to complete.
