import secrets
import string

_ALPHABET = string.ascii_lowercase + string.digits
_PASS_ALPHABET = _ALPHABET + string.ascii_uppercase

# good to read
# 15 collisions within 10M draws - https://stackoverflow.com/a/56398787/495800
def create_id():
    return ''.join(secrets.choice(_ALPHABET) for _ in range(8))


def create_random_password():
    return ''.join(secrets.choice(_PASS_ALPHABET) for _ in range(16))
