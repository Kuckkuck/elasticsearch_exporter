# Elasticsearch Exporter

[![Go Report Card](https://goreportcard.com/badge/github.com/Kuckkuck/elasticsearch_exporter)](https://goreportcard.com/report/github.com/Kuckkuck/elasticsearch_exporter)

Prometheus exporter for various metrics about ElasticSearch, written in Go.
Basic Authentication was added to support connections via auth proxies or Elasticsearch plugins like [Elasticsearch rest only](https://readonlyrest.com/).

### Installation

```bash
go get -u github.com/Kuckkuck/elasticsearch_exporter
```

### Configuration

```bash
elasticsearch_exporter --help
```

| Argument              | Description |
| --------              | ----------- |
| es.hostname           | Hostname of an Elasticsearch node, where client http is enabled. Default: localhost.
| es.protocol           | Protocol of an Elasticsearch node, where client http is enabled. Default: http.
| es.port               | Port of an Elasticsearch node, where client http is enabled. Default: 9200.
| es.user               | Username for basic authenticiation of an Elasticsearch node, where client http is enabled.
| es.password           | Password for basic authenticiation of an Elasticsearch node, where client http is enabled.
| es.all                | If true, query stats for all nodes in the cluster, rather than just the node we connect to.
| es.timeout            | Timeout for trying to get stats from Elasticsearch. (ex: 20s) |
| es.ca                 | Path to PEM file that contains trusted CAs for the Elasticsearch connection.
| es.client-private-key | Path to PEM file that contains the private key for client auth when connecting to Elasticsearch.
| es.client-cert        | Path to PEM file that contains the corresponding cert for the private key to connect to Elasticsearch.
| web.listen-address    | Address to listen on for web interface and telemetry. |
| web.telemetry-path    | Path under which to expose metrics. |

__NOTE:__ We support pulling stats for all nodes at once, but in production
this is unlikely to be the way you actually want to run the system. It is much
better to run an exporter on each Elasticsearch node to remove a single point
of failure and improve the connection between operation and reporting.

### Elasticsearch 2.0

Parts of the node stats struct changed for Elasticsearch 2.0. For the moment
we'll attempt to report important values for both.

* `indices.filter_cache` becomes `indices.query_cache`
* `indices.query_cache` becomes `indices.request_cache`
* `process.cpu` lost `user` and `sys` time, so we're now reporting `total`
* Added `process.cpu.max_file_descriptors`

### Original author

This package was originally created and mainted by [Eric Richardson](https://github.com/ewr),
who transferred this repository to us in Jan 2017.
Fork was done to add basic authentication, but this is a breaking change for old command line options from the justwatchcom/elasticsearch_exporter repo.
