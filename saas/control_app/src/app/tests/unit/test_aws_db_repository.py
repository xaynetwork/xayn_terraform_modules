import os
from app.functions.shared.db_repository import AwsDbRepository
from app.functions.shared.tenant_utils import create_id
import boto3


def test_write_tenant(): 
    profile = os.environ.get('PROFILE_B2B_DEV')
    boto3.setup_default_session(profile_name=profile)
    repo = AwsDbRepository(endpoint_url='http://localhost:8000', region="eu-west-3", table_name="saas")
    repo.create_tenant(email="test@test.de", tenant_id=create_id())
