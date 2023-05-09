import secrets
import string

alphabet = string.ascii_lowercase + string.digits

# good to read
# 15 collisions within 10M draws - https://stackoverflow.com/a/56398787/495800
def create_id():
    return ''.join(secrets.choice(alphabet) for _ in range(8))
