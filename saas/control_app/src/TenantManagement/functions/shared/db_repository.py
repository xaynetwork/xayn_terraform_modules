from abc import abstractmethod
import boto3
from TenantManagement.functions.shared.tenant import Tenant
from boto3.dynamodb.types import (TypeDeserializer, TypeSerializer)

_deserializer = TypeDeserializer()
_serializer = TypeSerializer()


# import logging
# logging.getLogger('botocore').setLevel(logging.DEBUG)


class DbException(Exception):
    pass


class RequestException(DbException):
    pass


class EmailAlreadyInUseException(DbException):
    pass


class TenantIdAlreadyInUseException(DbException):
    pass


class TooManyTenantsWithSameEmail(DbException):
    pass


class DbRepository():
    _endpoint_url: str | None
    _table_name: str
    _region: str

    def __init__(self, endpoint_url: str | None, table_name: str, region: str) -> None:
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

    @abstractmethod
    def get_tenant_by_email(self, email: str) -> Tenant | None:
        pass

    @abstractmethod
    def update_tenant(self, tenant: Tenant) -> Tenant:
        pass


class AwsDbRepository(DbRepository):
    def get_tenant(self, tenant_id: str) -> Tenant | None:

        dynamodb = boto3.client(
            'dynamodb', region_name=self._region, endpoint_url=self._endpoint_url)

        response = dynamodb.get_item(
            TableName=self._table_name,
            Key={
                'dataType': _serializer.serialize('tenants'),
                'dataId': _serializer.serialize(tenant_id)
            }
        )

        if 'Item' in response:
            return Tenant.from_json(self._deserialize(response['Item']))

        return None

    def get_tenant_by_email(self, email: str) -> Tenant | None:
        dynamodb = boto3.client(
            'dynamodb', region_name=self._region, endpoint_url=self._endpoint_url)

        response = dynamodb.query(
            ExpressionAttributeValues={
                ':dataType': _serializer.serialize('tenants'),
                ':email': _serializer.serialize(email),
            },
            FilterExpression='contains(email, :email)',
            KeyConditionExpression='dataType = :dataType',
            TableName=self._table_name,
        )

        if 'Items' in response:
            if len(response['Items']) == 0:
                return None
            if len(response['Items']) == 1:
                return Tenant.from_json(self._deserialize(response['Items'][0]))

            raise TooManyTenantsWithSameEmail(
                f'Found more than one tenant with email {email}')

        return None

    def update_tenant(self, tenant: Tenant) -> Tenant:
        dynamodb = boto3.client(
            'dynamodb', region_name=self._region, endpoint_url=self._endpoint_url)

        auth_keys = dict(
            map(lambda item: (item[0], item[1].to_json()), tenant.auth_keys.items()))
        plan_keys = dict(
            map(lambda item: (item[0].value, item[1]), tenant.plan_keys.items()))

        response = dynamodb.update_item(
            TableName=self._table_name,
            Key={
                'dataType': _serializer.serialize('tenants'),
                'dataId': _serializer.serialize(tenant.id),
            },
            ExpressionAttributeValues={
                ':email': _serializer.serialize(tenant.email),
                ':auth_keys': _serializer.serialize(auth_keys),
                ':plan_keys': _serializer.serialize(plan_keys),
            },
            UpdateExpression='SET plan_keys = :plan_keys, auth_keys = :auth_keys, email = :email',
        )

        if response['ResponseMetadata']['HTTPStatusCode'] != 200:
            raise RequestException(f'Failed updating tenant: {response}')

        updated = self.get_tenant(tenant_id=tenant.id)
        # The request succeeded so we can be sure that the tenant also exists
        assert updated

        return updated

    def create_tenant(self, email: str, tenant_id: str) -> Tenant:
        dynamodb = boto3.client(
            'dynamodb', region_name=self._region, endpoint_url=self._endpoint_url)

        tenant = self.get_tenant(tenant_id=tenant_id)
        if tenant is not None:
            raise TenantIdAlreadyInUseException(
                f'Tenant id  {tenant_id} already exists')

        tenant = self.get_tenant_by_email(email=email)
        if tenant is not None:
            raise EmailAlreadyInUseException(
                f'Tenant email  {email} already exists')

        response = dynamodb.put_item(
            TableName=self._table_name,
            Item={
                'dataType': _serializer.serialize('tenants'),
                'dataId': _serializer.serialize(tenant_id),
                'auth_keys': _serializer.serialize({}),
                'plan_keys': _serializer.serialize({}),
                'email': _serializer.serialize(email),
            }
        )
        if response['ResponseMetadata']['HTTPStatusCode'] != 200:
            raise RequestException(f'Failed creating tenant: {response}')

        tenant = self.get_tenant(tenant_id=tenant_id)
        # The request succeeded so we can be sure that the tenant also exists
        assert tenant

        return tenant

    def _deserialize(self, input_dict: dict) -> dict:
        out = {}
        for (k, v) in input_dict.items():
            out[k] = _deserializer.deserialize(v)

        return out
