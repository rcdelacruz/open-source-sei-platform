# Production Deployment

This guide covers best practices and procedures for deploying the SEI Platform to production environments, ensuring security, reliability, and scalability.

## Production Readiness Checklist

Before deploying to production, complete the following:

### Infrastructure

- [ ] Kubernetes cluster with at least 3 nodes
- [ ] Load balancer configured for external access
- [ ] SSL/TLS certificates from trusted CA
- [ ] DNS records configured
- [ ] Firewall rules and security groups defined
- [ ] Persistent storage with replication
- [ ] Backup solution in place
- [ ] Disaster recovery plan documented

### Security

- [ ] Secrets stored in secure vault (not environment files)
- [ ] RBAC policies configured and tested
- [ ] Network policies enforced
- [ ] API authentication enabled
- [ ] Rate limiting configured
- [ ] Security scanning passed
- [ ] Vulnerability assessment completed
- [ ] Penetration testing performed

### Monitoring

- [ ] Prometheus and Grafana deployed
- [ ] Alert rules configured
- [ ] Logging aggregation set up
- [ ] Uptime monitoring enabled
- [ ] Performance metrics collected
- [ ] Error tracking configured
- [ ] On-call rotation established

### Data

- [ ] Database migrations tested
- [ ] Backup procedures automated
- [ ] Restore procedures tested
- [ ] Data retention policies defined
- [ ] GDPR compliance verified
- [ ] Data encryption at rest enabled
- [ ] Data encryption in transit enabled

### Application

- [ ] Health checks implemented
- [ ] Graceful shutdown configured
- [ ] Resource limits defined
- [ ] Auto-scaling policies set
- [ ] Circuit breakers implemented
- [ ] Retry logic configured
- [ ] Caching strategy deployed
- [ ] CDN configured for static assets

## Architecture for Production

### High Availability Setup

Deploy services across multiple availability zones:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api-service
spec:
  replicas: 6
  template:
    spec:
      affinity:
        podAntiAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
          - labelSelector:
              matchExpressions:
              - key: app
                operator: In
                values:
                - api-service
            topologyKey: topology.kubernetes.io/zone
```

### Database Replication

Configure TimescaleDB for high availability:

- Primary-standby replication
- Automated failover with Patroni
- Point-in-time recovery enabled
- Continuous WAL archiving

### Load Balancing

Use external load balancer with:

- Health check endpoints
- Session affinity if needed
- SSL termination
- DDoS protection

## Secrets Management

### Using HashiCorp Vault

Store secrets in Vault instead of Kubernetes Secrets:

```bash
# Install Vault
helm install vault hashicorp/vault \
  --set server.ha.enabled=true \
  --set server.ha.replicas=3

# Configure Vault auth
vault auth enable kubernetes

# Store secrets
vault kv put secret/sei-platform/database \
  username=sei_user \
  password=secure_password

# Create policy
vault policy write sei-platform-policy - <<EOF
path "secret/data/sei-platform/*" {
  capabilities = ["read"]
}
EOF
```

Configure pods to use Vault:

```yaml
apiVersion: v1
kind: Pod
metadata:
  annotations:
    vault.hashicorp.com/agent-inject: "true"
    vault.hashicorp.com/role: "sei-platform"
    vault.hashicorp.com/agent-inject-secret-database: "secret/data/sei-platform/database"
spec:
  serviceAccountName: sei-platform-sa
```

### AWS Secrets Manager

Alternative using AWS Secrets Manager:

```bash
# Store secret
aws secretsmanager create-secret \
  --name sei-platform/database \
  --secret-string '{"username":"sei_user","password":"secure_pass"}'

# Grant IAM permissions
aws iam attach-role-policy \
  --role-name sei-platform-role \
  --policy-arn arn:aws:iam::aws:policy/SecretsManagerReadWrite
```

## SSL/TLS Configuration

### Certificate Management

Use cert-manager for automatic certificate provisioning:

```bash
# Install cert-manager
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.12.0/cert-manager.yaml

# Create ClusterIssuer
kubectl apply -f - <<EOF
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: admin@example.com
    privateKeySecretRef:
      name: letsencrypt-prod-key
    solvers:
    - http01:
        ingress:
          class: nginx
EOF
```

### Ingress with SSL

Configure Ingress with automatic SSL:

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: sei-platform-ingress
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-prod
    nginx.ingress.kubernetes.io/force-ssl-redirect: "true"
spec:
  tls:
  - hosts:
    - sei.example.com
    - api.sei.example.com
    secretName: sei-platform-tls
  rules:
  - host: sei.example.com
    http:
      paths:
      - path: /
        backend:
          service:
            name: frontend-service
            port:
              number: 3000
```

## Database Configuration

### Production Settings

Configure TimescaleDB for production workloads:

```sql
-- Connection pooling
ALTER SYSTEM SET max_connections = 200;
ALTER SYSTEM SET shared_buffers = '4GB';
ALTER SYSTEM SET effective_cache_size = '12GB';
ALTER SYSTEM SET maintenance_work_mem = '1GB';
ALTER SYSTEM SET checkpoint_completion_target = 0.9;
ALTER SYSTEM SET wal_buffers = '16MB';
ALTER SYSTEM SET default_statistics_target = 100;
ALTER SYSTEM SET random_page_cost = 1.1;
ALTER SYSTEM SET effective_io_concurrency = 200;
ALTER SYSTEM SET work_mem = '20MB';
ALTER SYSTEM SET min_wal_size = '2GB';
ALTER SYSTEM SET max_wal_size = '8GB';
```

### Connection Pooling

Use PgBouncer for connection pooling:

```ini
[databases]
sei_platform = host=timescaledb port=5432 dbname=sei_platform

[pgbouncer]
listen_addr = 0.0.0.0
listen_port = 6432
auth_type = md5
auth_file = /etc/pgbouncer/userlist.txt
pool_mode = transaction
max_client_conn = 1000
default_pool_size = 25
max_db_connections = 100
server_idle_timeout = 600
```

Deploy PgBouncer:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: pgbouncer
spec:
  replicas: 3
  template:
    spec:
      containers:
      - name: pgbouncer
        image: edoburu/pgbouncer:latest
        ports:
        - containerPort: 6432
        volumeMounts:
        - name: pgbouncer-config
          mountPath: /etc/pgbouncer
```

## Performance Optimization

### Caching Strategy

Implement multi-layer caching:

**Redis Configuration**:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: redis-config
data:
  redis.conf: |
    maxmemory 4gb
    maxmemory-policy allkeys-lru
    save 900 1
    save 300 10
    save 60 10000
    appendonly yes
    appendfsync everysec
```

**Application Caching**:

```python
from redis import Redis
from functools import wraps

redis_client = Redis(host='redis', port=6379, decode_responses=True)

def cache_result(ttl=3600):
    def decorator(func):
        @wraps(func)
        def wrapper(*args, **kwargs):
            cache_key = f"{func.__name__}:{args}:{kwargs}"
            cached = redis_client.get(cache_key)
            if cached:
                return json.loads(cached)
            result = func(*args, **kwargs)
            redis_client.setex(cache_key, ttl, json.dumps(result))
            return result
        return wrapper
    return decorator
```

### CDN Integration

Configure CDN for static assets:

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: frontend-cdn
  annotations:
    nginx.ingress.kubernetes.io/configuration-snippet: |
      add_header Cache-Control "public, max-age=31536000, immutable";
      add_header X-CDN-Cache $upstream_cache_status;
spec:
  rules:
  - host: cdn.sei.example.com
    http:
      paths:
      - path: /static
        backend:
          service:
            name: frontend-service
            port:
              number: 3000
```

## Monitoring and Alerting

### Prometheus Configuration

Production Prometheus setup:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: prometheus-config
data:
  prometheus.yml: |
    global:
      scrape_interval: 15s
      evaluation_interval: 15s
      external_labels:
        cluster: production
        environment: prod

    alerting:
      alertmanagers:
      - static_configs:
        - targets:
          - alertmanager:9093

    rule_files:
    - /etc/prometheus/rules/*.yml

    scrape_configs:
    - job_name: kubernetes-pods
      kubernetes_sd_configs:
      - role: pod
        namespaces:
          names:
          - sei-platform
```

### Alert Rules

Critical alert rules:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: prometheus-rules
data:
  alerts.yml: |
    groups:
    - name: sei_platform_alerts
      interval: 30s
      rules:
      - alert: HighErrorRate
        expr: rate(http_requests_total{status=~"5.."}[5m]) > 0.05
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: High error rate detected
          description: Error rate is {{ $value }} errors/sec

      - alert: HighMemoryUsage
        expr: container_memory_usage_bytes / container_spec_memory_limit_bytes > 0.9
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: High memory usage
          description: Memory usage is {{ $value | humanizePercentage }}

      - alert: DatabaseConnectionPoolExhausted
        expr: pg_stat_database_numbackends / pg_settings_max_connections > 0.8
        for: 2m
        labels:
          severity: critical
        annotations:
          summary: Database connection pool near exhaustion

      - alert: APILatencyHigh
        expr: histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m])) > 1
        for: 10m
        labels:
          severity: warning
        annotations:
          summary: API latency is high
```

### Grafana Dashboards

Import production dashboards:

```bash
# Import Kubernetes cluster dashboard
kubectl apply -f k8s/monitoring/grafana-dashboards/kubernetes-cluster.json

# Import application dashboard
kubectl apply -f k8s/monitoring/grafana-dashboards/sei-platform.json
```

## Logging

### Centralized Logging

Deploy ELK Stack for log aggregation:

```bash
# Deploy Elasticsearch
kubectl apply -f k8s/logging/elasticsearch-statefulset.yaml

# Deploy Logstash
kubectl apply -f k8s/logging/logstash-deployment.yaml

# Deploy Kibana
kubectl apply -f k8s/logging/kibana-deployment.yaml

# Deploy Filebeat as DaemonSet
kubectl apply -f k8s/logging/filebeat-daemonset.yaml
```

### Log Retention

Configure log retention policies:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: elasticsearch-config
data:
  elasticsearch.yml: |
    indices.lifecycle.poll_interval: 1m

    # Delete logs older than 30 days
    PUT _ilm/policy/sei_platform_logs
    {
      "policy": {
        "phases": {
          "hot": {
            "actions": {
              "rollover": {
                "max_age": "1d",
                "max_size": "50gb"
              }
            }
          },
          "delete": {
            "min_age": "30d",
            "actions": {
              "delete": {}
            }
          }
        }
      }
    }
```

## Backup and Disaster Recovery

### Automated Backups

Daily automated backups:

```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: database-backup
spec:
  schedule: "0 2 * * *"
  successfulJobsHistoryLimit: 7
  failedJobsHistoryLimit: 3
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: backup
            image: sei-platform/backup-tool:latest
            env:
            - name: BACKUP_DESTINATION
              value: s3://sei-platform-backups/
            - name: RETENTION_DAYS
              value: "30"
            - name: ENCRYPTION_KEY
              valueFrom:
                secretKeyRef:
                  name: backup-encryption
                  key: key
            command:
            - /bin/bash
            - -c
            - |
              TIMESTAMP=$(date +%Y%m%d_%H%M%S)
              pg_dump -h timescaledb -U sei_user sei_platform | \
                gzip | \
                openssl enc -aes-256-cbc -salt -pass env:ENCRYPTION_KEY | \
                aws s3 cp - ${BACKUP_DESTINATION}backup_${TIMESTAMP}.sql.gz.enc

              # Remove old backups
              aws s3 ls ${BACKUP_DESTINATION} | \
                awk '{print $4}' | \
                head -n -${RETENTION_DAYS} | \
                xargs -I {} aws s3 rm ${BACKUP_DESTINATION}{}
          restartPolicy: OnFailure
```

### Disaster Recovery Plan

**Recovery Time Objective (RTO)**: 1 hour
**Recovery Point Objective (RPO)**: 24 hours

Steps for disaster recovery:

1. **Provision new infrastructure**

    ```bash
    terraform apply -var-file=prod.tfvars
    ```

2. **Restore cluster state from Velero**

    ```bash
    velero restore create --from-backup sei-platform-daily-20250101
    ```

3. **Restore database from backup**

    ```bash
    aws s3 cp s3://sei-platform-backups/latest.sql.gz.enc - | \
      openssl enc -d -aes-256-cbc -pass env:ENCRYPTION_KEY | \
      gunzip | \
      psql -h new-timescaledb -U sei_user sei_platform
    ```

4. **Verify services**

    ```bash
    kubectl get pods -n sei-platform
    kubectl run smoke-test --rm -it --image=sei-platform/smoke-tests:latest
    ```

5. **Update DNS to point to new cluster**

## Deployment Process

### Blue-Green Deployment

Zero-downtime deployment strategy:

```bash
# Deploy green environment
kubectl apply -f k8s/production/green/

# Run smoke tests
./scripts/smoke-test.sh green

# Switch traffic to green
kubectl patch service api-service -p '{"spec":{"selector":{"version":"green"}}}'

# Monitor for issues
kubectl logs -f -l version=green

# If successful, remove blue
kubectl delete -f k8s/production/blue/

# If issues, rollback
kubectl patch service api-service -p '{"spec":{"selector":{"version":"blue"}}}'
```

### Canary Deployment

Gradual rollout with traffic splitting:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: api-service
spec:
  selector:
    app: api-service
  # 90% traffic to stable, 10% to canary
  sessionAffinity: ClientIP
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api-service-stable
spec:
  replicas: 9
  template:
    metadata:
      labels:
        app: api-service
        version: stable
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api-service-canary
spec:
  replicas: 1
  template:
    metadata:
      labels:
        app: api-service
        version: canary
```

## Security Hardening

### Network Policies

Restrict network access:

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-all
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-api-to-db
spec:
  podSelector:
    matchLabels:
      app: timescaledb
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: api-service
    ports:
    - protocol: TCP
      port: 5432
```

### Pod Security Standards

Enforce pod security:

```yaml
apiVersion: policy/v1beta1
kind: PodSecurityPolicy
metadata:
  name: restricted
spec:
  privileged: false
  allowPrivilegeEscalation: false
  requiredDropCapabilities:
  - ALL
  volumes:
  - 'configMap'
  - 'secret'
  - 'persistentVolumeClaim'
  runAsUser:
    rule: 'MustRunAsNonRoot'
  seLinux:
    rule: 'RunAsAny'
  fsGroup:
    rule: 'RunAsAny'
  readOnlyRootFilesystem: true
```

## Compliance

### GDPR Compliance

Implement data protection measures:

- Data encryption at rest and in transit
- Right to erasure implementation
- Data portability features
- Privacy by design
- Regular security audits
- Data processing agreements

### Audit Logging

Enable comprehensive audit logging:

```yaml
apiVersion: audit.k8s.io/v1
kind: Policy
rules:
- level: RequestResponse
  resources:
  - group: ""
    resources: ["secrets", "configmaps"]
- level: Metadata
  resources:
  - group: ""
    resources: ["pods", "services"]
```

## Performance Benchmarks

Target performance metrics for production:

- API response time: p50 < 100ms, p95 < 500ms, p99 < 1s
- Database query time: p95 < 100ms
- Page load time: < 2 seconds
- Time to first byte: < 500ms
- Throughput: 10,000 requests/second
- Uptime: 99.9%
- Error rate: < 0.1%

## Scaling Guidelines

### Vertical Scaling

Increase resources for individual services:

```bash
kubectl set resources deployment api-service \
  --requests=cpu=1000m,memory=2Gi \
  --limits=cpu=2000m,memory=4Gi
```

### Horizontal Scaling

Scale based on metrics:

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: api-service-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: api-service
  minReplicas: 10
  maxReplicas: 50
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
  - type: Pods
    pods:
      metric:
        name: http_requests_per_second
      target:
        type: AverageValue
        averageValue: "1000"
  behavior:
    scaleDown:
      stabilizationWindowSeconds: 300
      policies:
      - type: Percent
        value: 50
        periodSeconds: 60
    scaleUp:
      stabilizationWindowSeconds: 0
      policies:
      - type: Percent
        value: 100
        periodSeconds: 30
      - type: Pods
        value: 4
        periodSeconds: 30
```

## Cost Optimization

- Use spot instances for non-critical workloads
- Implement auto-scaling to match demand
- Use reserved instances for baseline capacity
- Optimize container images to reduce size
- Implement resource quotas and limits
- Monitor and eliminate unused resources
- Use multi-tenancy to share infrastructure
- Leverage CDN to reduce bandwidth costs

## Additional Resources

- [Kubernetes Production Best Practices](https://kubernetes.io/docs/setup/best-practices/)
- [Docker Compose Deployment](docker-compose.md)
- [Kubernetes Deployment](kubernetes.md)
- [Monitoring Setup](monitoring.md)
