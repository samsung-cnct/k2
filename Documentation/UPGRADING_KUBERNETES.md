# Upgrading Kubernetes

Kubernetes features advance, evolve, and deprecate cast enough that CNCT needs
to support targed configurations for each Kubernetes release.


## Configuration Branching

Example version notation: when Kubernetes releases 1.7, `N` means `v1.7`, while `N-1` means `v1.6`. 

For each new release `N` of Kubernetes, we should:

1. Ensure that [k2-tools][1] is upgraded accordingly, to include `N`, `N-1`, and `N-2` binaries. Support for `N-3` will be removed.
2. Copy the K2 default configuration to a directory `N-1`, representing functional configuration of the previous release-version.
3. Update default configurations as needed to produce functional clusters with the new Kubernetes release `N`.
4. Test creation of clusters of `N` and `N-1` to confirm functional configurations.

This repository also provides a few shortcuts to facilitate this:

```shell
# Copies the "default" templates to subdirectories named "v1.7"
# This requires a version expression [v<major>.<minor>].
sh hack/clone_version_config.sh copy_default v1.7
```



[1]: https://github.com/samsung-cnct/k2-tools