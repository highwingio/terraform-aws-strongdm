resource "sdm_node" "gateway" {
  gateway {
    name = var.service_identifier
    listen_address = "${aws_lb.nlb.dns_name}:${var.gateway_listen_port}"
    bind_address   = "0.0.0.0:${var.gateway_listen_port}"
  }
}
resource "aws_ssm_parameter" "gateway_token" {
  type  = "SecureString"
  value = sdm_node.gateway.gateway.0.token
  name  = "/strongdm/gateway/${sdm_node.gateway.gateway.0.name}/token"

  overwrite = true
}
