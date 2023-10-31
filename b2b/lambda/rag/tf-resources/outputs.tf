output "lambda_function_invoke_arn" {
  description = "ARN of the the `rag` lambda"
  value       = module.rag.lambda_function_invoke_arn
}

output "lambda_function_name" {
  description = "Name of the the `rag` lambda"
  value       = module.rag.lambda_function_name
}
