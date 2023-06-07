import base64
import binascii


def encode_auth_key(tenant_id: str, auth_key: str) -> str:
    return base64.b64encode(str.encode(f"{tenant_id}:{auth_key}")).decode("utf-8")


def try_decode_auth_key(encoded_auth_key: str) -> tuple[str | None, str | None]:
    """Returns a tuple with (tenantId, AuthKey) when encoded_auth_key is  base64encoded(tenenId:authKey)"""
    try:
        # Adds newlines every 76 characters as per RFC 2045, which need to be removed again
        decoded = base64.b64decode(encoded_auth_key).decode("utf-8").replace("\n", "")
        if ":" in decoded:
            (_id, key) = decoded.split(":", maxsplit=1)
            return (_id, key)

        return (None, None)
    except binascii.Error:
        return (None, None)
