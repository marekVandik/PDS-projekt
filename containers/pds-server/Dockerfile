# build nginx with quic logging patch
FROM alpine:3.23.3 AS pds-nginx-build

RUN apk add alpine-sdk
RUN adduser -D builder
RUN addgroup builder abuild
RUN mkdir /tmp/nginx-patched
RUN chown builder:abuild /tmp/nginx-patched

USER builder:abuild
WORKDIR /tmp/nginx-patched
RUN git clone --depth 1 --branch 3.23-stable "https://gitlab.alpinelinux.org/alpine/aports.git"
WORKDIR aports
RUN git sparse-checkout init --cone && git sparse-checkout set main/nginx
WORKDIR main/nginx
RUN abuild fetch
RUN abuild unpack

COPY --chown=builder:abuild ./nginx-patch/* /tmp/nginx-patched/aports/main/nginx/
RUN abuild-keygen -a -n
USER root
RUN cp /home/builder/.abuild/*.rsa.pub /etc/apk/keys/
USER builder:abuild
RUN abuild checksum
RUN abuild -r

# build BPF tracing binary
FROM alpine:3.23.3 AS pds-tracing-build
RUN mkdir /tmp/tracing-build
WORKDIR /tmp/tracing-build
COPY ./pds-server/tracing/* ./
RUN apk add --virtual .tracing-build --no-cache libbpf-dev clang bpftool make gcc linux-headers
RUN make -j build
RUN apk del .tracing-build

# standard container setup
FROM alpine:3.23.3

COPY --from=pds-tracing-build /tmp/tracing-build/tracing /tmp/tracing
COPY --from=pds-nginx-build /home/builder/packages/main/x86_64/nginx-1.28.3-r0.apk /tmp/
RUN apk add --no-cache --allow-untrusted /tmp/nginx-1.28.3-r0.apk

RUN apk add --no-cache iproute2
RUN apk add --no-cache iperf
RUN apk add --no-cache tcpdump
RUN apk add --no-cache libbpf

COPY --exclude=*Dockerfile ./pds-server/ /root/pds-server/

COPY ./scripts-common/ /root/scripts-common/
COPY ./ssl/            /var/ssl/

RUN rm -rf /var/www/*

RUN adduser -D -g 'www' www
RUN chown -R www:www /var/lib/nginx
RUN chown -R www:www /var/www
RUN chown -R www:www /var/ssl

ENTRYPOINT /root/pds-server/init.sh
