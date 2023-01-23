# terraform-aws-strongdm
Terraform module for deploying [strongDM](https://www.strongdm.com) gateways/relays on AWS ECS Fargate

----------------------

Usage
-----

```hcl
data "aws_region" "current" {}

resource "aws_ecs_cluster" "strongdm" {
  name               = "strongdm"
  capacity_providers = ["FARGATE", "FARGATE_SPOT"]

  default_capacity_provider_strategy {
    capacity_provider = "FARGATE_SPOT"
    weight            = 1
  }
}

module "ecs_strongdm" {
  source             = "github.com/highwingio/terraform-aws-strongdm:v1.0.0"
  region             = data.aws_region.current.name
  vpc_id             = data.vpc.my_vpc.vpc_id
  ecs_cluster_arn    = aws_ecs_cluster.strongdm.arn
  sdm_admin_token_parameter_arn    = "arn::aws::ssm:<SDM_ADMIN_TOKEN>"
  private_subnet_ids = <PRIVATE_SUBNETS>
  public_subnet_ids  = <PUBLIC_SUBNETS>
  security_group_ids = <SECURITY_GROUPS>
}

```

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 4.51.0 |
| <a name="provider_sdm"></a> [sdm](#provider\_sdm) | 3.5.4 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_group.task](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_ecs_service.service](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service) | resource |
| [aws_ecs_task_definition.task](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition) | resource |
| [aws_iam_role.service](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.task](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.service](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy_attachment.service](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.task_extra](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_lb.nlb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb) | resource |
| [aws_lb_listener.frontend](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) | resource |
| [aws_lb_target_group.gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group) | resource |
| [aws_security_group.nlb_listener_traffic](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_ssm_parameter.gateway_token](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [sdm_node.gateway](https://registry.terraform.io/providers/strongdm/sdm/latest/docs/resources/node) | resource |
| [aws_iam_policy_document.assume_role_service](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.assume_role_task](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.service_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.task_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.region](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ecs_cluster_arn"></a> [ecs\_cluster\_arn](#input\_ecs\_cluster\_arn) | ARN of ECS cluster in which the service will be deployed | `string` | n/a | yes |
| <a name="input_ecs_deployment_maximum_percent"></a> [ecs\_deployment\_maximum\_percent](#input\_ecs\_deployment\_maximum\_percent) | Upper limit in percentage of tasks that can be running during a deployment (default 200) | `string` | `"200"` | no |
| <a name="input_ecs_deployment_minimum_healthy_percent"></a> [ecs\_deployment\_minimum\_healthy\_percent](#input\_ecs\_deployment\_minimum\_healthy\_percent) | Lower limit in percentage of tasks that must remain healthy during a deployment (default 100) | `string` | `"100"` | no |
| <a name="input_ecs_desired_count"></a> [ecs\_desired\_count](#input\_ecs\_desired\_count) | Desired number of containers in the task (default 1) | `number` | `1` | no |
| <a name="input_ecs_health_check_grace_period"></a> [ecs\_health\_check\_grace\_period](#input\_ecs\_health\_check\_grace\_period) | Seconds to ignore failing load balancer health checks on newly instantiated tasks to prevent premature shutdown, up to 1800. (default 0) | `string` | `"0"` | no |
| <a name="input_ecs_log_retention"></a> [ecs\_log\_retention](#input\_ecs\_log\_retention) | Number of days of ECS task logs to retain (default 365) | `number` | `365` | no |
| <a name="input_extra_task_policy_arns"></a> [extra\_task\_policy\_arns](#input\_extra\_task\_policy\_arns) | List of ARNs of IAM policies to be attached to the ECS task role (in addition to the default policy, so cannot be more than 9 ARNs) | `list(any)` | `[]` | no |
| <a name="input_gateway_listen_port"></a> [gateway\_listen\_port](#input\_gateway\_listen\_port) | Port for SDM gateway to listen on | `number` | `5000` | no |
| <a name="input_log_group_name"></a> [log\_group\_name](#input\_log\_group\_name) | Name for CloudWatch Log Group that will receive collector logs (must be unique, default is created from service\_identifier and task\_identifier) | `string` | `""` | no |
| <a name="input_public_subnet_ids"></a> [public\_subnet\_ids](#input\_public\_subnet\_ids) | List of public subnet IDs in which to place the load balancer and tasks | `list(string)` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | AWS region in which ECS cluster is located (default is 'us-east-1') | `string` | `"us-east-1"` | no |
| <a name="input_security_group_ids"></a> [security\_group\_ids](#input\_security\_group\_ids) | Additional security groups for the SDM gateway (e.g. to access data sources) | `list(string)` | `[]` | no |
| <a name="input_service_identifier"></a> [service\_identifier](#input\_service\_identifier) | Unique identifier for this service (used in log prefix, service name etc.) | `string` | `"sdm"` | no |
| <a name="input_task_identifier"></a> [task\_identifier](#input\_task\_identifier) | Unique identifier for this task (used in log prefix, service name etc.) | `string` | `"gateway"` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | ID of VPC in which ECS cluster is located | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->

Authors
=======

Based off of https://github.com/asicsdigital/terraform-aws-strongdm

Changelog
=========

1.0.0 - Initial release.

License
=======

This software is released under the MIT License (see `LICENSE`).
