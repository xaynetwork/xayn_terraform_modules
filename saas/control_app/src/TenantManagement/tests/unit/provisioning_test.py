import json
from dataclasses import replace
from TenantManagement.functions import provisioning
from TenantManagement.tests.unit.fakes import (
    fake_no_tenant_db,
    FakeDiscoveryEngineRepository,
)
from TenantManagement.functions.shared.deployment_state import DeploymentState


def _event(path, email) -> dict:
    return {
        "body": json.dumps({"email": email}),
        "httpMethod": "POST",
        "path": f"/{path}",
    }


def test_provisioning_should_create_user_with_new_email():
    db = fake_no_tenant_db()
    data = provisioning.handle(
        _event("signup", "simon.joecks@xayn.com"), db, FakeDiscoveryEngineRepository()
    )

    tenant = db.get_tenant_by_email("simon.joecks@xayn.com")

    assert "statusCode" in data
    assert data["statusCode"] == 204
    assert tenant
    assert tenant.deployment_state is DeploymentState.NEEDS_UPDATE


def test_provisioning_should_delete_existing_user_with_email():
    db = fake_no_tenant_db()
    data = provisioning.handle(
        _event("signup", "simon.joecks@xayn.com"), db, FakeDiscoveryEngineRepository()
    )
    tenant = db.get_tenant_by_email("simon.joecks@xayn.com")
    db.update_tenant(replace(tenant, deployment_state=DeploymentState.DEPLOYED))

    data = provisioning.handle(
        _event("delete", "simon.joecks@xayn.com"), db, FakeDiscoveryEngineRepository()
    )
    tenant = db.get_tenant_by_email("simon.joecks@xayn.com")

    assert "statusCode" in data
    assert data["statusCode"] == 204
    assert tenant
    assert tenant.deployment_state is DeploymentState.NEEDS_DELETION


def test_provisioning_should_not_delete_non_existing_tenant():
    db = fake_no_tenant_db()
    data = provisioning.handle(
        _event("signup", "simon.joecks@xayn.com"), db, FakeDiscoveryEngineRepository()
    )
    data = provisioning.handle(
        _event("delete", "robert@xayn.com"), db, FakeDiscoveryEngineRepository()
    )

    assert "statusCode" in data
    assert data["statusCode"] == 400


def test_provisioning_should_not_delete_tenant_that_is_still_not_deployed():
    db = fake_no_tenant_db()
    data = provisioning.handle(
        _event("signup", "simon.joecks@xayn.com"), db, FakeDiscoveryEngineRepository()
    )
    data = provisioning.handle(
        _event("delete", "simon.joecks@xayn.com"), db, FakeDiscoveryEngineRepository()
    )

    assert "statusCode" in data
    assert data["statusCode"] == 400
