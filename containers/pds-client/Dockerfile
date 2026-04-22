FROM alpine:3.23.3

RUN apk add --no-cache iproute2
RUN apk add --no-cache iperf
RUN apk add --no-cache curl

COPY --exclude=*Dockerfile ./pds-client/ /root/pds-client/

COPY ./scripts-common/ /root/scripts-common/
COPY ./ssl/            /root/ssl/

RUN mkdir /usr/local/share/ca-certificates/
RUN cp /root/ssl/certificate.crt /usr/local/share/ca-certificates/certificate.crt
RUN cat /usr/local/share/ca-certificates/certificate.crt >> /etc/ssl/certs/ca-certificates.crt

ENTRYPOINT /root/pds-client/init.sh
