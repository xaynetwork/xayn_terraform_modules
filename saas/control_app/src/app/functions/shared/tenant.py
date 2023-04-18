#pylint: disable=too-many-locals

from enum import Enum
import re
from app.functions.shared.auth_context import AuthContext, NotAuthorizedContext, AuthorizedContext

# Example Tenant
# {
#     auth_keys: {
#         authKey1: { type: "FRONT_OFFICE", expires="31122023" },
#         authKey2: { type: "BACK_OFFICE" },
#         authKey3: { type: "FRONT_OFFICE" }
#     },
#     plan_keys: {
#         users: plan1
#         documents: plan2
#         semantic_search: plan1
#         ...
#     }
# }


class AuthPathGroups(Enum):
    FRONT_OFFICE = ['users', 'semantic_search', 'personalized_documents']
    BACK_OFFICE = ['documents', 'candidates']


class Tenant:
    _data: dict[str]

    def __init__(self, data: dict):
        self._data = data

    def get_authorization_context(self, method_arn: str, auth_key: str) -> AuthContext:
        # i.e. arn:aws:execute-api:eu-central-1:917039226361:aidokeulnk/default/DELETE/documents
        # 3: region
        # 4: awsAccountId
        # 5: path
        # path:
        # 0: restId
        # 1: stage
        # 2: method
        # 3..path.size: resource segements
        arn_prefix, aws, arn_method, region, account, api_id, api_version, method, path = (
            re.split(r':|\/', method_arn) + [None])[:9]

        tenant_map = self._data
        if auth_key in tenant_map['auth_keys']:
            paths_group = tenant_map['auth_keys'][auth_key]['type']
            auth_paths = AuthPathGroups[paths_group].value
            if path in auth_paths:
                method_arns = map(
                    lambda x: f"{arn_prefix}:{aws}:{arn_method}:{region}:{account}:{api_id}/{api_version}/{method}/{x}", auth_paths)
                return AuthorizedContext(plan_key=tenant_map['plan_keys'][path], method_arns=list(method_arns))

        return NotAuthorizedContext(method_arns=[method_arn])
