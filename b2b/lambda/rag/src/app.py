#!/bin/env python

import os
from typing import Optional

from aws_lambda_powertools.event_handler import APIGatewayRestResolver, CORSConfig
from aws_lambda_powertools.utilities.typing import LambdaContext
from aws_lambda_powertools import Logger
from aws_lambda_powertools.logging import correlation_paths, utils
from aws_lambda_powertools.utilities.parser import parse, ValidationError
from aws_lambda_powertools.utilities.parser import BaseModel

from xayn_rag.retrieval import Xayn
from xayn_rag.llm_templating import em_german_rag
from xayn_rag.generation import huggingfaceTGI

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

    search_engine = Xayn(
        endpoint=frontoffice_base_url or nlb_url,
        frontoffice_token=frontoffice_token,
        tenant_id=tenant_id,
    )
    search_results = search_engine.search(request.query, int(use_top_n_results))
    if search_results is None:
        return {"status_code": 500, "message": "Search failed"}

    llm = huggingfaceTGI(llm_url, llm_bearer_token)

    turns = []
    for search_result in search_results:
        turns.append(
            {
                "speaker": "context",
                "text": search_result,
            }
        )
    turns.append({"speaker": "question", "text": request.query})

    try:
        answer = llm.generate(em_german_rag(turns))
    except Exception as e:
        return {"status_code": 409, "message": str(e)}

    return {"status_code": 200, "response": answer}
