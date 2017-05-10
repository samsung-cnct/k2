# OS Configuration

## Options
| Key Name   | Required     | Type    | Description  |
| --------   | ------------ | ------  | ------------ |
| type       | __Required__ | String  | Operating System |
| distro     | __Required__ | String  | Operating System Distro |
| version    | __Required__ |         |              |
| subversion |              |         |              |
| channel    |              |         |              |
| rebootStrategy |        |         |              |


```yaml
osConfigs:
  - &defaultCoreOs
    name: defaultCoreOs
    kind: os
    type: coreOs
    version: current
    channel: stable
    rebootStrategy: "off"
  - &customUbuntu
    name: customUbuntu
    kind: os
    type: ubuntu
    distro: ubuntu
    version: 16.04
    subversion: latest
```
