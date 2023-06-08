class DiscoveryEngineRepository():

    def create_tenant(self, tenant_id: str):
        pass

    def delete_tenant(self, tenant_id: str):
        pass


class HttpDiscoveryEngineRepository(DiscoveryEngineRepository):

    def create_tenant(self, tenant_id: str):
        return super().create_tenant(tenant_id)
    
    def delete_tenant(self, tenant_id: str):
        return super().delete_tenant(tenant_id)
