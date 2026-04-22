FROM alpine:3.23.3

RUN apk add --no-cache iproute2
RUN apk add --no-cache dnsmasq
RUN apk add --no-cache ethtool

COPY --exclude=*Dockerfile ./pds-router/ /root/pds-router/

COPY ./scripts-common/ /root/scripts-common/

ENTRYPOINT /root/pds-router/init.sh
