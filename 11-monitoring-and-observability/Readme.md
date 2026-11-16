# Prometheus

## 01. Prometheus Overview

- Prometheus is an open-source systems monitoring and alerting toolkit designed for cloud-native environments, including Kubernetes.

- It collects and stores `metrics` as time-series data-numeric data with timestamps and labels.
- Uses a pull-based model to scrape metrics from services and resources.
- It features a query language (PromQL) for analyzing data.

## 02. Prometheus Core Architectural Concepts

- **Prometheus Server**
  - The core component that scrapes, stores, and manages time-series data.

- **Time Series Database (TSDB)**
  - Stores data on local disk, optimized for storing metric data with timestamps and labels.

- **Scraping/Pull Model**
  - Prometheus pulls (scrapes) data from monitored targets (exporters or applications) via HTTP endpoints rather than waiting for data to be pushed.

- **Service Discovery**
  - Automatically detects infrastructure targets (e.g., Kubernetes pods) to monitor, reducing manual configuration.

- **Exporters**
  - Dedicated agents that translate metrics from third-party systems (e.g., MySQL, Redis, HAProxy) into Prometheus format.

## 03. What is `Metric` in Prometheus?

- In Prometheus, a `metric` is a specific feature, measurement, or event in your system that you want to track over time (e.g., CPU usage, memory usage, or HTTP requests).
- Each metric tracks data as a time-series, meaning it stores a sequence of timestamped numeric values.

### Core Concepts of a Prometheus Metric

- A metric consists of three core components:

  ```bash
  metric_name{label_key="label_value", label_key="label_value"} float64_value

  metric_name{label_1="value_1", label_2="value_2"} 42.15
   └───┬────┘ └───────────────────┬────────────────┘ └──┬──┘
  Identifier                Dimensions/Context        Value (float64)
  ```

  1. **Metric Name**
     - Defines what is being measured (e.g., http_requests_total).
  2. **Labels**
     - Key-value pairs that add multi-dimensional context to the metric, allowing you to filter and group your data.
  3. **Sample**
     - The actual data point, which always contains a millisecond-precision timestamp and a **float64** numeric value.

### Prometheus Metric - Real-World Example | E-Commerce Checkout

- Imagine you run an online shop and want to monitor your checkout system. You create a metric called `checkout_transactions_total`.

- You would like to know which payment method was used and whether it succeeded, you attach `labels` to it.

**Step-01: How the Data Looks (The Time-Series)**

Prometheus pulls this data continuously. At a single moment in time, the raw metric data looks like this:

```bash
checkout_transactions_total{method="credit_card", status="success"} 1050
checkout_transactions_total{method="credit_card", status="failed"}  12
checkout_transactions_total{method="paypal",      status="success"} 420
checkout_transactions_total{method="paypal",      status="failed"}  4
```

- **Metric Name**
  - `checkout_transactions_total` tells you this tracks the total number of checkouts.
- **Labels**
  - _method_ and _status_ labels create four distinct, unique time-series streams out of one single metric.
- **Value**
  - _Value_ represents the total number of checkout attempts recorded from the moment the application started running up.
    - 1050: There have been exactly 1,050 successful credit card checkouts.
    - 12: There have been exactly 12 failed credit card checkouts.
    - 420: There have been exactly 420 successful PayPal checkouts.
    - 4: There have been exactly 4 failed PayPal checkouts.
  - Data Type: It is strictly a **64-bit floating-point number** (float64), it also means Prometheus can track both whole numbers and decimals.

**Step-02: How to Query This Metric using PromQL**

Now, you can use labels to filter the data and a single metric allows you to ask multiple types of questions about your system/app:

```bash

# Find all failed credit card transactions
checkout_transactions_total{method="credit_card", status="failed"}

# Find total checkouts across all payment methods combined
sum(checkout_transactions_total)

# Find the percentage of successful checkouts grouped by payment type
sum by (method) (rate(checkout_transactions_total{status="success"}[5m]))
```

## 04. `Lab`: Deploy an Observability Stack using Docker Compose, Prometheus and Grafana

### Step-4.1: Prerequisites

- AWS Account
- Well versed on the following concepts:
  - Managing Container Lifecycle
  - Managing multi-container apps using Docker Compose

### Step-4.2: Tool/Tech Stack

- Amazon Web Services
- Git
- Prometheus
- Grafana

### Step-4.3: Create an EC2 Instance - Monitoring Instance

- Name: MONITORING-INSTANCE
- Instance Type: t3.small _or bigger instance type_
- Network: Default VPC and Subnets
- Public IP: Enable
- Security Group
  - Ingress: 22, 9090, 9100, 3000
  - Egress: Allow All
- Storage: 15GB or more

### Step-4.5: Configure Monitoring Instance - Docker, Docker Compose, Git

#### Install Git

```bash
# Install Git
sudo dnf install -y git
```

#### Install Docker

```
# Install Docker package
sudo dnf install -y docker

# Start and enable docker service
sudo systemctl start docker
sudo systemctl enable docker

# Check the docker service status | should be in "running" state
sudo service status docker

# Check the current installed version on Docker
sudo docker --version

# Add 'ec2-user' to the 'docker' group
sudo usermod -a -G docker ec2-user

# Logout from SSH session and re-connect
exit
```

#### Install Docker Compose

```bash
# Download and Install the Compose CLI plugin
DOCKER_CONFIG=${DOCKER_CONFIG:-$HOME/.docker}

# Create a new directory for compose
mkdir -p $DOCKER_CONFIG/cli-plugins

# Download the compose binary on the above location
curl -SL https://github.com/docker/compose/releases/download/v5.1.2/docker-compose-linux-x86_64 -o $DOCKER_CONFIG/cli-plugins/docker-compose

# Apply executable permissions to the binary
sudo chmod +x $DOCKER_CONFIG/cli-plugins/docker-compose

# To verify, check Docker Compose (v2) version
docker compose version
```

### Step-4.6: Create Directory Structure for the Observability Stack

```
observability-stack/
├── docker-compose.yml
└── prometheus/
    └── prometheus.yml
```

Run the following commands to create above directory structure:

```bash
mkdir -p observability-stack/prometheus

cd observability-stack
```

### Step-4.7: Develop ` -compose.yml` (prometheus, node-exporter)

- Create the orchestrator configuration file i.e. `docker-compose.yml` inside the root directory.

- This config locks mounts standard Linux system boundaries ( /proc ,
  /sys ) safely, defines rotation-capped log arrays, and ties container execution
  onto a single isolated software bridge ( monitoring-net ).

`docker-compose.yml`

```yaml
services:
  prometheus:
    image: prom/prometheus:v2.54.0
    container_name: prometheus-prod
    restart: unless-stopped
    volumes:
      - ./prometheus/prometheus.yml:/etc/prometheus/prometheus.yml:ro
      - ./prometheus/alert.rules.yml:/etc/prometheus/alert.rules.yml:ro
      - prometheus-data:/prometheus
    command:
      - "--config.file=/etc/prometheus/prometheus.yml"
      - "--storage.tsdb.path=/prometheus"
      - "--storage.tsdb.retention.time=30d"
      - "--storage.tsdb.retention.size=50GB"
      - "--web.enable-lifecycle"
      - "--web.console.templates=/usr/share/prometheus/consoles"
      - "--web.console.libraries=/usr/share/prometheus/console_libraries"
    ports:
      - "9090:9090"
    networks:
      - monitoring-net
    healthcheck:
      test:
        [
          "CMD",
          "wget",
          "-q",
          "--tries=1",
          "-O-",
          "http://localhost:9090/-/healthy",
        ]
      interval: 30s
      timeout: 10s
      retries: 3
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"

  node-exporter:
    image: prom/node-exporter:v1.8.2
    container_name: node-exporter-prod
    restart: unless-stopped
    volumes:
      - /proc:/host/proc:ro
      - /sys:/host/sys:ro
      - /:/rootfs:ro
    command:
      - "--path.procfs=/host/proc"
      - "--path.sysfs=/host/sys"
      - "--path.rootfs=/rootfs"
      - "--collector.filesystem.mount-points-exclude=^/(sys|proc|dev|host|etc)($|/)"
    ports:
      - "9100:9100"
    networks:
      - monitoring-net
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"

networks:
  monitoring-net:
    driver: bridge

volumes:
  prometheus-data:
    driver: local
```

### Step-4.8: Architecting Scrape Targets - `prometheus/prometheus.yml`

```yaml
global:
  scrape_interval: 15s
  evaluation_interval: 15s
  scrape_timeout: 10s
  external_labels:
    environment: "production"
    region: "us-east-1"
    cluster: "docker-prod-01"

# Point to our alerting rules file
rule_files:
  - "alert.rules.yml"

# Alertmanager configuration
alerting:
  alertmanagers:
    - static_configs:
        - targets:
            - "alertmanager:9093" # Resolves automatically using Docker internal DNS

scrape_configs:
  - job_name: "prometheus"
    static_configs:
      - targets: ["prometheus:9090"]

  - job_name: "node-exporter"
    scrape_interval: 15s
    static_configs:
      - targets: ["node-exporter:9100"]
    relabel_configs:
      - source_labels: [__address__]
        target_label: instance
        regex: '([^:]+)(:\d+)?'
        replacement: "${1}"
```

### Step-4.9: Deploy the Observability Stack

- Run the following commands in your project directory:

```bash
# Deploy the stack in the detach mode
docker compose up -d

# List all the deployed services or containers | Ensure both the container are in running state
docker compose ps
```

- Look closely at the STATUS column. _prometheus-prod_ must explicitly display
  **running (healthy)**.

- If it displays **unhealthy** or **exited** , run `docker compose logs prometheus-prod` to
  review the configuration parser errors.

### Step-4.10: Accessing Prometheus Web UI (Dashboard)

- Launch a browser on your local system and navigate to: **http://{monitoring-instance-public-ip}:9090**

### Step-4.11: Running PromQL Queries

#### CPU Usage Percentage (Non-Idle)

This query calculates the average percentage of CPU time spent running non-idle tasks across each instance over a 5-minute window.

```
100 - (avg by (instance) (rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)
```

#### Memory Utilization Percentage

This query determines the active memory usage percentage by subtracting available/free memory from the total memory.

```
100 * (1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes))
```

#### Disk Space Usage Percentage

This query finds the percentage of disk space currently used for each mounted filesystem, ignoring temporary or pseudo-filesystems.

```
100 - (node_filesystem_free_bytes{fstype!~"tmpfs|fuse.lxcfs|overlay"} / node_filesystem_size_bytes{fstype!~"tmpfs|fuse.lxcfs|overlay"} * 100)
```

#### Disk I/O Rate (Bytes Read/Written per Second)

This query computes the total read and write throughput in bytes per second for physical disk devices.

```
sum by (instance, device) (rate(node_disk_read_bytes_total[5m]) + rate(node_disk_written_bytes_total[5m]))
```

#### Network Traffic Rate (Receive/Transmit per Second)

This query measures the rate of network traffic received and transmitted across network interfaces in bytes per second:

```
sum by (instance, device) (rate(node_network_receive_bytes_total[5m]) + rate(node_network_transmit_bytes_total[5m]))
```

- For more PromQL queries examples, kindly refer https://prometheus.io/docs/prometheus/latest/querying/examples/

### Step-4.12: Configure Alerting using Prometheus `AlertManager` - `prometheus/alert.rules.yml`

```
observability-stack/
├── docker-compose.yml
└── prometheus/
    ├── prometheus.yml
    └── alert.rules.yml
```

- Create the alert engine configuration file under `prometheus/alert.rules.yml`.

- This file provides production-ready alert rules for your Node Exporter setup, formatted to plug directly into your Prometheus instance.

`prometheus/alert.rules.yml`

```yaml
groups:
  - name: NodeExporterAlerts
    rules:
      - alert: HostHostlayerDown
        expr: up{job="node-exporter"} == 0
        for: 2m
        labels:
          severity: critical
        annotations:
          summary: "Host down (instance {{ $labels.instance }})"
          description: "Node Exporter has been down for more than 2 minutes."

      - alert: HostHighCpuLoad
        expr: 100 - (avg by (instance) (rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100) > 85
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High CPU load (instance {{ $labels.instance }})"
          description: "CPU usage is above 85% for more than 5 minutes. Current value: {{ $value | printf "%.2f" }}%"

      - alert: HostOutOfMemory
        expr: (1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100 > 90
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "Host out of memory (instance {{ $labels.instance }})"
          description: "Node memory is filling up and has less than 10% available. Current memory usage: {{ $value | printf "%.2f" }}%"

      - alert: HostDiskWillRunOutOfSpace
        expr: (node_filesystem_free_bytes{fstype!~"tmpfs|fuse.lxcfs|overlay"} / node_filesystem_size_bytes{fstype!~"tmpfs|fuse.lxcfs|overlay"} * 100) < 15 and predict_linear(node_filesystem_free_bytes{fstype!~"tmpfs|fuse.lxcfs|overlay"}[1h], 8 * 3600) < 0
        for: 30m
        labels:
          severity: critical
        annotations:
          summary: "Host disk space filling up (instance {{ $labels.instance }}, device {{ $labels.device }}, mountpoint {{ $labels.mountpoint }})"
          description: "Disk space available is less than 15% and is predicted to fill up within the next 8 hours based on the last 1 hour of usage. Current free space: {{ $value | printf "%.2f" }}%"

      - alert: HostPredictOutOfInodes
        expr: node_filesystem_files_free{fstype!~"tmpfs|fuse.lxcfs|overlay"} / node_filesystem_files{fstype!~"tmpfs|fuse.lxcfs|overlay"} * 100 < 10 and predict_linear(node_filesystem_files_free{fstype!~"tmpfs|fuse.lxcfs|overlay"}[1h], 8 * 3600) < 0
        for: 20m
        labels:
          severity: critical
        annotations:
          summary: "Host inodes filling up (instance {{ $labels.instance }}, device {{ $labels.device }}, mountpoint {{ $labels.mountpoint }})"
          description: "Free disk inodes available are less than 10% and are predicted to run out within 8 hours. Current free node usage percentage: {{ $value | printf "%.2f" }}%"

      - alert: HostNetworkReceiveErrors
        expr: rate(node_network_receive_errors_total[2m]) / rate(node_network_receive_packets_total[2m]) > 0.01
        for: 2m
        labels:
          severity: warning
        annotations:
          summary: "Host network receive errors (instance {{ $labels.instance }}, interface {{ $labels.device }})"
          description: "Network interface {{ $labels.device }} is experiencing packet drops/errors on receive greater than 1% over the last 2 minutes."

```

### Step-4.13: Update the `docker-compose.yml` file for enabling Prometheus Alerts

## 05. `Lab`: Query, Visualize, Alert on, and explore your metrics, logs, and traces using Grafana

### Step-5.1: Prerequisites

• Docker Host with Docker Compose
• A text editor (like vim, nano, or VS Code)
• Internet access to pull images from Docker Hub

### Step-5.2: Directory Structure and Architectural Flow

```
observability-stack/
├── docker-compose.yml
└── prometheus/
    └── prometheus.yml
```

- Architectural Flow

```
[ Linux Host Engine ] ──> ( Node Exporter: Port 9100 )
                                   │ (Exposes /metrics)
                                   ▼
                        ( Prometheus: Port 9090 ) ──> [ TSDB Storage ]
                                   │ (Scrapes every 15s)
                                   ▼
                         ( Grafana: Port 3000 )   ──> [ Visual Dashboards ]
```

### Step-5.3: Update the the `prometheus.yml` file

- Kindly refer a sample [prometheus/prometheus.yml](./observability-stack/prometheus/prometheus.yml).

### Step-5.4: Update the the `docker-compose.yml` file

- Kindly refer a sample [docker-compose.yml](./observability-stack/docker-compose.yml) with Grafana service.

### Step-5.5: Deploy the Observability Stack with Prometheus, Node Exporter and Grafana

```bash
docker compose up -d

# Verify that all containers are active and running
docker compose up
```

### Step-5.6: Access Grafana Web UI (Dashboard)

- Navigate to [http://{docker-host-public-ip}:3000]() to access your Grafana Dashboard.

- **Sign-in to Grafana**
  - Use the default credentials
    - Username:admin
    - Password: admin
  - Skip or complete the prompt to set a new password.

### Step-5.7: Create integrate Grafana with Prometheus (data source)

- **Add Data Source**
  - On the home dashboard, click on **Connections** &rarr; **Data Sources**, select **Add data source**, and choose **Prometheus**.
  - HTTP URL configuration: [http://prometheus:9090]()
  - Click _Save_ & _Test_ at the bottom. You should see a confirmation saying "Data source is working".

### Step-5.8: Create or Import a Pre-configured Dashboard

Instead of building a dashboard from scratch, let's use a community gold standard:

- Click the + (plus icon) in the upper right corner or click Dashboards &rarr; New &rarr; Import.

- In the Find and import dashboards field, enter ID number 1860.
  - It pulls the highly-rated, official Node Exporter Full dashboard directly from the [Grafana Community Dashboard Library](https://grafana.com/grafana/dashboards/1860-node-exporter-full/).
  - Click **Load**.
  - Select your newly added Prometheus data source drop-down menu selection at the bottom &rarr; **Import**
- Success!
  - You will immediately be redirected to a live operational panel visualizing your host machine's live RAM usage, network traffic, CPU context switches, and disk operations.
