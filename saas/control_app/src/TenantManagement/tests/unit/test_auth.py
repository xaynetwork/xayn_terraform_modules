# pylint: disable=redefined-outer-name
import pytest
from TenantManagement.functions.shared.auth_utils import encode_auth_key
from TenantManagement.functions import authenticator
from TenantManagement.tests.unit.fakes import (
    fake_tenant_db, fake_no_tenant_db)


@pytest.fixture()
def apigw_correct_event():
    """ Generates API GW Event"""

    return {
        "type": "TOKEN",
        "methodArn": "arn:aws:execute-api:eu-west-3:917039226361:4qnmcgc1lg/ESTestInvoke-stage/GET/documents",
        "authorizationToken": encode_auth_key('tenant1', 'authKey2')
    }


@pytest.fixture()
def apigw_incorrect_event():
    """ Generates API GW Event"""

    return {
        "type": "TOKEN",
        "methodArn": "arn:aws:execute-api:eu-west-3:917039226361:4qnmcgc1lg/ESTestInvoke-stage/GET/documents",
        "authorizationToken": "dsjhagfsdjh"
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
