resource "aws_oam_sink" "this" {
  name = var.sink_name
  tags = var.tags
}

resource "aws_oam_sink_policy" "this" {
  sink_identifier = aws_oam_sink.this.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["oam:CreateLink", "oam:UpdateLink"]
        Effect   = "Allow"
        Resource = "*"
        Principal = {
          "AWS" = var.source_accounts
        }
        Condition = {
          "ForAllValues:StringEquals" = {
            "oam:ResourceTypes" = var.resource_types
          }
        }
      }
    ]
  })
}
