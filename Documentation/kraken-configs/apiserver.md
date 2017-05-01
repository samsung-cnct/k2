# API Server Configuration

## Options
| Key Name     | Required    | Type | Description|
| ------------ | ----------- | ---- | ---------- |
| loadbalancer | __Required__|      |            |
| state        | __Required__|      |            |
| events       | Optional    |      |            |


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
