FROM ubuntu:bionic

ENV DEBIAN_FRONTEND noninteractive
ENV VARNISH_VERSION 6.4
ENV GO_VERSION 1.14.6

RUN apt update && apt install -y \
	curl \
	pkg-config

RUN /bin/bash -c \
	'curl -s https://packagecloud.io/install/repositories/varnishcache/varnish${VARNISH_VERSION/./}/script.deb.sh | /bin/bash' \
	&& apt update \
	&& apt install -y \
	  varnish \
	  varnish-dev \
	&& apt clean && rm -rf /var/lib/apt/lists/* \
	&& curl -SsOL https://golang.org/dl/go${GO_VERSION}.linux-amd64.tar.gz \
	&& tar xzf go1.14.6.linux-amd64.tar.gz

ADD . varnishstatbeat

WORKDIR varnishstatbeat

ADD default.vcl /etc/varnish/default.vcl
ADD docker-entrypoint.sh /docker-entrypoint.sh

RUN sed -i 's/localhost:9200/elasticsearch:9200/' varnishstatbeat.yml \
	&& /go/bin/go build .

EXPOSE 8080

CMD /docker-entrypoint.sh
