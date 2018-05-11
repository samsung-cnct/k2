#!/usr/bin/env python
import re

def clean_start(filepath):
    cloud_config_fd = open(filepath, "r")
    cloud_config = cloud_config_fd.read()
    cloud_config_fd.close()

    return cloud_config

def clean_end(filepath, cloud_config):
    cloud_config_fd = open(filepath, "w")
    cloud_config_fd.write(cloud_config)
    cloud_config_fd.close()
 
def install_docker(cloud_config):
    late_service_restart = '''runcmd:
- systemctl restart --no-block docker.service kubelet.service
'''
    update_packages = "package_update: true\n"
    docker_install = "packages:\n- docker.io\n"
    cloud_config += update_packages
    cloud_config += docker_install
    cloud_config += late_service_restart
    return cloud_config

def fqdn(cloud_config):
    #  add FQDN environment variable
    cloud_config = re.sub("EnvironmentFile=/etc/network-environment\\\\n",  \
        "EnvironmentFile=/etc/network-environment\\\\n\\\\\n    ExecStartPre=/bin/bash -c " + \
        "'/bin/systemctl set-environment FQDN=`hostname --fqdn`'\\\\n", cloud_config)

    #  use FDQN environment variable
    cloud_config = re.sub("HOST_NAME=%H", "HOST_NAME=${FQDN}", cloud_config)
    return cloud_config


def clean_etcd(filepath):
    if filepath is None:
        print "no filepath passed to script.  do nothing"
        return

    cloud_config = clean_start(filepath)

    #  rule: change /usr/bin/mkdir to /bin/mkdir
    cloud_config = re.sub("/usr/bin/mkdir", "/bin/mkdir", cloud_config, count=0)

    #  rule:  change occurances of /usr/bin/[mkdir|bash|systemctl] to /bin/[mkdir|bash|systemctl]
    cloud_config = re.sub("/usr/bin/([mkdir|bash|systemctl|grep])", "/bin/" + r"\g" + "<1>", \
        cloud_config)
    cloud_config = re.sub("/usr/sbin/([blkid|wipefs|mkfs.ext4])", "/sbin/" + r"\g" + "<1>", \
        cloud_config)
    cloud_config = re.sub("/bin/([dig])", "/usr/bin/" + r"\g" + "<1>", \
        cloud_config)


    clean_end(filepath, cloud_config)
    
def clean_master(filepath, ipaddress):
    if filepath is None:
        print "no filepath passed to script.  do nothing"
        return

    if ipaddress is None:
        print "ipaddress of etcd not provided.  this is not going to work"
        return

    cloud_config = clean_start(filepath)

    #  rule:  change occurances of /usr/bin/[mkdir|bash|systemctl] to /bin/[mkdir|bash|systemctl]
    cloud_config = re.sub("/usr/bin/([mkdir|bash|systemctl|grep])", "/bin/" + r"\g" + "<1>", \
        cloud_config)
    cloud_config = re.sub("/usr/sbin/([blkid|wipefs|mkfs.ext4])", "/sbin/" + r"\g" + "<1>", \
        cloud_config)

    #  rule:  install docker
    cloud_config = install_docker(cloud_config)
    
    #  rule:  need to use the fqdn for ubuntu
    cloud_config = fqdn(cloud_config)

    clean_end(filepath, cloud_config)

def clean_worker(filepath, ipaddress):
    if filepath is None:
        print "no filepath passed to script.  do nothing"
        return

    if ipaddress is None:
        print "ipaddress of master not provided.  this is not going to work"
        return

    cloud_config = clean_start(filepath)

    #  rule:  change occurances of /usr/bin/[mkdir|bash|systemctl] to /bin/[mkdir|bash|systemctl]
    cloud_config = re.sub("/usr/bin/([mkdir|bash|systemctl|grep])", "/bin/\g<1>", cloud_config)
    cloud_config = re.sub("/usr/sbin/([blkid|wipefs|mkfs.ext4])", "/sbin/" + r"\g" + "<1>", \
        cloud_config)

    #  rule:  install docker
    cloud_config = install_docker(cloud_config)

    #  rule:  need to use the fqdn for ubuntu
    cloud_config = fqdn(cloud_config)

    clean_end(filepath, cloud_config)