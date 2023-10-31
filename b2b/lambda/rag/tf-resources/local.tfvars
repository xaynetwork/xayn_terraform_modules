# define required varables here:
environment_variables = {
  "AWS_REGION"              = "eu-central-1"
  "SAGEMAKER_ENDPOINT_NAME" = "gte-base-endpoint"
  "NLB_URL"                 = "http://nlb-dev-649f929e99958326.elb.eu-central-1.amazonaws.com"
}
# define required varables here:
environment_variables = {
  "AWS_REGION"              = "eu-central-1"
  "SAGEMAKER_ENDPOINT_NAME" = "gte-base-endpoint"
  # for local development NLB_URL can point to a local front office
  "NLB_URL" = "http://nlb-dev-649f929e99958326.elb.eu-central-1.amazonaws.com"
}
layers = ["arn:aws:lambda:eu-central-1:017000801446:layer:AWSLambdaPowertoolsPythonV2-Arm64:46"]
