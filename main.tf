data "aws_region" "region" {
  name = var.region
}

locals {
  docker_environment = [
    {
      "name"  = "SDM_DOCKERIZED"
      "value" = "true"
    }
  ]
}
