variable "endpoint_config_name" {
  description = "The name of the endpoint configuration. If omitted, the name will be `<model_name>-endpoint-config-<random_id>`."
  type        = string
  default     = null
}

variable "endpoint_config_production_variants" {
  description = "Map of production variants to create."
  type        = any
  # example
  # [{
  # initial_instance_count = 1
  # instance_type          = "ml.c6g.large"
  # variant_name           = "variant1"
  # enable_ssm_access      = true
  # },
  # {
  # initial_instance_count = 2
  # instance_type          = "ml.c6g.2xlarge"
  # variant_name           = "variant2"
  # }]
}

variable "create_endpoint" {
  description = "Determines if an endpoint is created."
  type        = bool
  default     = true
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

variable "model_multi_model_mode" {
  description = "If this endpoint runs in multi or single model mode."
  type        = bool
  default     = false
}

variable "model_name" {
  description = "The name of the model (must be unique)."
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
  # example
  # {
  #   subnets = []
  # }
}

variable "model_role_name" {
  description = "Name of IAM role to use for Sagemaker"
  type        = string
}

variable "model_role_description" {
  description = "Description of IAM role to use for Sagemaker"
  type        = string
  default     = null
}

variable "model_policy_name" {
  description = "IAM policy name."
  type        = string
}

variable "model_policy_jsons" {
  description = "An additional policy document as JSON to attach to the Sagemaker role"
  type        = list(any)
  default     = []
}

variable "model_model_buckets" {
  description = "List of S3 bucket names that Sagemaker should be given access to."
  type        = list(string)
  default     = []
}

variable "model_ecr_repositories" {
  description = "List of ECR repository arns that Sagemaker should be given access to."
  type        = list(string)
}

variable "create_model_security_group" {
  description = "Determines if a security group is created"
  type        = bool
  default     = true
}

variable "model_security_group_name" {
  description = "Name to use on security group created"
  type        = string
  default     = null
}

variable "model_security_group_use_name_prefix" {
  description = "Determines whether the security group name (`security_group_name`) is used as a prefix"
  type        = bool
  default     = true
}

variable "model_security_group_description" {
  description = "Description of the security group created"
  type        = string
  default     = null
}

variable "model_security_group_rules" {
  description = "Security group rules to add to the security group created"
  type        = any
  default     = {}
}

variable "enable_autoscaling" {
  description = "Determines whether to enable autoscaling for the endpoint."
  type        = bool
  default     = false
}

variable "autoscaling_capacity" {
  description = "Map of minimum and maximum number of tasks to run in your endpoint. Minimum defaults to 1. Maximum defaults to 10."
  type        = any
  default     = {}
  # example
  # {
  #   main = {
  #     min = 2
  #     max = 5
  #   }
  # }
}

variable "autoscaling_policies" {
  description = "Map of autoscaling policies to create for production variants of the endpoint."
  type        = any
  default     = {}
  # example
  # {
  #   variant1 = [{
  #     name = "invocations"
  #     target_tracking_scaling_policy_configuration = {
  #       predefined_metric_specification = {
  #         predefined_metric_type = "SageMakerVariantInvocationsPerInstance"
  #       }
  #     }
  #   }],
  #   variant2 = [{
  #     name = "invocations"
  #     target_tracking_scaling_policy_configuration = {
  #       predefined_metric_specification = {
  #         predefined_metric_type = "SageMakerVariantInvocationsPerInstance"
  #       }
  #     }
  #   }]
  # }
}

variable "autoscaling_scheduled_actions" {
  description = "Map of autoscaling scheduled actions to create for production variants of the endpoint."
  type        = any
  default     = {}
  # example
  # {
  #   variant1 = [
  #     {
  #       name         = "up"
  #       schedule     = "cron(35 15 * * ? *)"
  #       min_capacity = 2
  #       max_capacity = 10
  #       timezone     = "Europe/Berlin"
  #     }],
  #   variant2 = [
  #     {
  #       name         = "up"
  #       schedule     = "cron(35 15 * * ? *)"
  #       min_capacity = 2
  #       max_capacity = 10
  #       timezone     = "Europe/Berlin"
  #     }]
  # }
}

variable "create_ssm_parm" {
  description = "Determines if a ssm parameter is created in which the endpoint URL is stored."
  type        = bool
  default     = false
}

variable "create_kms" {
  description = "Determines if a kms key is created in which is used to encrypt data on the storage volume attached to the ML compute instance that hosts the endpoint."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Custom tags to set on the underlining resources."
  type        = map(string)
  default     = {}
}
