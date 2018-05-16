data "aws_region" "region" {
  name = "${var.region}"
}

data "aws_vpc" "vpc" {
  id = "${var.vpc_id}"
}

locals {
  docker_environment = [
    {
      "name"  = "SERVICE_NAME"
      "value" = "strongdm-relay"
    },
    {
      "name"  = "SDM_ADMIN_TOKEN"
      "value" = "${var.sdm_admin_token}"
    },
  ]
}
