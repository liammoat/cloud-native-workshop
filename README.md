# Cloud Native Workshop
Explore Cloud Native technologies like Kubernetes and Helm.

## Labs

### Getting Started

1. In your browser open Azure Cloud Shell by navigating to https://shell.azure.com.

    > You will use Azure Cloud Shell for all labs in this workshop. See [here](https://docs.microsoft.com/en-us/azure/cloud-shell/using-the-shell-window) for some tips and tricks (like how to *copy* and *paste*).

2. Check which subscription you have connected to:

    ```bash
    az account show
    ```

3. If you prefer, you can switch to a different subscription:

    ```bash
    az account set --subscription <subscription-name>
    ```

4. Within Cloud Shell, run the following command to download and execute the setup script:

    ```bash
    bash <(curl -Ls https://aka.ms/cloud-native-workshop/setup-script)
    ```

### Kubernetes

1. [Lab 01 - Getting Started with Kubernetes](./Day%2001_Kubernetes/labs/01-getting-started-with-kubernetes.md)
1. [Lab 02 - Pods, Deployments and Services](./Day%2001_Kubernetes/labs/02-pods-deployments-and-services.md)
1. [Lab 03 - State, config and jobs](./Day%2001_Kubernetes/labs/03-state-config-and-jobs.md)
1. [Lab 04 - Advanced Kubernetes](./Day%2001_Kubernetes/labs/04-advanced-kubernetes.md)
1. [Lab 05 - Kubernetes Best Practices](./Day%2001_Kubernetes/labs/05-kubernetes-best-practices.md)

### Helm

1. [Lab 01 - Getting Started with Helm](./Day%2002_Helm/labs/01-getting-started-with-helm.md)
1. [Lab 02 - Working with Helms Charts](./Day%2002_Helm/labs/02-working-with-helms-charts.md)
1. [Lab 03 - Working with Registries](./Day%2002_Helm/labs/03-working-with-registries.md)

## Contributors

* **Liam Moat**

    * GitHub: [@liammoat](https://github.com/liammoat)
    * Twitter: [@liammoat](https://www.twitter.com/liammoat)
    * Website: [www.liammoat.com](https://www.liammoat.com)

* **Kunal Babre**

    * GitHub: [@kunalbabre](https://github.com/kunalbabre)
    * Twitter: [@kunalbabre](https://www.twitter.com/kunalbabre)
    * Website: [www.kunalbabre.com](https://www.kunalbabre.com)

* **Suren Mohandass**

    * GitHub: [@surenmcode](https://github.com/surenmcode)
