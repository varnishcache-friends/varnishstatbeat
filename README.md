# Varnishstatbeat

Varnishstatbeat is an Elastic [beat](https://www.elastic.co/products/beats)
that collects Stats data from a Varnish Shared Memory file and ships
it to Elasticsearch.

Varnishstatbeat uses [vago](https://github.com/phenomenes/vago).

### Requirements

* [Go](https://golang.org/dl/) >= 1.7
* pkg-config
* [varnish-dev](http://www.varnish-cache.org/releases/) >= 4.1

You will also need to set `PKG_CONFIG_PATH` to the directory where
`varnishapi.pc` is located before running `go get`. For example:

```
export PKG_CONFIG_PATH=/usr/lib/pkgconfig
```

### Build

```
go get github.com/phenomenes/varnishstatbeat
cd $GOPATH/src/github.com/phenomenes/varnishstatbeat
go build .
```

### Run

Install and run [Elasticsearch](https://github.com/elastic/elasticsearch).

Run `varnishstatbeat` with debugging output enabled:

```
./varnishstatbeat -c varnishstatbeat.yml -e -d "*"
```

Additionally you can install [Kibana](https://github.com/elastic/kibana) to
visualize the data.

### Run on Docker

```
docker-compose up --build
```

The above command will create the following containers:

- [Kibana](http://127.0.0.1:5601/status#?_g=())
- Varnishlogbeat / [Varnish](http://127.0.0.1:8080/status)
- [Nginx](http://127.0.0.1/)
- [Elasticsearch](http://127.0.0.1:9200/)
