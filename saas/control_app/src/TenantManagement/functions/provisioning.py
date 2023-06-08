# pylint: disable=wrong-import-position
# pylint: disable=invalid-name
import os
import logging
import json
import re

from TenantManagement.functions.shared.db_repository import AwsDbRepository
from TenantManagement.functions.shared.db_repository import (
    DbRepository,
    TenantIdAlreadyInUseException,
    EmailAlreadyInUseException,
)

from TenantManagement.functions.shared.tenant import Tenant
from TenantManagement.functions.shared.discovery_engine_repository import (
    DiscoveryEngineRepository,
    HttpDiscoveryEngineRepository,
    DiscoveryEngineException,
)


EMAIL_REGEX = re.compile(r"^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$")


class EventException(Exception):
    pass


def assert_event_key(event: dict, key: str) -> str:
    value = event.get(key, None)
    if value is not None:
        return value

    raise EventException(f"No {key} found.")


def build_response(message: str, status_code: int):
    return {
        "statusCode": status_code,
        "body": json.dumps({"message": message}),
        "headers": {
            "Content-Type": "application/json",
        },
    }


def handle_signup(
    email: str, db_repo: DbRepository, discovery_repo: DiscoveryEngineRepository
) -> dict:
    if not EMAIL_REGEX.match(email):
        return build_response("Email address is not valid", 400)

    tenant = Tenant.create_default(email=email)
    try:
        tenant = db_repo.save_tenant(tenant)
    except TenantIdAlreadyInUseException:
        # Retry to create another tenantId in case of a single collision, in this case we just let the requester know that they need to try that again.
        logging.exception("Couldn't generate a unique id, abort the process.")
        return build_response(
            "Can not create tenant, try again later. ", status_code=500
        )
    except EmailAlreadyInUseException:
        # Actually this message should be "Email already in use, but this could be a spoofing mechanism to detect use emails from us. TODO intoduce a captcha, mechanism"
        return build_response("Can not create tenant", status_code=400)

    discovery_repo.create_tenant(tenant.id)

    return build_response(f"User created ({email}).", status_code=204)


def handle(
    event, repo: DbRepository, discovery_repo: DiscoveryEngineRepository
) -> dict:
    path = assert_event_key(event, "path")
    http_method = assert_event_key(event, "httpMethod")
    raw_body = assert_event_key(event, "body")
    assert raw_body
    body = json.loads(raw_body)
    if path == "/signup" and http_method == "POST":
        email = assert_event_key(body, "email")
        assert email
        return handle_signup(email, repo, discovery_repo)

    return build_response(
        f'Unsupported path ("{path}")  or method ("{http_method}").', 400
    )


def lambda_handler(event: dict, _context) -> dict:
    # pylint: disable=duplicate-code
    region = os.environ["REGION"]
    db_table = os.environ["DB_TABLE"]
    db_endpoint = os.environ.get("DB_ENDPOINT", None)
    host = event.get("headers", {}).get("Host", "")

    db_repo = AwsDbRepository(
        endpoint_url=db_endpoint, table_name=db_table, region=region
    )
    infra_repo = HttpDiscoveryEngineRepository(endpoint=host, region=region)
    try:
        return handle(event, db_repo, infra_repo)
    except (
        EventException,
        json.JSONDecodeError,
        TypeError,
        DiscoveryEngineException,
    ) as ee:
        return build_response(f"Error: {ee}", 400)
