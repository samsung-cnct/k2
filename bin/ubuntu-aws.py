#!/usr/bin/env python

import cloudconfigcleanup

CLOUD_CONFIG_DIR = "/Users/pat/.kraken/pac-ubuntu/cloud-config/"

cloudconfigcleanup.clean_etcd(CLOUD_CONFIG_DIR + "etcd.cloud-config.yaml")
cloudconfigcleanup.clean_master(CLOUD_CONFIG_DIR + "master.cloud-config.yaml", "fake")
cloudconfigcleanup.clean_worker(CLOUD_CONFIG_DIR + "clusterNodes.cloud-config.yaml", "fake")
