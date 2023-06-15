from dataclasses import FrozenInstanceError
from unittest import TestCase
from TenantManagement.functions.shared.tenant import AuthPathGroup, AuthKey, Tenant
from TenantManagement.functions.shared.deployment_state import DeploymentState
from TenantManagement.tests.unit.fakes import fake_tenant
from TenantManagement.functions.shared.tenant import TenantStateException


class TenantTestCase(TestCase):
    def test_auth_key_dataclasses_are_equal(self):
        assert AuthKey(AuthPathGroup.BACK_OFFICE) == AuthKey(AuthPathGroup.BACK_OFFICE)

    def test_auth_key_dataclasses_are_not_equal(self):
        assert AuthKey(AuthPathGroup.BACK_OFFICE) != AuthKey(AuthPathGroup.FRONT_OFFICE)

    def test_can_not_set_values_in_frozen_dataclass(self):
        self.assertRaises(FrozenInstanceError, self.assign_value_to_auth_key)

    def assign_value_to_auth_key(self):
        AuthKey(AuthPathGroup.BACK_OFFICE).group = AuthPathGroup.FRONT_OFFICE

    def test_tenant_dataclasses_are_not_equal(self):
        assert Tenant.create_default("s@xayn.com") != Tenant.create_default(
            "s@xayn.com"
        )

    def test_tenant_dataclasses_are_equal(self):
        assert Tenant.from_dict(
            fake_tenant("123", "345", "a@b.com")
        ) == Tenant.from_dict(fake_tenant("123", "345", "a@b.com"))

    def test_auth_path_group_dataclasses_are_equal(self):
        assert AuthPathGroup["BACK_OFFICE"] == AuthPathGroup.BACK_OFFICE

    def test_auth_path_group_dataclasses_are_not_equal(self):
        assert AuthPathGroup.FRONT_OFFICE != AuthPathGroup.BACK_OFFICE

    def test_setting_a_new_state_creates_a_new_tenant_that_is_equal_but_not_the_same(
        self,
    ):
        tenant = Tenant.create_default("a@b.com")
        tenant2 = tenant.change_state(DeploymentState.NEEDS_UPDATE)
        assert tenant2 == tenant
        assert tenant2 is not tenant

    def test_setting_a_new_state_sets_the_new_state(self):
        tenant = Tenant.create_default("a@b.com")
        tenant2 = tenant.change_state(DeploymentState.NEEDS_DELETION)
        assert tenant2.deployment_state != tenant.deployment_state
        assert tenant2.deployment_state is DeploymentState.NEEDS_DELETION

    def test_setting_an_invalid_state_will_raise_an_exception(self):
        tenant = Tenant.create_default("a@b.com")
        self.assertRaises(
            TenantStateException, tenant.change_state, DeploymentState.DEPLOYED
        )

    def test_setting_a_tenant_to_be_deleted_also_revokes_auth_keys(self):
        tenant = Tenant.create_default("a@b.com")
        tenant2 = tenant.set_to_be_deleted()
        assert tenant2.deployment_state is DeploymentState.NEEDS_DELETION
        assert not tenant2.auth_keys
