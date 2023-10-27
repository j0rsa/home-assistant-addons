FROM alpine:3.6

RUN apk add --no-cache sniproxy

COPY sniproxy.conf /
COPY run.sh /

ENTRYPOINT run.sh