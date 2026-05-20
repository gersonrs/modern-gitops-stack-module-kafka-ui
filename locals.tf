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
        backend_service   = var.oidc != null ? "kafka-ui-oauth2-proxy" : "kafka-ui"
        backend_port      = var.oidc != null ? 4180 : 80
      }
    }
  }]

  helm_values_oauth2proxy = var.oidc != null ? [{
    oauth2proxy = {
      enabled      = true
      upstreamUrl  = "http://kafka-ui:80"
      redirectUrl  = "https://${local.domain}/oauth2/callback"
      cookieSecret = random_password.oauth2_proxy_cookie_secret.result
      oidc = {
        issuerUrl    = var.oidc.issuer_url
        clientId     = var.oidc.client_id
        clientSecret = var.oidc.client_secret
      }
      extraArgs = concat(
        var.oidc.oauth2_proxy_extra_args,
        [for g in var.allowed_groups : "--allowed-group=${g}"]
      )
    }
  }] : []
}
