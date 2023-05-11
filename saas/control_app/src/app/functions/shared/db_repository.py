from abc import abstractmethod
import boto3
from app.functions.shared.tenant import Tenant
# import logging
# logging.getLogger('botocore').setLevel(logging.DEBUG)


class DbException(Exception):
    pass


class EmailAlreadyInUseException(DbException):
    pass


class TenantIdAlreadyInUseException(DbException):
    pass


class DbRepository():
    _endpoint_url: str
    _table_name: str
    _region: str

    def __init__(self, endpoint_url: str, table_name: str, region: str) -> None:
        self._endpoint_url = endpoint_url
        self._table_name = table_name
        self._region = region

    @abstractmethod
    def get_tenant(self, tenant_id: str) -> Tenant:
        pass

    @abstractmethod
    def create_tenant(self, email: str, tenant_id: str) -> Tenant:
        """Creates a tenant with a unique email. 
        If the email is already taken returns a EmailAlreadyInUseException. 
        If the tenantId is already taken returns a TenantIdAlreadyInUseException. 
        """
        pass


class AwsDbRepository(DbRepository):

    def get_tenant(self, tenant_id: str):
        dynamodb = boto3.client(
            'dynamodb', region_name=self._region, endpoint_url=self._endpoint_url)

        response = dynamodb.get_item(
            TableName=self._table_name,
            Key={
                'dataType': {'S': 'tenants'},
                'dataId': {'S': tenant_id}
            }
        )

        if 'Item' in response:
            return Tenant.from_json(response['Item'])

        return None

    def create_tenant(self, email: str, tenant_id: str) -> Tenant:
        dynamodb = boto3.client(
            'dynamodb', region_name=self._region, endpoint_url=self._endpoint_url)

        response = dynamodb.put_item(
            TableName=self._table_name,
            Item={
                'dataType': 'tenants',
                'dataId': tenant_id,
                'auth_keys': {},
                'plan_keys': {},
                'email': email,
            }
        )
       
        return Tenant.from_json(response)
