import uuid
from TenantManagement.functions.shared.tenant_utils import (
    create_id,
    create_secure_string,
)


def test_two_tenant_ids_should_never_be_the_same():
    assert create_id() != create_id()


def test_that_tenant_id_can_be_converted_to_uuid4_again():
    id1hex = create_id()
    id2 = uuid.UUID(hex=id1hex, version=4)

    assert id1hex == id2.hex


def test_secure_is_long_enough():
    secure = create_secure_string()

    assert len(secure) >= 20
