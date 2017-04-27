# Deployment Configuration

The snippet configuration for deployments depends on the provider.

## Options

### Root Options

| Key Name        | Required | Type | Description|
| --------------- | ------------ | --- | --- |
| name            | __Required__ | String | Name to use for the cluster created by this deployment |
| resourcePrefix  | Optional     | String | Tagging and naming prefix for providers that need it. |
| serviceCidr     | __Required__ | String | Cluster service ip range CIDR |
| serviceDNS      | __Required__ | String | Cluster (kubedns) service IP |
| clusterDomain   | __Required__ | String | Domain name for cluster (internal resolution) |
| coreos          | Optional     | Object array | named CoreOS options array|
| keypair         | Optional     | Object Array | Array of key pairs to use in this deployment (in node pools and so on) |
| kubeConfig      | __Required__ | Object Array | Array of [Kubernetes configurations](kubernetes.md) |
| containerConfig | __Required__ | Object Array | Array of [Container runtime configurations](container.md) |
| provider        | __Required__ | String | Type of cluster provider, e.g. aws, etc |
| providerConfig  | __Required__ | Object | provider configuration section |
| master          | __Required__ | Object | [Master](master.md) - specific configuration section |
| node            | __Required__ | Object | [Nodes](nodes.md) - specific configuration section |
| helmConfigs     | __Required__ | Object | [Helm Configs](helmconfigs.md) - specific configuration section |
| etcd            | __Required__ | Object | [etcd](nodes.md) - specific configuration section |
| readiness       | __Required__ | Object | When is cluster considered to be ready. Defaults to 'exact' with 600 second total wait. |
| kubeAuth        | Optional     | Object | Master admin authentication. Defaults to admin:<random character string> |


## auth Options

| Key Name | Required | Type    | Description|
| -------- | -------- | -----   | ----------- |
| name     | Required | String  | Name of this configuration                                          |
| user     | Optional | String  | Username. Defaults to 'admin'                                       |
| password | Optional | String  | Password. Defaults to "ChangeMe". Please change.                    |

## coreos Options

| Key Name       | Required | Type   | Description|
| -------------- | -------- | ------ | --- |
| name           | Required | String | Name of this configuration|
| version        | Optional | String | OS version. Specific version number or 'current'. Defaults to current |
| channel        | Optional | String | OS update channel. Stable, alpha, beta. Defaults to beta |
| rebootStrategy | Optional | String | CoreOS reboot strategy values. etcd-lock, reboot, off. Defaults to off. |

## keypair Options

| Key Name | Required | Type | Description|
| --- | --- | --- | --- |
| name | __Required__ | String | Keypair name |
| publickeyFile | Optional | String | Path to public key material. |
| publickey | Optional | String | Public key material. |
| privatekeyFile | Optional | String | Path to private key. |
| providerConfig | Optional | Object | [Provider](keypair/README.md)-specific configuration. |

## readiness Options

| Key Name | Required | Type | Description|
| --- | --- | --- | --- |
| type | __Required__ | String | Type of check: 'exact' 'percent' 'delta' |
| value | Optional | Integer | For percent - what percentage of nodes currently up from total node count is a healthy cluster (Default - 100). For delta - allowed difference between expected and current node count (default 0) |
| wait | Optional | Integer | Wait for how many seconds total |

## providerConfig Options

| Key Name | Required | Type | Description|
| --- | --- | --- | --- |
| type | Optional | String | Type of provider. cloudinit or autonomous. Autonomous providers do not require cloud init configuration. Defaults to cloudinit |
| ... | __Required__ | Object | [Provider](deployments/README.md) - specific configuration section |

# Prototype

```yaml
deployment:
  clusters:
    - name: myCluster
      network: 10.32.0.0/12
      dns: 10.32.0.2
      domain: cluster.local
      providerConfig: *defaultAws
      nodePools:
        - name: etcd
          count: 5
          etcdConfig: *defaultEtcd
          containerConfig: *defaultDocker
          osConfig: *defaultCoreOs
          nodeConfig: *defaultAwsEtcdNode
          keyPair: *defaultKeyPair
        - name: etcdEvents
          count: 5
          etcdConfig: *defaultEtcdEvents
          containerConfig: *defaultDocker
          osConfig: *defaultCoreOs
          nodeConfig: *defaultAwsEtcdEventsNode
          keyPair: *defaultKeyPair
        - name: master
          count: 3
          apiServerConfig: *defaultApiServer
          kubeConfig: *defaultKube
          containerConfig: *defaultDocker
          osConfig: *defaultCoreOs
          nodeConfig: *defaultAwsMasterNode
          keyPair: *defaultKeyPair
        - name: clusterNodes
          count: 3
          kubeConfig: *defaultKube
          containerConfig: *defaultDocker
          osConfig: *defaultCoreOs
          nodeConfig: *defaultAwsClusterNode
          keyPair: *defaultKeyPair
        - name: specialNodes
          count: 2
          kubeConfig: *defaultKube
          containerConfig: *defaultDocker
          osConfig: *defaultCoreOs
          nodeConfig: *defaultAwsSpecialNode
          keyPair: *defaultKeyPair
      fabricConfig: *defaultCanalFabric
      kubeAuth: *defaultKubeAuth
      helmConfig: *defaultHelm
      dnsConfig: *defaultDns
  readiness:
    type: exact
    value: 0
    wait: 600
```

See each configuration section for more details.
