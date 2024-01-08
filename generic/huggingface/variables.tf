variable "hf_name" {
  description = " The name for the instance service."
  type        = string
}

variable "hf_region" {
  description = "Hugging face region where to create the resource."
  type        = string
  default     = "eu-west-1"
}

variable "namespace" {
  description = "Name of the hugging face namespace"
  type        = string
}

variable "write_token" {
  description = "Token for writing into hugging face"
  type        = string
}

variable "read_token" {
  description = "Token for reading into hugging face"
  type        = string
}

variable "instance_type" {
  description = "The type of instance where to deploy the model."
  type        = string
}

variable "instance_size" {
  description = "The size of the instance where to deploy the model."
  type        = string
}

variable "min_replica" {
  description = "The minimum number of replicas to deploy."
  type        = number
  default     = 0
}

variable "max_replica" {
  description = "The maximum number of replicas to deploy."
  type        = number
  default     = 1
}

variable "model_repo" {
  description = "Model repository"
  type        = string
}

variable "task" {
  description = "Task for the model"
  type        = string
  default     = "text-generation"
}

variable "framework" {
  description = "Framework for the model"
  type        = string
  default     = "pytorch"
}

variable "image_url" {
  description = "Custom image URL"
  type        = string
  default     = "ghcr.io/huggingface/text-generation-inference:1.1.0"
}

variable "env_var" {
  description = "Environment variables for the model"
  type        = map(string)
  default = {
    MAX_BATCH_PREFILL_TOKENS = "8192",
    MAX_INPUT_LENGTH         = "7168",
    MAX_TOTAL_TOKENS         = "8192",
    MODEL_ID                 = "/repository",
    QUANTIZE                 = "awq",
  }
}
