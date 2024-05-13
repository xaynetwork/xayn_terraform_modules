resource "grafana_folder" "this" {
  title = var.name
}

resource "grafana_rule_group" "this" {
  name             = "${var.name} Rules"
  folder_uid       = grafana_folder.this.uid
  interval_seconds = 180

  dynamic "rule" {
    for_each = var.rules != null ? toset(keys(var.rules)) : []

    content {
      name      = var.rules[rule.key].name
      condition = var.rules[rule.key].condition

      dynamic "data" {
        for_each = var.rules[rule.key].data != null ? toset(keys(var.rules[rule.key].data)) : []

        content {
          ref_id = var.rules[rule.key].data[data.key].ref_id

          relative_time_range {
            from = var.rules[rule.key].data[data.key].time_range_end
            to   = var.rules[rule.key].data[data.key].time_range_start
          }
          datasource_uid = var.rules[rule.key].data[data.key].datasource_uid
          model          = var.rules[rule.key].data[data.key].model
        }
      }

      no_data_state  = var.rules[rule.key].no_data_state
      exec_err_state = var.rules[rule.key].exec_err_state
      for            = "3m"
      annotations = {
        summary = var.rules[rule.key].summary
      }

      labels    = {}
      is_paused = false
    }
  }
}

