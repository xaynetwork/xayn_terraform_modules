#!/bin/env python

import os
from typing import Optional

from aws_lambda_powertools.event_handler import APIGatewayRestResolver
from aws_lambda_powertools.utilities.typing import LambdaContext
from aws_lambda_powertools import Logger
from aws_lambda_powertools.logging import correlation_paths
from aws_lambda_powertools.utilities.parser import parse, ValidationError
import boto3

from xayn_infra_lib.models import QuestionRequest

aws_region = os.getenv("AWS_REGION")
sagemaker_endpoint_url = os.getenv("SAGEMAKER_ENDPOINT_URL")
nlb_url = os.getenv("NLB_URL")

app = APIGatewayRestResolver()
logger = Logger()
session = boto3.Session(region_name=aws_region)


@logger.inject_lambda_context(correlation_id_path=correlation_paths.API_GATEWAY_REST)
def lambda_handler(event: dict, context: LambdaContext) -> dict:
    return app.resolve(event, context)


@app.post("/rag")
def get_answer():
    tenant_id: Optional[str] = app.current_event.request_context.authorizer.principal_id

    try:
        request: QuestionRequest = parse(
            event=app.current_event.json_body, model=QuestionRequest
        )
        return {"tenant_id": tenant_id, "answer": request.question}
    except ValidationError:
        return {"status_code": 400, "message": "Invalid question request"}
