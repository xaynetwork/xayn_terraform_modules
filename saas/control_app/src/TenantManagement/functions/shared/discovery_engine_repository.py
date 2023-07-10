import requests
from TenantManagement.functions.shared.auth_utils import get_auth
from TenantManagement.functions.shared.logging import logging

_SILO_MANAGEMENT_ENDPOINT = "_ops/silo_management"


class DiscoveryEngineException(Exception):
    pass


class DiscoveryEngineRepository:
    def create_tenant(self, tenant_id: str):
        pass

    def delete_tenant(self, tenant_id: str):
        pass


class HttpDiscoveryEngineRepository(DiscoveryEngineRepository):
    _region: str
    _api_host: str

    def __init__(self, region: str, api_host: str) -> None:
        self._api_host = api_host
        self._region = region

    def create_tenant(self, tenant_id: str) -> bool:
        data = self.create_operation("CreateTenant", tenant_id)
        # use the base url without a potential stage name
        host = self._api_host.split("/")[0]
        auth = get_auth(region=self._region, host=host)
        response = requests.post(
            url=f"https://{self._api_host}/{_SILO_MANAGEMENT_ENDPOINT}",
            timeout=1000,
            json=data,
            auth=auth,
        )
        if response.status_code >= 200 and response.status_code < 300:
            return True

        raise DiscoveryEngineException(
            f"{response.status_code} : {response.reason}  - {response.content}"
        )

    def delete_tenant(self, tenant_id: str):
        data = self.create_operation("DeleteTenant", tenant_id)
        # use the base url without a potential stage name
        host = self._api_host.split("/")[0]
        auth = get_auth(region=self._region, host=host)
        response = requests.post(
            url=f"https://{self._api_host}/{_SILO_MANAGEMENT_ENDPOINT}",
            timeout=1000,
            json=data,
            auth=auth,
            headers={"Content-Type": "application/json"},
        )
        if response.status_code >= 200 and response.status_code < 300:
            return True

        logging.error(
            f"Failed request to {_SILO_MANAGEMENT_ENDPOINT} - {response.status_code}, {response.reason}, {response.content}"
        )
        raise DiscoveryEngineException(
            f"{response.status_code} : {response.reason}  - {response.content}"
        )

    def create_operation(self, operation: str, tenant_id: str) -> dict:
        return {
            "operations": [
                {operation: {"tenant_id": tenant_id}},
            ]
        }
