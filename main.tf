data "aws_region" "current" {}

locals {
  identifier = "${var.identifier}"
}


resource "aws_security_group" "sdm" {
  description = "Allow all inbound traffic"
}

module "sdm_relay" {
  source                                 = "github.com/FitnessKeeper/tf_aws_ecs_service?ref=v2.4.1"
  region                                 = "${var.region}" #"${data.aws_region.current.name}"
  vpc_id                                 = "${var.vpc_id}"
  ecs_cluster_arn                        = "${var.ecs_cluster_arn}"
  ecs_security_group_id                  = "${aws_security_group.sdm.id}" #"${var.security_group_id}"
  #ecs_desired_count                      = "${local.instance_count}" # make this a var that can be passed
  ecs_placement_strategy_type            = "spread"
  ecs_placement_strategy_field           = "instanceId"
  ecs_deployment_minimum_healthy_percent = "50"
  service_identifier                     = "${local.identifier}" #"sdm_relay-${var.env}"
  task_identifier                        = "relay"
  docker_image                           = "quay.io/sdmrepo/relay:latest"
  #docker_command                         = "/scripts/start_elevation.sh"
  #docker_memory                          = 256
  #docker_memory_reservation              = 128
  alb_enable_https                        = false
  alb_enable_http                         = false
  app_port                                = 5000
  network_mode                            = "awsvpc"

  docker_environment = [
    {
      "name"  = "SERVICE_NAME"
      "value" = "strongdm_relay"
    },
  ]

#  docker_mount_points = [
#    {
#      "sourceVolume"  = "data"
#      "containerPath" = "/data"
#    },
#  ]

}
