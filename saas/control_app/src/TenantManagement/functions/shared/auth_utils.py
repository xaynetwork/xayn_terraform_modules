import base64
import binascii


def encode_auth_key(tenant_id: str, auth_key: str) -> str:
    return base64.b64encode(str.encode(f"{tenant_id}:{auth_key}")).decode('utf-8')

def try_decode_auth_key(encoded_auth_key: str):
    """Returns a tuple with (tenantId, AuthKey) when encoded_auth_key is  base64encoded(tenenId:authKey)"""
    try:
        decoded = base64.b64decode(encoded_auth_key).decode('utf-8')
        if ':' in decoded:
            return decoded.split(':', maxsplit=1)

        return (None, None)
    except binascii.Error:
        return (None, None)
