# KV Store Options

## Sections

### Root

By default we have an array of etcd clusters that we want to configure

| Name            | Required  | Type          | Description |
| --------------- | --------- | ------------- | --- |
| name            | __TRUE__  | String        | name for this kvStore cluster |
| kind            | __TRUE__  | String        | Must be kvStore |
| type            | __TRUE__  | String        | Type is etcd |
| clientPorts     | __FALSE__ | Integer Array | Defaults to 2379 and 4001 - the client ports for etcd |
| clusterToken    | __FALSE__ | String        | Defaults to _name_-cluster-token - the initial cluster token used |
| peerPorts       | __FALSE__ | Integer Array | Defaults to 2380 - the peer ports for peer-to-peer traffic |
| ssl             | __FALSE__ | Boolean       | Whether or not SSL is used for etcd traffic.  Defaults to true |
| version         | __TRUE__  | String        | etcd tag version |
| image           | __FALSE__ | String        | etcd image path - defaults to quay.io/coreos/etcd |

## Example
```yaml
kvStoreConfigs:
  - &defaultEtcd
    name: etcd
    kind: kvStore
    type: etcd
    clientPorts: [2379, 4001]
    clusterToken: espouse-monger-rarely
    peerPorts: [2380]
    ssl: true
    version: v3.1.0
  - &defaultEtcdEvents
    name: etcdEvents
    kind: kvStore
    type: etcd
    clientPorts: [2381]
    clusterToken: animism-training-chastity
    peerPorts: [2382]
    ssl: true
    version: v3.1.0
```
