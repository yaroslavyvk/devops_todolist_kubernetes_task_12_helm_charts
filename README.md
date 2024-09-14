# Django ToDo List Kubernetes Deployment

## Introduction

This project involves deploying a **Django ToDo List** web application on a Kubernetes cluster using Helm charts. The application includes essential web app features such as user accounts/login, an API, and an interactive UI.

### Application Features

This is a todo list web application with basic features common to most web apps:

- **User Accounts/Login**: Secure authentication system.
- **API**: Provides RESTful API endpoints for interacting with todo items.
- **Interactive UI**: User-friendly interface for managing todos.

**Technologies Used**:

- **CSS**: [Skeleton](http://getskeleton.com/) - A lightweight CSS framework.
- **JavaScript**: [jQuery](https://jquery.com/) - A fast, small, and feature-rich JavaScript library.

---

## Table of Contents

- [Prerequisites](#prerequisites)
- [Tasks Overview](#tasks-overview)
- [Installation Instructions](#installation-instructions)
  - [1. Make the Script Executable](#1-make-the-script-executable)
  - [2. Execute the Script](#2-execute-the-script)
- [Verification](#verification)
- [Explanation of Tasks](#explanation-of-tasks)
  - [Creating the Kubernetes Cluster](#creating-the-kubernetes-cluster)
  - [Node Labels and Taints](#node-labels-and-taints)
  - [Helm Chart for `todoapp`](#helm-chart-for-todoapp)
  - [Subchart for `mysql`](#subchart-for-mysql)
  - [Dependencies Between Charts](#dependencies-between-charts)
- [Best Practices Implemented](#best-practices-implemented)
- [Accessing the Application](#accessing-the-application)
- [Cleanup](#cleanup)
- [Additional Resources](#additional-resources)
- [Conclusion](#conclusion)

---

## Prerequisites

Before you begin, ensure you have the following installed on your machine:

- [Docker](https://www.docker.com/get-started)
- [kubectl](https://kubernetes.io/docs/tasks/tools/)
- [kind (Kubernetes IN Docker)](https://kind.sigs.k8s.io/)
- [Helm 3](https://helm.sh/docs/intro/install/)
- [NGINX Ingress Controller](https://kubernetes.github.io/ingress-nginx/)

---



## Tasks Overview

The project encompasses the following key tasks:

1. **Creating a Kubernetes cluster using kind with a custom configuration.**
2. **Labeling and tainting nodes to control pod scheduling.**
3. **Developing a Helm chart for the `todoapp` application with customizable values.**
4. **Creating a subchart for `mysql` within the `todoapp` Helm chart.**
5. **Managing dependencies between the `todoapp` and `mysql` charts.**
6. **Automating the deployment process with a `bootstrap.sh` script.**
7. **Verifying the deployment and providing instructions for validation.**

---

## Installation Instructions

To deploy the Kubernetes cluster and the `todoapp` application, follow the steps below.

### 1. Make the Script Executable

Before running the script, ensure it has the necessary execution permissions:

```bash
chmod +x bootstrap.sh
```

### 2. Execute the Script

Run the script to set up the entire environment:

```bash
./bootstrap.sh
```

The script performs the following actions:

- **Creates a kind Kubernetes cluster** using a custom configuration.
- **Applies node labels and taints** to control pod scheduling.
- **Installs the NGINX Ingress Controller** for managing ingress resources.
- **Deploys the `todoapp` Helm chart**, which includes:
  - Deployment of the Django application.
  - Deployment of the MySQL database as a subchart.
  - Configuration of all resources using values from `values.yaml`.

---

## Verification

After the script completes, verify that the resources are deployed correctly:

```bash
kubectl get all,cm,secret,ingress -A
```

This command retrieves all Kubernetes resources across all namespaces, including:

- Pods
- Services
- ConfigMaps
- Secrets
- Ingresses

You can also check the status of the nodes:

```bash
kubectl get nodes -o wide
```

The output of these commands is saved in the `output.log` file located at the root of the repository.

---

## Explanation of Tasks

### Creating the Kubernetes Cluster

- **kind Cluster Creation**: The cluster is created using kind (Kubernetes IN Docker) with a custom configuration file that defines the cluster's nodes and settings.
- **Multi-node Setup**: The configuration allows for setting up multiple nodes with specific roles, enabling a more realistic cluster environment.

### Node Labels and Taints

- **Labeling Nodes**: Nodes are labeled with `app=mysql` to identify where MySQL pods should be scheduled.
- **Tainting Nodes**: Nodes labeled with `app=mysql` are tainted with `app=mysql:NoSchedule` to prevent other pods from being scheduled on them unless they tolerate the taint.

### Helm Chart for `todoapp`

The Helm chart for `todoapp` includes:

- **Customizable Namespace**: The namespace is defined in `values.yaml` and can be modified as needed.
- **Resource Naming**: All resources are prefixed with `.Chart.Name` for consistency.
- **Secrets Management**:
  - Secrets are controlled via `values.yaml`.
  - The `range` function is used to populate secret data dynamically.
- **Deployment Configuration**:
  - Resource requests and limits are configurable.
  - RollingUpdate strategy parameters are set in `values.yaml`.
  - Image repository and tag are customizable.
  - Node affinity settings are defined to control pod placement.
- **Horizontal Pod Autoscaler (HPA)**:
  - Minimum and maximum replicas are set via `values.yaml`.
  - CPU and memory utilization thresholds are configurable.
- **Service and Ingress**:
  - Configured to expose the application via a NodePort service.
  - Ingress rules are set up for routing HTTP traffic to the application.

### Subchart for `mysql`

The `mysql` subchart includes:

- **Customizable Namespace**: Controlled via `values.yaml`.
- **Resource Naming**: Uses `.Chart.Name` as a prefix.
- **Secrets Management**:
  - Secrets are defined in `values.yaml`.
  - Dynamic population using the `range` function.
- **StatefulSet Configuration**:
  - Replica count is configurable.
  - Image details and storage requests are set in `values.yaml`.
- **Affinity and Tolerations**: Configurable to ensure pods are scheduled on appropriate nodes.
- **Resource Requests and Limits**: Defined in `values.yaml` for optimal performance.

### Dependencies Between Charts

- The `todoapp` chart has an explicit dependency on the `mysql` subchart.
- This is defined in the `Chart.yaml` file:

  ```yaml
  dependencies:
    - name: mysql
      version: 1.0.0
      repository: file://charts/mysql
  ```

---

## Best Practices Implemented

- **Infrastructure as Code**: All configurations are defined in code, allowing for version control and reproducibility.
- **Modularity with Helm Charts**: Separating the application and database into distinct charts for better manageability.
- **Customizability**: Using `values.yaml` files to allow easy customization of deployments without changing the templates.
- **Dynamic Configuration**: Utilizing Helm functions like `range` to dynamically generate configurations.
- **Resource Management**: Defining resource requests and limits to ensure applications run efficiently.
- **Security**: Managing sensitive data using Kubernetes Secrets.
- **Scalability**: Implementing Horizontal Pod Autoscaling based on CPU and memory utilization.
- **Node Affinity and Tolerations**: Controlling pod placement to optimize resource usage and performance.
- **Automation**: Using a script to automate the deployment process, reducing the risk of human error.

---

## Accessing the Application

After deployment, you can access the Django ToDo application using either **Ingress** or the **NodePort Service**.

### Using Ingress

The application is accessible via `localhost` because the Ingress controller routes incoming requests to the application service.

- **Access the Application**:

  Open your web browser and navigate to:

  ```
  http://localhost
  ```

  The Ingress controller will direct your request to the `todoapp` service, and the Django application will be displayed.

### Using NodePort Service

Alternatively, the application is exposed via a NodePort service on port **`30007`**.

- **Access the Application**:

  Open your web browser and navigate to:

  ```
  http://localhost:30007
  ```

  This will bring up the Django ToDo application's interface.

---

## Cleanup

To delete the Kubernetes cluster and all associated resources, run:

```bash
kind delete cluster --name kind
```

This will remove the cluster and free up resources on your machine.

---

## Additional Resources

- **Kubernetes Documentation**: [https://kubernetes.io/docs/home/](https://kubernetes.io/docs/home/)
- **Helm Documentation**: [https://helm.sh/docs/](https://helm.sh/docs/)
- **NGINX Ingress Controller**: [https://kubernetes.github.io/ingress-nginx/](https://kubernetes.github.io/ingress-nginx/)
- **kind (Kubernetes IN Docker)**: [https://kind.sigs.k8s.io/](https://kind.sigs.k8s.io/)

---

## Conclusion

This project demonstrates the deployment of a complex application using Kubernetes and Helm charts, following best practices for configuration, scalability, and maintainability. By automating the deployment process and utilizing Kubernetes features like node taints, affinities, and Helm chart dependencies, the application is both robust and flexible.

---

