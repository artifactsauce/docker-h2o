FROM alpine:3.10 AS build-env
ENV H2O_VERSION 2.2.6
ENV PARENTDIR /var/tmp
WORKDIR ${PARENTDIR}/h2o-${H2O_VERSION}
RUN true \
  && apk --no-cache add \
  curl=7.65.1-r0 \
  cmake=3.14.5-r0 \
  make=4.2.1-r2 \
  gcc=8.3.0-r0 \
  g++=8.3.0-r0 \
  bison=3.3.2-r0 \
  zlib-dev=1.2.11-r1 \
  yaml-dev=0.2.2-r1 \
  libuv-dev=1.29.1-r0 \
  linux-headers=4.19.36-r0 \
  openssl-dev=1.1.1c-r0 \
  ruby=2.5.5-r0 \
  mruby-dev=1.4.1-r0
RUN true \
  && curl -sL https://github.com/h2o/h2o/archive/v${H2O_VERSION}.tar.gz -o ${PARENTDIR}/v${H2O_VERSION}.tar.gz \
  && tar zxvf ${PARENTDIR}/v${H2O_VERSION}.tar.gz -C ${PARENTDIR} \
  && cmake -DWITH_BUNDLED_SSL=on -DWITH_MRUBY=on -DCMAKE_INSTALL_PREFIX=/srv/h2o . \
  && make && make install

FROM alpine:3.10
RUN true \
  && apk --no-cache add \
  libstdc++=8.3.0-r0 \
  libgcc=8.3.0-r0 \
  openssl=1.1.1c-r0
COPY --from=build-env /srv/h2o /srv/h2o
WORKDIR /srv/h2o/share/doc/h2o
ENTRYPOINT [ "/srv/h2o/bin/h2o" ]
CMD [ "-c", "/srv/h2o/share/doc/h2o/examples/h2o/h2o.conf" ]
