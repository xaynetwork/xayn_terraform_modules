resource "aws_kms_key" "this" {
  description             = "Key for ${var.name}"
  deletion_window_in_days = 10
  tags                    = var.tags
}

resource "aws_kms_alias" "this" {
  name          = "alias/${var.name}"
  target_key_id = aws_kms_key.this.key_id
}
