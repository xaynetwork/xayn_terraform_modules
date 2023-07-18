import base64
import binascii
import boto3
from aws_requests_auth.aws_auth import AWSRequestsAuth


def encode_auth_key(tenant_id: str, auth_key: str) -> str:
    return base64.b64encode(str.encode(f"{tenant_id}:{auth_key}")).decode("utf-8")


def try_decode_auth_key(encoded_auth_key: str) -> tuple[str | None, str | None]:
    """Returns a tuple with (tenantId, AuthKey) when encoded_auth_key is  base64encoded(tenenId:authKey)"""
    try:
        # Adds newlines every 76 characters as per RFC 2045, which need to be removed again
        decoded = base64.b64decode(encoded_auth_key).decode("utf-8").replace("\n", "")
        if ":" in decoded:
            (_id, key) = decoded.split(":", maxsplit=1)
            return (_id, key)

        return (None, None)
    except (binascii.Error, UnicodeDecodeError):
        return (None, None)


def get_auth(host, region):
    session = boto3.Session()
    credentials = session.get_credentials()
    auth = AWSRequestsAuth(
        aws_access_key=credentials.access_key,
        aws_secret_access_key=credentials.secret_key,
        aws_token=credentials.token,
        aws_host=host,
        aws_region=region,
        aws_service="execute-api",
    )
    return auth
