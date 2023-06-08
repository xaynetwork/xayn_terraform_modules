from TenantManagement.functions.shared.tenant import Tenant
from TenantManagement.functions.shared.db_repository import DbRepository
from TenantManagement.functions.shared.tenant import DeploymentState
from TenantManagement.functions.shared.discovery_engine_repository import (
    DiscoveryEngineRepository,
)

FRONT_OFFICE_KEY = "kLT338LumaJaNJ8jNiW1"
BACK_OFFICE_KEY = "NVU51pLO8zVXGdBNTflQ"
TENANT_ID = "53a09747-2942-46a8-8bba-ccb5d40dbe32"


def fake_tenant(front_office, back_office, tenant_id):
    # Changing any of those fields in the tenant model most likely needs a migration!
    return {
        "auth_keys": {
            front_office: {"group": "FRONT_OFFICE"},
            back_office: {"group": "BACK_OFFICE"},
        },
        "deployment_state": "DEPLOYED",
        "email": "bla@blub.de",
        "id": tenant_id,
        "plan_keys": {
            "candidates": "vE1aHDPrtDLinis1Q76o",
            "documents": "vE1aHDPrtDLinis1Q76o",
            "semantic_search": "vE1aHDPrtDLinis1Q76o",
            "users": "vE1aHDPrtDLinis1Q76o",
        },
    }


# pylint: disable=dangerous-default-value


def fake_tenant_db(tenant=None):
    if tenant is None:
        tenant = fake_tenant(FRONT_OFFICE_KEY, BACK_OFFICE_KEY, TENANT_ID)
    return FakeDbRepository("", "", {tenant["id"]: Tenant.from_dict(tenant)})


def fake_no_tenant_db():
    return FakeDbRepository("", "", {})


class FakeDbRepository(DbRepository):
    _tenants = {}

    def __init__(
        self, endpoint_url: str, table_name: str, tenants: dict[str, Tenant]
    ) -> None:
        self._tenants = tenants
        super().__init__(endpoint_url, table_name, "eu-local")

    def get_tenant(self, tenant_id: str) -> Tenant | None:
        return self._tenants[tenant_id] if tenant_id in self._tenants else None

    def get_tenant_by_email(self, email: str) -> Tenant | None:
        for v in self._tenants.values():
            if v.email == email:
                return v
        return None

    def save_tenant(self, tenant: Tenant) -> Tenant:
        self._tenants[tenant.id] = tenant
        return tenant

    def create_tenant(
        self,
        email: str,
        tenant_id: str,
        deployment_state: DeploymentState,
        auth_keys: dict | None = None,
        plan_keys: dict | None = None,
    ) -> Tenant:
        tenant = Tenant(
            email=email,
            id=tenant_id,
            auth_keys=auth_keys or {},
            deployment_state=deployment_state,
            plan_keys=plan_keys or {},
        )
        return self.save_tenant(tenant)

    def update_tenant(self, tenant: Tenant) -> Tenant:
        return self.save_tenant(tenant)


class FakeDiscoveryEngineRepository(DiscoveryEngineRepository):
    def notify_stack_deployment(self):
        pass
