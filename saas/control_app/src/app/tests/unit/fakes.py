from typing import Callable
from app.functions.shared.tenant import Tenant
from app.functions.shared.db_repository import DbRepository

FAKE_TENANT_1 = {
    "auth_keys": {
        "authKey1": {"type": "FRONT_OFFICE"},
        "authKey2": {"type": "BACK_OFFICE"},
    },
    "plan_keys": {
        "users": "planKey1",
        "semantic_search": "planKey1",
        "personalized_documents": "planKey1",
        "documents": "planKey2",
        "candidates": "planKey2"
    }
}


def fake_tenant():
    return FakeDbRepository("", "", lambda: Tenant(data=FAKE_TENANT_1))


class FakeDbRepository(DbRepository):
    _get_tenant: Callable[[], Tenant]

    def __init__(self, endpoint_url: str, table_name: str, get_tenant: Callable[[], Tenant]) -> None:
        self._get_tenant = get_tenant
        super().__init__(endpoint_url, table_name, "eu-local")

    def get_tenant(self, tenant_id: str) -> Tenant:
        return self._get_tenant()
