# Prometheus

## Prometheus Overview

- Prometheus is an open-source systems monitoring and alerting toolkit designed for cloud-native environments, including Kubernetes.

- It collects and stores `metrics` as time-series data-numeric data with timestamps and labels.
- Uses a pull-based model to scrape metrics from services and resources.
- It features a query language (PromQL) for analyzing data.

## Prometheus Core Architectural Concepts

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

## What is `Metric` in Prometheus?

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
