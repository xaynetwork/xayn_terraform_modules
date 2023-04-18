# pylint: disable=redefined-outer-name
import pytest
from app.functions.shared.auth_utils import encode_auth_key
from app.functions import authenticator
from app.tests.unit.fakes import fake_tenant


@pytest.fixture()
def apigw_event():
    """ Generates API GW Event"""

    return {
        "type": "TOKEN",
        "methodArn": "arn:aws:execute-api:eu-west-3:917039226361:4qnmcgc1lg/ESTestInvoke-stage/GET/documents",
        "authorizationToken": encode_auth_key('tenant1', 'authKey2')
    }


def test_lambda_should_return_deny(apigw_event):

    data = authenticator.handle(apigw_event, fake_tenant())

    assert "policyDocument" in data
    assert "Statement" in data["policyDocument"]
    assert "Effect" in data["policyDocument"]["Statement"][0]
    assert data["policyDocument"]["Statement"][0]["Effect"] == "Allow"
