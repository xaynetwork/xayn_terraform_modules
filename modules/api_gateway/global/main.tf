# allow API Gateway to call the lambda authorizer
data "aws_iam_policy_document" "assume_role_api_gateway" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["apigateway.amazonaws.com"]
    }
  }
}

# allow writing API Gateway logs to CloudWatch
resource "aws_iam_role" "api_gateway_cloudwatch" {
  name               = "api_gateway_cloudwatch_global"
  assume_role_policy = data.aws_iam_policy_document.assume_role_api_gateway.json
  tags               = var.tags
}

resource "aws_iam_role_policy_attachment" "execution_role" {
  role       = aws_iam_role.api_gateway_cloudwatch.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonAPIGatewayPushToCloudWatchLogs"
}

# Automatically created log group when creating an api_gateway, just here to be tracked, and eventually deleted as well by terraform
resource "aws_cloudwatch_log_group" "this" {
  name              = "/aws/apigateway/welcome"
  retention_in_days = var.log_retention_in_days
  tags              = var.tags
}

resource "aws_api_gateway_vpc_link" "this" {
  name        = "api_gateway_lb_vpc_link"
  description = "VPC link between API gateway and network load balancer"
  target_arns = [var.nlb_arn]
  tags        = var.tags
}

# monitoring setting for API Gateway
resource "aws_api_gateway_account" "this" {
  cloudwatch_role_arn = aws_iam_role.api_gateway_cloudwatch.arn
}
