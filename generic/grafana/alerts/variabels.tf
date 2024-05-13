variable "grafana_url" {
  description = "URL to access grafana"
  type        = string
}

variable "name" {
  description = "Alert Folder Name"
  type        = string
}

variable "rules" {
  description = "Rules for the grafana alerts"
  type = object({
    name      = string
    condition = string
    data = object({
      ref_id           = string
      time_range_start = number
      time_range_end   = number
      datasource_uid   = string
      model            = string
    })
    no_data_state  = string
    exec_err_state = string
    summary        = string
  })
}
