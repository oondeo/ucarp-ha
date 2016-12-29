## Dockerfile: Virtual / Floating IP with UCARP for High Availability

Assign Virtual / Floating IP with UCARP to your Docker Host for High Availability.

### Usage

docker run --rm --cap-add=NET_ADMIN --net=host -it titpetric/ucarp 10.0.75.20 broadcast foobar [ip/netmask, ipv6/netmask, etc.]

- where 10.0.75.20 is the floating / virtual ip
- broadcast is the broadcast address (10.0.75.255 maybe)
- foobar is the password
- [ip/netmask] list should include the floating/virtual ip with netmask (10.0.75.20/24) in first place

### Caveats

The device `eth0` is a private lan, the device `eth1` is the one with all the public facing ips. On `eth0`, MAC address spoofing must be
allowed. There's currently [a PR waiting on ucarp github to disable MAC addr spoofs](https://github.com/jedisct1/UCarp/pull/20/commits/ca318a8abb4ed2bfa8737c7c76ed3a19b4306996).

In case you're running Hyper-V, the setting must be enabled on the LAN (eth0) network card device.

### Credits

- Tit Petric (myself)
- Damjan Cvetko
- debian build: https://github.com/khurram-aziz/hellodocker
- alpine build: https://github.com/nicolerenee/docker-ucarp
