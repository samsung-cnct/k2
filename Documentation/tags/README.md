# Usage For Tags

## Usage

User can use certain part of ansible roles under /k2/roles directory through tags. To use tags with commands, user should set environment variable ( $KRAKEN_TAGS ) for the session bash executes those commands .

### Run with tag through K2 image

User should set an env variable for tag inside of the container that executes a command.
For exmple. if you can set  $KRAKEN_TAGS as 'dryrun' to run shell script without spinning up actual cluster


```bash
$ docker run $K2OPTS -e KRAKEN_TAGS="dryrun" quay.io/samsung_cnct/k2:latest ./up.sh --config $HOME/.kraken/${CLUSTER}.yaml
```

Then you can verify those tags through stdout when run some commands such as 'up.sh'
```bash
...
WARNING: --output not specified. Using /Users/blackdog/.kraken as location
WARNING: Using 'dryrun' as tags
...
```

User are also able to use **multiple tags** using delimeter : ','
```bash
$ docker run $K2OPTS -e KRAKEN_TAGS="fabric_only,services_only" quay.io/samsung_cnct/k2:latest ./up.sh --config $HOME/.kraken/${CLUSTER}.yaml
```

### Run with tags through K2-tools image for using local k2 repository
Like example above, you can set  $KRAKEN_TAGS as 'dryrun' to run shell script without spinning up
clusters

```bash
$ .${YOURK2PATH}/hack/dockerdev -c ~/.kraken/${CLUSTER}.yaml

Mappings:
/Users/blackdog/.aws/credentials:/Users/blackdog/.aws/credentials
/Users/blackdog/.aws:/Users/blackdog/.aws
/Users/blackdog/.kraken/cappuccino.yaml:/Users/blackdog/.kraken/cappuccino.yaml
/Users/blackdog/.kraken:/Users/blackdog/.kraken
/Users/blackdog/.ssh/id_rsa.pub:/Users/blackdog/.ssh/id_rsa.pub
/Users/blackdog/.ssh:/Users/blackdog/.ssh
/Users/blackdog/dev/k2/lib/bashrc:/Users/blackdog/.bashrc
/Users/blackdog/dev/k2:/kraken

$ export KRAKEN_TAGS="dryrun"
$ echo $KRAKEN_TAGS
dryrun
```

After setting up env variables you can execute up.sh without spinning up actual cluster
```bash
$ ./up.sh --config ~/.kraken/${CLUSTER}.yaml
```

Then you can verify those tags through stdout when run some commands such as 'up.sh'
```bash
...
WARNING: --output not specified. Using /Users/blackdog/.kraken as location
WARNING: Using 'dryrun' as tags
...
```
Or you can set multiple tags using ',' for delimeter
```bash
$ export KRAKEN_TAGS="fabric_only,services_only"
$ echo $KRAKEN_TAGS
fabric_only,services_only
```

## Ansible roles for shell

| Role Name  | up.sh ( up.yaml )    |  down.sh ( down.yaml )  | update ( update.yaml ) |
| -------------- | ------------ | ----------   | ------------ |
| kraken.config | O | O | O |
| roles.kraken.cluster_common | O |  X | O |
| roles.kraken.nodePool/kraken.nodePool.selector | O | X |  O |
| roles.kraken.assembler | O | X | O |
| roles.kraken.provider/kraken.provider.selector | O | O | O |
| roles.kraken.ssh/kraken.ssh.selector | O | X | O |
| roles/kraken.access | O | X | X |
| roles/kraken.rbac | O | X | X |
| roles.kraken.readiness | O | X | O |
| roles.kraken.fabric/kraken.fabric.selector | O | X | O |
| roles.kraken.services | O |  O | X |
| roles.kraken.clean |  X | O | X |


## List of tags and usage for ansible roles

### all

- roles/kraken.cluster_common
- roles/kraken.nodePool/kraken.nodePool.selector
- roles/kraken.assembler
- roles/kraken.provider/kraken.provider.selector
- roles/kraken.ssh/kraken.ssh.selector
- roles/kraken.access
- roles/kraken.rbac
- roles/kraken.readiness
- roles/kraken.fabric/kraken.fabric.selector
- roles/kraken.services

### dryrun

- roles/kraken.cluster_common
- roles/kraken.nodePool/kraken.nodePool.selector
- roles/kraken.assembler
- roles/kraken.provider/kraken.provider.selector
- roles/kraken.fabric/kraken.fabric.selector
- roles/kraken.ssh/kraken.ssh.selector
- roles/kraken.access
- roles/kraken.clean

### config_only
- kraken.config

### common_only
- roles/kraken.cluster_common

### nodepools_only
- roles/kraken.nodePool/kraken.nodePool.selector

### assembler
- roles/kraken.cluster_common
- roles/kraken.nodePool/kraken.nodePool.selector
- roles/kraken.assembler
- roles/kraken.fabric/kraken.fabric.selector

### assembler_only
- roles/kraken.assembler

### provider
- roles/kraken.cluster_common
- roles/kraken.nodePool/kraken.nodePool.selector
- roles/kraken.assembler
- roles/kraken.provider/kraken.provider.selector
- roles/kraken.fabric/kraken.fabric.selector

### provider_only
- roles/kraken.provider/kraken.provider.selector


### ssh
- roles/kraken.cluster_common
- roles/kraken.nodePool/kraken.nodePool.selector
- roles/kraken.assembler
- roles/kraken.provider/kraken.provider.selector
- roles/kraken.fabric/kraken.fabric.selector
- roles/kraken.ssh/kraken.ssh.selector

### ssh_only
- roles/kraken.ssh/kraken.ssh.selector

### access_only
- roles/kraken.access

### rbac_only
- roles/kraken.rbac

### readiness
- roles/kraken.cluster_common
- roles/kraken.nodePool/kraken.nodePool.selector
- roles/kraken.assembler
- roles/kraken.provider/kraken.provider.selector
- roles/kraken.access
- roles/kraken.rbac
- roles/kraken.readiness
- roles/kraken.fabric/kraken.fabric.selector

### readiness_only
- roles/kraken.readiness

### fabric_only
- roles/kraken.fabric/kraken.fabric.selector

### services
- roles/kraken.cluster_common
- roles/kraken.nodePool/kraken.nodePool.selector
- roles/kraken.assembler
- roles/kraken.provider/kraken.provider.selector
- roles/kraken.access
- roles/kraken.rbac
- roles/kraken.readiness
- roles/kraken.fabric/kraken.fabric.selector
- roles/kraken.services

### services_only
- roles/kraken.services
