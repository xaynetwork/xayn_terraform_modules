# pylint: disable=wrong-import-position
import os
import logging

from enum import Enum
import typing
from TenantManagement.functions.shared.auth_utils import try_decode_auth_key
from TenantManagement.functions.shared.auth_context import (
    AuthorizedContext,
    create_authorization_context,
)
from TenantManagement.functions.shared.db_repository import AwsDbRepository
from TenantManagement.functions.shared.db_repository import DbRepository


class PolicyEffect(Enum):
    """Effects for the AWS policy"""

    DENY = "Deny"
    ALLOW = "Allow"


def build_policy(
    api_token: str, tenant_id: str, method_arn: list[str], effect: PolicyEffect
):
    return {
        "principalId": tenant_id,
        # used by the usage plan
        "usageIdentifierKey": api_token,
        "policyDocument": {
            "Version": "2012-10-17",
            "Statement": [
                {
                    "Action": "execute-api:Invoke",
                    "Effect": effect.value,
                    "Resource": method_arn,
                },
            ],
        },
        # this can be used then by the API Gateway as: context.authorizer.principalId
        "context": {"principalId": tenant_id},
    }


def handle(event, repo: DbRepository):
    api_token = event.get("authorizationToken", "")
    method_arn = event.get("methodArn", "")

    tenant_id, auth_key = try_decode_auth_key(api_token)
    if tenant_id is None or auth_key is None:
        logging.error("Could not decode %s", api_token)
        return build_policy(api_token, "", [method_arn], effect=PolicyEffect.DENY)

    tenant = repo.get_tenant(tenant_id)
    if tenant is None:
        logging.error("No tenant found with id %s", tenant_id)
        return build_policy(api_token, "", [method_arn], effect=PolicyEffect.DENY)

    context = create_authorization_context(tenant, method_arn, auth_key)

    if context.is_authorized:
        return build_policy(
            typing.cast(AuthorizedContext, context).plan_key,
            tenant_id,
            context.method_arns,
            effect=PolicyEffect.ALLOW,
        )

    return build_policy(api_token, "", [method_arn], effect=PolicyEffect.DENY)


def lambda_handler(event, _context):
    """Sample pure Lambda function

    Parameters
    ----------
    event: dict, required
        API Gateway Lambda Proxy Input Format

        Event doc: https://docs.aws.amazon.com/apigateway/latest/developerguide/set-up-lambda-proxy-integrations.html#api-gateway-simple-proxy-for-lambda-input-format

    context: object, required
        Lambda Context runtime methods and attributes

        Context doc: https://docs.aws.amazon.com/lambda/latest/dg/python-context-object.html

    Returns
    ------
    API Gateway Lambda Proxy Output Format: dict

        Return doc: https://docs.aws.amazon.com/apigateway/latest/developerguide/set-up-lambda-proxy-integrations.html
    """
    region = os.environ["REGION"]
    db_table = os.environ["DB_TABLE"]
    db_endpoint = os.environ["DB_ENDPOINT"] if "DB_ENDPOINT" in os.environ else None

    db_repo = AwsDbRepository(
        endpoint_url=db_endpoint, table_name=db_table, region=region
    )
    return handle(event, db_repo)
