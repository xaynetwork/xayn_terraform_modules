import * as cdk from 'aws-cdk-lib';
import * as apigw from 'aws-cdk-lib/aws-apigateway';
import { Construct } from 'constructs';

// import * as sqs from 'aws-cdk-lib/aws-sqs';

export class UsagePlanStack extends cdk.Stack {
  constructor(scope: Construct, id: string, props?: cdk.StackProps) {
    super(scope, id, props);

    const apiId = scope.node.getContext("api_id")
    const tenantId = scope.node.getContext("tenant_id")
    const stageName = scope.node.getContext("stage_name")
    const apiKeyValue = scope.node.getContext("api_key_value")

    // optional
    const limit: number = +(scope.node.tryGetContext("limit") ?? "10000")
    const periodKey = (scope.node.tryGetContext("period") ?? "DAY") as keyof typeof apigw.Period
    const period = apigw.Period[periodKey]
    const rateLimit: number = +(scope.node.tryGetContext("rate_limit") ?? "10")
    const burstLimit: number = +(scope.node.tryGetContext("burst_limit") ?? "5")

    const api =
      apigw.RestApi.fromRestApiId(this, "Api", apiId) as apigw.RestApi

    const plan = api.addUsagePlan(
      `UsagePlan-${tenantId}`, { throttle: { rateLimit: rateLimit, burstLimit: burstLimit }, quota: { limit: limit, period: period } }
    )

    const cfnPlan = plan.node.defaultChild as apigw.CfnUsagePlan

    cfnPlan.addPropertyOverride(
      "ApiStages",
      [
        {
          "ApiId": apiId,
          "Stage": stageName,
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
      this, "ApiKey", { apiKeyName: `tenant_key_${tenantId}`, value: apiKeyValue }
    )
    const cfnKey = key.node.defaultChild as apigw.CfnApiKey
    cfnKey.addPropertyOverride(
      "StageKeys", [{ "RestApiId": apiId, "StageName": stageName }]
    )


    plan.addApiKey(key)
  }
}
