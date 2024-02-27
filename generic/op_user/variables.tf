variable "vault_id" {
  type        = string
  description = "ID of the vault where the keys are stored"
}

variable "item_uid" {
  type        = string
  description = "UID of the item to retrieve"
}

variable "op_account" {
  type        = string
  description = "One password account where to retrieve user data"
  default     = "https://xaynag.1password.com/"
}

