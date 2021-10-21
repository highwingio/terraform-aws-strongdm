data "aws_region" "region" {
  name = var.region
}

locals {
  docker_environment = [
    {
      "name"  = "SERVICE_NAME"
      "value" = "strongdm-gateway"
    },
    {
      "name"  = "ENABLE_SDM_GATEWAY"
      "value" = "true"
    },
    {
      "name"  = "SDM_GATEWAY_LISTEN_APP_PORT"
      "value" = tostring(var.sdm_gateway_listen_app_port)
    },
    {
      "name"  = "PUBLIC_HOST"
      "value" = aws_lb.nlb.dns_name
    },
  ]
}
