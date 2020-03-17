# Demo Guide - Charts Deep Dive

## Prerequisites

* Demo Guide - Helm Introduction

## Demo 1 - Adding Notes to a Chart

### Steps

1. Open the chart created in the previous demo guide.

    ```
    code ./my-demo-chart
    ```

2. Explore ./templates/NOTES.txt. Highlight:

    * The use of the templating engine
    * It prints useful commands to help the consumer get started

3. We can see what was printed for the previous release:

    ```bash
    helm status my-release --namespace my-demo-chart
    ```

4. Add the following text at the end of the NOTES.txt file, increase the ```version``` in the Chart.yaml file to "0.2.0".

    ```txt
    2. View the logs for application:

      kubectl logs -l "app.kubernetes.io/name={{ include "my-demo-chart.name" . }}" --namespace {{ .Release.Namespace }}
    ```

5. Package the chart up for distribution:

    ```bash
    helm package my-demo-chart
    ```

6. Upgrade the existing release to the new chart:

    ```bash
    helm upgrade my-release ./my-demo-chart-0.2.0.tgz --namespace my-demo-chart
    ```

## Demo 2 - Working with Dependencies

### Steps

1. Open the ```my-demo-chart``` chart in the Code editor.

    ```bash
    code ./my-demo-chart
    ```

 2. Add a stable repo (this may already exist)
    
    ```bash
    helm repo add stable https://kubernetes-charts.storage.googleapis.com/
    ```

2. Update "Chart.yaml" with the following YAML section:

    ```yaml
    dependencies:
      - name: redis
        version: 10.3.1
        repository: "@stable"
      - name: mysql
        version: 1.6.2
        repository: "@stable"
    ```
  
3. Use ```helm lint``` to verify the changes.

    ```bash
    helm lint my-demo-chart
    ```

4. Update your dependencies and store them as chart archives in the "charts/" directory.

    ```bash
    helm dependency update my-demo-chart
    ```

5. View the "charts/" directory to see the restored charts.

    ```bash
    ls my-demo-chart/charts/
    ```

6. Update the ```version``` in chart.yaml to "0.3.0"

7. Package the chart up for distribution:

    ```bash
    helm package my-demo-chart
    ```

8. Upgrade the existing release to the new chart:

    ```bash
    helm upgrade my-release ./my-demo-chart-0.3.0.tgz --namespace my-demo-chart
    ```

9. Show the additional services that have been deployed

    ```bash
    kubectl get all --namespace my-demo-chart
    ```

## Demo 3 - Working with Templates

### Steps

1. Add a new template to your Helm chart called "configmap.yaml"

    ```bash
    touch my-demo-chart/templates/configmap.yaml
    code my-demo-chart/templates/configmap.yaml
    ```

2. Add the following YAML to the file:

    ```yaml
    apiVersion: v1
    kind: ConfigMap
    metadata:
      name: {{ .Release.Name }}-configmap
    data:
      myvalue: "{{ .Values.config.myValue }}"
    ```

3. Update "values.yaml" to specify a default value for ```config.myValue```.

4. Test the template engine locally so you can see the output:

    ```bash
    helm install test-release --debug --dry-run ./my-demo-chart | grep -C 3 test-release-configmap 
    ```

## Demo 4 - Working with Values

### Steps

1. Continue from the previous demo. Verify that the value is set correctly when the "values.yaml" file is overriden:

    ```bash
    helm install test-release --set 'config.myValue=New Value'  --debug --dry-run ./my-demo-chart | grep -C 3 test-release-configmap 
    ``` 

2. Create a new file called "myvalues.yaml"

    ```bash
    touch myvalues.yaml
    code myvalues.yaml
    ```

3. Add the following YAML to the file:

    ```yaml
    config:
      myValue: "New value"
    ```

5. Test the template engine locally so you can see the output:

    ```bash
    helm install test-release -f ./myvalues.yaml --debug --dry-run ./my-demo-chart | grep -C 3 test-release-configmap 
    ```

## Demo 5 - Validate that your chart works

### Steps

1. Open you chart in the Code editor.

    ```bash
    code my-demo-chart
    ``` 

2. Take a look at "templates/tests/test-connection.yaml". This is an example test. Explore how it works.

    > This is essentially a Pod that is deployed into Kubernetes. Once deployed the following command is executed:
    >
    > ```bash
    > wget my-release-my-demo-chart:80
    > ```
    > If this command is executed successfully, the test passes. If it fails, the test will fail.
    >
    > This is a relatively simple test. But it can be as complex as required.
    >
    > For reference, take a look at the [test.yaml](https://github.com/helm/charts/blob/master/stable/mysql/templates/tests/test.yaml) for the MySQL chart.

3. Highlight:

    * annotations
    * spec

4. Run the tests for the release you made in the previous exercise.

    ```bash
    helm test my-release --namespace my-demo-chart
    ```

    > Note that it runs both "my-release-my-demo-chart-test-connection" and "my-release-mysql-test" from your chart and the MySQL dependency respectively.
