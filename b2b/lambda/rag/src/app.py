#!/bin/env python

import os
from typing import Optional

from aws_lambda_powertools.event_handler import APIGatewayRestResolver
from aws_lambda_powertools.utilities.typing import LambdaContext
from aws_lambda_powertools import Logger
from aws_lambda_powertools.logging import correlation_paths
import requests

aws_region = os.getenv("AWS_REGION")
nlb_url = os.getenv("NLB_URL")

app = APIGatewayRestResolver()
logger = Logger()


@logger.inject_lambda_context(correlation_id_path=correlation_paths.API_GATEWAY_REST)
def lambda_handler(event: dict, context: LambdaContext) -> dict:
    return app.resolve(event, context)


@app.post("/rag")
def get_answer():
    tenant_id: Optional[str] = app.current_event.request_context.authorizer.principal_id

    if tenant_id is not None:
        r = requests.post(
            f"{nlb_url}/semantic_search",
            headers={"X-Tenant-Id": tenant_id},
            json={
                "document": {"query": "test"},
            },
        )
        print(r.text)

    return {"tenant_id": tenant_id}
