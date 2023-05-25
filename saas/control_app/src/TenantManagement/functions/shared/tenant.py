# pylint: disable=too-many-locals

from __future__ import annotations
from enum import Enum
import re
from strenum import StrEnum
from TenantManagement.functions.shared.auth_context import AuthContext, UnauthorizedContext, AuthorizedContext
from TenantManagement.functions.shared.tenant_utils import create_secure_string
from TenantManagement.functions.shared import tenant_utils

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


class SerializeException(Exception):
    pass


class DeploymentState(StrEnum):
    NEEDS_UPDATE = "NEEDS_UPDATE"
    UPDATED_IN_PROGRESS = "UPDATED_IN_PROGRESS"
    DEPLOYED = "DEPLOYED"


class Endpoint(StrEnum):
    USERS = "users"
    SEMANTIC_SEARCH = "semantic_search"
    PERSONALIZED_DOCUMENTS = "personalized_documents"
    DOCUMENTS = "documents"
    CANDIDATES = "candidates"


class AuthPathGroup(Enum):
    FRONT_OFFICE = [Endpoint.USERS,
                    Endpoint.SEMANTIC_SEARCH, Endpoint.SEMANTIC_SEARCH]
    BACK_OFFICE = [Endpoint.DOCUMENTS, Endpoint.CANDIDATES]

    def __eq__(self, other):
        if self.__class__ is other.__class__:
            return self.value == other.value
        return NotImplemented


class AuthKey():
    _group: AuthPathGroup

    def __init__(self, group: AuthPathGroup) -> None:
        self._group = group

    @staticmethod
    def from_json(data: dict):
        if 'group' not in data:
            raise SerializeException('No group in AuthKey json')
        return AuthKey(AuthPathGroup[data["group"]])

    @property
    def group(self) -> AuthPathGroup:
        return self._group

    def to_json(self) -> dict:
        return {"group": self.group.name}

    def __eq__(self, other):
        if self.__class__ is other.__class__:
            return self.to_json() == other.to_json()
        return NotImplemented


class Tenant:

    _id: str
    _auth_keys: dict[str, AuthKey]
    _plan_keys: dict[Endpoint, str]
    _deployment_state: DeploymentState

    @staticmethod
    def create_default(email: str) -> Tenant:
        usage_plan_key = create_secure_string()
        auth_keys = {}
        plan_keys = {}
        if not auth_keys:
            auth_keys[create_secure_string()] = AuthKey(
                group=AuthPathGroup.FRONT_OFFICE)
            auth_keys[create_secure_string()] = AuthKey(
                group=AuthPathGroup.BACK_OFFICE)
        for endpoint in Endpoint:
            plan_keys[endpoint] = usage_plan_key

        return Tenant(email=email, id=tenant_utils.create_id(), auth_keys=auth_keys, plan_keys=plan_keys, deployment_state=DeploymentState.NEEDS_UPDATE)

    @staticmethod
    def from_json(json: dict):
        auth_keys: dict = json['auth_keys'] if 'auth_keys' in json else {}
        plan_keys: dict = json['plan_keys'] if 'plan_keys' in json else {}
        auth_keys = dict(
            map(lambda item: (item[0], AuthKey.from_json(item[1])), auth_keys.items()))
        plan_keys = dict(
            map(lambda item: (Endpoint(item[0]), item[1]), plan_keys.items()))
        state = DeploymentState[json["deployment_state"]]
        return Tenant(id=json['id'], auth_keys=auth_keys, plan_keys=plan_keys, email=json['email'], deployment_state=state)

    # pylint: disable=invalid-name
    # pylint: disable=redefined-builtin

    def __init__(self, id: str, auth_keys: dict[str, AuthKey], plan_keys: dict[Endpoint, str], email: str, deployment_state: DeploymentState):
        self._id = id
        self._auth_keys = auth_keys or {}
        self._plan_keys = plan_keys or {}
        self._email = email
        self._deployment_state = deployment_state

    @property
    def id(self) -> str:
        return self._id

    @property
    def email(self) -> str:
        return self._email

    @property
    def auth_keys(self) -> dict[str, AuthKey]:
        return self._auth_keys

    @property
    def plan_keys(self) -> dict[Endpoint, str]:
        return self._plan_keys

    @property
    def deployment_state(self) -> DeploymentState:
        return self._deployment_state

    def get_auth_keys(self, group: AuthPathGroup) -> list[str]:
        keys = []
        for (k, v) in self._auth_keys.items():
            if v.group is group:
                keys.append(k)
        return keys

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

        if auth_key in self._auth_keys:
            paths_group = self._auth_keys[auth_key].group
            auth_paths = paths_group.value
            endpoint_path = Endpoint(path)
            if endpoint_path in auth_paths:
                method_arns = map(
                    lambda x: f"{arn_prefix}:{aws}:{arn_method}:{region}:{account}:{api_id}/{api_version}/{method}/{x}", auth_paths)
                return AuthorizedContext(plan_key=self._plan_keys[endpoint_path], method_arns=list(method_arns))

        return UnauthorizedContext(method_arns=[method_arn])

    def __eq__(self, other) -> bool:
        """Overrides the default implementation"""
        if isinstance(other, Tenant):
            return self.id == other.id and self.email == other.email and self.auth_keys == other.auth_keys and self.plan_keys == other.plan_keys
        return NotImplemented
