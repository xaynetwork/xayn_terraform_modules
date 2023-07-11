variable "endpoint_config_name" {
  description = "The name of the endpoint configuration. If omitted, the name will be `<model_name>-endpoint-config`."
  type        = string
  default     = null
}

variable "endpoint_config_production_variant" {
  description = "A ProductionVariant object."
  type        = any
}

variable "endpoint_name" {
  description = "The name of the endpoint. If omitted, the name will be `<model_name>-endpoint`."
  type        = string
  default     = null
}

variable "endpoint_deployment_config" {
  description = "The deployment configuration for an endpoint, which contains the desired deployment strategy and rollback configurations."
  type        = any
  default     = {}
}

variable "model_name" {
  description = "The name of the model (must be unique). If omitted, Terraform will assign a random, unique name."
  type        = string
}

variable "model_primary_container" {
  description = "The primary docker image containing inference code that is used when the model is deployed for predictions."
  type        = any
}

variable "model_enable_network_isolation" {
  description = "Isolates the model container. No inbound or outbound network calls can be made to or from the model container."
  type        = bool
  default     = false
}

variable "model_vpc_config" {
  description = "Specifies the VPC that you want your model to connect to. VpcConfig is used in hosting services and in batch transform."
  type        = any
  default     = {}
}

variable "model_exec_iam_role_policies" {
  description = "Map of IAM role policy ARNs to attach to the IAM role"
  type        = map(string)
  default     = {}
}

variable "enable_autoscaling" {
  description = "Determines whether to enable autoscaling for the endpoint."
  type        = bool
  default     = true
}

variable "autoscaling_min_capacity" {
  description = "Minimum number of tasks to run in your endpoint."
  type        = number
  default     = 1
}

variable "autoscaling_max_capacity" {
  description = "Maximum number of tasks to run in your endpoint."
  type        = number
  default     = 10
}

variable "autoscaling_policies" {
  description = "Map of autoscaling policies to create for the endpoint."
  type        = any
  default = {
    invocations = {
      target_tracking_scaling_policy_configuration = {
        predefined_metric_specification = {
          predefined_metric_type = "SageMakerVariantInvocationsPerInstance"
        }
      }
    }
  }
}

variable "autoscaling_scheduled_actions" {
  description = "Map of autoscaling scheduled actions to create for the endpoint."
  type        = any
  default     = {}
}

variable "tags" {
  description = "Custom tags to set on the underlining resources."
  type        = map(string)
  default     = {}
}
