## Dockerfile: Virtual / Floating IP with UCARP for High Availability

Assign Virtual / Floating IP with UCARP to your Docker Host for High Availability.

### Usage

docker run --rm --cap-add=NET_ADMIN --net=host -it titpetric/ucarp-ha 10.0.75.20 foobar

- where 10.0.75.20 is the floating / virtual ip and foobar is the password

### Credits

- Tit Petric (myself)
- Damjan Cvetko
- debian build: https://github.com/khurram-aziz/hellodocker
- alpine build: https://github.com/nicolerenee/docker-ucarp
