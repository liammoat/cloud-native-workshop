# Demo Guide - Module 1 - Helm Introduction

## Demo 1 - Making my first release

### Steps

1. Create a new namespace called "wordpress":

    ```bash
    kubectl create namespace wordpress
    ```

2. Install "stable/wordpress".

    ```bash
    helm install wp-release stable/wordpress --namespace wordpress
    ```

3. While your release finalises use the ```helm show chart``` command to display the contents of the Charts.yaml file:

    ```bash
    helm show chart stable/wordpress
    ```

4. Track the release’s state:

    ```bash
    helm status wp-release --namespace wordpress
    ```

5. Check the deployment status:

    ```bash
    helm list --namespace wordpress
    ```

6. Take a look at what was released.

    ```bash
    kubectl get all --namespace wordpress
    ```

7. Obtain the external IP address for the ```wordpress``` service.

    ```bash
    export SERVICE_IP=$(kubectl get svc --namespace wordpress wp-release-wordpress --template "{{ range (index .status.loadBalancer.ingress 0) }}{{.}}{{ end }}")
    echo "WordPress URL: http://$SERVICE_IP/"
    ```

8. Navigate to your new WordPress site. 

8. Uninstall the ```wordpress``` release.

    ```bash
    helm uninstall wp-release --namespace wordpress
    kubectl delete ns wordpress
    ```

## Demo 2 - Explore a Helm Chart

### Steps

1. Create an empty Helm chart from template

    ```bash
    helm create my-demo-chart
    ```
2. Use the Code editor to show: 

    * ./Chart.yaml
    * ./values.yaml
    * ./templates/deployment.yaml
    * ./templates/service.yaml

    ```
    code ./my-demo-chart
    ```

## Demo 3 - Creating my first Chart

### Steps

1. Explore the `my-demo-chart` folder created in the previous demo.

    ```
    code ./my-demo-chart
    ```

2. Show the Chart.yaml file, and note the name and version number.

3. Update the "values.yaml" file to set ```service.type``` to "LoadBalancer".

4. Lint the chart:

    ```bash
    helm lint my-demo-chart
    ```
    
5. Package the chart up for distribution:

    ```bash
    helm package my-demo-chart
    ```

6. Install the new chart:

    ```bash
    kubectl create ns my-demo-chart
    helm install my-release ./my-demo-chart-0.1.0.tgz --namespace my-demo-chart
    ```

7. Retreive the application URL and verify your release was successful.

    ```bash
    kubectl get svc --namespace my-demo-chart my-release-my-demo-chart 
    ```

## Demo 4 - Helm v3
In this demo, we will show how Helm 3's 3-way Strategic Merge Patches can help prevent environment drift.

In Helm 3, we now use a three-way strategic merge patch. Helm considers the old manifest, its live state, and the new manifest when generating a patch.

### Steps

1. Show the deployment from the previous demo.

    ```bash
    kubectl get deploy --namespace my-demo-chart
    ```

2. "Accidently" scale deployment to zero replicas.

    ```bash
    kubectl scale deployment my-release-my-demo-chart --namespace my-demo-chart --replicas 0
    ```

3. Show that the deployment has a scaled down to zero

    ```bash
    kubectl get deploy --namespace my-demo-chart
    ```

4. Obtain the application's external IP address, and verify the application is no longer available:

    ```bash
    kubectl get svc my-release-my-demo-chart --namespace my-demo-chart
    ```

5. Using the external IP address, open a new tab and show that the app not available

    > You may need to reload the page, if the result has been cached.

6. Rollback the release to its previous state

    ```bash
    helm upgrade my-release ./my-demo-chart-0.1.0.tgz --namespace my-demo-chart
    ```

    > In Helm 2, it would generate a patch, comparing the old manifest against the new manifest. Because this is a rollback, it’s the same manifest. Helm would determine that there is nothing to change because there is no difference between the old manifest and the new manifest. The replica count continues to stay at zero. Panic ensues.
    >
    > In Helm 3, the patch is generated using the old manifest, the live state, and the new manifest. Helm recognizes that the old state was at three, the live state is at zero and the new manifest wishes to change it back to three, so it generates a patch to change the state back to three.

7. Verify the deployment spec has been has been correctly re-set:

    ```bash
    kubectl get deploy --namespace my-demo-chart
    ```

8. Once again, navigate to the external IP address and verify the application is back online. 

___
#### Conditions and Terms of Use

Microsoft Confidential  

This training package is proprietary and confidential, and is intended only for uses described in the training materials. Content and software is provided to you under a Non-Disclosure Agreement and cannot be distributed. Copying or disclosing all or any portion of the content and/or software included in such packages is strictly prohibited.
The contents of this package are for informational and training purposes only and are provided "as is" without warranty of any kind, whether express or implied, including but not limited to the implied warranties of merchantability, fitness for a particular purpose, and non-infringement.

Training package content, including URLs and other Internet Web site references, is subject to change without notice. Because Microsoft must respond to changing market conditions, the content should not be interpreted to be a commitment on the part of Microsoft, and Microsoft cannot guarantee the accuracy of any information presented after the date of publication. Unless otherwise noted, the companies, organizations, products, domain names, e-mail addresses, logos, people, places, and events depicted herein are fictitious, and no association with any real company, organization, product, domain name, e-mail address, logo, person, place, or event is intended or should be inferred. 

© 2017 Microsoft Corporation. All rights reserved

For more information, see Use of Microsoft Copyrighted Content at
http://www.microsoft.com/en-us/legal/intellectualproperty/permissions/default.aspx
