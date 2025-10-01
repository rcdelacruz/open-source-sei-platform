# Monitoring and Observability

Comprehensive monitoring is critical for maintaining the health, performance, and reliability of the SEI Platform. This guide covers setting up monitoring, alerting, and observability tools.

## Overview

The monitoring stack consists of:

- Prometheus for metrics collection and storage
- Grafana for visualization and dashboards
- AlertManager for alert routing and notifications
- Fluent Bit for log collection
- Elasticsearch for log storage
- Kibana for log visualization
- Jaeger for distributed tracing
- Node Exporter for infrastructure metrics
- Kube State Metrics for Kubernetes metrics

## Prometheus Setup

### Installation

Deploy Prometheus using Helm:

```bash
# Add Prometheus Helm repository
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

# Install Prometheus
helm install prometheus prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --create-namespace \
  --set prometheus.prometheusSpec.retention=30d \
  --set prometheus.prometheusSpec.storageSpec.volumeClaimTemplate.spec.resources.requests.storage=100Gi
```

### Configuration

Configure Prometheus scrape targets:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: prometheus-config
  namespace: monitoring
data:
  prometheus.yml: |
    global:
      scrape_interval: 15s
      evaluation_interval: 15s
      external_labels:
        cluster: sei-platform
        environment: production

    alerting:
      alertmanagers:
      - static_configs:
        - targets:
          - alertmanager:9093

    rule_files:
    - /etc/prometheus/rules/*.yml

    scrape_configs:
    - job_name: 'kubernetes-apiservers'
      kubernetes_sd_configs:
      - role: endpoints
      scheme: https
      tls_config:
        ca_file: /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
      bearer_token_file: /var/run/secrets/kubernetes.io/serviceaccount/token

    - job_name: 'kubernetes-nodes'
      kubernetes_sd_configs:
      - role: node
      relabel_configs:
      - action: labelmap
        regex: __meta_kubernetes_node_label_(.+)

    - job_name: 'kubernetes-pods'
      kubernetes_sd_configs:
      - role: pod
        namespaces:
          names:
          - sei-platform
      relabel_configs:
      - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_scrape]
        action: keep
        regex: true
      - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_path]
        action: replace
        target_label: __metrics_path__
        regex: (.+)
      - source_labels: [__address__, __meta_kubernetes_pod_annotation_prometheus_io_port]
        action: replace
        regex: ([^:]+)(?::\d+)?;(\d+)
        replacement: $1:$2
        target_label: __address__

    - job_name: 'timescaledb'
      static_configs:
      - targets:
        - timescaledb-exporter:9187
        labels:
          service: timescaledb

    - job_name: 'kafka'
      static_configs:
      - targets:
        - kafka-exporter:9308
        labels:
          service: kafka

    - job_name: 'redis'
      static_configs:
      - targets:
        - redis-exporter:9121
        labels:
          service: redis
```

### ServiceMonitor for Applications

Configure automatic scraping for application metrics:

```yaml
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: api-service-monitor
  namespace: sei-platform
spec:
  selector:
    matchLabels:
      app: api-service
  endpoints:
  - port: metrics
    interval: 30s
    path: /metrics
    scheme: http
---
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: data-collector-monitor
  namespace: sei-platform
spec:
  selector:
    matchLabels:
      component: data-collector
  endpoints:
  - port: metrics
    interval: 60s
```

## Grafana Setup

### Installation

Grafana is included with kube-prometheus-stack, or install separately:

```bash
helm install grafana grafana/grafana \
  --namespace monitoring \
  --set persistence.enabled=true \
  --set persistence.size=10Gi \
  --set adminPassword=admin123
```

### Access Grafana

```bash
# Port forward to access Grafana
kubectl port-forward -n monitoring svc/grafana 3000:80

# Get admin password
kubectl get secret -n monitoring grafana -o jsonpath="{.data.admin-password}" | base64 --decode
```

### Data Source Configuration

Add Prometheus as data source:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: grafana-datasources
  namespace: monitoring
data:
  prometheus.yaml: |
    apiVersion: 1
    datasources:
    - name: Prometheus
      type: prometheus
      access: proxy
      url: http://prometheus:9090
      isDefault: true
      editable: false
```

### Dashboards

Import pre-built dashboards:

```bash
# Kubernetes cluster monitoring
kubectl apply -f k8s/monitoring/grafana-dashboards/kubernetes-cluster.json

# API service dashboard
kubectl apply -f k8s/monitoring/grafana-dashboards/api-service.json

# Database performance dashboard
kubectl apply -f k8s/monitoring/grafana-dashboards/timescaledb.json

# Kafka metrics dashboard
kubectl apply -f k8s/monitoring/grafana-dashboards/kafka.json
```

Key dashboard panels:

- Request rate and latency
- Error rate by endpoint
- Database query performance
- Cache hit/miss ratio
- Queue depth and lag
- Resource utilization
- Pod status and health

## Alert Configuration

### AlertManager Setup

Configure AlertManager for alert routing:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: alertmanager-config
  namespace: monitoring
data:
  alertmanager.yml: |
    global:
      resolve_timeout: 5m
      slack_api_url: 'https://hooks.slack.com/services/YOUR/SLACK/WEBHOOK'

    route:
      group_by: ['alertname', 'cluster', 'service']
      group_wait: 10s
      group_interval: 10s
      repeat_interval: 12h
      receiver: 'default'
      routes:
      - match:
          severity: critical
        receiver: 'pagerduty'
        continue: true
      - match:
          severity: warning
        receiver: 'slack'

    receivers:
    - name: 'default'
      slack_configs:
      - channel: '#sei-platform-alerts'
        title: 'Alert: {{ .GroupLabels.alertname }}'
        text: '{{ range .Alerts }}{{ .Annotations.description }}{{ end }}'

    - name: 'slack'
      slack_configs:
      - channel: '#sei-platform-warnings'
        title: 'Warning: {{ .GroupLabels.alertname }}'
        text: '{{ range .Alerts }}{{ .Annotations.description }}{{ end }}'
        send_resolved: true

    - name: 'pagerduty'
      pagerduty_configs:
      - service_key: 'YOUR_PAGERDUTY_KEY'
        description: '{{ .GroupLabels.alertname }}: {{ .CommonAnnotations.summary }}'

    inhibit_rules:
    - source_match:
        severity: 'critical'
      target_match:
        severity: 'warning'
      equal: ['alertname', 'cluster', 'service']
```

### Alert Rules

Critical platform alerts:

```yaml
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  name: sei-platform-alerts
  namespace: monitoring
spec:
  groups:
  - name: api_service
    interval: 30s
    rules:
    - alert: APIHighErrorRate
      expr: |
        sum(rate(http_requests_total{job="api-service",status=~"5.."}[5m]))
        /
        sum(rate(http_requests_total{job="api-service"}[5m]))
        > 0.05
      for: 5m
      labels:
        severity: critical
        service: api-service
      annotations:
        summary: API error rate is above 5%
        description: Error rate is {{ $value | humanizePercentage }}

    - alert: APIHighLatency
      expr: |
        histogram_quantile(0.95,
          sum(rate(http_request_duration_seconds_bucket{job="api-service"}[5m])) by (le)
        ) > 1
      for: 10m
      labels:
        severity: warning
        service: api-service
      annotations:
        summary: API p95 latency is above 1 second
        description: p95 latency is {{ $value }}s

    - alert: APIServiceDown
      expr: up{job="api-service"} == 0
      for: 1m
      labels:
        severity: critical
        service: api-service
      annotations:
        summary: API service is down
        description: API service has been down for more than 1 minute

  - name: database
    interval: 30s
    rules:
    - alert: DatabaseConnectionPoolHigh
      expr: |
        pg_stat_database_numbackends{datname="sei_platform"}
        /
        pg_settings_max_connections
        > 0.8
      for: 5m
      labels:
        severity: warning
        service: timescaledb
      annotations:
        summary: Database connection pool usage is high
        description: Connection pool at {{ $value | humanizePercentage }} capacity

    - alert: DatabaseSlowQueries
      expr: |
        rate(pg_stat_database_blk_read_time{datname="sei_platform"}[5m])
        > 100
      for: 10m
      labels:
        severity: warning
        service: timescaledb
      annotations:
        summary: Database experiencing slow queries
        description: Average query time increased

    - alert: DatabaseReplicationLag
      expr: |
        pg_replication_lag
        > 60
      for: 5m
      labels:
        severity: critical
        service: timescaledb
      annotations:
        summary: Database replication lag is high
        description: Replication lag is {{ $value }} seconds

  - name: kafka
    interval: 30s
    rules:
    - alert: KafkaConsumerLag
      expr: |
        kafka_consumergroup_lag
        > 10000
      for: 10m
      labels:
        severity: warning
        service: kafka
      annotations:
        summary: Kafka consumer lag is high
        description: Consumer lag is {{ $value }} messages

    - alert: KafkaOfflinePartitions
      expr: kafka_server_replicamanager_offlinereplicacount > 0
      for: 5m
      labels:
        severity: critical
        service: kafka
      annotations:
        summary: Kafka has offline partitions
        description: {{ $value }} offline partitions detected

  - name: resources
    interval: 30s
    rules:
    - alert: PodCPUThrottling
      expr: |
        rate(container_cpu_cfs_throttled_seconds_total{namespace="sei-platform"}[5m])
        > 0.5
      for: 10m
      labels:
        severity: warning
      annotations:
        summary: Pod experiencing CPU throttling
        description: Pod {{ $labels.pod }} is being CPU throttled

    - alert: PodMemoryPressure
      expr: |
        container_memory_working_set_bytes{namespace="sei-platform"}
        /
        container_spec_memory_limit_bytes{namespace="sei-platform"}
        > 0.9
      for: 5m
      labels:
        severity: warning
      annotations:
        summary: Pod under memory pressure
        description: Pod {{ $labels.pod }} using {{ $value | humanizePercentage }} of memory

    - alert: PersistentVolumeNearFull
      expr: |
        kubelet_volume_stats_available_bytes{namespace="sei-platform"}
        /
        kubelet_volume_stats_capacity_bytes{namespace="sei-platform"}
        < 0.1
      for: 10m
      labels:
        severity: critical
      annotations:
        summary: Persistent volume nearly full
        description: Volume {{ $labels.persistentvolumeclaim }} has less than 10% free space
```

## Logging

### Fluent Bit Deployment

Deploy Fluent Bit for log collection:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: fluent-bit-config
  namespace: monitoring
data:
  fluent-bit.conf: |
    [SERVICE]
        Flush         5
        Log_Level     info
        Daemon        off
        Parsers_File  parsers.conf

    [INPUT]
        Name              tail
        Path              /var/log/containers/*sei-platform*.log
        Parser            docker
        Tag               kube.*
        Refresh_Interval  5
        Mem_Buf_Limit     50MB
        Skip_Long_Lines   On

    [FILTER]
        Name                kubernetes
        Match               kube.*
        Kube_URL            https://kubernetes.default.svc:443
        Kube_CA_File        /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
        Kube_Token_File     /var/run/secrets/kubernetes.io/serviceaccount/token
        Merge_Log           On
        K8S-Logging.Parser  On
        K8S-Logging.Exclude On

    [OUTPUT]
        Name            es
        Match           *
        Host            elasticsearch
        Port            9200
        Index           sei-platform
        Type            _doc
        Logstash_Format On
        Retry_Limit     False

  parsers.conf: |
    [PARSER]
        Name        docker
        Format      json
        Time_Key    time
        Time_Format %Y-%m-%dT%H:%M:%S.%L
        Time_Keep   On
---
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: fluent-bit
  namespace: monitoring
spec:
  selector:
    matchLabels:
      app: fluent-bit
  template:
    metadata:
      labels:
        app: fluent-bit
    spec:
      containers:
      - name: fluent-bit
        image: fluent/fluent-bit:2.0
        volumeMounts:
        - name: varlog
          mountPath: /var/log
        - name: varlibdockercontainers
          mountPath: /var/lib/docker/containers
          readOnly: true
        - name: fluent-bit-config
          mountPath: /fluent-bit/etc/
      volumes:
      - name: varlog
        hostPath:
          path: /var/log
      - name: varlibdockercontainers
        hostPath:
          path: /var/lib/docker/containers
      - name: fluent-bit-config
        configMap:
          name: fluent-bit-config
```

### Elasticsearch and Kibana

Deploy Elasticsearch for log storage:

```bash
helm install elasticsearch elastic/elasticsearch \
  --namespace monitoring \
  --set replicas=3 \
  --set minimumMasterNodes=2 \
  --set persistence.enabled=true \
  --set volumeClaimTemplate.resources.requests.storage=100Gi

helm install kibana elastic/kibana \
  --namespace monitoring \
  --set elasticsearch.hosts=http://elasticsearch-master:9200
```

Access Kibana:

```bash
kubectl port-forward -n monitoring svc/kibana 5601:5601
```

## Distributed Tracing

### Jaeger Setup

Deploy Jaeger for distributed tracing:

```bash
kubectl apply -f - <<EOF
apiVersion: jaegertracing.io/v1
kind: Jaeger
metadata:
  name: sei-platform-jaeger
  namespace: monitoring
spec:
  strategy: production
  storage:
    type: elasticsearch
    options:
      es:
        server-urls: http://elasticsearch:9200
        index-prefix: jaeger
  ingress:
    enabled: true
EOF
```

### Application Integration

Add tracing to applications:

```python
from jaeger_client import Config
from flask import Flask
from flask_opentracing import FlaskTracing

app = Flask(__name__)

config = Config(
    config={
        'sampler': {'type': 'const', 'param': 1},
        'logging': True,
        'reporter_batch_size': 1,
    },
    service_name='api-service',
    validate=True,
)

tracer = config.initialize_tracer()
tracing = FlaskTracing(tracer, True, app)
```

## Custom Metrics

### Application Metrics

Expose custom metrics from applications:

```python
from prometheus_client import Counter, Histogram, Gauge, generate_latest
from flask import Response

# Define metrics
requests_total = Counter(
    'api_requests_total',
    'Total API requests',
    ['method', 'endpoint', 'status']
)

request_duration = Histogram(
    'api_request_duration_seconds',
    'API request duration',
    ['method', 'endpoint']
)

active_users = Gauge(
    'api_active_users',
    'Number of active users'
)

# Metrics endpoint
@app.route('/metrics')
def metrics():
    return Response(generate_latest(), mimetype='text/plain')

# Instrument endpoints
@app.route('/api/data')
@request_duration.labels(method='GET', endpoint='/api/data').time()
def get_data():
    requests_total.labels(method='GET', endpoint='/api/data', status=200).inc()
    return jsonify({'data': 'value'})
```

## Monitoring Best Practices

### Key Metrics to Monitor

**Application Metrics**:

- Request rate
- Error rate
- Response time (p50, p95, p99)
- Saturation (queue depth, connection pool usage)

**Infrastructure Metrics**:

- CPU utilization
- Memory usage
- Disk I/O
- Network throughput
- Pod restarts

**Business Metrics**:

- Active users
- Data processing rate
- API usage by customer
- Feature adoption

### Dashboard Organization

Create role-specific dashboards:

**Operations Dashboard**:

- System health overview
- Resource utilization
- Error rates
- Alert status

**Development Dashboard**:

- Application performance
- API latency breakdown
- Database query performance
- Cache hit rates

**Executive Dashboard**:

- System uptime
- User growth
- Cost metrics
- SLA compliance

## Health Checks

### Liveness and Readiness Probes

Implement health check endpoints:

```python
from flask import Flask, jsonify
import psycopg2

app = Flask(__name__)

@app.route('/health')
def liveness():
    """Liveness probe - is the application running?"""
    return jsonify({'status': 'healthy'}), 200

@app.route('/ready')
def readiness():
    """Readiness probe - can the application serve traffic?"""
    checks = {
        'database': check_database(),
        'redis': check_redis(),
        'kafka': check_kafka()
    }

    if all(checks.values()):
        return jsonify({'status': 'ready', 'checks': checks}), 200
    else:
        return jsonify({'status': 'not ready', 'checks': checks}), 503

def check_database():
    try:
        conn = psycopg2.connect(DATABASE_URL)
        conn.close()
        return True
    except:
        return False
```

## Troubleshooting

### High CPU Usage

Check for:

- Inefficient queries
- Excessive logging
- Resource limits too low
- Background jobs

```bash
kubectl top pods -n sei-platform
kubectl describe pod <pod-name> -n sei-platform
```

### Memory Leaks

Monitor memory growth over time:

```promql
rate(container_memory_working_set_bytes{namespace="sei-platform"}[1h])
```

Investigate with heap profiling:

```bash
kubectl exec -it <pod-name> -- python -m memory_profiler script.py
```

### Slow Database Queries

Identify slow queries:

```sql
SELECT query, mean_exec_time, calls
FROM pg_stat_statements
ORDER BY mean_exec_time DESC
LIMIT 10;
```

## Additional Resources

- [Prometheus Documentation](https://prometheus.io/docs/)
- [Grafana Dashboards](https://grafana.com/grafana/dashboards/)
- [Production Deployment Guide](production.md)
- [Kubernetes Deployment](kubernetes.md)
