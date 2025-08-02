output "public-ip" {
  value = azurerm_public_ip.public_ip.ip_address
}

output "metrics_endpoint" {
  description = "URL for accessing the raw metrics endpoint"
  value       = "http://${azurerm_public_ip.public_ip.ip_address}:8000/metrics"
}