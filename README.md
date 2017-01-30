## Dockerfile: Virtual / Floating IP with UCARP for High Availability

Assign Virtual / Floating IP with UCARP to your Docker Host for High Availability.

### Quickstart

There are a few things you need to be aware of:

* The network device `eth0` is assumed to be the private LAN interface,
* UCARP communicates over `eth0` and needs MAC spoofing enabled,
* There's currently [a PR waiting on ucarp github to disable MAC addr spoofs](https://github.com/jedisct1/UCarp/pull/20/commits/ca318a8abb4ed2bfa8737c7c76ed3a19b4306996),
* The network device `eth1` is assumed to be the public-facing DMZ inteface

In case you're running Hyper-V, the allow MAC spoofing setting must be enabled on the LAN (eth0) network card device.

### Usage

If you only have one IP and no special routing, you may run ucarp with this short oneliner:

~~~
docker run --rm --cap-add=NET_ADMIN --net=host -it titpetric/ucarp 10.0.75.20 broadcast foobar [ip/netmask, ipv6/netmask, etc.]
~~~

- where 10.0.75.20 is the floating / virtual ip
- broadcast is the broadcast address (10.0.75.255 maybe)
- foobar is the password
- [ip/netmask] list should include the floating/virtual ip with netmask (10.0.75.20/24) in first place

### Advanced usage

The container contains support for network interfaces with `/etc/network/interfaces`. Generally, only this file
should be mounted; the scripts detect the presence of this configuration, and run `ifup [dev]` and `ifdown [dev]`
inside the container respectively. This makes advanced configurations more feasible, for example:

~~~
# The primary network interface
allow-hotplug eth0
auto eth0
iface eth0 inet static
  address [server.ip]
  netmask 255.255.255.0
  up route add -net 10.55.0.0/16 gw [server.gateway]
  up route add -net 10.13.32.0/21 gw [server.gateway]
  gateway [server.gateway]
  metric 1

iface eth1 inet static
  address 94.103.67.6
  netmask 255.255.255.224
  gateway 94.103.67.1
  up ip addr add 94.103.67.7/$IF_NETMASK dev $IFACE

iface eth1 inet6 static
  address 2a02:7a8:1:250::80:6
  netmask 64
  pre-up echo 0 > /proc/sys/net/ipv6/conf/$IFACE/accept_dad
  up ip -6 addr add 2a02:7a8:1:250::80:7/$IF_NETMASK dev $IFACE
  gateway fe80::1
~~~

This is part of the production config at RTV Slovenia. It handles two IPv4 and two IPv6 addresses on the eth1 interface.
It adds custom routing (gateway/netmask) for a smaller DMZ subnet and the interfaces file is shared between the
host and the container with a volume mount. The two-IP settings are mostly practical as we can split some traffic
with DNS entries and eventually modify the configuration to take advantage of two load balancers, without having to
wait for hours or days to update DNS entries globally.

~~~
docker run --name ucarp --restart=always --privileged --cap-add=NET_ADMIN --net=host \
	-v /etc/network/interfaces:/etc/network/interfaces \
	-e OPTS="$OPTS" -d titpetric/ucarp:alpine 94.103.67.6 94.103.67.31 [ucarp-password-here] \
	94.103.67.6/27 94.103.67.7/27 2a02:7a8:1:250::80:6/64 2a02:7a8:1:250::80:7/64
~~~

With the above command, you could pass OPTS like `-n` (bring down interface on startup), or `-P` (preemprive failover -
prefer current host as the new master).

### Failing over your ucarp

When you have two hosts connected and running ucarp, you can fail-over the active host with `docker stop ucarp`. This
will take down the eth1 network interface and "quit" running UCARP. The second node will sense this disconnect within
about 5 seconds (`--deadratio=5` option with ucarp). The default is 3 seconds, but we increased this because we experienced
occasional fail-overs with that value.

### Credits

- Tit Petric (https://scene-si.org)
- Damjan Cvetko

### Related projects

- Debian build: https://github.com/khurram-aziz/hellodocker
- Alpine build: https://github.com/nicolerenee/docker-ucarp
