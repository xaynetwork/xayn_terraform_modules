output "status_code" {
  description = "Status code of the lambda invocation response"
  value       = shell_script.invoke_lambda.output["statusCode"]
}

output "body" {
  description = "Body of the lambda invocation response"
  value       = shell_script.invoke_lambda.output["body"]
}
