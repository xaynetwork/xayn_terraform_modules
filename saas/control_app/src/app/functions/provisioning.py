# pylint: disable=wrong-import-position
import os
import logging
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


class EventException(Exception):
    pass


def assert_event_key(event: dict, key: str):
    if key in event:
        return event["type"]
    else:
        raise EventException("event does not contain type")


def build_response(status_code: int, message: dict):
    return {
        "statusCode": status_code,
        "body": JSON.stringify(message),
        "headers": {
            'Content-Type': 'application/json',
        }
    }


def handle(event, repo: DbRepository):
    type = assert_event_key(event, "type")


def lambda_handler(event, context):
    db_repo = AwsDbRepository(endpoint_url=db_endpoint,
                              table_name=db_table, region=region)
    try:
        return handle(event, db_repo)
    except EventException as ee:
        return build_response
