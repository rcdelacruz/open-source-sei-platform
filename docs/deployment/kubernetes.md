# Kubernetes Deployment

This guide covers deploying the SEI Platform to Kubernetes for production-ready, scalable environments. Kubernetes provides orchestration, auto-scaling, self-healing, and efficient resource management.

## Prerequisites

Before deploying to Kubernetes, ensure you have:

- Kubernetes cluster 1.24 or higher
- kubectl CLI configured to access your cluster
- Helm 3.8 or higher
- At least 16GB of RAM across nodes
- 100GB of available storage
- Load balancer support or Ingress controller

Verify your setup:

```bash
kubectl version --client
kubectl cluster-info
helm version
```

## Architecture Overview

The Kubernetes deployment consists of:

- Namespace isolation for multi-tenancy
- StatefulSets for databases
- Deployments for stateless services
- Services for internal communication
- Ingress for external access
- ConfigMaps for configuration
- Secrets for sensitive data
- PersistentVolumeClaims for data storage
- HorizontalPodAutoscalers for auto-scaling

## Quick Start

Deploy the platform to your Kubernetes cluster:

```bash
# Create namespace and RBAC
kubectl apply -f k8s/namespace.yaml

# Create ConfigMaps and Secrets
kubectl create configmap sei-config --from-file=config/ -n sei-platform
kubectl create secret generic sei-secrets --from-env-file=.env -n sei-platform

# Deploy all components
kubectl apply -f k8s/

# Or use the Makefile
make deploy-local
```

## Namespace Setup

The platform runs in the `sei-platform` namespace with dedicated RBAC:

```bash
# Verify namespace
kubectl get namespace sei-platform

# Check service account
kubectl get serviceaccount sei-platform-sa -n sei-platform

# View RBAC permissions
kubectl describe clusterrole sei-platform-role
```

## Storage Configuration

### Persistent Volumes

The platform requires persistent storage for databases:

Create a StorageClass for dynamic provisioning:

```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: sei-fast-storage
provisioner: kubernetes.io/gce-pd  # Adjust for your cloud provider
parameters:
  type: pd-ssd
  replication-type: regional-pd
reclaimPolicy: Retain
allowVolumeExpansion: true
```

Apply the StorageClass:

```bash
kubectl apply -f k8s/storage/storageclass.yaml
```

### Persistent Volume Claims

Each database service uses a PVC:

- TimescaleDB: 100Gi for time-series metrics
- PostgreSQL: 50Gi for metadata
- Kafka: 50Gi for message logs
- Prometheus: 100Gi for monitoring data

View PVCs:

```bash
kubectl get pvc -n sei-platform
```

## Database Deployment

### TimescaleDB StatefulSet

Deploy TimescaleDB for time-series data:

```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: timescaledb
  namespace: sei-platform
spec:
  serviceName: timescaledb
  replicas: 1
  selector:
    matchLabels:
      app: timescaledb
  template:
    metadata:
      labels:
        app: timescaledb
    spec:
      containers:
      - name: timescaledb
        image: timescale/timescaledb:latest-pg14
        ports:
        - containerPort: 5432
        env:
        - name: POSTGRES_DB
          value: sei_platform
        - name: POSTGRES_USER
          valueFrom:
            secretKeyRef:
              name: sei-secrets
              key: DB_USER
        - name: POSTGRES_PASSWORD
          valueFrom:
            secretKeyRef:
              name: sei-secrets
              key: DB_PASSWORD
        volumeMounts:
        - name: timescale-data
          mountPath: /var/lib/postgresql/data
        resources:
          requests:
            memory: "2Gi"
            cpu: "1000m"
          limits:
            memory: "4Gi"
            cpu: "2000m"
  volumeClaimTemplates:
  - metadata:
      name: timescale-data
    spec:
      accessModes: ["ReadWriteOnce"]
      storageClassName: sei-fast-storage
      resources:
        requests:
          storage: 100Gi
```

### PostgreSQL StatefulSet

Deploy PostgreSQL for metadata:

```bash
kubectl apply -f k8s/databases/postgresql-statefulset.yaml
```

Verify deployment:

```bash
kubectl get statefulset -n sei-platform
kubectl get pods -l app=postgresql -n sei-platform
```

## Application Services

### API Service Deployment

Deploy the REST/GraphQL API:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api-service
  namespace: sei-platform
spec:
  replicas: 3
  selector:
    matchLabels:
      app: api-service
  template:
    metadata:
      labels:
        app: api-service
    spec:
      containers:
      - name: api-service
        image: sei-platform/api-service:latest
        ports:
        - containerPort: 8080
        env:
        - name: TIMESCALE_URL
          valueFrom:
            secretKeyRef:
              name: sei-secrets
              key: TIMESCALE_URL
        - name: REDIS_URL
          valueFrom:
            secretKeyRef:
              name: sei-secrets
              key: REDIS_URL
        livenessProbe:
          httpGet:
            path: /health
            port: 8080
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /ready
            port: 8080
          initialDelaySeconds: 5
          periodSeconds: 5
        resources:
          requests:
            memory: "512Mi"
            cpu: "500m"
          limits:
            memory: "1Gi"
            cpu: "1000m"
```

### Data Collectors

Deploy data collectors for GitHub, GitLab, and Jira:

```bash
kubectl apply -f k8s/collectors/git-collector-deployment.yaml
kubectl apply -f k8s/collectors/jira-collector-deployment.yaml
```

### Data Processors

Deploy stream processing services:

```bash
kubectl apply -f k8s/processors/data-processor-deployment.yaml
```

## Message Queue Setup

### Kafka Deployment

Deploy Kafka for event streaming:

```bash
kubectl apply -f k8s/messaging/zookeeper-statefulset.yaml
kubectl apply -f k8s/messaging/kafka-statefulset.yaml
```

Verify Kafka is running:

```bash
kubectl get pods -l app=kafka -n sei-platform
kubectl logs kafka-0 -n sei-platform
```

## Monitoring Stack

### Prometheus

Deploy Prometheus for metrics collection:

```bash
kubectl apply -f k8s/monitoring/prometheus-config.yaml
kubectl apply -f k8s/monitoring/prometheus-deployment.yaml
```

### Grafana

Deploy Grafana for visualization:

```bash
kubectl apply -f k8s/monitoring/grafana-deployment.yaml
```

Access Grafana:

```bash
kubectl port-forward svc/grafana 3000:3000 -n sei-platform
```

## Service Configuration

### Internal Services

Services for internal communication:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: api-service
  namespace: sei-platform
spec:
  selector:
    app: api-service
  ports:
  - port: 8080
    targetPort: 8080
  type: ClusterIP
```

### External Access

Create a LoadBalancer service for external access:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: api-service-external
  namespace: sei-platform
spec:
  selector:
    app: api-service
  ports:
  - port: 80
    targetPort: 8080
  type: LoadBalancer
```

## Ingress Configuration

### Nginx Ingress

Configure Ingress for HTTP/HTTPS access:

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: sei-platform-ingress
  namespace: sei-platform
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
    cert-manager.io/cluster-issuer: letsencrypt-prod
spec:
  ingressClassName: nginx
  tls:
  - hosts:
    - sei.example.com
    secretName: sei-tls-cert
  rules:
  - host: sei.example.com
    http:
      paths:
      - path: /api
        pathType: Prefix
        backend:
          service:
            name: api-service
            port:
              number: 8080
      - path: /
        pathType: Prefix
        backend:
          service:
            name: frontend-service
            port:
              number: 3000
```

Apply the Ingress:

```bash
kubectl apply -f k8s/ingress/ingress.yaml
```

## Configuration Management

### ConfigMaps

Create ConfigMaps for application configuration:

```bash
# From files
kubectl create configmap sei-config \
  --from-file=config/app.yaml \
  --from-file=config/prometheus.yml \
  -n sei-platform

# From literals
kubectl create configmap sei-env-config \
  --from-literal=LOG_LEVEL=INFO \
  --from-literal=ENVIRONMENT=production \
  -n sei-platform
```

### Secrets

Create Secrets for sensitive data:

```bash
# From environment file
kubectl create secret generic sei-secrets \
  --from-env-file=.env.production \
  -n sei-platform

# From literals
kubectl create secret generic api-keys \
  --from-literal=GITHUB_TOKEN=ghp_xxxxx \
  --from-literal=JIRA_TOKEN=xxxxx \
  -n sei-platform
```

## Auto-scaling

### Horizontal Pod Autoscaler

Configure HPA for API service:

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: api-service-hpa
  namespace: sei-platform
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: api-service
  minReplicas: 3
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
  - type: Resource
    resource:
      name: memory
      target:
        type: Utilization
        averageUtilization: 80
```

Apply HPA:

```bash
kubectl apply -f k8s/autoscaling/api-service-hpa.yaml
```

Verify HPA:

```bash
kubectl get hpa -n sei-platform
kubectl describe hpa api-service-hpa -n sei-platform
```

## Health Checks

### Liveness Probes

Ensure containers are restarted if unhealthy:

```yaml
livenessProbe:
  httpGet:
    path: /health
    port: 8080
  initialDelaySeconds: 30
  periodSeconds: 10
  timeoutSeconds: 5
  failureThreshold: 3
```

### Readiness Probes

Prevent traffic to containers not ready:

```yaml
readinessProbe:
  httpGet:
    path: /ready
    port: 8080
  initialDelaySeconds: 5
  periodSeconds: 5
  timeoutSeconds: 3
  failureThreshold: 3
```

## Security

### Network Policies

Restrict network traffic between pods:

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: api-service-netpol
  namespace: sei-platform
spec:
  podSelector:
    matchLabels:
      app: api-service
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: frontend-service
    ports:
    - protocol: TCP
      port: 8080
  egress:
  - to:
    - podSelector:
        matchLabels:
          app: timescaledb
    ports:
    - protocol: TCP
      port: 5432
```

### Pod Security Policies

Apply security constraints:

```yaml
apiVersion: policy/v1beta1
kind: PodSecurityPolicy
metadata:
  name: sei-platform-psp
spec:
  privileged: false
  allowPrivilegeEscalation: false
  requiredDropCapabilities:
    - ALL
  runAsUser:
    rule: MustRunAsNonRoot
  fsGroup:
    rule: RunAsAny
  seLinux:
    rule: RunAsAny
  supplementalGroups:
    rule: RunAsAny
  volumes:
    - configMap
    - secret
    - persistentVolumeClaim
```

## Backup and Disaster Recovery

### Database Backups

Create CronJob for automated backups:

```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: timescaledb-backup
  namespace: sei-platform
spec:
  schedule: "0 2 * * *"  # Daily at 2 AM
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: backup
            image: postgres:14
            command:
            - sh
            - -c
            - pg_dump -h timescaledb -U sei_user sei_platform | gzip > /backup/backup-$(date +%Y%m%d).sql.gz
            env:
            - name: PGPASSWORD
              valueFrom:
                secretKeyRef:
                  name: sei-secrets
                  key: DB_PASSWORD
            volumeMounts:
            - name: backup-storage
              mountPath: /backup
          volumes:
          - name: backup-storage
            persistentVolumeClaim:
              claimName: backup-pvc
          restartPolicy: OnFailure
```

### Velero for Cluster Backups

Install Velero for complete cluster backups:

```bash
# Install Velero CLI
brew install velero

# Install Velero in cluster
velero install \
  --provider aws \
  --bucket sei-platform-backups \
  --secret-file ./credentials-velero

# Create backup schedule
velero schedule create sei-daily \
  --schedule="@daily" \
  --include-namespaces sei-platform
```

## Monitoring and Logging

### Prometheus Monitoring

Configure ServiceMonitor for metrics:

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
```

### Logging with Fluent Bit

Deploy Fluent Bit for log aggregation:

```bash
kubectl apply -f k8s/logging/fluent-bit-daemonset.yaml
```

## Deployment Strategies

### Rolling Update

Default deployment strategy with zero downtime:

```yaml
spec:
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: 1
      maxSurge: 1
```

### Blue-Green Deployment

Switch between versions instantly:

```bash
# Deploy new version (green)
kubectl apply -f k8s/deployments/api-service-v2.yaml

# Test green deployment
kubectl port-forward deployment/api-service-v2 8081:8080

# Switch service to green
kubectl patch service api-service -p '{"spec":{"selector":{"version":"v2"}}}'

# Remove blue deployment
kubectl delete deployment api-service-v1
```

## Troubleshooting

### Pod Issues

Check pod status:

```bash
kubectl get pods -n sei-platform
kubectl describe pod <pod-name> -n sei-platform
kubectl logs <pod-name> -n sei-platform
kubectl logs <pod-name> -n sei-platform --previous
```

### Service Connectivity

Test service connectivity:

```bash
kubectl run test-pod --rm -it --image=busybox -n sei-platform -- sh
wget -O- http://api-service:8080/health
```

### Resource Issues

Check resource usage:

```bash
kubectl top nodes
kubectl top pods -n sei-platform
kubectl describe node <node-name>
```

### Events

View cluster events:

```bash
kubectl get events -n sei-platform --sort-by='.lastTimestamp'
```

## Scaling Operations

### Manual Scaling

Scale deployments manually:

```bash
# Scale API service
kubectl scale deployment api-service --replicas=5 -n sei-platform

# Scale data collectors
kubectl scale deployment git-collector --replicas=3 -n sei-platform
```

### Cluster Auto-scaling

Configure cluster autoscaler for node scaling:

```bash
kubectl apply -f k8s/autoscaling/cluster-autoscaler.yaml
```

## Upgrades and Updates

### Rolling Update

Update deployment with new image:

```bash
kubectl set image deployment/api-service \
  api-service=sei-platform/api-service:v2.0.0 \
  -n sei-platform
```

### Rollback

Rollback to previous version:

```bash
# View rollout history
kubectl rollout history deployment/api-service -n sei-platform

# Rollback to previous revision
kubectl rollout undo deployment/api-service -n sei-platform

# Rollback to specific revision
kubectl rollout undo deployment/api-service --to-revision=2 -n sei-platform
```

## Production Best Practices

- Use resource requests and limits for all pods
- Implement proper health checks
- Configure HPA for dynamic scaling
- Use StatefulSets for stateful services
- Implement network policies for security
- Use secrets for sensitive data
- Enable RBAC for access control
- Set up monitoring and alerting
- Implement backup strategies
- Use multiple replicas for high availability
- Configure anti-affinity rules
- Use init containers for dependencies
- Implement graceful shutdown
- Use readiness gates for traffic management

## Useful Commands

```bash
# Get cluster info
kubectl cluster-info
kubectl get nodes

# Manage deployments
kubectl get deployments -n sei-platform
kubectl get pods -n sei-platform -o wide
kubectl get services -n sei-platform

# View logs
kubectl logs -f deployment/api-service -n sei-platform
kubectl logs -f -l app=api-service -n sei-platform

# Execute commands
kubectl exec -it <pod-name> -n sei-platform -- /bin/bash
kubectl exec -it timescaledb-0 -n sei-platform -- psql -U sei_user

# Port forwarding
kubectl port-forward svc/api-service 8080:8080 -n sei-platform
kubectl port-forward svc/grafana 3000:3000 -n sei-platform

# Configuration
kubectl get configmap -n sei-platform
kubectl get secret -n sei-platform
kubectl describe configmap sei-config -n sei-platform
```

## Additional Resources

- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Helm Charts](https://helm.sh/docs/)
- [Production Deployment Guide](production.md)
- [Monitoring Setup](monitoring.md)
- [Docker Compose Deployment](docker-compose.md)
