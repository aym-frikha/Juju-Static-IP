The script network-config.sh can be used as a juju cloud-init config in (Postrun command for example) 
to statically configure ip address for hosts as well as for LXD containers.

For LXD containers: To identify the name of the interface to configure, we should should use the lxd-profile capability 
of the charm.
Example:

```
description: lxd profile subordinate for testing

devices:
  eth1:
    mtu: "1500"
    name: ethmon
    nictype: bridged
    parent: prvtbr
    type: nic
```

To be able to configure the ip address prefix inside the LXD based on the host hostname, the script inject the hostname variable 
as an environment variable for the default lxd profile inside the host ```lxc profile set default environment.HOST_HOSTNAME `hostname` ```
