from enum import Enum

class PolicyEffect(Enum):
    Deny = 0
    Allow = 1


def build_policy(api_token: str, methodArn: str, effect: PolicyEffect):
    return {
        "principalId": "customer_id_" + api_token,
        # used by the usage plan
        "usageIdentifierKey": api_token,
        "policyDocument": {
            "Version": "2012-10-17",
            "Statement": [
                {
                    "Action": "execute-api:Invoke",
                    "Effect": effect.name,
                    "Resource": methodArn,
                },
            ],
        },
    }


# import requests
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

    apiToken = event["authorizationToken"]
    methodArn = event["methodArn"]

    return build_policy(api_token=apiToken, effect=PolicyEffect.Deny)
