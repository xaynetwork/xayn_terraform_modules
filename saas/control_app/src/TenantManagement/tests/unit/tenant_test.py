from dataclasses import FrozenInstanceError
from unittest import TestCase
from TenantManagement.functions.shared.tenant import AuthPathGroup, AuthKey, Tenant
from TenantManagement.tests.unit.fakes import fake_tenant


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
        assert AuthPathGroup.FRONT_OFFICE == AuthPathGroup.BACK_OFFICE
