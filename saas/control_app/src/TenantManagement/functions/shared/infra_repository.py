from abc import abstractmethod
from botocore.exceptions import ClientError
from TenantManagement.functions.shared.cloudformation_boto_repository import CloudformationBotoRepository
from TenantManagement.functions.shared.stacks.usage_plan_stack import (UsagePlanStack)
import aws_cdk as cdk

from TenantManagement.functions.shared.tenant_utils import create_random_password


class InfraException(Exception):
    pass


class CreateUsagePlanResponse():
    def __init__(self, api_key_value: str) -> None:
        self._api_key_value = api_key_value

    @property
    def api_key_value(self):
        return self._api_key_value


class InfraRepository():
    def __init__(self, region: str, account_id: str, endpoint_url: str | None = None) -> None:
        self._endpoint_url = endpoint_url
        self._region = region
        self._account_id = account_id

    @abstractmethod
    def create_usage_plan(self, api_id: str, tenant_id: str, stage_name: str) -> CreateUsagePlanResponse:
        pass


class CdkInfraRepository(InfraRepository):

    def create_usage_plan(self, api_id: str, tenant_id: str, stage_name: str) -> CreateUsagePlanResponse:
        cdkboto = CloudformationBotoRepository(region=self._region, endpoint_url=self._endpoint_url)
        api_key_value = create_random_password()

        stack_name = f"UsagePlanStack-{tenant_id}"
        app = cdk.App(context={
            "tenant_id": tenant_id,
            "api_id": api_id,
            "stage_name": stage_name,
            "api_key_value": api_key_value
        })
        UsagePlanStack(app, stack_name, env=cdk.Environment(
            account=self._account_id, region=self._region))
        synth = app.synth()
        synth_dir = synth.directory

        cdkboto.create_update(stack_name=stack_name,
                              template=f"{synth_dir}/{stack_name}.template.json")

        return CreateUsagePlanResponse(api_key_value=api_key_value)




# Legacy Repo to deploy a Apikey change only using the AWS api, this is very fast but has no automatic rollback and management solution
# class BotoInfraRepository(InfraRepository):
#     def create_usage_plan(self, api_id: str, tenant_id: str, stage_name: str) -> CreateUsagePlanResponse:
#         (api_key_response, usage_plan_response, usage_plan_key_response) = (None, None, None)

#         try:
#             api_key_response = self._create_api_key_for_usage_plan(
#                 tenant_id=tenant_id, value=api_key_value)
#             usage_plan_response = self._create_usage_plan(
#                 tenant_id=tenant_id, stage_name=stage_name, api_id=api_id)
#             usage_plan_key_response = self._create_usage_api_key(
#                 key_id=api_key_response["id"], usage_plan_id=usage_plan_response["id"])
#         except InfraException as ie:
#             # TODO rollback all the changes
#             raise ie

#         return CreateUsagePlanResponse( api_key_value=api_key_response["value"])

#     def _create_api_key_for_usage_plan(self, tenant_id: str, value: str) -> dict:
#         try:
#             apigateway = boto3.client(
#                 'apigateway', region_name=self._region, endpoint_url=self._endpoint_url)

#             return apigateway.create_api_key(
#                 name=f'saas_api_plan_{tenant_id}',
#                 description=f'The API usage plan key for {tenant_id}, managed by provisioning.py',
#                 enabled=True,
#                 value=value,
#                 tags={
#                     'tenant': tenant_id
#                 })

#         except ClientError as e:
#             logging.error(
#                 f"Could not create api key with tenant_id: {str} {self._region} {self._endpoint_url}: {e.response['Error']['Code']}")
#             raise InfraException("Could not create api key.") from e

#     def _create_usage_plan(self, api_id: str,  tenant_id: str, stage_name: str) -> dict:
#         try:
#             apigateway = boto3.client(
#                 'apigateway', region_name=self._region, endpoint_url=self._endpoint_url)

#             return apigateway.create_usage_plan(
#                 name=f'{tenant_id}_usage_plan',
#                 description=f'A default usage plan for {tenant_id}',
#                 apiStages=[
#                     {
#                         'apiId': api_id,
#                         'stage': stage_name,
#                     },
#                 ],
#                 throttle={
#                     'burstLimit': 10,
#                     'rateLimit': 5
#                 },
#                 quota={
#                     'limit': 10000,
#                     'offset': 0,
#                     'period': 'DAY'
#                 },
#                 tags={
#                     'tenant': tenant_id
#                 }
#             )

#         except ClientError as e:
#             logging.error(
#                 f"Could not create usage plan tenant_id: {str} {self._region} {self._endpoint_url}: {e.response['Error']['Code']}")
#             raise InfraException("Could not create usage plan") from e

#     def _create_usage_api_key(self, usage_plan_id: str, key_id: str) -> str:
#         try:
#             apigateway = boto3.client(
#                 'apigateway', region_name=self._region, endpoint_url=self._endpoint_url)
#             return apigateway.create_usage_plan_key(
#                 usagePlanId=usage_plan_id,
#                 keyId=key_id,
#                 keyType='API_KEY'
#             )

#         except ClientError as e:
#             logging.error(
#                 f"Could not create usage plan key tenant_id: {str} {self._region} {self._endpoint_url}: {e.response['Error']['Code']}")
#             raise InfraException("Could not create usage plan key") from e
