import json
from TenantManagement.functions import provisioning
from TenantManagement.tests.unit.fakes import fake_no_tenant_db, FakeInfraRepository
from TenantManagement.tests.unit.test_utils import get_root_module_path


def _event() -> dict:
    with open(
        f"{get_root_module_path()}/events/signup.json", "r", encoding="utf8"
    ) as f:
        return json.load(f)


def test_provisioning_should_create_user_with_new_email():
    data = provisioning.handle(_event(), fake_no_tenant_db(), FakeInfraRepository())

    assert "statusCode" in data
    assert data["statusCode"] == 204
