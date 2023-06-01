import secrets
import string
import uuid

_ALPHABET = string.ascii_lowercase + string.digits
_PASS_ALPHABET = _ALPHABET + string.ascii_uppercase


def create_id() -> str:
    return str(uuid.uuid4())


def create_secure_string() -> str:
    return "".join(secrets.choice(_PASS_ALPHABET) for _ in range(20))
