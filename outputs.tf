output "id" {
  description = "ID to pass other modules in order to refer to this module as a dependency."
  value       = resource.null_resource.this.id
}

output "cluster_dns" {
  description = "Kafka-ui cluster dns"
  value       = "kafka-ui.observability.svc.cluster.local"
}
output "cluster_ip" {
  description = "Kafka-ui cluster ip internal"
  value       = data.kubernetes_service_v1.kafka-ui.spec[0].cluster_ip
}

output "endpoint" {
  description = "Kafka-ui endpoint external"
  value       = "https://kafka-ui.apps.${var.cluster_name}.${var.base_domain}"
}
