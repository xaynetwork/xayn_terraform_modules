resource "aws_kms_key" "this" {
  description = "KMS key for Slack URL"
}

resource "aws_kms_ciphertext" "slack_url" {
  plaintext = var.slack_url
  key_id    = aws_kms_key.this.arn
}

module "notify_slack" {
  source  = "terraform-aws-modules/notify-slack/aws"
  version = "5.5.0"

  sns_topic_name = "slack-alarm-notification"

  slack_webhook_url = aws_kms_ciphertext.slack_url.ciphertext_blob
  slack_channel     = "aws-notification"
  slack_username    = "reporter"

  kms_key_arn = aws_kms_key.this.arn

  lambda_description = "Lambda function which sends notifications to Slack"

  cloudwatch_log_group_tags = var.tags
  sns_topic_tags            = var.tags
  lambda_function_tags      = var.tags
  tags                      = var.tags
}


resource "aws_sns_topic_subscription" "additional_subscriptions" {
  count     = length(var.additional_subscriptions)
  topic_arn = module.notify_slack.slack_topic_arn
  protocol  = var.additional_subscriptions[count.index].protocol
  endpoint  = var.additional_subscriptions[count.index].endpoint
}
