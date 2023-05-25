import os
import boto3
import pytest

from TenantManagement.functions.shared.db_repository import AwsDbRepository
from TenantManagement.functions.shared.tenant_utils import create_id
from TenantManagement.functions.shared.tenant import AuthPathGroup
from TenantManagement.functions.shared.tenant import DeploymentState


@pytest.mark.skip(reason="Integration test")
def test_write_tenant():
    profile = os.environ.get('PROFILE_B2B_DEV')
    boto3.setup_default_session(profile_name=profile)
    repo = AwsDbRepository(endpoint_url='http://localhost:8000',
                           region="eu-west-3", table_name="saas")
    tenant = repo.create_tenant(email="test@test.de", tenant_id=create_id(), deployment_state=DeploymentState.NEEDS_UPDATE)
    assert tenant
    assert tenant.email == "test@test.de"


@pytest.mark.skip(reason="Integration test")
def test_add_keys_to_tenant():
    boto3.setup_default_session(aws_access_key_id='X',
                                aws_secret_access_key='X')
    repo = AwsDbRepository(endpoint_url='http://localhost:8000',
                           region="eu-west-3", table_name="saas")
    tenant = repo.get_tenant_by_email(email="test@test.de")
    assert tenant
    assert tenant.email == "test@test.de"

    new_tenant = tenant.update_auth_defaults(usage_plan_key="blabla")

    assert new_tenant.email == tenant.email
    assert new_tenant.id == tenant.id
    front = new_tenant.get_auth_keys(group=AuthPathGroup.FRONT_OFFICE)
    back = new_tenant.get_auth_keys(group=AuthPathGroup.BACK_OFFICE)

    assert len(front) == 1
    assert len(back) == 1

    updated = repo.update_tenant(new_tenant)

    assert updated.auth_keys == new_tenant.auth_keys
    assert updated.plan_keys == new_tenant.plan_keys
    assert updated.email == new_tenant.email
    assert updated.id == new_tenant.id
    assert updated == new_tenant
