from abc import abstractmethod
import boto3
from boto3.dynamodb.types import TypeDeserializer, TypeSerializer
from TenantManagement.functions.shared.tenant import Tenant, DeploymentState

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


class DbRepository:
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
    def save_tenant(self, tenant: Tenant) -> Tenant:
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
            "dynamodb", region_name=self._region, endpoint_url=self._endpoint_url
        )

        response = dynamodb.get_item(
            TableName=self._table_name, Key={"id": _serializer.serialize(tenant_id)}
        )

        if "Item" in response:
            return Tenant.from_json(self._deserialize(response["Item"]))

        return None

    def get_tenant_by_email(self, email: str) -> Tenant | None:
        dynamodb = boto3.client(
            "dynamodb", region_name=self._region, endpoint_url=self._endpoint_url
        )

        response = dynamodb.scan(
            ExpressionAttributeValues={
                ":email": _serializer.serialize(email),
            },
            FilterExpression="contains(email, :email)",
            TableName=self._table_name,
        )

        if len(response["Items"]) == 0:
            return None
        if len(response["Items"]) == 1:
            return Tenant.from_json(self._deserialize(response["Items"][0]))

        raise TooManyTenantsWithSameEmail(
            f"Found more than one tenant with email {email}"
        )

    def update_tenant(self, tenant: Tenant) -> Tenant:
        dynamodb = boto3.client(
            "dynamodb", region_name=self._region, endpoint_url=self._endpoint_url
        )

        auth_keys = dict(
            map(lambda item: (item[0], item[1].to_json()), tenant.auth_keys.items())
        )
        plan_keys = dict(
            map(lambda item: (item[0].value, item[1]), tenant.plan_keys.items())
        )

        response = dynamodb.update_item(
            TableName=self._table_name,
            Key={
                "id": _serializer.serialize(tenant.id),
            },
            ExpressionAttributeValues={
                ":email": _serializer.serialize(tenant.email),
                ":auth_keys": _serializer.serialize(auth_keys),
                ":plan_keys": _serializer.serialize(plan_keys),
                ":deployment_state": _serializer.serialize(
                    tenant.deployment_state.value
                ),
            },
            UpdateExpression="SET plan_keys = :plan_keys, auth_keys = :auth_keys, email = :email, deployment_state = :deployment_state",
        )

        if response["ResponseMetadata"]["HTTPStatusCode"] != 200:
            raise RequestException(f"Failed updating tenant: {response}")

        updated = self.get_tenant(tenant_id=tenant.id)
        # The request succeeded so we can be sure that the tenant also exists
        assert updated

        return updated

    def save_tenant(self, tenant: Tenant) -> Tenant:
        return self._create_tenant(
            email=tenant.email,
            tenant_id=tenant.id,
            auth_keys=tenant.auth_keys,
            plan_keys=tenant.plan_keys,
            deployment_state=tenant.deployment_state,
        )

    def _create_tenant(
        self,
        email: str,
        tenant_id: str,
        deployment_state: DeploymentState,
        auth_keys: dict | None = None,
        plan_keys: dict | None = None,
    ) -> Tenant:
        dynamodb = boto3.client(
            "dynamodb", region_name=self._region, endpoint_url=self._endpoint_url
        )

        tenant = self.get_tenant(tenant_id=tenant_id)
        if tenant is not None:
            raise TenantIdAlreadyInUseException(
                f"Tenant id: {tenant_id} already exists"
            )

        tenant = self.get_tenant_by_email(email=email)
        if tenant is not None:
            raise EmailAlreadyInUseException(f"Tenant email: {email} already exists")

        auth_keys = dict(
            map(lambda item: (item[0], item[1].to_json()), (auth_keys or {}).items())
        )
        plan_keys = dict(
            map(lambda item: (item[0].value, item[1]), (plan_keys or {}).items())
        )

        response = dynamodb.put_item(
            TableName=self._table_name,
            Item={
                "id": _serializer.serialize(tenant_id),
                "auth_keys": _serializer.serialize(auth_keys),
                "plan_keys": _serializer.serialize(plan_keys),
                "email": _serializer.serialize(email),
                "deployment_state": _serializer.serialize(deployment_state.value),
            },
        )
        if response["ResponseMetadata"]["HTTPStatusCode"] != 200:
            raise RequestException(f"Failed creating tenant: {response}")

        tenant = self.get_tenant(tenant_id=tenant_id)
        # The request succeeded so we can be sure that the tenant also exists
        assert tenant

        return tenant

    def _deserialize(self, input_dict: dict) -> dict:
        out = {}
        for k, v in input_dict.items():
            out[k] = _deserializer.deserialize(v)

        return out
