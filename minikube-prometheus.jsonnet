local kp = 
    (import 'kube-prometheus/kube-prometheus.libsonnet') + 
    (import 'kube-prometheus/kube-prometheus-kubeadm.libsonnet') +
    (import 'kube-prometheus/kube-prometheus-node-ports.libsonnet') +
    {
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
{ ['kube-state-metrics-' + name]: kp.kubeStateMetrics[name] for name in std.objectFields(kp.kubeStateMetrics) } +
{ ['alertmanager-' + name]: kp.alertmanager[name] for name in std.objectFields(kp.alertmanager) } +
{ ['prometheus-' + name]: kp.prometheus[name] for name in std.objectFields(kp.prometheus) } +
{ ['grafana-' + name]: kp.grafana[name] for name in std.objectFields(kp.grafana) }