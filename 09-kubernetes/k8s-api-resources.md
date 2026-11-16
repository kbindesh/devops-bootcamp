# Kubernetes API Resources

| API Group / Category                  | Resource Type (Plural)          | Object Name (Kind)             | Namespaced Scope? | Supported API Verbs                                               |
| ------------------------------------- | ------------------------------- | ------------------------------ | ----------------- | ----------------------------------------------------------------- |
| Core (v1)                             | Pods                            | Pod                            | TRUE              | get, list, watch, create, update, patch, delete, deletecollection |
|                                       | Services                        | Service                        | TRUE              | get, list, watch, create, update, patch, delete                   |
|                                       | ConfigMaps                      | ConfigMap                      | TRUE              | get, list, watch, create, update, patch, delete, deletecollection |
|                                       | Secrets                         | Secret                         | TRUE              | get, list, watch, create, update, patch, delete, deletecollection |
|                                       | ServiceAccounts                 | ServiceAccount                 | TRUE              | get, list, watch, create, update, patch, delete                   |
|                                       | PersistentVolumeClaims          | PersistentVolumeClaim          | TRUE              | get, list, watch, create, update, patch, delete                   |
|                                       | ReplicationControllers          | ReplicationController          | TRUE              | get, list, watch, create, update, patch, delete, deletecollection |
|                                       | Endpoints                       | Endpoints                      | TRUE              | get, list, watch, create, update, patch, delete                   |
|                                       | Events                          | Event                          | TRUE              | get, list, watch, create, update, patch, delete, deletecollection |
|                                       | Namespaces                      | Namespace                      | FALSE             | get, list, watch, create, update, patch, delete                   |
|                                       | Nodes                           | Node                           | FALSE             | get, list, watch, create, update, patch                           |
|                                       | PersistentVolumes               | PersistentVolume               | FALSE             | get, list, watch, create, update, patch, delete                   |
|                                       | ComponentStatuses               | ComponentStatus                | FALSE             | get, list                                                         |
| Apps (apps/v1)                        | Deployments                     | Deployment                     | TRUE              | get, list, watch, create, update, patch, delete, deletecollection |
|                                       | StatefulSets                    | StatefulSet                    | TRUE              | get, list, watch, create, update, patch, delete, deletecollection |
|                                       | DaemonSets                      | DaemonSet                      | TRUE              | get, list, watch, create, update, patch, delete, deletecollection |
|                                       | ReplicaSets                     | ReplicaSet                     | TRUE              | get, list, watch, create, update, patch, delete, deletecollection |
| Batch (batch/v1)                      | Jobs                            | Job                            | TRUE              | get, list, watch, create, update, patch, delete, deletecollection |
|                                       | CronJobs                        | CronJob                        | TRUE              | get, list, watch, create, update, patch, delete, deletecollection |
| Networking (networking.k8s.io/v1)     | Ingresses                       | Ingress                        | TRUE              | get, list, watch, create, update, patch, delete                   |
|                                       | NetworkPolicies                 | NetworkPolicy                  | TRUE              | get, list, watch, create, update, patch, delete                   |
|                                       | IngressClasses                  | IngressClass                   | FALSE             | get, list, watch, create, update, patch, delete                   |
| Autoscaling (autoscaling/v2)          | HorizontalPodAutoscalers        | HorizontalPodAutoscaler        | TRUE              | get, list, watch, create, update, patch, delete                   |
| RBAC (rbac.authorization.k8s.io/v1)   | Roles                           | Role                           | TRUE              | get, list, watch, create, update, patch, delete                   |
|                                       | RoleBindings                    | RoleBinding                    | TRUE              | get, list, watch, create, update, patch, delete                   |
|                                       | ClusterRoles                    | ClusterRole                    | FALSE             | get, list, watch, create, update, patch, delete                   |
|                                       | ClusterRoleBindings             | ClusterRoleBinding             | FALSE             | get, list, watch, create, update, patch, delete                   |
| Storage (storage.k8s.io/v1)           | StorageClasses                  | StorageClass                   | FALSE             | get, list, watch, create, update, patch, delete                   |
|                                       | VolumeAttachments               | VolumeAttachment               | FALSE             | get, list, watch, create, update, patch, delete                   |
|                                       | CSIDrivers                      | CSIDriver                      | FALSE             | get, list, watch, create, update, patch, delete                   |
|                                       | CSINodes                        | CSINode                        | FALSE             | get, list, watch, create, update, patch, delete                   |
| Admission Registration                | MutatingWebhookConfigurations   | MutatingWebhookConfiguration   | FALSE             | get, list, watch, create, update, patch, delete                   |
|                                       | ValidatingWebhookConfigurations | ValidatingWebhookConfiguration | FALSE             | get, list, watch, create, update, patch, delete                   |
| Policy (policy/v1)                    | PodDisruptionBudgets            | PodDisruptionBudget            | TRUE              | get, list, watch, create, update, patch, delete, deletecollection |
| Scheduling (scheduling.k8s.io/v1)     | PriorityClasses                 | PriorityClass                  | FALSE             | get, list, watch, create, update, patch, delete                   |
| Certificates (certificates.k8s.io/v1) | CertificateSigningRequests      | CertificateSigningRequest      | FALSE             | get, list, watch, create, update, patch, delete, deletecollection |
| Coordination (coordination.k8s.io/v1) | Leases                          | Lease                          | TRUE              | get, list, watch, create, update, patch, delete                   |
