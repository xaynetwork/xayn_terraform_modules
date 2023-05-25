# pylint: disable=redefined-outer-name
import pytest
from TenantManagement.functions.shared.auth_utils import encode_auth_key
from TenantManagement.functions import authenticator
from TenantManagement.tests.unit.fakes import (fake_tenant_db, fake_no_tenant_db)

def event(path,token):
    """ Generates API GW Event"""

    return {
        "type": "TOKEN",
        "methodArn": f"arn:aws:execute-api:eu-west-3:917039226361:4qnmcgc1lg/ESTestInvoke-stage/GET/{path}",
        "authorizationToken": token
    }

def test_lambda_should_return_allow_candidates_path():

    data = authenticator.handle(event("candidates",encode_auth_key('tenant1', 'authKey2')), fake_tenant_db())

    assert "policyDocument" in data
    assert "Statement" in data["policyDocument"]
    assert "Effect" in data["policyDocument"]["Statement"][0]
    assert data["policyDocument"]["Statement"][0]["Effect"] == "Allow"

def test_lambda_should_return_allow_documents_path():

    data = authenticator.handle(event("documents",encode_auth_key('tenant1', 'authKey2')), fake_tenant_db())

    assert "policyDocument" in data
    assert "Statement" in data["policyDocument"]
    assert "Effect" in data["policyDocument"]["Statement"][0]
    assert data["policyDocument"]["Statement"][0]["Effect"] == "Allow"


def test_lambda_should_return_deny_when_tenant_does_not_exist():

    data = authenticator.handle(event("documents",encode_auth_key('tenant1', 'authKey2')), fake_no_tenant_db())

    assert "policyDocument" in data
    assert "Statement" in data["policyDocument"]
    assert "Effect" in data["policyDocument"]["Statement"][0]
    assert data["policyDocument"]["Statement"][0]["Effect"] == "Deny"

def test_lambda_should_return_deny_when_key_incorrect():

    data = authenticator.handle(event("documents",encode_auth_key('tenant1', 'authKey1')), fake_tenant_db())

    assert "policyDocument" in data
    assert "Statement" in data["policyDocument"]
    assert "Effect" in data["policyDocument"]["Statement"][0]
    assert data["policyDocument"]["Statement"][0]["Effect"] == "Deny"

def test_lambda_should_return_deny_when_key_empty():

    data = authenticator.handle(event("documents",encode_auth_key('tenant1', '')), fake_tenant_db())

    assert "policyDocument" in data
    assert "Statement" in data["policyDocument"]
    assert "Effect" in data["policyDocument"]["Statement"][0]
    assert data["policyDocument"]["Statement"][0]["Effect"] == "Deny"

def test_lambda_should_return_deny_when_tenant_incorrect_key_exist():

    data = authenticator.handle(event("documents",encode_auth_key('fa', 'authKey2')), fake_no_tenant_db())

    assert "policyDocument" in data
    assert "Statement" in data["policyDocument"]
    assert "Effect" in data["policyDocument"]["Statement"][0]
    assert data["policyDocument"]["Statement"][0]["Effect"] == "Deny"
