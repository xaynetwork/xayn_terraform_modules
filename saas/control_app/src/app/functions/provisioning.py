# pylint: disable=wrong-import-position
# pylint: disable=invalid-name
import os
import logging
import json
import re
# import sys

# sys.path.append(os.path.join(os.path.dirname(__file__), 'functions'))
from app.functions.shared.db_repository import AwsDbRepository
from app.functions.shared.db_repository import (
    DbRepository, TenantIdAlreadyInUseException, EmailAlreadyInUseException)
import app.functions.shared.tenant_utils as tenant_utils

from app.functions.shared.tenant import Tenant
from app.functions.shared.infra_repository import InfraRepository
from app.functions.shared.infra_repository import CreateUsagePlanResponse, InfraException
from app.functions.shared.db_repository import DbException
from saas.control_app.src.app.functions.shared.infra_repository import CdkInfraRepository

region = os.environ['REGION'] if 'REGION' in os.environ else "ddblocal"
db_table = os.environ['DB_TABLE'] if 'DB_TABLE' in os.environ else "saas"
db_endpoint = os.environ['DB_ENDPOINT'] if 'DB_ENDPOINT' in os.environ else None
api_id = os.environ['API_ID']
api_stage_name = os.environ['API_STAGE_NAME'] if 'API_STAGE_NAME' in os.environ else "default"


EMAIL_REGEX = re.compile(r"^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$")


class EventException(Exception):
    pass


def assert_event_key(event: dict, *keys: str):
    _event = event
    path = keys[0]
    for index, key in enumerate(keys, start=1):
        if index == len(keys):
            if key in _event:
                return _event[key]
            else:
                raise EventException(f"event does not contain \"{path}\"")
        else:
            if key in _event:
                _event = _event[key]
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


def handle_signup(email: str, db_repo: DbRepository, infra_repo: InfraRepository) -> dict:
    if not EMAIL_REGEX.match(email):
        return build_response(f"Email address is not valid", 400)

    tenant: Tenant | None = None
    try:
        tenant = db_repo.create_tenant(
            email=email, tenant_id=tenant_utils.create_id())
    except TenantIdAlreadyInUseException:
        # Retry to create another tenantId in case of a single collision, in this case we just let the requester know that they need to try that again.
        try:
            tenant = db_repo.create_tenant(
                email=email, tenant_id=tenant_utils.create_id())
        except Exception as _:
            return build_response(f"Can not create tenant, try again later. ", status_code=500)
    except EmailAlreadyInUseException:
        # Actually this message should be "Email already in use, but this could be a spoofing mechanism to detect use emails from us. TODO intoduce a captcha, mechanism"
        return build_response(f"Can not create tenant", status_code=409)

    # Create Api-key in api-gateway
    usage_plan_response: CreateUsagePlanResponse
    try:
        usage_plan_response = infra_repo.create_usage_plan(
            api_id=api_id, stage_name=api_stage_name, tenant_id=tenant.id)
    # pylint: disable=invalid-name
    except InfraException:
        logging.exception("Could not create tenant, because plan createion faild.")
        return build_response("Can not create tenant", status_code=500)
    
    try:
        tenant = tenant.update_auth_defaults(usage_plan_response.api_key_value)
        db_repo.update_tenant(tenant)
    except DbException:
        logging.exception("Could not update the tenant with auth information. Will rollback changes... TODO")
        # TODO remove the usage_plan again
        return build_response(f"Can not create tenant", status_code=500)
    
    # TODO send email via SNS

    return build_response(f"User created ({email}).", status_code=204)


def handle(event, repo: DbRepository) -> dict:
    path = assert_event_key(event, "path")
    http_method = assert_event_key(event, "httpMethod")
    raw_body = assert_event_key(event, "body")
    assert raw_body
    body = json.loads(raw_body)
    if path == "/signup" and http_method == "POST":
        return handle_signup(assert_event_key(body, "email"), repo)
    else:
        return build_response(f"Unsupported path (\"{path}\")  or method (\"{http_method}\").", 400)


def lambda_handler(event, context) -> dict:
    db_repo = AwsDbRepository(endpoint_url=db_endpoint,
                              table_name=db_table, region=region)
    infra_repo = CdkInfraRepository(endpoint_url=db_endpoint,
                              table_name=db_table, region=region)
    try:
        return handle(event, db_repo)
    except EventException as ee:
        return build_response(f"Error: {ee}", 400)
    except json.JSONDecodeError as je:
        return build_response(f"Error: {je}", 400)
    except TypeError as te:
        return build_response(f"Error: {te}", 400)
