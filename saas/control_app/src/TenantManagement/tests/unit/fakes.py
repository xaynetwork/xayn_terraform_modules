from TenantManagement.functions.shared.tenant import Tenant
from TenantManagement.functions.shared.db_repository import DbRepository
from TenantManagement.functions.shared.tenant import DeploymentState
from TenantManagement.functions.shared.infra_repository import InfraRepository

FAKE_TENANT_1 = {
    "auth_keys": {
        "authKey1": {"group": "FRONT_OFFICE"},
        "authKey2": {"group": "BACK_OFFICE"},
    },
    "plan_keys": {
        "users": "planKey1",
        "semantic_search": "planKey1",
        "documents": "planKey2",
        "candidates": "planKey2",
    },
    "id": "tenant1",
    "email": "tenant@tenants.com",
    "deployment_state": "NEEDS_UPDATE",
}


def fake_tenant_db():
    return FakeDbRepository("", "", {"tenant1": Tenant.from_dict(FAKE_TENANT_1)})


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


class FakeInfraRepository(InfraRepository):
    def notify_stack_deployment(self):
        pass
