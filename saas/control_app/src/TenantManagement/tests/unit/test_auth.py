# pylint: disable=redefined-outer-name
import pytest
import boto3
from TenantManagement.functions.shared.auth_utils import encode_auth_key
from TenantManagement.functions import authenticator
from TenantManagement.tests.unit.fakes import (
    fake_tenant_db,
    fake_no_tenant_db,
    FRONT_OFFICE_KEY,
    BACK_OFFICE_KEY,
    TENANT_ID,
)
from TenantManagement.functions.shared.db_repository import AwsDbRepository

ARN = "arn:aws:execute-api:eu-west-3:917039226361:4qnmcgc1lg/ESTestInvoke-stage/GET/"


def apigw_event(tenant_id: str, auth_key: str, endpoint: str):
    """Generates API GW Event"""

    return {
        "type": "TOKEN",
        "methodArn": f"{ARN}{endpoint}",
        "authorizationToken": encode_auth_key(tenant_id, auth_key),
    }


def test_auth_should_return_allow():
    data = authenticator.handle(
        apigw_event(TENANT_ID, FRONT_OFFICE_KEY, "users"), fake_tenant_db()
    )

    assert data["policyDocument"]["Statement"][0]["Effect"] == "Allow"


def test_frontoffice_allow_should_contain_users_and_semantic_search():
    data = authenticator.handle(
        apigw_event(TENANT_ID, FRONT_OFFICE_KEY, "users"), fake_tenant_db()
    )

    assert data["policyDocument"]["Statement"][0]["Resource"] == [
        f"{ARN}users",
        f"{ARN}semantic_search",
    ]


def test_backoffice_allow_should_contain_docuemtns_and_candidates():
    data = authenticator.handle(
        apigw_event(TENANT_ID, BACK_OFFICE_KEY, "documents"), fake_tenant_db()
    )

    assert data["policyDocument"]["Statement"][0]["Resource"] == [
        f"{ARN}documents",
        f"{ARN}candidates",
    ]


def test_allow_should_contain_the_userid_as_pricipal():
    data = authenticator.handle(
        apigw_event(TENANT_ID, FRONT_OFFICE_KEY, "users"), fake_tenant_db()
    )

    assert data["principalId"] == TENANT_ID


def test_deny_should_not_contain_the_userid_as_pricipal():
    data = authenticator.handle(
        apigw_event(TENANT_ID, FRONT_OFFICE_KEY, "documents"), fake_tenant_db()
    )

    assert data["principalId"] == ""


def test_auth_should_return_deny_when_tenant_does_not_exist():
    data = authenticator.handle(
        apigw_event(TENANT_ID, FRONT_OFFICE_KEY, "users"), fake_no_tenant_db()
    )

    assert data["policyDocument"]["Statement"][0]["Effect"] == "Deny"


def test_auth_should_return_deny_when_tenan_exist_but_wrong_endpoint_is_used():
    data = authenticator.handle(
        apigw_event(TENANT_ID, FRONT_OFFICE_KEY, "documents"), fake_tenant_db()
    )

    assert data["policyDocument"]["Statement"][0]["Effect"] == "Deny"


def test_auth_when_request_denied_only_return_the_same_resource():
    event = apigw_event(TENANT_ID, FRONT_OFFICE_KEY, "documents")
    data = authenticator.handle(event, fake_tenant_db())

    assert data["policyDocument"]["Statement"][0]["Resource"] == [event["methodArn"]]


@pytest.mark.skip(reason="Integration test")
def test_e2e_check_auth():
    boto3.setup_default_session(profile_name="AdministratorAccess-917039226361")
    repo = AwsDbRepository(
        region="eu-west-3", table_name="saas_tenants", endpoint_url=None
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
