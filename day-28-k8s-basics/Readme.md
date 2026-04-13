# Day-28: Introduction to Kubernetes

In this section, you will learn the following topics:

- What is Kubernetes?

- Understanding container orchestration
- Understading Kubernetes key concepts
- Kubernetes Container Runtimes
- Kubernetes Distributions

## 01. What is Kubernetes?

- Kubernetes is a platform to orchestrate the deployment, scaling, and management of container-based applications.

- The correct pronunciation of Kubernetes is **Koo-ber-netties** or **Koo-ber-nay-tace**.

- Kubernetes official documents
  - Website: https://kubernetes.io/
  - Documentation: https://kubernetes.io/docs/home/
  - Github Repo: https://github.com/kubernetes/kubernetes

- Kubernetes was a Google project, but joined the _Cloud Native Computing Foundation (CNCF)_ and is now the de facto standard in the space of container-based applications.
- The core functionality is scheduling workloads in containers across your infrastructure.
- Some of the other kubernetes capabilites of kubernetes are as follows:
  - Providing authentication and authorization
  - Debugging applications
  - Accessing and ingesting logs
  - Rolling updates
  - Using Cluster Autoscaling
  - Using the Horizontal Pod Autoscaler
  - Replicating application instances
  - Checking application health and readiness
  - Monitoring resources
  - Balancing loads
  - Naming and service discovery
  - Distributing secrets
  - Mounting storage systems

## 02. What is Container Orchestration?

- The primary responsibility of Kubernetes is _container orchestration_.
- K8s make sure that all the containers that execute various workloads are scheduled to run on physical or virtual machines.

- K8s must keep an eye on all running containers and replace dead, unresponsive, or unhealthy containers.
- In order to run workloads, you need:
  - Physical machines
  - Virtual machines (optional)
  - Local persistent disks
  - Shared persistent disks
  - Networking resources
- K8s can be deployed on a bare-metal cluster or on a cluster of virtual machines.
- K8s rchestrates container lifecycles across clusters of physical or virtual machines, handling tasks like:
  - Automated Scaling
  - Self-Healing
  - Service Discovery & Load Balancing
  - Storage Orchestration
  - Automated Rollouts/Rollbacks

## 03. Kubernetes - Key Concepts

### Kubernetes Architecture

- K8s architecture follows a _client-server model_ structured into two main layers:
  1. **Control Plane** (the "brain" that makes decisions)

  2. **Worker Nodes** (the "muscle" that runs applications)

### Control Plane Components

- The Kubernetes Control Plane manages the state of the cluster and responds to events.

- **kube-apiserver**
  - The central hub and entry point for all administrative tasks. It exposes the Kubernetes API and handles authentication and authorization.
- **etcd**
  - A highly available distributed key-value store that acts as the cluster's single source of truth, storing all configuration data and cluster state.
- **kube-scheduler**
  - Matches newly created Pods to suitable Nodes based on resource availability, affinity rules, and constraints.

- kube-controller-manager
  - Runs background control loops that regulate the state of the cluster. It includes the Node Controller (detecting node failures) and Replication Controller (maintaining the correct pod count).

### Worker Node Components (Data Plane)

- Worker Nodes are the physical or virtual machines that host the containerized application workloads.

- **kubelet**
  - An agent running on each node that ensures containers are running in a Pod and are healthy according to their specifications.
- **kube-proxy**
  - A network proxy that maintains networking rules on nodes, enabling communication to Pods from inside or outside the cluster.
- **Container Runtime**
  - The software (e.g., containerd, CRI-O) responsible for actually running the containers

### Kubernetes `API Resources`

- The API provides a comprehensive view of what you can do with the system as a user.

```
/api/v1
/api/v2
/api/v2alpha3
```

- Kubernetes exposes several sets of REST APIs for different purposes and audiences via API groups.

- Kubernetes defines the following resource categories:
  - **Workloads**: Objects you use to manage and run containers on the cluster.
  - **Discovery and load balancing**: Objects you use to expose your
    workloads to - the world as externally accessible, load-balanced services.
  - **Config and storage**: Objects you use to initialize and configure your applications, and to persist data that is outside the container.
  - **Cluster**: Objects that define how the cluster itself is configured; these - are typically used only by cluster operators.
  - **Metadata**: Objects you use to configure the behavior of other resources - within the cluster, such as HorizontalPodAutoscaler for scaling workloads.

## 04. Kubernetes Container Runtimes

- Kubernetes originally only supported Docker as a container runtime engine. However, that is no longer the case.
- Kubernetes now supports any runtime that implements the CRI interface.
  - **Docker**
  - **containerd**
  - **CRI-O**

- Source: https://kubernetes.io/docs/setup/production-environment/container-runtimes/

## 05. Kubernetes Distributions

Some of the most popular Kubernetes distributions are as follows:

- minikube (for learning)
- kubeadm
- k3s (IoT & Edge computing)
- k3d (Rancher Lab's minimal distro)
- Rancher Kubernetes (Open source)
- Docker Kubernetes Service (Open source)
- Amazon Elastic Kubernetes Service (Cloud managed)
- Azure Kubernetes Service (Cloud managed)
- Google Kubernetes Engine (Cloud managed)
- RedHat Openshift (Enterprise)
- Tanzu Kubernetes Grid (Enterprise)
- Mirantis (Enterprise)
- Elastisys Compliant Kubernetes (Enterprise)
