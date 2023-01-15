output "sns_slack_topic_arn" {
  description = "ARN of the SNS Slack topic"
  value       = module.notify_slack.slack_topic_arn
}
