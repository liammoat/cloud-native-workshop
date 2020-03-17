# Lab 2 - Working with Helms Charts

## Prerequisites

* [Lab 1 - Getting Started with Helm](./01-getting-started-with-helm.md)

## Exercise 1 - Working with Dependencies
In this exercise, you will add two dependencies to the ```my-first-chart``` chart you created in the [Getting Started with Helm](./01-getting-started-with-helm.md) lab.
The charts required by the current chart are defined as a list in the dependencies field.

### Steps

1. Open Cloud Shell and open the ```my-first-chart``` chart in the Code editor.

    ```bash
    code ./my-first-chart
    ```

2. Update "Chart.yaml" with the following YAML section:

    ```yaml
    dependencies:
      - name: redis
        version: 10.3.1
        repository: "https://kubernetes-charts.storage.googleapis.com/"
      - name: mysql
        version: 1.6.2
        repository: "https://kubernetes-charts.storage.googleapis.com/"
    ```

    > Alternatively, you could set ```repository``` to "@stable", if you have previously ran:
    > 
    > ```bash
    > helm repo add stable https://kubernetes-charts.storage.googleapis.com/
    > ```

3. Use ```helm lint``` to verify the changes.

    ```bash
    helm lint my-first-chart
    ```

4. Use the ```helm dependency``` subcommand to update your dependencies and store them as chart archives in the "charts/" directory.

    ```bash
    helm dependency update my-first-chart
    ```

5. Update the version in chart.yaml to "0.2.0".

5. Package up the chart.

    ```bash
    helm package my-first-chart
    ```

    > This will generate a new archive called "my-first-chart-0.2.0.tgz".

6. Update the "my-release" release with this new chart.

    ```bash
    helm upgrade my-release ./my-first-chart-0.2.0.tgz --namespace my-first-chart
    ```

7. Use ```kubectl get all``` to see what has been deloyed into the ```my-first-chart``` namespace.

    ```bash
    kubectl get all --namespace my-first-chart
    ```

    > You should see objects deployed for:
    > 
    > * nginx
    > * mysql
    > * redis

## Exercise 2 - Working with Templates and Values

### Steps

1. Add a new template to your Helm chart called "configmap.yaml"

    ```bash
    touch my-first-chart/templates/configmap.yaml
    code my-first-chart/templates/configmap.yaml
    ```

    > Template names do not follow a rigid naming pattern. However, we recommend using the suffix .yaml for YAML files and .tpl for helpers.

2. Add the following YAML to the file:

    ```yaml
    apiVersion: v1
    kind: ConfigMap
    metadata:
      name: mychart-configmap
    data:
      myvalue: "Hello World"
    ```

3. Increate the version number in the Chart.yaml file to "0.3.0", and then install the chart directly from source.

    ```bash
    helm upgrade my-release ./my-first-chart --namespace my-first-chart
    ```

4. Using ```helm get manifest```,  retrieve the release and see the actual template that was loaded.

    ```bash
    helm get manifest my-release --namespace my-first-chart | grep -C 3 mychart-configmap
    ```

5. Alter "configmap.yaml" to template the ConfigMap's name:

    ```yaml
    apiVersion: v1
    kind: ConfigMap
    metadata:
      name: {{ .Release.Name }}-configmap
    data:
      myvalue: "Hello World"
    ```

    > The template directive **{{ .Release.Name }}** injects the release name into the template. The values that are passed into a template can be thought of as namespaced objects, where a dot (.) separates each namespaced element.

6. Continue to edit "configmap.yaml". Replace the value of ```myValue``` with: "{{ .Values.config.myValue }}"

7. Update "values.yaml" to specify a default value for ```config.myValue```.

8. Instead of installing the chart,we can test the template engine locally so you can see the output:

    ```bash
    helm install test-release --debug --dry-run ./my-first-chart | grep -C 3 test-release-configmap 
    ```

9. Verify that the value is set correctly when the "values.yaml" file is overriden:

    ```bash
    helm install test-release --set 'config.myValue=New Value'  --debug --dry-run ./my-first-chart | grep -C 3 test-release-configmap 
    ```

## Exercise 3 - Validate that your chart works

### Steps

1. Open you chart in the Code editor.

    ```bash
    code my-first-chart
    ``` 

2. Take a look at "templates/tests/test-connection.yaml". This is an example test. Explore how it works.

    ```yaml
    apiVersion: v1
    kind: Pod
    metadata:
      name: "{{ include "my-first-chart.fullname" . }}-test-connection"
      labels:
    {{ include "my-first-chart.labels" . | nindent 4 }}
      annotations:
        "helm.sh/hook": test-success
    spec:
      containers:
        - name: wget
          image: busybox
          command: ['wget']
          args:  ['{{ include "my-first-chart.fullname" . }}:{{ .Values.service.port }}']
      restartPolicy: Never
    ```

    > This is essentially a Pod that is deployed into Kubernetes. Once deployed the following command is executed:
    >
    > ```bash
    > wget my-release-my-first-chart:80
    > ```
    > If this command is executed successfully, the test passes. If it fails, the test will fail.
    >
    > This is a relatively simple test. But it can be as complex as required.
    >
    > For reference, take a look at the [test.yaml](https://github.com/helm/charts/blob/master/stable/mysql/templates/tests/test.yaml) for the MySQL chart.

3. Run the tests for the release you made in the previous exercise.

    ```bash
    helm test my-release --namespace my-first-chart
    ```

    > Note that it runs both "my-release-my-first-chart-test-connection" and "my-release-mysql-test" from your chart and the MySQL dependency respectively.

4. Add an annotation to the Pod's metadata in "test-connection.yaml" to include "helm.sh/hook-weight", with a value of **"10"**.
    > Note that the hook-weight value must set as a numeric STRING (meaning you need to include the quotation marks ``helm.sh/hook-weight: "10"``)

5. Create a new file called "ab-test.yaml" in the *tests* directory.

    ```bash
    touch my-first-chart/templates/tests/ab-test.yaml
    code my-first-chart #this will refresh to Code editor
    ```

6. Using "test-connection.yaml" as reference, write "ab-test.yaml" to:

    * Run after "test-connection"
    * Use the "mocoso/apachebench" image
    * Run the ```bash``` command with the following arguments:
        * -c
        * ab -n 10 -c 10 http://\<service-name>:\<port-number>/

7. Verify your changes with the ```helm lint``` command.

    ```bash
    helm lint my-first-chart
    ```

7. Update the chart's version number to **0.4.0**.

8. Use the ```helm package``` command to package the chart.

    ```bash
    helm package my-first-chart
    ```

9. Update the "my-release" release with this new chart.

    ```bash
    helm upgrade my-release ./my-first-chart-0.4.0.tgz --namespace my-first-chart
    ```

10. Run the Chart Tests, and output the logs.

    ```bash
    helm test my-release --namespace my-first-chart --logs
    ```

    > Once complete, review the log dump from "my-release-my-first-chart-ab-test". You will see the successful execution of ApacheBench.

11. Update "ab-test" to intentionally fail. For exampe, test a port number that hasn't been exposed. Update the version number, create a new package and update the release. Run the ```helm test``` command to see output.

    > You can use Chart Tests to validate that your configuration was properly injected, assert that your services are up and correctly load balancing and more.
    > 
    > For a chart consumer, this is a great way to sanity check that their release of a chart (or application) works as expected.
    > 
    > You could also build ```helm test``` into your deployment pipelines, enabling you to implement automated rollback.
