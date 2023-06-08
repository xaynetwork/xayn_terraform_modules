import requests
from TenantManagement.functions.shared.auth_utils import get_auth


class DiscoveryEngineException(Exception):
    pass


class DiscoveryEngineRepository:
    def create_tenant(self, tenant_id: str):
        pass

    def delete_tenant(self, tenant_id: str):
        pass


class HttpDiscoveryEngineRepository(DiscoveryEngineRepository):
    _region: str
    _endpoint: str

    def __init__(self, region: str, endpoint: str) -> None:
        self._endpoint = endpoint
        self._region = region

    def create_tenant(self, tenant_id: str) -> bool:
        data = {"CreateTenant": {"tenant_id": tenant_id}}
        auth = get_auth(region=self._region, host=self._endpoint)
        response = requests.post(
            url=f"https://{self._endpoint}/default/_silo_management",
            timeout=1000,
            data=data,
            auth=auth,
        )
        if response.status_code >= 200 and response.status_code < 300:
            return True

        raise DiscoveryEngineException(
            f"{response.status_code} : {response.reason}  - {response.content}"
        )

    def delete_tenant(self, tenant_id: str):
        data = {"DeleteTenant": {"tenant_id": tenant_id}}
        auth = get_auth(region=self._region, host=self._endpoint)
        response = requests.post(
            url=f"https://{self._endpoint}/default/_silo_management",
            timeout=1000,
            data=data,
            auth=auth,
        )
        if response.status_code >= 200 and response.status_code < 300:
            return True

        raise DiscoveryEngineException(
            f"{response.status_code} : {response.reason}  - {response.content}"
        )
