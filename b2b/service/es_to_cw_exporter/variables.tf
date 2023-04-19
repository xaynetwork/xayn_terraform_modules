# ElasticSearch to Cloudwatch metric exporter service settings
variable "cluster_name" {
  description = "Name of the ECS cluster"
  type        = string
}

variable "cluster_id" {
  description = "ID of the ECS cluster"
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

variable "subnet_ids" {
  description = "VPC subnet IDs to launch in the ECS service"
  type        = list(string)
}

variable "task_cpu" {
  description = "The number of cpu units the ECS container agent reserves for the task"
  type        = number
  default     = 256
}

variable "task_memory" {
  description = "The hard limit of memory (in MiB) to present to the task"
  type        = number
  default     = 512
}

variable "task_cpu_architecture" {
  description = "CPU architecture"
  type        = string
  default     = "X86_64"
}

# elasticsearch exporter container settings
variable "es_exporter_container_image" {
  description = "Specifies value of the container image"
  type        = string
}

variable "es_exporter_scrape_interval" {
  description = "Cluster info update interval for the cluster label"
  type        = string
  default     = "5m"
}

variable "elasticsearch_url" {
  description = "Name of the Elasticsearch URL"
  type        = string
}

variable "elasticsearch_username" {
  description = "Name of the Elasticsearch username"
  type        = string
}

variable "elasticsearch_password_ssm_parameter_arn" {
  description = "ARN of the Elasticsearch password SSM parameter"
  type        = string
}

# prometheus exporter container settings
variable "pc_exporter_container_image" {
  description = "Specifies value of the container image"
  type        = string
}

variable "pc_exporter_scrape_interval" {
  description = "Prometheus scrape interval in seconds"
  type        = number
  default     = 300
}

variable "pc_exporter_include_metrics" {
  description = "Only publish the specified metrics (comma-separated list of glob patterns)"
  type        = string
}

variable "es_cluster_name" {
  description = "Name of the ElasticSearch cluster"
  type        = string
}

# other
variable "tags" {
  description = "Custom tags to set on the underlining resources"
  type        = map(string)
  default     = {}
}
