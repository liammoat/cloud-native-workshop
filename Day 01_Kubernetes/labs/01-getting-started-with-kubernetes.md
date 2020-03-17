# Lab 1 - Getting Started with Kubernetes

## Exercise 1 - Deploy AKS
In this exercise, you will use the Azure CLI to deploy a Kubernetes cluster with Azure Kubernetes Service.

### Steps

1. Navigate to Cloud Shell (https://shell.azure.com).

    > This is where you will complete all command based activites, throughout this workshop.

2. Login using you Azure Account.

3. The first time you access Cloud Shell you will need to select a subscription to create a storage account and Microsoft Azure Files share. Select your Azure Subscription and select **Create storage**.

4. Check that the environment drop-down from the left-hand side of shell window says "Bash".

    ![Bash](./imgs/01/01_bash.png)

5. List subscriptions you have access to.

    ```bash
    az account list
    ```

6. Set your preferred subscription to your Azure Pass Subscription.

    ```bash
    az account set --subscription 'my-subscription-name'
    ```

7. Create a resource group, replace "\<aks-resource-group>" with the name of the Resource Group you want to create:

    ```bash
    az group create --name=<aks-resource-group> --location=northeurope
    ```

8. Run the following command to deploy Kubernetes cluster with AKS. Replace "\<aks-resource-group>" and "\<aks-name>" with the name of the Resource Group you created and the AKS cluster name you want to create:

    ```bash
    az aks create --resource-group <aks-resource-group> --name <aks-name> --node-count 3 --node-vm-size "Standard_DS2_v2" --generate-ssh-keys
    ```

    > This may take a short while to complete.

9. Use the Azure CLI to get the credentials to connect kubectl to your AKS cluster:

    ```bash
    az aks get-credentials --resource-group <aks-resource-group> --name <aks-name>
    ```

10. Verify everything worked as expect by running a command against your Kubernetes cluster.

    ```bash
    kubectl get all
    ```

## Exercise 2 - Deploy ACR
In this exercise, you will create an Azure Container Registry instance using the Azure CLI and setup integration between ACR and AKS. 

### Steps

1. Create a resource group, replace "\<acr-resource-group>" with the name of the Resource Group you want to create:

    ```bash
    az group create --name=<acr-resource-group> --location=northeurope
    ```

2. Create an ACR instance using the ```az acr create``` command. Replace "\<acr-resource-group>" and "\<acr-name>" with the Resource Group name and the Azure Container Registry name you wish to create.

    ```bash
    az acr create --resource-group <acr-resource-group> --name <acr-name> --sku Basic
    ```

3. When you're using Azure Container Registry (ACR) with Azure Kubernetes Service (AKS), an authentication mechanism needs to be established. Use the ```az aks update``` command to integrate with your newly created Container Registry.

    ```bash
    az aks update -n <aks-name> -g <aks-resource-group> --attach-acr <acr-name>
    ``` 

## Exercise 3 - Interfacing with Kubernetes
```kubectl```, said *Kube-Control*, is the  command line interface for running commands against a Kubernetes clusters. In this execise, you will explore some useful features of ```kubectl``` that you may find useful.

### Explore ```kubectl```

1. Get Cluster information.

    ```bash
    kubectl cluster-info
    ```

1. Write Cluster information to a file name 'cluster.txt'.

    ```bash
    kubectl cluster-info > cluster.txt
    ```

1. Get a list of nodes in the cluster.

    ```bash
    kubectl get nodes
    ```
 
1. Get a list of all namespaces in the cluster.

    ```bash
    kubectl get namespaces
    ```

1. Find out CPU and memory limits for the first node in the cluster

    ```bash
    # get list of nodes
    kubectl get nodes

    # using the first one, describe the node
    kubectl describe node <node-name>
    ```

    **or**

    ```bash
    # once you become more familar with jsonpath, you could do the same like this
    kubectl get nodes -o jsonpath='{.items[0].metadata.name}' | kubectl describe node
    ```

### Generate YAML

1. Generate the yaml to create a namespace called 'new-namespace'.

    ```bash
    kubectl create namespace new-namespace --dry-run -o yaml
    ```

    > **Note:** the use of ```--dry-run -o yaml``` to generate the yaml. 
    >
    > * ```--dry-run``` - prints the object that would be sent, without sending it. 
    > * ```-o yaml``` - changes the output format to yaml

1. Write the yaml to create a namespace called 'new-namespace' to a file named 'namespace.yaml'.

    ```bash
    # write the generate yaml to disk
    kubectl create namespace new-namespace --dry-run -o yaml > namespace.yaml

    # check the contents of the file
    cat namespace.yaml
    ```

1. We can do the same for to define a pod:

    ```bash
    kubectl run nginx --image nginx --restart=Never --dry-run -o yaml > pod.yaml
    ```

1. Use ```kubectl``` to apply the configuration:

    ```bash
    kubectl apply -f namespace.yaml
    kubectl apply -f pod.yaml -n new-namespace
    ```

### Explain
```kubectl explain``` will explain the given resource. For example, a top level API-object like Pod or a specific field like a Pod's container. 

1. Get the documentation of a Pod resource and its fields.

    ```bash
    kubectl explain pods
    ```

1. Get the documentation for a Pod's container specification.

    ```bash
    kubectl explain pods.spec.containers
    ```

    > **Note:** ```pods.spec.containers``` matches the yaml object structure:
    > ```yaml
    > apiVersion: v1
    > kind: Pod
    > metadata:
    > creationTimestamp: null
    > name: nginx
    > spec:
    >   containers:
    >   - image: nginx
    >     imagePullPolicy: IfNotPresent
    >     name: nginx
    >     resources: {}
    >   dnsPolicy: ClusterFirst
    >   restartPolicy: Never
    > ```

## Exercise 3 - Explore the Kubernetes Dashboard

### Steps

1. By default, the AKS cluster we created was deployed with Role Based Access Control (RBAC) enabled. This will cause errors when you first browse the dashboard, which is deployed with minimal read permissions. To get access to the dashboard, run the following command to create a `ClusterRoleBinding`:

    ```bash
    kubectl create clusterrolebinding kubernetes-dashboard --clusterrole=cluster-admin --serviceaccount=kube-system:kubernetes-dashboard
    ```

1. Run the following command to access the dashboard:

    ```bash
    az aks browse --resource-group <aks-resource-group> --name <aks-cluster-name>
    ``` 
