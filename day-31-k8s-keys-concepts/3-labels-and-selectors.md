# Labels, Node selectors and Annotations

- Labels, selectors, and annotations are useful notions with respect to k8s workload scheduling.

## 01. Labels and Selectors

- _Labels_ are key-value pairs attached to K8s objects that can be listed in the `metadata.labels` section of an object descriptor.
- _Selectors_ are used for identifying and selecting a group of objects using their labels.

- You can use either `-l` (label) flag for passing label selector value/s.

```
# Examples - equality-based selectors
kubectl get pods -l app=webapp

kubectl get pods -l env=production

# Examples - inequality-based selectors
kubectl get pods -l env!=production

# To chain multiple selectors using comma-delimited values
kubectl get pods -l key1=value1,key2=value2
kubectl get pods -l app=myapp,env=production
```

- To chain multiple `field selectors` in a kubectl get command, use the `--field-selector` flag and separate the individual selectors with a comma (,).

```
# Syntax
kubectl get <resource-type> --field-selector=<field-key-1>=<value-1>,<field-key-2>!=<value-2>,...

# Example-01 - Select pods that are not Running AND have a specific restart policy
kubectl get pods --field-selector=status.phase!=Running,spec.restartPolicy=Always

# Example-02 - Select resources not in the default namespace
kubectl get statefulsets,services --all-namespaces --field-selector=metadata.namespace!=default

# Example-03 - Select a specific pod by name and status
kubectl get pod --field-selector=metadata.name=app3-pod,status.phase=Running
```

## 02. Node selectors

- To assign a pod to a particular node, you can use **node selectors**.
- You can specify a map of key-value pairs in the PodSpec field:

```
# Start by labeling the worker node/s
kubectl label node worker-node1 env=dev

# List worker nodes with it's labels
kubectl get nodes --show-labels
```

- Then, you can add the `node selector` in the Pod YAML definition as follows:

```
apiVersion: v1
kind: Pod
metadata:
  name: nginx
  labels:
    env: test
spec:
  nodeSelector:
    env: dev
  containers:
  - name: nginx
    image: nginx
```

## 03. Annotations

- In K8s, _Annotations_ are key-value pairs used to attach arbitrary, non-identifying metadata to objects.
- Unlike labels, which are used to select and group resources, _annotations_ are primarily used for storing information that is useful to humans, tools, and libraries but is not used by the core K8s system to identify or filter objects.

### Annotations - Common Use Cases

- Contextual Information
  - Build/release details (image hashes, PRs) or ownership contact info.

- Tooling/Config
  - External tool configuration, such as for monitoring, logging, or service meshes.

- Documentation
  - Detailed, free-form descriptions of resources

### Annotations - Examples

- Example-01 - Pod with

```
apiVersion: v1
kind: Pod
metadata:
  name: annotated-pod
  annotations:
    description: "Sample pod with annotations"
    owner: "platform-team"
    imageregistry: "https://hub.docker.com/"

```

- Example-02 - Tool Integration

```
annotations:
  prometheus.io/scrape: "true"
  prometheus.io/port: "9090"
  prometheus.io/path: "/metrics"
```

- Example-03 - Deployment Information | Track rollout versions or last-applied configuration

```
annotations:
  deployment.kubernetes.io/revision: "2"
  kubectl.kubernetes.io/last-applied-configuration: |
    {"apiVersion":"v1","kind":"Pod"...}
```

## References

- Well-Known Labels, Annotations - https://kubernetes.io/docs/reference/labels-annotations-taints/
