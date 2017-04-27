# API Server Configuration

## Example 

```yaml
apiServerConfigs:
  - &defaultApiServer
    name: defaultApiServer
    kind: apiServer
    loadBalancer: cloud
    state:
      etcd: *defaultEtcd
    events:
      etcd: *defaultEtcdEvents
```
