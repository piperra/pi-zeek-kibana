FROM golang:1.15.5 AS builder

ENV V_BEAT 7.10.0

RUN echo "Cloning Beats from GitHub..." \
  && git clone -b v$V_BEAT https://github.com/elastic/beats.git

RUN echo "Downloading filebeat for dashboards..." \
  && cd /tmp \
  && wget '--progress=bar:force' -O filebeat.tar.gz https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-$V_BEAT-linux-x86_64.tar.gz \
  && tar xzvf filebeat.tar.gz \
  && mv filebeat-$V_BEAT-linux-x86_64/kibana /go/beats/x-pack/filebeat/

RUN echo "Compiling filebeat..." \
  && cd /go/beats/x-pack/filebeat/ \
  && GOARCH=arm64 go get \
  && GOARCH=arm64 go build 

RUN echo "Shrinking image..." \
  && strip -s /go/beats/x-pack/filebeat/filebeat

RUN echo "Size of the Filebeat install..." \
  && du -sh /go/beats/x-pack/filebeat/filebeat

#########################################################################################################

FROM debian:buster

RUN apt update \
  && apt install -y curl jq

RUN mkdir /filebeat \
  && mkdir /filebeat/module \
  && mkdir /filebeat/modules.d \
  && mkdir /filebeat/kibana

COPY --from=builder /go/beats/x-pack/filebeat/filebeat /filebeat
COPY --from=builder /go/beats/x-pack/filebeat/filebeat.reference.yml /filebeat
COPY --from=builder /go/beats/x-pack/filebeat/module /filebeat/module
COPY --from=builder /go/beats/x-pack/filebeat/modules.d /filebeat/module
COPY --from=builder /go/beats/x-pack/filebeat/kibana /filebeat/kibana
COPY ./filebeat.yml /filebeat/filebeat.yml
COPY ./entrypoint.sh /filebeat/entrypoint.sh

RUN chmod +x /filebeat/entrypoint.sh

WORKDIR /filebeat

ENTRYPOINT ["./entrypoint.sh"]
