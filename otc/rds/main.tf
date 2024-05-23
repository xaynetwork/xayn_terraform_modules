data "opentelekomcloud_dcs_az_v1" "az_1" {
  name = var.region_zone
}

resource "opentelekomcloud_networking_secgroup_v2" "this" {
  name        = "${var.name}-sg"
  description = "Security Group for the Postgres db"
}

resource "opentelekomcloud_rds_instance_v3" "instance" {
  name              = var.name
  availability_zone = [data.opentelekomcloud_dcs_az_v1.az_1.id]

  db {
    password = var.password
    type     = var.type
    version  = var.db_version
    port     = var.port
  }

  security_group_id = opentelekomcloud_networking_secgroup_v2.this.id
  subnet_id         = var.subnet_id
  vpc_id            = var.vpc_id
  flavor            = var.flavor

  volume {
    type = var.volume.type
    size = var.volume.size
  }

  dynamic "backup_strategy" {
    for_each = var.backup_strategy == null ? [] : [var.backup_strategy]
    content {
      start_time = var.backup_strategy.start_time
      keep_days  = var.backup_strategy.keep_days
    }
  }
}
