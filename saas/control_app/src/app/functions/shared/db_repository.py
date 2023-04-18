from abc import abstractmethod
import boto3
from app.functions.shared.tenant import Tenant
# import logging
# logging.getLogger('botocore').setLevel(logging.DEBUG)


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


class AwsDbRepository(DbRepository):

    @abstractmethod
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
            return Tenant(response['Item'])
        
        return None
