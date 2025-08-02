# Automated Temperature Monitoring Stack with Terraform, Prometheus & Grafana - Tallinn

This repository automates the deployment of a cloud-based weather monitoring system. It provisions infrastructure on Azure, deploys Dockerized services for Grafana, Prometheus, 
and a custom Python exporter, and continuously monitors real-time weather temperature data.


## Features

- CI/CD with GitHub Actions -  for SonarQube code scanning and infrastructure provisioning
- Terraform - deploys a VM and required resources on Azure (vnet, pub-ip, nsg, pub-subnet, network interface, etc)
- Python Exporter - collects live weather data using the Visual Crossing API
- Prometheus - scrapes metrics ( temperature , humidity, and pressure)
- Grafana - visualizes temperature in a dashboard
- Docker Compose - runs all services in a single VM
- Remote Backend - Stores terraform tfstate (az blob storage )


---

## CI/CD Pipeline (`.github/workflows/deploy.yml`)

### Triggered Manually (`workflow_dispatch`)

* (If you need to run when a commit is made to the main branch, just comment the workflow_dispatch and uncomment the commented block in the .github/workflows/deploy.yml)

This GitHub Actions pipeline includes three main jobs:

1. environment-setup
   Installs Terraform CLI for the upcoming provisioning job.

2. sonarcloud-scan 
   Runs **SonarQube analysis** on the code to ensure code quality.

3. terraform-provision
   Provisions an Azure VM using Terraform and injects secrets (like `WEATHER_API_KEY`) into the instance via cloud-init.

---

## How It Works

### The Exporter (`app/temperature-exporter.py`)

- Fetches weather data every 10 seconds from Visual Crossing Weather API
- Exposes the following Prometheus metrics on port `8000`:
  - `weather_temperature_celsius`
  - `weather_humidity_percent`
  - `weather_pressure_mb`

### Prometheus (`prometheus/prometheus.yml`)

- Scrapes metrics from the exporter at `localhost:8000/metrics`

### Grafana (`grafana/provisioning/`)

- Automatically provisions a Temperature Dashboard
- Data source and dashboard are loaded via provisioning YAMLs

### Docker Compose (`docker-compose.yml`)

Three containers are spun up:
- `grafana`: Dashboard UI (port `3000`)
- `prometheus`: Time-series DB and metric scraper (port `9090`)
- `temperature-exporter`: Python-based weather data collector (port `8000`)

---

## Terraform + Azure

Terraform code:
- Spins up 1 Linux VM with the necessary resources, such as public IP, vnet, nsg, network interface, nsg associations etc.
- Uses **cloud-init** to:
  - Install Docker, Docker Compose, Git
  - Clone this repo
  - Inject `WEATHER_API_KEY`
  - Launch Docker Compose services automatically

Cloud-init script (snippet):

```yaml
#cloud-config
runcmd:
  - git clone https://github.com/nethu9/home-assignment.git /opt/home-assignment
  - echo 'WEATHER_API_KEY=${weather_api_key}' > /opt/home-assignment/.env
  - cd /opt/home-assignment && docker-compose --env-file .env up -d
