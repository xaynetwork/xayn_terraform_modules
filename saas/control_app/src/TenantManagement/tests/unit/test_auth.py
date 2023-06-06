# pylint: disable=redefined-outer-name
import pytest
import boto3
from TenantManagement.functions.shared.auth_utils import encode_auth_key
from TenantManagement.functions import authenticator
from TenantManagement.tests.unit.fakes import fake_tenant_db, fake_no_tenant_db
from TenantManagement.functions.shared.db_repository import AwsDbRepository


@pytest.fixture()
def apigw_correct_event():
    """Generates API GW Event"""

    return {
        "type": "TOKEN",
        "methodArn": "arn:aws:execute-api:eu-west-3:917039226361:4qnmcgc1lg/ESTestInvoke-stage/GET/documents",
        "authorizationToken": encode_auth_key("tenant1", "authKey2"),
    }


@pytest.fixture()
def apigw_incorrect_event():
    """Generates API GW Event"""

    return {
        "type": "TOKEN",
        "methodArn": "arn:aws:execute-api:eu-west-3:917039226361:4qnmcgc1lg/ESTestInvoke-stage/GET/documents",
        "authorizationToken": "dsjhagfsdjh",
    }


def test_lambda_should_return_allow(apigw_correct_event):
    data = authenticator.handle(apigw_correct_event, fake_tenant_db())

    assert "policyDocument" in data
    assert "Statement" in data["policyDocument"]
    assert "Effect" in data["policyDocument"]["Statement"][0]
    assert data["policyDocument"]["Statement"][0]["Effect"] == "Allow"


def test_lambda_should_return_deny_when_tenant_does_not_exist(apigw_correct_event):
    data = authenticator.handle(apigw_correct_event, fake_no_tenant_db())

    assert "policyDocument" in data
    assert "Statement" in data["policyDocument"]
    assert "Effect" in data["policyDocument"]["Statement"][0]
    assert data["policyDocument"]["Statement"][0]["Effect"] == "Deny"



@pytest.mark.skip(reason="Integration test")
def test_e2e_check_auth():
    boto3.setup_default_session(profile_name="AdministratorAccess-917039226361")
    repo = AwsDbRepository(
        region="eu-west-3",
        table_name="saas_tenants",
        endpoint_url=None
    )

    event = {
        "type": "TOKEN",
        "methodArn": "arn:aws:execute-api:eu-west-3:917039226361:4qnmcgc1lg/ESTestInvoke-stage/GET/documents",
        "authorizationToken": "NTNhMDk3NDctMjk0Mi00NmE4LThiYmEtY2NiNWQ0MGRiZTMyOk5WVTUxcExPOHpWWEdkQk5UZmxRCg==",
    }
    data = authenticator.handle(event, repo)

    
    assert "policyDocument" in data
    assert "Statement" in data["policyDocument"]
    assert "Effect" in data["policyDocument"]["Statement"][0]
    assert data["policyDocument"]["Statement"][0]["Effect"] == "Allow"

