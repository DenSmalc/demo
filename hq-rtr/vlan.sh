#!/bin/bash

apt-get install NetworkManager-ovs -y
systemctl enable --now openvswitch
ovs-vsctl add-br hq-sw
ovs-vsctl add-port hq-sw ens20 tag=10
ovs-vsctl add-port hq-sw ens21 tag=20
ovs-vsctl add-port hq-sw ens22 tag=99
ovs-vsctl add-port hq-sw vlan10 tag=10 -- set interface vlan10 type=internal
ovs-vsctl add-port hq-sw vlan20 tag=20 -- set interface vlan20 type=internal
ovs-vsctl add-port hq-sw vlan99 tag=99 -- set interface vlan99 type=internal
Systemctl restart openvswitch
rm -f /etc/net/ifaces/ens20/ipv4address
rm -f /etc/net/ifaces/ens21/ipv4address
rm -f /etc/net/ifaces/ens22/ipv4address
ip link set hq-sw up
