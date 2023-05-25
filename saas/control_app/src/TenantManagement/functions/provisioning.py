# pylint: disable=wrong-import-position
# pylint: disable=invalid-name
import os
import logging
import json
import re
# import sys

# sys.path.append(os.path.join(os.path.dirname(__file__), 'functions'))
from TenantManagement.functions.shared.db_repository import AwsDbRepository
from TenantManagement.functions.shared.db_repository import (
    DbRepository, TenantIdAlreadyInUseException, EmailAlreadyInUseException)
from TenantManagement.functions.shared import tenant_utils

from TenantManagement.functions.shared.tenant import Tenant
from TenantManagement.functions.shared.tenant_utils import create_random_password
from TenantManagement.functions.shared.tenant import DeploymentState
from TenantManagement.functions.shared.infra_repository import (InfraRepository, BotoInfraRepository)

region = os.environ['REGION'] if 'REGION' in os.environ else "ddblocal"
db_table = os.environ['DB_TABLE'] if 'DB_TABLE' in os.environ else "saas"
db_endpoint = os.environ['DB_ENDPOINT'] if 'DB_ENDPOINT' in os.environ else None

EMAIL_REGEX = re.compile(r"^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$")


class EventException(Exception):
    pass


def assert_event_key(event: dict, *keys: str):
    _event = event
    path = keys[0]
    result = None
    for index, key in enumerate(keys, start=1):
        if index == len(keys):
            if key in _event:
                result = _event[key]
            else:
                raise EventException(f"event does not contain \"{path}\"")

        if key in _event:
            _event = _event[key]
            path = f"{path}.{key}"
        else:
            raise EventException(f"event does not contain \"{path}\"")

    return result

def build_response(message: str, status_code: int):
    return {
        "statusCode": status_code,
        "body": json.dumps({"message": message}),
        "headers": {
            'Content-Type': 'application/json',
        }
    }


def handle_signup(email: str, db_repo: DbRepository, infra_repo: InfraRepository) -> dict:
    if not EMAIL_REGEX.match(email):
        return build_response("Email address is not valid", 400)

    tenant = Tenant(email=email, id=tenant_utils.create_id(), auth_keys={}, plan_keys={
    }, deployment_state=DeploymentState.NEEDS_UPDATE).update_auth_defaults(create_random_password())
    try:
        tenant = db_repo.save_new_tenant(tenant)
    except TenantIdAlreadyInUseException:
        # Retry to create another tenantId in case of a single collision, in this case we just let the requester know that they need to try that again.
        logging.exception(
            "Couldn't generate a unique id, abort the process.")
        return build_response("Can not create tenant, try again later. ", status_code=500)
    except EmailAlreadyInUseException:
        # Actually this message should be "Email already in use, but this could be a spoofing mechanism to detect use emails from us. TODO intoduce a captcha, mechanism"
        return build_response("Can not create tenant", status_code=409)

    # Check the resuklt and implement function
    infra_repo.notify_stack_deployment()

    return build_response(f"User created ({email}).", status_code=204)


def handle(event, repo: DbRepository, infra_repo: InfraRepository) -> dict:
    path = assert_event_key(event, "path")
    http_method = assert_event_key(event, "httpMethod")
    raw_body = assert_event_key(event, "body")
    assert raw_body
    body = json.loads(raw_body)
    if path == "/signup" and http_method == "POST":
        email = assert_event_key(body, "email")
        assert email
        return handle_signup(email, repo, infra_repo)

    return build_response(f"Unsupported path (\"{path}\")  or method (\"{http_method}\").", 400)


def lambda_handler(event, _context) -> dict:
    db_repo = AwsDbRepository(endpoint_url=db_endpoint,
                              table_name=db_table, region=region)
    infra_repo = BotoInfraRepository()
    try:
        return handle(event, db_repo, infra_repo)
    except EventException as ee:
        return build_response(f"Error: {ee}", 400)
    except json.JSONDecodeError as je:
        return build_response(f"Error: {je}", 400)
    except TypeError as te:
        return build_response(f"Error: {te}", 400)
