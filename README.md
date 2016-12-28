## Dockerfile: Virtual / Floating IP with UCARP for High Availability

Assign Virtual / Floating IP with UCARP to your Docker Host for High Availability.

### Usage

docker run --rm --cap-add=NET_ADMIN --net=host -it titpetric/ucarp 10.0.75.20 broadcast foobar [ip/netmask, ipv6/netmask, etc.]

- where 10.0.75.20 is the floating / virtual ip
- broadcast is the broadcast address (10.0.75.255 maybe)
- foobar is the password
- [ip/netmask] list should include the floating/virtual ip with netmask (10.0.75.20/24) in first place

### Credits

- Tit Petric (myself)
- Damjan Cvetko
- debian build: https://github.com/khurram-aziz/hellodocker
- alpine build: https://github.com/nicolerenee/docker-ucarp
