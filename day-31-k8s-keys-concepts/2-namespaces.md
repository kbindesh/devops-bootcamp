# Kubernetes Namespaces

In this section, you will learn the following concepts:

- Namespace Overview

- Listing Namespaces
- Creating Namespaces using both imperative & declarative ways
- Limit Ranges

## 01. Overview

- In Kubernetes (K8s), a namespace is a way to logically divide a single cluster into multiple "virtual clusters".
- Think of it like folders on a computer - you can have two files with the same name as long as they are in different folders.

### 1.1 Why Use Namespaces?

- Isolation
  - Separate environments (like dev, staging, and prod) or different teams within the same physical cluster.
- Avoid Naming Conflicts
  - You can name two different pods "database" as long as they are in separate namespaces.

- Resource Control
  - Administrators can set Resource Quotas to limit how much CPU or memory a specific team or project can use.
- Access Control
  - Using Role-Based Access Control (RBAC), you can give a developer full access to a `dev` namespace but only "read-only" access to the `prod` namespace.

### 1.2 Default Namespaces

- When you first set up a cluster, Kubernetes automatically creates four initial namespaces:

| Namespace Name  | Description                                                                                                 |
| --------------- | ----------------------------------------------------------------------------------------------------------- |
| Default         | The "catch-all" home for any resource created without an assigned namespace.                                |
| kube-system     | Reserved for critical internal objects created by the Kubernetes system (like the API server or DNS).       |
| kube-public     | Accessible to all users (even unauthenticated ones) and typically used for cluster-wide public information. |
| kube-node-lease | Used for heartbeats that tell the cluster if each node is still alive and healthy.                          |

## 02. Namespace - kubectl commands

### 2.1 Listing Namespaces

```
kubectl get namespaces
OR
kubectl get ns
```

### 2.2 Create Namespaces (imperative way)

```
# Create a dedicated namespace for development environment
kubectl create namespace dev

# Create a dedicated namespace for test environment
kubectl create namespace test

# Create a dedicated namespace for production environment
kubectl create namespace prod

# To check created ns, list all the namespaces
```

### 2.3 Create Namespaces (Declarative way)

- You may refer to the following manisfests to create two namespaces namely development and production respectively:
  - [manifests/dev-namespace.yml](./manifests/dev-namespace.yml)

```
kubectl apply -f manifests/dev-namespace.yml
```

## 03. Lab: Deploy an Application in custom Namespaces

- You can specify Namespace details for an application in two ways:

### 3.1 Using `kubectl apply -n` option

```
# Deploy nginx app in production namespace
kubectl apply -f nginx-deployment.yml -n production
```

### 3.2 Using `namespace` attribute of the `metadata` element

```
# Notice metadata.namespace attribute

apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  namespace: production
  labels:
    app: nginx
```

- Now, deploy an app (e.g. nginx) in _development_ namespaces:

```
kubectl apply -f manifests/nginx-deploy-in-dev-ns.yml
```

## 04. List Objects in a Namespace

```
# List all common objects in a Namespace
kubectl get all -n my-namespace

# List all the Pods from a given Namespace
kubectl get pods -n my-namespace

# List all the Services from a given Namespace
kubectl get svc -n my-namespace

# List objects by label in a Namespace
kubectl get all -n my-namespace -l app=frontend

# Set Default Namespace for kubectl commands
kubectl config set-context --current --namespace=my-namespace
kubectl get pods

[Now, you can just run commands without appending -n or --namespace]
```

## 05. Namespace `Limit Ranges`

### 5.1. `limitRange` Overview

As an Administrator, you might be concerned about making sure that a single object cannot monopolize all available resources within a namespace.

- A **LimitRange** is a policy to constrain the resource allocations (limits and requests) that you can specify for each applicable object kind (such as _Pod_ or _PersistentVolumeClaim_) in a namespace.
- A **LimitRange** provides constraints that can:
  - _Enforce minimum and maximum compute resources usage per Pod or Container in a namespace_.
  - _Enforce minimum and maximum storage request per PersistentVolumeClaim in a namespace_.
  - _Enforce a ratio between request and limit for a resource in a namespace_.
  - _Set default request/limit for compute resources in a namespace and automatically inject them to Containers at runtime_.

### 5.2 Lab: Create a Namespace and restrict the Pod resource allocation using `LimitRange`

#### 5.2.1 Create a Namespace

```
apiVersion: v1
kind: Namespace
metadata:
  name: development
```

#### 5.2.2 Create a `limitRange` for Namespaces

- You may refer to this manifest: [manifests/dev-namespace-with-limit-range.yml](./manifests/dev-ns-with-limitrange.yml)

#### 5.2.3 Deploy an Application

- Deploy an application (e.g. nginx) in the same Namespace as limitRange object (here, it is development ns):

```
kubectl apply -f dev-ns-with-limitrange.yml
```

#### 5.2.4 Verify the deployed app Pods and it's Resource limits (cpu, memory)

```
# List all the pods present in development namespace
kubectl get pods -n development -w

# List all the limitRanges of development namespace
kubectl get limits -n development

# Describe the limit range to view resource limits for dev Pods
kubectl describe limits dev-limit-range -n development

# Finally, check the Pod resource limits inherited from limitRange
kubectl describe pod <pod_name> -n development

[Observe the resource limits of the Pod]
```

## 06. References

- https://kubernetes.io/docs/concepts/policy/limit-range/
- https://kubernetes.io/docs/concepts/policy/resource-quotas/
