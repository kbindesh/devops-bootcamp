# Kubernetes API Resources

## What are API Resources in K8s?

- K8s API resources are the specific endpoints in the Kubernetes API that represent different types of objects you can manage in a cluster.

- Every interaction you have with Kubernetes, whether via _kubectl_ or a _dashboard_, is essentially a call to these API resources.

```bash
# To list all the K8s API Resources
kubectl api-resources
```

### Common K8s API Resources

- API Resources are categorized by their function within the cluster:

| Category       | Key Resources                                                        | Purpose                                                                               |
| -------------- | -------------------------------------------------------------------- | ------------------------------------------------------------------------------------- |
| Workloads      | Pods, Deployments, StatefulSets, Jobs                                | Running and managing your applications.                                               |
| Networking     | Services, Ingress, NetworkPolicies                                   | Managing traffic and connectivity between components.                                 |
| Storage        | PersistentVolumes (PV), PersistentVolumeClaims (PVC), StorageClasses | Handling persistent data storage.                                                     |
| Config/Secrets | ConfigMaps, Secrets                                                  | Storing configuration data and sensitive information.                                 |
| Metadata       | Namespaces, Events, Nodes,                                           | Organizing resources, tracking cluster state, and managing physical/virtual hardware. |

### K8s API Resources - Key Concepts

- API Groups & Versioning
  - Resources are organized into groups (e.g., apps, batch, networking.k8s.io) and versioned (e.g., v1, v1beta1) to allow the API to evolve without breaking existing tools.
- Kind
  - While a "resource" is the API endpoint (like /pods), the Kind is the name of the object schema (like Pod).
- Verbs
  - Each resource supports specific actions like get, list, create, update, patch, delete, and watch.
- Custom Resource Definitions (CRDs)
  - You can extend the Kubernetes API by adding your own custom resources, which then behave like built-in ones.

## Exploring K8s API Resources

- You can use `kubectl` to see exactly which resources are available on your specific cluster:

```bash
# List all api resources
kubectl api-resources

# List api resources with more detail (like supported verbs)
kubectl api-resources -o wide

# Filter by API Group
kubectl api-resources --api-group=apps

# Check Namespaced vs Cluster-wide api resources
kubectl api-resources --namespaced=true
```
