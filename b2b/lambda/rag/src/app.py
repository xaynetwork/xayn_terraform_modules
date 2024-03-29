#!/bin/env python

import os
import json
from typing import Optional

from aws_lambda_powertools.event_handler import APIGatewayRestResolver, CORSConfig
from aws_lambda_powertools.utilities.typing import LambdaContext
from aws_lambda_powertools import Logger
from aws_lambda_powertools.logging import correlation_paths, utils
from aws_lambda_powertools.utilities.parser import parse, ValidationError
from aws_lambda_powertools.utilities.parser import BaseModel

from xayn_rag.rag import run_query
from xayn_rag.context import (
    ConfigContext,
    ConfigEnvLoader,
)
from xayn_rag.retrieval import SimpleSearchQuery


nlb_url = os.getenv("NLB_URL")
frontoffice_base_url = os.getenv("FRONTOFFICE_BASE_URL")
frontoffice_token = os.getenv("FRONTOFFICE_TOKEN")
llm_url = os.getenv("LLM_URL")
llm_bearer_token = os.getenv("LLM_BEARER_TOKEN")
use_top_n_results = os.getenv("USE_TOP_N_RESULTS", "2")

cors_config = CORSConfig(
    max_age=300, allow_credentials=True, allow_headers=["authorizationToken"]
)
app = APIGatewayRestResolver(cors=cors_config)
logger = Logger()
utils.copy_config_to_registered_loggers(source_logger=logger)


class QuestionRequest(BaseModel):
    query: str
    filter: str | None
    include_properties: bool = True
    use_hybrid_search: bool = False


@logger.inject_lambda_context(correlation_id_path=correlation_paths.API_GATEWAY_REST)
def lambda_handler(event: dict, context: LambdaContext) -> dict:
    return app.resolve(event, context)


@app.post("/rag")
def get_answer():
    tenant_id: Optional[str] = app.current_event.request_context.authorizer.principal_id
    error_wrap = (
        app.current_event.get_query_string_value(
            name="error_wrap", default_value="false"
        )
        == "true"
    )
    if not tenant_id:
        logger.error(
            "request_context.authorizer.principal_id is not set! This lambda must be called with a valid TenantId!"
        )
        return response_error(
            http_code=500,
            error_code="InternalServerError",
            error_message="",
            error_wrap=error_wrap,
        )

    if not nlb_url or not llm_bearer_token or not llm_url:
        logger.error(
            f"Environment Variables are not set correctly! nlb_url={nlb_url}, llm_bearer_token={llm_bearer_token}, llm_url={llm_url}"
        )
        return response_error(
            http_code=500,
            error_code="InternalServerError",
            error_message="",
            error_wrap=error_wrap,
        )

    try:
        request: QuestionRequest = parse(
            event=app.current_event.json_body, model=QuestionRequest
        )

    except ValidationError:
        return response_error(
            http_code=400,
            error_code="InvalidQuery",
            error_message="Invalid question request",
            error_wrap=error_wrap,
        )

    # TODO move this to ssm
    configs = {
        "porschedemoe5": {
            "type": "EM_GERMAN_RAG",
            "config": {
                "LLM_PLATFORM": "HUGGINGFACE",
                "SEARCH_PLATFORM": "XAYN_INTERNAL",
            },
            "envs": {
                "XAYN_SEARCH_ENDPOINT": nlb_url,
                "TENANT_ID": tenant_id,
                "HUGGINGFACE_ENDPOINT_TOKEN": llm_bearer_token,
                "HUGGINGFACE_ENDPOINT_URL": llm_url,
                "USE_TOP_N_RESULTS": 5,
            },
        },
        "legaldemolarge": {
            "type": "EM_GERMAN_RAG",
            "config": {
                "LLM_PLATFORM": "HUGGINGFACE",
                "SEARCH_PLATFORM": "XAYN_INTERNAL",
            },
            "envs": {
                "XAYN_SEARCH_ENDPOINT": nlb_url,
                "TENANT_ID": tenant_id,
                "HUGGINGFACE_ENDPOINT_TOKEN": llm_bearer_token,
                "HUGGINGFACE_ENDPOINT_URL": llm_url,
                "USE_TOP_N_RESULTS": 5,
            },
        },
    }

    config = configs[tenant_id]
    context = ConfigContext(
        config=config["config"],
        env_loader=ConfigEnvLoader(config["envs"]),
    )
    res = run_query(
        query=SimpleSearchQuery(
            query=request.query,
            filter_json=request.filter,
            include_properties=request.include_properties,
            use_hybrid_search=request.use_hybrid_search,
        ),
        context=context,
        rag_type=configs[tenant_id]["type"],
    )
    return convert_response(res, error_wrap=error_wrap)


def response_error(
    http_code: int,
    error_code: str,
    error_message: str = "",
    error_wrap: bool = False,
):
    """The error response body."""

    return {
        "error_code": error_code,
        "error_message": error_message,
    }, 200 if error_wrap else http_code


def convert_response(
    message: dict,
    error_wrap: bool = False,
):
    """The error response body."""

    return json.loads(
        json.dumps(message["message"], default=vars)
    ), 200 if error_wrap else int(message["http_code"])
