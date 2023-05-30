import * as cdk from 'aws-cdk-lib';
import * as apigw from 'aws-cdk-lib/aws-apigateway';
import { ApiGateway } from 'aws-cdk-lib/aws-events-targets';
import { Construct } from 'constructs';

// import * as sqs from 'aws-cdk-lib/aws-sqs';

export class UsagePlanStack extends cdk.Stack {
  constructor(scope: Construct, id: string, props?: cdk.StackProps) {
    super(scope, id, props);


    const api_id = scope.node.getContext("api_id")
    const tenant_id = scope.node.getContext("tenant_id")
    const stage_name = scope.node.getContext("stage_name")
    const api_key_value = scope.node.getContext("api_key_value")

    // optional
    const limit: number = +scope.node.tryGetContext("limit") ?? "10000"
    const period_key = (scope.node.tryGetContext("period") ?? "DAY") as keyof typeof apigw.Period
    const period = apigw.Period[period_key]
    const rate_limit: number = +scope.node.tryGetContext("rate_limit") ?? "10"
    const burst_limit: number = +scope.node.tryGetContext("burst_limit") ?? "5"

    const api =
      apigw.RestApi.fromRestApiId(this, "Api", api_id) as apigw.RestApi



    const plan = api.addUsagePlan(
      `UsagePlan-${tenant_id}`, { throttle: { rateLimit: rate_limit, burstLimit: burst_limit }, quota: { limit: limit, period: period } }
    )

    const cfnPlan = plan.node.defaultChild as apigw.CfnUsagePlan

    cfnPlan.addPropertyOverride(
      "ApiStages",
      [
        {
          "ApiId": api_id,
          "Stage": stage_name,
          // Can also specify limits for each endpoint
          // "Throttle": {
          //  "/": {
          //"BurstLimit": 123,
          //"RateLimit": 123
          // }
        }

      ],
    )

    const key = new apigw.ApiKey(
      this, "ApiKey", { apiKeyName: "Tenant-key", value: api_key_value }
    )
    const cfnKey = key.node.defaultChild as apigw.CfnApiKey
    cfnKey.addPropertyOverride(
      "StageKeys", [{ "RestApiId": api_id, "StageName": stage_name }]
    )

    plan.addApiKey(key)
  }
}
