# Demo Guide - Helm Registry

## Prerequisites

* Enable OCI Support. Currently OCI support is considered experimental. In order to use the commands described below, please set ```HELM_EXPERIMENTAL_OCI``` in the enironment:

    ```bash
    export HELM_EXPERIMENTAL_OCI=1
    ```

## Demo 1 - Running a Helm Registry

### Steps

1. You can run a registry as a Docker container. There is an official Helm chart for running a registry in Kubernetes.

    ```bash
    kubectl create ns registry
    helm install registry stable/docker-registry --namespace registry
    ```

2. Once the deployment is complete, export ```POD_NAME```.

    ```bash
    export POD_NAME=$(kubectl get pods --namespace registry -l "app=docker-registry,release=registry" -o jsonpath="{.items[0].metadata.name}")
    ```

3. Use ```kubectl port-forward``` to forward a local port to your registry pod.

    ```bash
    kubectl port-forward $POD_NAME 5000:5000 --namespace registry
    ```

    > This will map localhost:5000 to port 5000 on your pod running in Kubernetes. In case you are running this in your local machine, port 5000 might be in use. In that case, just replace e first port number (for example 5020:5000).

## Demo 2 - Working with a Helm Registry

### Steps

1. Select the **Open a new session** in the Cloud Shell toolbar.

2. Use the ```helm chart save``` subcommand to store a copy of chart in local registry cache.

    ```bash
    helm chart save my-demo-chart "localhost:5000/myrepo/my-demo-chart:1.0.0"
    ```

3. Verify the chart has been saved by listing all charts in the local registry cache.

    ```bash
    helm chart list
    ```

4. Upload ```my-demo-chart:1.0.0``` chart to your remote registry.

    ```bash
    helm chart push "localhost:5000/myrepo/my-demo-chart:1.0.0"
    ```

5. Remove ```my-demo-chart:1.0.0``` from the local cache.

    ```bash
    helm chart remove "localhost:5000/myrepo/my-demo-chart:1.0.0"
    ```

6. Using ```helm chart pull``` you can still pull the chart from your registry.

    ```bash
    helm chart pull "localhost:5000/myrepo/my-demo-chart:1.0.0"
    ```

7. You can verify the chart has been saved back in the local registry cache.

    ```bash
    helm chart list
    ```

## Demo 3 - Using Azure Container Registry

### Steps

1. Navigate to https://portal.azure.com. Open the Azure Container Registry resource.

2. Select **Access keys** and take note of:

    * Login server - \<acr-server>
    * Username - \<acr-username>
    * Password - \<acr-password>

3. Login to a registry:

    ```bash
    helm registry login -u <acr-username> <acr-server>
    ```

4. When prompted, input the "\<acr-password>" and press Enter.

5. Save a copy of chart in local registry cache.

    ```bash
    helm chart save my-demo-chart "<acr-server>/myrepo/my-demo-chart:1.0.0"
    ```

6. Verify the chart has been saved by listing all charts in the local registry cache.

    ```bash
    helm chart list
    ```

7. Upload ```my-demo-chart:1.0.0``` chart to your remote registry.

    ```bash
    helm chart push "<acr-login-server>/myrepo/my-demo-chart:1.0.0"
    ```

8. Return to the Azure Container Registry in the Azure Portal. Select **Repositories**. Open "myrepo/my-demo-chart". If you open tag "1.0.0", you will be able to explore the Charts manifest, which references the chart artifact. 

8. Return to Cloud Shell and remove ```my-demo-chart:1.0.0``` from the local cache.

    ```bash
    helm chart remove "<acr-login-server>/myrepo/my-demo-chart:1.0.0"
    ```

9. Pull the chart from your registry.

    ```bash
    helm chart pull "<acr-login-server>/myrepo/my-demo-chart:1.0.0"
    ```

10. You can verify the chart has been saved back in the local registry cache.

    ```bash
    helm chart list
    ```
