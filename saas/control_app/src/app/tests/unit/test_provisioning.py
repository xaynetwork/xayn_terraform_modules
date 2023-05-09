# pylint: disable=redefined-outer-name
import logging
import os
import sys
import pytest
from app.functions.shared.auth_utils import encode_auth_key
from app.functions import authenticator
from app.tests.unit.fakes import (fake_tenant, fake_no_tenant)
from app.functions.shared.infra_repository import BotoInfraRepository
import boto3




def test_create_api_key():
    profile = os.environ.get('PROFILE_B2B_DEV')
    boto3.setup_default_session(profile_name=profile)
    infra = BotoInfraRepository(region="eu-west-3")
    res = infra.create_usage_plan(tenant_id="test", api_id="4qnmcgc1lg", stage_name="default")

    
    logging.error(f"Finished test with ${res}")
