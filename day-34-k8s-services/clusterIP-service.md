# ClusterIP Service

- ClusterIP is the default Kubernetes service type for internal communications.
- In the case of a pod or ClusterIP, the pod is reachable inside the Kubernetes cluster.
- The network traffic load - balances (round-robin) and routes to the pod and then, it goes through ClusterIP or other services before hitting the pods.

## Lab: Publishing an Application Pod within K8s cluster using `ClusterIP service`
