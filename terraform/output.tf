output "public-ip" {
  value = azurerm_public_ip.public_ip.ip_address
}

output "metrics_endpoint" {
  description = "URL for accessing the raw metrics endpoint"
  value       = "http://${azurerm_public_ip.public_ip.ip_address}:8000/metrics"
}

output "grafana_url" {
  description = "URL for accessing Grafana"
  value       = "http://${azurerm_public_ip.public_ip.ip_address}:3000"
}

output "prometheus_url" {
  description = "URL for accessing Prometheus"
  value       = "http://${azurerm_public_ip.public_ip.ip_address}:9090"
}