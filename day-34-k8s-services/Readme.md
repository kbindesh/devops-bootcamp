# Networking in Kubernetes

## 01. Kubernetes Networking Model

- Kubernetes networking resolves the challenge of how to allow different Kubernetes components to communicate with each other.
- It also allows applications on Kubernetes to communicate with other applications, as well as the services outside of the Kubernetes cluster.

Let's understand how k8s networking works in the following use-cases:

- **Container-to-Container communication**

- **Pod-to-Pod communication**

- **Pod-to-Service communication**

- **External-to-Service communication**

- **Node-to-Node communication**

### 1.1 Container-to-container communication

- The following is an example called _multi-container-pod.yaml_ that shows how to create multi-containers in a pod.
- In this pod, it contains **nginx** and **busybox** as two containers where
  busybox is a container that calls nginx container through port _80_ on _localhost_

  ```
  apiVersion: v1
  kind: Pod
  metadata:
    name: multi-container-pod
    labels:
      app: multi-container
  spec:
    containers:
    - name: nginx
      image: nginx:latest
      ports:
      - containerPort: 80
    - name: busybox-helper
      image: busybox:latest
      command: ['sh', '-c', 'while true; do sleep 600; done;']
  ```

- Deploy the above Pod

  ```
  kubectl apply -f multi-container-pod.yaml
  ```

- Now, let's check whether we can communicate with the nginx container from the busybox helper container:

  ```
  kubectl exec multi-container-pod -c busybox-helper -- wget http://localhost:80

  OR

  kubectl exec multi-container-pod -c busybox-helper -- cat index.html
  ```

### 1.2 Pod-to-Pod communication

- In Kubernetes, each pod has been assigned a unique IP address based on the _podCIDR_ range of that worker node.
- This IP assignment is not permanent, as the pod eventually fails or restarts, the new pod will be assigned a new IP address.
- By default, pods can communicate with all pods on all nodes through pod networking without setting up Network Address Translation (NAT).

- The following example demonstrates:

  ```
  # Create an nginx pod
  kubectl run nginx-pod --image=nginx --port=8080

  # To check the Pod IP address
  kubectl get pod nginx-pod -o wide

  # To check all pods present in default namespace with assigned IP addresses
  kubectl get pods -o wide

  [Notice that the multi-container pod and nginx-pod are in the same podCIDR]

  # Check the podCIDR of a node (here it is minikube)
  kubectl get node minikube -o json | jq .spec.podCIDR

  ```

- **Note**: When we start a vanilla minikube installation with the _minikube start_ command without specifying additional parameters for the CNI network plugin, it sets the default value as _auto_. It chooses a _kindnet plugin_ to use, which creates a bridge and then adds the host and the container to it.

### 1.3 Pod-to-Service communication

- The service accepts traffic from both inside and outside of the cluster.
- The effective communication between Pods and Services involves letting the service expose an application running on a set of pods.

- **Kubernetes Service Types**
  1. **ClusterIP**
     - A default service type for Kubernetes.
     - For internal communications, exposing the service makes it reachable within the cluster.

  2. **NodePort**
     - For both internal and external communication.
     - NodePort exposes the service on a static port on each worker node.
     - Example -
       ```
       # For external communication
       <node_ip_address>:<node_port>
       ```
  3. **LoadBalancer**
     - Works with cloud providers, as it is backed by thier respective load balancer service offerings. Ex. AWS ALB
     - Underneath LoadBalancer, ClusterIP and NodePort are created, which are used for internal and external communication.

  4. **ExternalName**
     - Maps the _service_ to the contents with a _CNAME record_ with its value.
     - It allows external traffic access through it.
