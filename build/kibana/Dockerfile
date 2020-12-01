FROM node:10.22.1-alpine3.11

ENV VERSION 7.10.0
ENV DOWNLOAD_URL https://artifacts.elastic.co/downloads/kibana
ENV TARBAL "${DOWNLOAD_URL}/kibana-${VERSION}-linux-aarch64.tar.gz"
ENV TARBALL_ASC "${DOWNLOAD_URL}/kibana-${VERSION}-linux-aarch64.tar.gz.asc"
ENV TARBALL_SHA "bcdff063acfc7f6a8c3cb500096623c0ee977da53f02518b5a6a4061409c6fdddbbf586b0c1c157032ad8ab760c0b36dce5f4abf050e5fd0cb79c68a965476c2"
ENV GPG_KEY "4609 5ACC 8548 582C 1A26 99A9 D27D 666C D88E 42B4"

ENV PATH /usr/share/kibana/bin:$PATH

RUN apk add --no-cache bash su-exec curl bash
RUN apk add --no-cache -t .build-deps wget ca-certificates gnupg openssl \
  && set -ex \
  && cd /tmp \
  && echo "===> Install Kibana..." \
  && wget --progress=bar:force -O kibana.tar.gz "$TARBAL"; \
  if [ "$TARBALL_SHA" ]; then \
  echo "$TARBALL_SHA *kibana.tar.gz" | sha512sum -c -; \
  fi; \
  if [ "$TARBALL_ASC" ]; then \
  wget --progress=bar:force -O kibana.tar.gz.asc "$TARBALL_ASC"; \
  export GNUPGHOME="$(mktemp -d)"; \
  ( gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$GPG_KEY" \
  || gpg --keyserver pgp.mit.edu --recv-keys "$GPG_KEY" \
  || gpg --keyserver keyserver.pgp.com --recv-keys "$GPG_KEY" ); \
  gpg --batch --verify kibana.tar.gz.asc kibana.tar.gz; \
  rm -rf "$GNUPGHOME" kibana.tar.gz.asc || true; \
  fi; \
  tar -xf kibana.tar.gz \
  && ls -lah \
  && mv kibana-${VERSION}-linux-aarch64 /usr/share/kibana \
  && bundled='NODE="${DIR}/node/bin/node"' \
  && alpine_node='NODE="/usr/local/bin/node"' \
  && sed -i "s|$bundled|$alpine_node|g" /usr/share/kibana/bin/kibana-plugin \
  && sed -i "s|$bundled|$alpine_node|g" /usr/share/kibana/bin/kibana \
  && rm -rf /usr/share/kibana/node \
  && rm -rf /tmp/* \
  && apk del --purge .build-deps


RUN echo 'server.host: "0.0.0.0"' >  /usr/share/kibana/config/kibana.yml
RUN echo 'elasticsearch.hosts: ["http://elasticsearch:9200"]' >> /usr/share/kibana/config/kibana.yml

COPY ./entrypoint.sh /usr/share/kibana/entrypoint.sh
RUN chmod +x /usr/share/kibana/entrypoint.sh

WORKDIR /usr/share/kibana

EXPOSE 5601

ENTRYPOINT ["./entrypoint.sh"]
