# Lab Guide - Advanced Kubernetes

## Exercise 1 - Working with Init Containers

### Steps

1. Deploy the Pod that has both regular/application
container and the init container defined. 

    ```bash
    # review the manifest
    cat ./assets/lab-04/init.yaml

    # apply the configuration
    kubectl apply -f ./assets/lab-04/init.yaml
    ```

    > Notice the use of **initContainers** section with the command the checks if **nginx** web server is accessible. Until it's not, init container will make sure that application container, which is busy box container, won't run. 

2. You should now check the status of the Pod. 

    ```bash
    kubectl get pod myapp-pod
    ```

    > Notice that the status of **myapp-pod** shows **Init:0/1**. This means that 0 out of 1 init containers are still running. Until init container's condition is satisfied the application pod won't run.  
    > 
    > You can check what's going on inside the Pod by running the command: ```kubectl describe pod myapp-pod```
    >
    > Scroll down to the conditions section within the output.

1. Notice that the **myapp-container** is not initialized yet. This is exactly what you expect because init container is still running. Review the logs to verify that.

    ```bash
    kubectl logs myapp-pod -c init-ngservice
    ```

    > You should see "**Waiting for ngservice to come up**" message in thelogs (ignore "**sh: 200: unknown operand**" message as it's not relevant).  

1. To enable the init container to complete we need to create the **ngservice**. It's going to create a **nginx** service and a service. The service endpoint, once up and running, will satisfy the init container condition.

    ```bash
    kubectl apply -f ./assets/lab-04/myservice.yaml
    ```

1. After a couple of minutes, check the Pod's status:

    ```bash
    kubectl get pod myapp-pod
    ```

    > Notice that **myapp-pod** is now showing **Running** status (previously its **Init:0/1**), This means init container has completed its job and is terminated.  

1. Now, check the logs for application container.

    ```bash
    kubectl logs myapp-pod
    ```

## Exercise 2 - Working with PostStart Container Hooks

### Steps

1. Review the contents of "./assets/lab-04/hooks.yaml"

    ```bash
    cat ./assets/lab-04/hooks.yaml
    ```

2. Run the following command, to create a Pod with hook.  

    ```bash
    kubectl apply -f ./assets/lab-04/hooks.yaml
    ```
    
3. Wait for 5 seconds and then run the command to view Pod details.

    ```bash
    kubectl describe pods hooks
    ```

    > Scroll down and locate the **Events** section. 
    >
    > The PostStart hook first echoed a message, then slept for 3 seconds and finally return an exit code -1. Since the exit code is non-zero the container was killed and re-created again. Initially, you will see **PostStartHookError** within the events section. However, as PostHook will run again and once again returns exist code -1, the container will be killed again and re-created.  

4. Watch the Pod restart, every time the PostStartHookError error occurs.

    ```bash
    kubectl get pods hooks -w
    ```

## Exercise 3 - Working with VS Code

### Steps

1. Install VS Code from https://code.visualstudio.com/ 
2. Go to Extensions (ctrl + shift + x) and install Kubernetes Extension 
3. Click on the Kubernetes Icon from left panel and connect to existing cluster. (click on `...` and select `Add Existing CLuster` )
4. Explore the cluster and workloads created so far.

## Exercise 4 - Get Started with Azure Dev Spaces
...

### Steps

1. Enable Azure Dev Spaces
2. 

___
#### Conditions and Terms of Use

Microsoft Confidential  

This training package is proprietary and confidential, and is intended only for uses described in the training materials. Content and software is provided to you under a Non-Disclosure Agreement and cannot be distributed. Copying or disclosing all or any portion of the content and/or software included in such packages is strictly prohibited.
The contents of this package are for informational and training purposes only and are provided "as is" without warranty of any kind, whether express or implied, including but not limited to the implied warranties of merchantability, fitness for a particular purpose, and non-infringement.

Training package content, including URLs and other Internet Web site references, is subject to change without notice. Because Microsoft must respond to changing market conditions, the content should not be interpreted to be a commitment on the part of Microsoft, and Microsoft cannot guarantee the accuracy of any information presented after the date of publication. Unless otherwise noted, the companies, organizations, products, domain names, e-mail addresses, logos, people, places, and events depicted herein are fictitious, and no association with any real company, organization, product, domain name, e-mail address, logo, person, place, or event is intended or should be inferred. 

© 2017 Microsoft Corporation. All rights reserved

For more information, see Use of Microsoft Copyrighted Content at
http://www.microsoft.com/en-us/legal/intellectualproperty/permissions/default.aspx
