#!/bin/bash
NETWORK=$1
MASK=$2
RELEASE=`lsb_release -c | awk -F"\t" '{print $2}'`
if [[ $RELEASE = "xenial" ]]
then
   HOSTNAME=`hostname -s`
   if [[ $HOSTNAME = storage* ]]
   then
      PREFIX=`echo ${HOSTNAME:8:3} | tr -dc '0-9'`
      printf "%s\n" "
      auto prvtbr
      iface prvtbr inet static
            address $((NETWORK)).$((PREFIX + 3))/$((MASK))
            dns-nameservers TO BE DEFINED
            dns-search maas
            bridge_fd 15
            bridge_ports ens8
            bridge_stp off
            mtu 1500
      " > '/etc/network/interfaces.d/prvtbr.cfg'
      ifup prvtbr
      lxc profile set default environment.HOST_HOSTNAME `hostname`
   elif [[ -d "/sys/class/net/ethmon" ]]
   then
      . <(xargs -0 bash -c 'printf "export %q\n" "$@"' -- < /proc/1/environ )
      PREFIX=`echo ${HOST_HOSTNAME:8:3} | tr -dc '0-9'`

      printf "%s\n" "
      auto ethmon
      iface ethmon inet static
         address $((NETWORK)).$((PREFIX + 3))/$((MASK))
      " >> '/etc/network/interfaces'
      ifdown ethmon
      ifup ethmon

   elif [[ -d "/sys/class/net/ethexport" ]]
   then
      . <(xargs -0 bash -c 'printf "export %q\n" "$@"' -- < /proc/1/environ )
      PREFIX=`echo ${HOST_HOSTNAME:8:3} | tr -dc '0-9'`

      printf "%s\n" "
      auto ethmon
      iface ethmon inet static
         address $((NETWORK)).$((PREFIX + 3))/$((MASK))
      " >> '/etc/network/interfaces'
      ifdown ethexport
      ifup ethexport

   fi
elif [[ $RELEASE = "bionic" ]]
then
   HOSTNAME=`hostname -s`
   if [[ $HOSTNAME = storage* ]]
   then
      apt update
      apt install -y python-yaml
      PREFIX=`echo ${HOSTNAME:8:3} | tr -dc '0-9'`
      python /usr/local/bin/netplan_config_host.py $PREFIX ens8 simple $NETWORK $MASK
      netplan apply
      lxc profile set default environment.HOST_HOSTNAME `hostname`
   elif [[ -d "/sys/class/net/ethmon" ]]
   then
      apt update
      apt install -y python-yaml
      . <(xargs -0 bash -c 'printf "export %q\n" "$@"' -- < /proc/1/environ )
      PREFIX=`echo ${HOST_HOSTNAME:8:3} | tr -dc '0-9'`
      python /usr/local/bin/netplan_config_lxd.py $PREFIX ethmon simple $NETWORK $MASK
      netplan apply
   elif [[ -d "/sys/class/net/ethexport" ]]
   then
      apt update
      apt install -y python-yaml
      . <(xargs -0 bash -c 'printf "export %q\n" "$@"' -- < /proc/1/environ )
      PREFIX=`echo ${HOST_HOSTNAME:8:3} | tr -dc '0-9'`
      python /usr/local/bin/netplan_config_lxd.py $PREFIX  ethexport simple $NETWORK $MASK
      netplan apply
   fi
fi
