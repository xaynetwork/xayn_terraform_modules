#!/bin/env python

import json
import os
from typing import Optional

from aws_lambda_powertools.event_handler import APIGatewayRestResolver
from aws_lambda_powertools.utilities.typing import LambdaContext
from aws_lambda_powertools import Logger
from aws_lambda_powertools.logging import correlation_paths
from aws_lambda_powertools.utilities.parser import parse, ValidationError
import boto3

from xayn_infra_lib.models import QuestionRequest
from xayn_infra_lib.retrevial import MockSearchProvider, Xayn
from xaun_infra_lib.llm_templating import em_german_rag
from xayn_infra_lib.generation import MockLLMProvider, SageMakerLLM

aws_region = os.getenv("AWS_REGION")
sagemaker_endpoint_name = os.getenv("SAGEMAKER_ENDPOINT_NAME")
nlb_url = os.getenv("NLB_URL")

app = APIGatewayRestResolver()
logger = Logger()


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
    except ValidationError:
        return {"status_code": 400, "message": "Invalid question request"}
    
    # Rough outline of usage
    search_engine = Xayn(endpoint=f"{nlb_url}/semantic_search", frontoffice_token="")
    search_results = search_engine.search(request.question)
    llm = SageMakerLLM(aws_region, "sagemaker-runtime", sagemaker_endpoint_name)
    answer = llm.generate(em_german_rag(search_results))
    
    return {"tenant_id": tenant_id, "answer": answer}
