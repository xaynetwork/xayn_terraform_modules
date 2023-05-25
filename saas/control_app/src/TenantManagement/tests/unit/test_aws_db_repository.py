import boto3
import pytest

from TenantManagement.functions.shared.db_repository import AwsDbRepository
from TenantManagement.functions.shared.tenant import (Tenant, AuthPathGroup)


@pytest.mark.skip(reason="Integration test")
def test_write_tenant():
    boto3.setup_default_session(aws_access_key_id='X',
                                aws_secret_access_key='X')
    repo = AwsDbRepository(endpoint_url='http://localhost:8000',
                           region="eu-west-3", table_name="saas_tenants")
    tenant = repo.save_tenant(tenant=Tenant.create_default(email="test@test.de"))
    assert tenant
    assert tenant.email == "test@test.de"


@pytest.mark.skip(reason="Integration test")
def test_check_tenant():
    boto3.setup_default_session(aws_access_key_id='X',
                                aws_secret_access_key='X')
    repo = AwsDbRepository(endpoint_url='http://localhost:8000',
                           region="eu-west-3", table_name="saas_tenants")
    tenant = repo.get_tenant_by_email(email="tes1t@test.de")
    assert tenant
    assert tenant.email == "test@test.de"

    front = tenant.get_auth_keys(group=AuthPathGroup.FRONT_OFFICE)
    back = tenant.get_auth_keys(group=AuthPathGroup.BACK_OFFICE)

    assert len(front) == 1
    assert len(back) == 1
