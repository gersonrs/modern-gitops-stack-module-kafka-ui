locals {
  domain      = format("kafka-ui.%s", trimprefix("${var.subdomain}.${var.base_domain}", "."))
  domain_full = format("kafka-ui.%s.%s", trimprefix("${var.subdomain}.${var.cluster_name}", "."), var.base_domain)

  helm_values = [{
    kafka-ui = {
      yamlApplicationConfig = {
        kafka = {
          clusters = [{
            name             = "local"
            bootstrapServers = "${var.kafka_broker_name}-kafka-bootstrap.ingestion.svc.cluster.local:9092"
            schemaRegistry   = "http://schema-registry-cp-schema-registry.ingestion.svc.cluster.local:8081"
            # schemaRegistryAuth = {
            #   username = "username"
            #   password = "password"
            # }
            # metrics = {
            #   port = "9997"
            #   type = "JMX"
            # }
            #     schemaNameTemplate: "%s-value"
          }]
        }
        # spring = {
        #   security = {
        #     oauth2 = false
        #   }
        # }
        auth = {
          type = "disabled"
        }
        management = {
          health = {
            ldap = {
              enabled = false
            }
          }
        }
      }

      ingress = {
        enabled = false
      }
    }
  }]

  helm_values_httproute = [{
    kafka-ui = {
      httproute = {
        enabled           = true
        host              = local.domain
        gateway_name      = var.gateway_name
        gateway_namespace = var.gateway_namespace
      }
    }
  }]
}
