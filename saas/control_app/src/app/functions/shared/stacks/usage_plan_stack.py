import typing
from aws_cdk import Stack
from constructs import Construct
import aws_cdk.aws_apigateway as apigateway


class UsagePlanStack(Stack):

    def __init__(self, scope: Construct, construct_id: str, **kwargs) -> None:
        super().__init__(scope, construct_id, **kwargs)

        # required
        api_id = scope.node.get_context("api_id")
        tenant_id = scope.node.get_context("tenant_id")
        stage_name = scope.node.get_context("stage_name")
        api_key_value = scope.node.get_context("api_key_value")

        # optional
        limit = scope.node.try_get_context("limit") or "10000"
        period = scope.node.try_get_context("period") or "DAY"
        rate_limit = scope.node.try_get_context("rate_limit") or "10"
        burst_limit = scope.node.try_get_context("burst_limit") or "5"

        api = typing.cast(apigateway.RestApi, apigateway.RestApi.from_rest_api_id(
            self, id="Api", rest_api_id=api_id))

        throttle = apigateway.ThrottleSettings(
            burst_limit=int(burst_limit), rate_limit=int(rate_limit))
        quota = apigateway.QuotaSettings(
            limit=int(limit), period=apigateway.Period[period])

        plan = api.add_usage_plan(f'UsagePlan-{tenant_id}',
                                  throttle=throttle, quota=quota)
        cfnPlan = typing.cast(apigateway.CfnUsagePlan, plan.node.default_child)

        cfnPlan.add_property_override("ApiStages", [
            {
                "ApiId": api_id,
                "Stage": stage_name,
                # Can also specify limits for each endpoint
                # "Throttle": {
                #     "/": {
                #         "BurstLimit": 123,
                #         "RateLimit": 123
                #     }
                # }
            }
        ])

        key = apigateway.ApiKey(
            self, 'ApiKey', api_key_name='Tenant-key', value=api_key_value)
        cfnKey = typing.cast(apigateway.CfnApiKey, key.node.default_child)
        cfnKey.add_property_override('StageKeys', [
            {
                "RestApiId": api_id,
                "StageName": stage_name
            }
        ])

        plan.add_api_key(key)
