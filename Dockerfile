FROM golang:1.9.2-stretch

LABEL maintainer phenomenes

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get install -y \
	apt-transport-https \
	&& echo "deb https://packagecloud.io/varnishcache/varnish51/debian/ stretch main" >> \
	    /etc/apt/sources.list.d/varnish.list \
	&& curl -s -L https://packagecloud.io/varnishcache/varnish51/gpgkey | apt-key add - \
	&& apt-get update && apt-get install -y \
	libjemalloc1 \
	pkg-config \
	varnish \
	varnish-dev \
	&& apt-get clean && rm -rf /var/lib/apt/lists/*

ADD . $GOPATH/src/github.com/phenomenes/varnishstatbeat

WORKDIR $GOPATH/src/github.com/phenomenes/varnishstatbeat

ADD default.vcl /etc/varnish/default.vcl
ADD docker-entrypoint.sh /docker-entrypoint.sh

RUN sed -i 's/localhost:9200/elasticsearch:9200/' \
	$GOPATH/src/github.com/phenomenes/varnishstatbeat/varnishstatbeat.yml \
	&& go build .

EXPOSE 8080

CMD /docker-entrypoint.sh
