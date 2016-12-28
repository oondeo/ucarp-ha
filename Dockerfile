FROM alpine:3.4

MAINTAINER Tit Petric <tit.petric@monotek.net>

RUN apk --update add ucarp bash

COPY ucarp/ /ucarp/

WORKDIR /ucarp

ENTRYPOINT ["/ucarp/run.sh"]
