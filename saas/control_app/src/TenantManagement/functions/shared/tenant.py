from __future__ import annotations
from dataclasses import dataclass
from enum import Enum
from strenum import StrEnum
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
    NEEDS_DELETION = "NEEDS_DELETION"
    DELETION_IN_PROGRESS = "DELETION_IN_PROGRESS"
    DELETED = "DELETED"
    UPDATE_FAILED = "UPDATE_FAILED"
    DELETION_FAILED = "DELETION_FAILED"


class Endpoint(StrEnum):
    USERS = "users"
    SEMANTIC_SEARCH = "semantic_search"
    DOCUMENTS = "documents"
    CANDIDATES = "candidates"

    @classmethod
    def find_endpoint(cls, value: str | None) -> Endpoint | None:
        """Does not throw when not finding an endpoint, which is safer for checking arbitrary values."""
        for endpoint in Endpoint:
            if endpoint.value == value:
                return endpoint
        return None


@dataclass(frozen=True)
class AuthPathGroup(Enum):
    FRONT_OFFICE = [Endpoint.USERS, Endpoint.SEMANTIC_SEARCH]
    BACK_OFFICE = [Endpoint.DOCUMENTS, Endpoint.CANDIDATES]


@dataclass(frozen=True)
class AuthKey:
    group: AuthPathGroup

    @staticmethod
    def from_dict(data: dict):
        if "group" not in data:
            raise SerializeException("No group in AuthKey dict")
        return AuthKey(AuthPathGroup[data["group"]])

    def to_dict(self) -> dict:
        return {"group": self.group.name}


@dataclass(frozen=True)
class Tenant:
    id: str
    email: str
    auth_keys: dict[str, AuthKey]
    plan_keys: dict[Endpoint, str]
    deployment_state: DeploymentState

    @staticmethod
    def create_default(email: str) -> Tenant:
        usage_plan_key = create_secure_string()
        auth_keys = {}
        plan_keys = {}
        if not auth_keys:
            auth_keys[create_secure_string()] = AuthKey(
                group=AuthPathGroup.FRONT_OFFICE
            )
            auth_keys[create_secure_string()] = AuthKey(group=AuthPathGroup.BACK_OFFICE)
        for endpoint in Endpoint:
            plan_keys[endpoint] = usage_plan_key

        return Tenant(
            email=email,
            id=tenant_utils.create_id(),
            auth_keys=auth_keys,
            plan_keys=plan_keys,
            deployment_state=DeploymentState.NEEDS_UPDATE,
        )

    @staticmethod
    def from_dict(data: dict):
        auth_keys: dict = data["auth_keys"] if "auth_keys" in data else {}
        plan_keys: dict = data["plan_keys"] if "plan_keys" in data else {}
        auth_keys = dict(
            map(lambda item: (item[0], AuthKey.from_dict(item[1])), auth_keys.items())
        )
        plan_keys = dict(
            map(lambda item: (Endpoint(item[0]), item[1]), plan_keys.items())
        )
        state = DeploymentState[data["deployment_state"]]
        return Tenant(
            id=data["id"],
            auth_keys=auth_keys,
            plan_keys=plan_keys,
            email=data["email"],
            deployment_state=state,
        )

    def get_auth_keys(self, group: AuthPathGroup) -> list[str]:
        keys = []
        for k, v in self.auth_keys.items():
            if v.group is group:
                keys.append(k)
        return keys
