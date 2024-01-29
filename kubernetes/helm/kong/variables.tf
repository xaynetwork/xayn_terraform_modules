variable "chart_version" {
  description = "The version of the ingress kong chart"
  type        = string
  default     = "v0.10.1"
}

variable "gateway_config_yaml" {
  description = "The gateway config yaml, similar to the example-gatway.yaml. Loaded as string, i.e. file('gateway.yaml')"
  type        = string
}
