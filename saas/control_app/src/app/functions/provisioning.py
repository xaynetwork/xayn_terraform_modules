# pylint: disable=wrong-import-position
import os
import logging
import json
import re
# import sys

# sys.path.append(os.path.join(os.path.dirname(__file__), 'functions'))
from enum import Enum
from app.functions.shared.auth_utils import try_decode_auth_key
from app.functions.shared.auth_context import AuthorizedContext
from app.functions.shared.db_repository import AwsDbRepository
from app.functions.shared.db_repository import DbRepository

region = os.environ['REGION'] if 'REGION' in os.environ else "ddblocal"
db_table = os.environ['DB_TABLE'] if 'DB_TABLE' in os.environ else "saas"
db_endpoint = os.environ['DB_ENDPOINT'] if 'DB_ENDPOINT' in os.environ else None



EMAIL_REGEX = re.compile(r"^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$")

class EventException(Exception):
    pass


def assert_event_key(event: dict, *keys: str):
    event = event
    path = keys[0]
    for index, key in enumerate(keys, start=1):
        if index == len(keys):
            if key in event:
                return event[key]
            else:
                raise EventException(f"event does not contain \"{path}\"")
        else:
            if key in event:
                event = event[key]
                path = f"{path}.{key}"
            else:
                raise EventException(f"event does not contain \"{path}\"")


def build_response(message: str, status_code: int):
    return {
        "statusCode": status_code,
        "body": json.dumps({"message": message}),
        "headers": {
            'Content-Type': 'application/json',
        }
    }


def handle_signup(email: str) ->dict:
    # Create user in db if user, doesn't exist
    # Create Api-key in api-gateway
    if not EMAIL_REGEX.match(email):
        return build_response(f"Email address is not valid", 400)

    return build_response(f"User created ({email}).", status_code=204)


def handle(event, repo: DbRepository) -> dict:
    path = assert_event_key(event, "path")
    http_method = assert_event_key(event, "httpMethod")
    raw_body = assert_event_key(event, "body")
    body = json.loads(raw_body)
    if path == "/signup" and http_method == "POST":
        return handle_signup(assert_event_key(body, "email"))
    else:
        return build_response(f"Unsupported path (\"{path}\")  or method (\"{http_method}\").", 400)


def lambda_handler(event, context) -> dict:
    db_repo = AwsDbRepository(endpoint_url=db_endpoint,
                              table_name=db_table, region=region)
    try:
        return handle(event, db_repo)
    except EventException as ee:
        return build_response(f"Error: {ee}", 400)
    except json.JSONDecodeError as je:
        return build_response(f"Error: {je}", 400)
    except TypeError as te:
        return build_response(f"Error: {te}", 400)
