[![CircleCI](https://circleci.com/gh/gavinzhou/prometheus-kubernetes.svg?style=svg)](https://circleci.com/gh/gavinzhou/prometheus-kubernetes)
# prometheus-kubernetes

> Base from [contrib/kube-prometheus/](https://github.com/coreos/kube-prometheus)

This repository collects Kubernetes manifests, [Grafana](http://grafana.com/) dashboards, and [Prometheus rules](https://prometheus.io/docs/prometheus/latest/configuration/recording_rules/) combined with documentation and scripts to provide easy to operate end-to-end Kubernetes cluster monitoring with [Prometheus](https://prometheus.io/) using the Prometheus Operator.

The content of this project is written in [jsonnet](http://jsonnet.org/). This project could both be described as a package as well as a library.

Components included in this package:

* The [Prometheus Operator](https://github.com/coreos/prometheus-operator)
* Highly available [Prometheus](https://prometheus.io/)
* Highly available [Alertmanager](https://github.com/prometheus/alertmanager)
* [Prometheus node-exporter](https://github.com/prometheus/node_exporter)
* [kube-state-metrics](https://github.com/kubernetes/kube-state-metrics)
* [Grafana](https://grafana.com/)

This stack is meant for cluster monitoring, so it is pre-configured to collect metrics from all Kubernetes components. In addition to that it delivers a default set of dashboards and alerting rules. Many of the useful dashboards and alerts come from the [kubernetes-mixin project](https://github.com/kubernetes-monitoring/kubernetes-mixin), similar to this project it provides composable jsonnet as a library for users to customize to their needs.

## Quickstart

Although this project is intended to be used as a library, a compiled version of the Kubernetes manifests generated with this library is checked into this repository in order to try the content out quickly.

Simply create the stack:

```bash
kubectl apply -f manifests
```

## Usage

The content of this project consists of a set of [jsonnet](http://jsonnet.org/) files making up a library to be consumed.

Install this library in your own project with [jsonnet-bundler](https://github.com/jsonnet-bundler/jsonnet-bundler#install):

```bash
$ git clone https://github.com/gavinzhou/prometheus-kubernetes.git
$ jb install
```

> `jb` can be installed with `go get github.com/jsonnet-bundler/jsonnet-bundler/cmd/jb`

You may wish to not use ksonnet and simply render the generated manifests to files on disk, this can be done with:

[embedmd]:# (kube-prometheus.jsonnet)
```jsonnet
local kp = (import 'kube-prometheus/kube-prometheus.libsonnet') + {
    _config+:: {
        namespace: 'monitor',

        prometheus+:: {
            replicas: 1,
        },

        alertmanager+:: {
            replicas: 1,
        },

        grafana+:: {
            config: {
                sections: {
                    "auth.anonymous": {enabled: true},
                },
            },
        },
    },
};

{ ['00namespace-' + name]: kp.kubePrometheus[name] for name in std.objectFields(kp.kubePrometheus) } +
{ ['0prometheus-operator-' + name]: kp.prometheusOperator[name] for name in std.objectFields(kp.prometheusOperator) } +
{ ['node-exporter-' + name]: kp.nodeExporter[name] for name in std.objectFields(kp.nodeExporter) } +
{ ['kube-state-metrics-' + name]: kp.kubeStateMetrics[name] for name in std.objectFields(kp.kubeStateMetrics) } +
{ ['alertmanager-' + name]: kp.alertmanager[name] for name in std.objectFields(kp.alertmanager) } +
{ ['prometheus-' + name]: kp.prometheus[name] for name in std.objectFields(kp.prometheus) } +
{ ['grafana-' + name]: kp.grafana[name] for name in std.objectFields(kp.grafana) }
```

This renders all manifests in a json structure of `{filename: manifest-content}`.

### Compiling

To compile the above and get each manifest in a separate file on disk use the following script:

[embedmd]:# (build.sh)
```sh
#!/usr/bin/env bash
set -e
set -x
# only exit with zero if all commands of the pipeline exit successfully
set -o pipefail

# Make sure to start with a clean 'manifests' dir
rm -rf manifests
mkdir manifests

                                               # optional, but we would like to generate yaml, not json
jsonnet -J vendor -m manifests "${1-kube-prometheus.jsonnet}" | xargs -I{} sh -c 'cat {} | gojsontoyaml > {}.yaml; rm -f {}' -- {}

```

> Note you need `jsonnet` and `gojsonyaml` (`go get github.com/brancz/gojsontoyaml`) installed. If you just want json output, not yaml, then you can skip the pipe and everything afterwards.

This script reads each key of the generated json and uses that as the file name, and writes the value of that key to that file.

## Install Prometheus Kubernetes

```sh
./build.sh ## need some time
kubectl apply -f manifests
```

## Check running Prometheus pod

```sh
kubectl get po -n monitor -w
```

The grafana definition is located in a different project [gavinzhou/kubernetes-grafana](https://github.com/gavinzhou/kubernetes-grafana) ,it fixed some bugs.

## Show grafana with port-forward

```sh
kubectl port-forward $(kubectl get pod -l app=grafana -n monitor -o 'jsonpath={.items[0].metadata.name}') -n monitor 3000
```

## Customization

Get more Readme from [prometheus-operator](https://github.com/coreos/prometheus-operator)
