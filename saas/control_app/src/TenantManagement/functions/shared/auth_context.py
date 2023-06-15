# pylint: disable=too-many-locals
from dataclasses import dataclass
import re

from TenantManagement.functions.shared.tenant import Tenant, Endpoint


@dataclass
class AuthContext:
    method_arns: list[str]
    is_authorized: bool


@dataclass
class AuthorizedContext(AuthContext):
    plan_key: str


@dataclass
class UnauthorizedContext(AuthContext):
    pass


def create_authorization_context(
    tenant: Tenant, method_arn: str, auth_key: str
) -> AuthContext:
    # i.e. arn:aws:execute-api:eu-central-1:917039226361:aidokeulnk/default/DELETE/documents
    # 3: region
    # 4: awsAccountId
    # 5: path
    # path:
    # 0: restId
    # 1: stage
    # 2: method
    # 3..path.size: resource segements
    (
        arn_prefix,
        aws,
        arn_method,
        region,
        account,
        api_id,
        api_version,
        method,
        path,
    ) = (re.split(r":|\/", method_arn) + [None])[:9]

    if auth_key in tenant.auth_keys:
        paths_group = tenant.auth_keys[auth_key].group
        auth_paths = paths_group.value
        endpoint_path = Endpoint.find_endpoint(path)
        if endpoint_path in auth_paths:
            method_arns = map(
                lambda x: f"{arn_prefix}:{aws}:{arn_method}:{region}:{account}:{api_id}/{api_version}/{method}/{x}",
                auth_paths,
            )
            method_arns_wildcards = map(
                lambda x: f"{arn_prefix}:{aws}:{arn_method}:{region}:{account}:{api_id}/{api_version}/{method}/{x}/*",
                auth_paths,
            )
            return AuthorizedContext(
                is_authorized=True,
                plan_key=tenant.plan_keys[endpoint_path],
                method_arns=list(method_arns) + list(method_arns_wildcards),
            )

    return UnauthorizedContext(is_authorized=False, method_arns=[method_arn])
