# pylint: disable=wrong-import-position
import os
import logging
# import sys

# sys.path.append(os.path.join(os.path.dirname(__file__), 'functions'))
from enum import Enum
from app.functions.shared.auth_utils import try_decode_auth_key
from app.functions.shared.auth_context import AuthorizedContext
from app.functions.shared.db_repository import AwsDbRepository
from app.functions.shared.db_repository import DbRepository

region = os.environ['REGION'] if 'REGION' in os.environ else "ddblocal"
db_table = os.environ['DB_TABLE'] if 'DB_TABLE' in os.environ else "saas"
db_endpoint = os.environ['DB_ENDPOINT'] if 'DB_ENDPOINT' in os.environ else None


class PolicyEffect(Enum):
    '''Effects for the AWS policy'''
    DENY = 'Deny'
    ALLOW = 'Allow'

def build_policy(api_token: str, method_arn: list[str], effect: PolicyEffect):
    return {
        "principalId": "customer_id_" + api_token,
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
    }


def handle(event, repo : DbRepository):
    api_token = event["authorizationToken"] if "authorizationToken" in event else ""
    method_arn = event["methodArn"] if "methodArn" in event else ""

    tenant_id, auth_key = try_decode_auth_key(api_token)
    if tenant_id == None or auth_key == None:
        logging.error("Could not decode %s", api_token)
        return build_policy(api_token, [method_arn], effect=PolicyEffect.DENY)
    
    tenant = repo.get_tenant(tenant_id=tenant_id)
    if tenant is None:
        logging.error("No tenant found with id %s", tenant_id)
        return build_policy(api_token, [method_arn], effect=PolicyEffect.DENY)
    
    context = tenant.get_authorization_context(method_arn, auth_key)
    
    if isinstance(context, AuthorizedContext):
        return build_policy(context.plan_key, context.method_arns, effect=PolicyEffect.ALLOW)

    return build_policy(api_token, [method_arn], effect=PolicyEffect.DENY)

def lambda_handler(event, context):
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
    db_repo = AwsDbRepository(endpoint_url=db_endpoint, table_name=db_table, region=region)
    handle(event, db_repo)
