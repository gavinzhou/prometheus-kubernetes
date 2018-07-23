# prometheus-kubernetes

```jsonnet
local kp = (import 'kube-prometheus/kube-prometheus.libsonnet') + {
    _config+:: {
        namespace: 'monitor',

        prometheus+:: {
            replicas: 2,
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
            datasources: [{
                name: 'prometheus',
                type: 'prometheus',
                access: 'proxy',
                orgId: 1,
                url: 'http://prometheus-' + $._config.prometheus.name + '.monitor.svc:9090',
                version: 1,
                editable: false,
            }],
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