# Usage For Tags

## Usage

User can specify subset parts of ansible roles under /Kraken/roles directory through tags. To use tags with commands, user should set environment variable ( $KRAKEN_TAGS ) for the session in which bash executes those commands.

### Run with tag through kraken-lib image

User should set an env variable for tag inside of the container that executes a command.
For example, you can set  $KRAKEN_TAGS as 'dryrun' to run shell script without spinning up actual cluster.


```bash
$ docker run $K2OPTS -e KRAKEN_TAGS="dryrun" quay.io/samsung_cnct/k2:latest ./bin/up.sh --config $HOME/.kraken/${CLUSTER}.yaml
```

Then you can verify those tags through stdout when running commands such as 'up.sh'
```bash
...
WARNING: --output not specified. Using $HOME/.kraken as location
WARNING: Using 'dryrun' as tags
...
```

Users can set **multiple tags** using the ',' delimiter
```bash
$ docker run $K2OPTS -e KRAKEN_TAGS="fabric_only,services_only" quay.io/samsung_cnct/k2:latest ./bin/up.sh --config $HOME/.kraken/${CLUSTER}.yaml
```

### Run with tags through Kraken-tools image for using local Kraken repository
Like the example above, you can set $KRAKEN_TAGS as 'dryrun' to run shell script without spinning up
clusters.

```bash
$ .${YOURK2PATH}/hack/dockerdev -c ~/.kraken/${CLUSTER}.yaml

Mappings:
$HOME/.aws/credentials:$HOME/.aws/credentials
$HOME/.aws:$HOME/.aws
$HOME/.kraken/cappuccino.yaml:$HOME/.kraken/cappuccino.yaml
$HOME/.kraken:$HOME/.kraken
$HOME/.ssh/id_rsa.pub:$HOME/.ssh/id_rsa.pub
$HOME/.ssh:$HOME/.ssh
$HOME/dev/k2/lib/bashrc:$HOME/.bashrc
$HOME/dev/k2:/kraken

$ export KRAKEN_TAGS="dryrun"
$ echo $KRAKEN_TAGS
dryrun
```

After setting up env variables you can execute up.sh without spinning up an actual cluster
```bash
$ ./bin/up.sh --config ~/.kraken/${CLUSTER}.yaml
```

Then you can verify those tags through stdout when running commands like 'up.sh'
```bash
...
WARNING: --output not specified. Using $HOME/.kraken as location
WARNING: Using 'dryrun' as tags
...
```
Or you can set multiple tags using the ',' delimiter
```bash
$ export KRAKEN_TAGS="fabric_only,services_only"
$ echo $KRAKEN_TAGS
fabric_only,services_only
```

## Ansible roles for shell

| Role Name  | up.sh ( up.yaml )    |  down.sh ( down.yaml )  | update ( update.yaml ) |
| -------------- | ------------ | ----------   | ------------ |
| roles.kraken.config | O | O | O |
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
| roles.kraken.post | O | X | X |
| roles.kraken.clean |  X | O | X |

## List of tags and usage for ansible roles

### always
**: This tag forces ansible to run roles with the 'always' tag. Use this for default roles such as 'kraken.config'**

### all
 **: If no tags are specified, the default tag is 'all'**
- roles/kraken.config
- roles/kraken.cluster_common
- roles/kraken.nodePool/kraken.nodePool.selector
- roles/kraken.assembler
- roles/kraken.provider/kraken.provider.selector
- roles/kraken.ssh/kraken.ssh.selector
- roles/kraken.access
- roles/kraken.rbac
- roles/kraken.readiness
- roles/kraken.fabric/kraken.fabric.selector
- roles/kraken.readiness
- roles/kraken.ssh/kraken.ssh.selector
- roles/kraken.services
- roles/kraken.post

### dryrun
 **: Execute all codepaths to build any physical resources without spinning up an actual cluster**
- roles/kraken.config
- roles/kraken.cluster_common
- roles/kraken.nodePool/kraken.nodePool.selector
- roles/kraken.assembler
- roles/kraken.provider/kraken.provider.selector
- roles/kraken.fabric/kraken.fabric.selector
- roles/kraken.ssh/kraken.ssh.selector
- roles/kraken.access
- roles/kraken.clean

### config_only
**: To use for debugging the parsing of the config file**
- roles/kraken.config

### assembler
**: Render and then assemble all of the part files for cloud-config to make XXXX.cloud-config for each nodePool**
- roles/kraken.config
- roles/kraken.cluster_common
- roles/kraken.nodePool/kraken.nodePool.selector
- roles/kraken.assembler
- roles/kraken.fabric/kraken.fabric.selector

### fabric_only
 **: Render and execute kubernetes config yamls for creating the network fabric**
 **: Useful for development and production upgrades of a network**
- roles/kraken.fabric/kraken.fabric.selector


### provider
 **: Render and spin up an unconfigured kubernetes cluster on a cloud, such as AWS or GKE**
- roles/kraken.config
- roles/kraken.cluster_common
- roles/kraken.nodePool/kraken.nodePool.selector
- roles/kraken.assembler
- roles/kraken.provider/kraken.provider.selector

### pre_provider
 **: create cloud-config files**
- roles/kraken.config
- roles/kraken.cluster_common
- roles/kraken.nodePool
- roles/kraken.assembler

### post_provider
 **: Assumes a set of machines has been created and has nodes in etcd, master and cluster pools**
 **: Requires manually setting the krakenconfig cli variable**
- roles/kraken.config
- roles/kraken.cluster_common
- roles/kraken.access
- roles/kraken.rbac
- roles/kraken.readiness
- roles/kraken.fabric/kraken.fabric.selector
- roles/kraken.readiness
- roles/kraken.ssh/kraken.ssh.selector
- roles/kraken.services
- roles/kraken.post

### ssh_only
**: To regenerate the ssh config without doing other stuff**
- roles/kraken.readiness
- roles/kraken.ssh/kraken.ssh.selector

### ssh
**: To test ssh, spins up an actual cluster including fabric config and ssh config**
- roles/kraken.config
- roles/kraken.cluster_common
- roles/kraken.nodePool/kraken.nodePool.selector
- roles/kraken.assembler
- roles/kraken.provider/kraken.provider.selector
- roles/kraken.fabric/kraken.fabric.selector
- roles/kraken.ssh/kraken.ssh.selector

### access_only
**: To setup things to access the kubernetes cluster**
- roles/kraken.config
- roles/kraken.access

### rbac_only
**: To setup RBAC (role based access control) for the cluster**
- roles/kraken.config
- roles/kraken.rbac

### dns_only
**: To update DNS components for a running cluster, you can modify images and versions in k2/ansible/roles/kraken.services/defaults/main.yaml**
- roles/kraken.services


### readiness
**: To test readiness which waits for when api server is ready, spins up actual cluster except for ssh setup and services setup**
- roles/kraken.config
- roles/kraken.cluster_common
- roles/kraken.nodePool/kraken.nodePool.selector
- roles/kraken.assembler
- roles/kraken.provider/kraken.provider.selector
- roles/kraken.access
- roles/kraken.rbac
- roles/kraken.readiness
- roles/kraken.fabric/kraken.fabric.selector
- roles/kraken.post

### services
**: To test services which installs kraken services on kubernetes cluster, it spins up actual cluster except for ssh setup for nodes**
- roles/kraken.config
- roles/kraken.cluster_common
- roles/kraken.nodePool/kraken.nodePool.selector
- roles/kraken.assembler
- roles/kraken.provider/kraken.provider.selector
- roles/kraken.access
- roles/kraken.rbac
- roles/kraken.readiness
- roles/kraken.fabric/kraken.fabric.selector
- roles/kraken.services
- roles/kraken.post

### post_only
**: To test touching cluster.status.lock file on config base directory.**
- roles/kraken.post

### clean_only
**:To test removing config base directory and cluser.status.lock file**
- roles/kraken.clean
