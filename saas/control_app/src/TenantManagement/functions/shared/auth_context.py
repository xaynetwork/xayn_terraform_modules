# pylint: disable=too-many-locals

import re
from TenantManagement.functions.shared.tenant import Tenant, Endpoint


class AuthContext:
    _method_arns: list[str]
    _is_authorized: bool

    def __init__(self, method_arns: list[str], is_authorized: bool) -> None:
        self._is_authorized = is_authorized
        self._method_arns = method_arns

    @property
    def is_authorized(self) -> bool:
        return self._is_authorized

    @property
    def method_arns(self) -> list[str]:
        return self._method_arns


class AuthorizedContext(AuthContext):
    _plan_key: str

    def __init__(self, plan_key: str, method_arns: list[str]) -> None:
        self._plan_key = plan_key
        super().__init__(method_arns, True)

    @property
    def plan_key(self):
        return self._plan_key

    @property
    def method_arns(self) -> list[str]:
        return super().method_arns


class UnauthorizedContext(AuthContext):
    def __init__(self, method_arns: list[str]) -> None:
        super().__init__(method_arns, False)


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
                plan_key=tenant.plan_keys[endpoint_path],
                method_arns=list(method_arns) + list(method_arns_wildcards),
            )

    return UnauthorizedContext(method_arns=[method_arn])
