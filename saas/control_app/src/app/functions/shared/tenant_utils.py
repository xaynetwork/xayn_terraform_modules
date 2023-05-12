import secrets
import string

alphabet = string.ascii_lowercase + string.digits
pass_alphabet = alphabet + string.ascii_uppercase

# good to read
# 15 collisions within 10M draws - https://stackoverflow.com/a/56398787/495800
def create_id():
    return ''.join(secrets.choice(alphabet) for _ in range(8))


def create_random_password():
    return ''.join(secrets.choice(pass_alphabet) for _ in range(16))
