from typing import Callable

from TenantManagement.functions.shared.tenant import Tenant
from TenantManagement.functions.shared.db_repository import DbRepository
from TenantManagement.functions.shared.tenant import DeploymentState

FAKE_TENANT_1 = {
    "auth_keys": {
        "authKey1": {"group": "FRONT_OFFICE"},
        "authKey2": {"group": "BACK_OFFICE"},
    },
    "plan_keys": {
        "users": "planKey1",
        "semantic_search": "planKey1",
        "personalized_documents": "planKey1",
        "documents": "planKey2",
        "candidates": "planKey2"
    },
    "dataId": "tenant1",
    "email": "tenant@tenants.com"
}


def fake_tenant_db():
    return FakeDbRepository("", "", lambda: Tenant.from_json(FAKE_TENANT_1))


def fake_no_tenant_db():
    return FakeDbRepository("", "", lambda: None)


class FakeDbRepository(DbRepository):
    _get_tenant: Callable[[], Tenant | None]

    def __init__(self, endpoint_url: str, table_name: str, get_tenant: Callable[[], Tenant | None]) -> None:
        self._get_tenant = get_tenant
        super().__init__(endpoint_url, table_name, "eu-local")

    def get_tenant(self, _tenant_id: str) -> Tenant | None:
        return self._get_tenant()

    def get_tenant_by_email(self, email: str) -> Tenant | None:
        raise NotImplementedError

    def save_new_tenant(self, tenant: Tenant) -> Tenant:
        raise NotImplementedError

    def create_tenant(self, email: str, tenant_id: str, deployment_state: DeploymentState, auth_keys: dict | None = None, plan_keys: dict | None = None) -> Tenant:
        raise NotImplementedError
