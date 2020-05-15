FROM alpine:3.11 AS build-env
ENV H2O_VERSION 2.2.6
ENV PARENTDIR /var/tmp
WORKDIR ${PARENTDIR}/h2o-${H2O_VERSION}
RUN set -eux \
  && apk --no-cache add \
  curl=7.67.0-r0 \
  cmake=3.15.5-r0 \
  make=4.2.1-r2 \
  gcc=9.2.0-r4 \
  g++=9.2.0-r4 \
  bison=3.4.2-r0 \
  zlib-dev=1.2.11-r3 \
  yaml-dev=0.2.2-r1 \
  libuv-dev=1.34.0-r0 \
  linux-headers=4.19.36-r0 \
  openssl-dev=1.1.1g-r0 \
  ruby=2.6.6-r2 \
  mruby-dev=2.0.1-r0
RUN set -eux \
  && curl -sL https://github.com/h2o/h2o/archive/v${H2O_VERSION}.tar.gz -o ${PARENTDIR}/v${H2O_VERSION}.tar.gz \
  && tar zxvf ${PARENTDIR}/v${H2O_VERSION}.tar.gz -C ${PARENTDIR} \
  && cmake -DWITH_BUNDLED_SSL=on -DWITH_MRUBY=on -DCMAKE_INSTALL_PREFIX=/srv/h2o . \
  && make && make install

FROM alpine:3.11
RUN set -eux \
  && apk --no-cache add \
  perl=5.30.1-r0 \
  libstdc++=9.2.0-r4 \
  libgcc=9.2.0-r4 \
  openssl=1.1.1g-r0
COPY --from=build-env /srv/h2o /srv/h2o
WORKDIR /srv/h2o/share/doc/h2o
ENTRYPOINT [ "/srv/h2o/bin/h2o" ]
CMD [ "-c", "/srv/h2o/share/doc/h2o/examples/h2o/h2o.conf" ]
