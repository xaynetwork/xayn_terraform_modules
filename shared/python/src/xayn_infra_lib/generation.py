from abc import ABC, abstractmethod
from typing import List

import json


class LLMProvider(ABC):
    @abstractmethod
    def generate(self, prompt: str) -> str:
        pass


class MockLLMProvider(LLMProvider):
    def generate(self, prompt: str) -> str:
        return "As an advanced AI agent, I believe the capital of Germany is Berlin"


class LocalLlamaCpp(LLMProvider):
    def __init__(
        self,
        model_path: str,
        n_ctx: int = 4096,
        n_gpu_layers: int = -1,
        max_tokens: int = 1000,
        temperature: float = 0.0,
        top_p: float = 0.9,
        stop: List[str] = [],
    ):
        try:
            from llama_cpp import Llama

            # TODO: question for reviewers: What would be the best way to handle optional dependencies regarding pyproject.toml?
            # I'd like to have the option to not install llama_cpp if it's not needed.
            # The Lambda will certainly not be using llama.cpp, so perhaps we can only list the dependencies for the Lambda
            # and have whatever environment is using this code install the optional dependencies?
        except ImportError:
            raise ImportError(
                "Please install the llama-cpp-python package to use the LocalLlamaCpp LLM provider"
            )
        self.llm = Llama(model_path=model_path, n_ctx=n_ctx, n_gpu_layers=n_gpu_layers)
        self.max_tokens = max_tokens
        self.temperature = temperature
        self.top_p = top_p
        self.stop = stop

    def generate(self, prompt: str) -> str:
        output = self.llm(
            prompt,
            max_tokens=self.max_tokens,
            stop=self.stop,
            temperature=self.temperature,
            top_p=self.top_p,
        )
        output_text = output["choices"][0]["text"]
        return output_text


class SageMakerLLM(LLMProvider):
    def __init__(self, aws_region: str, client: str, sagemaker_endpoint_name: str, temperature: float = 0.0, top_p: float = 0.9, max_tokens: int = 1024):
        try:
            import boto3
        except ImportError:
            raise ImportError(
                "Please install the boto3 package to use the SageMakerLLM provider"
            )
        self.sagemaker_endpoint_name = sagemaker_endpoint_name
        self.session = boto3.Session(region_name=aws_region)
        self.client = self.session.client("sagemaker-runtime")
        self.temperature = temperature
        self.top_p = top_p
        self.max_tokens = max_tokens

    def generate(self, prompt: str) -> str:
        response = self.client.invoke_endpoint(
            EndpointName=self.sagemaker_endpoint_name,
            Body=json.dumps(
                {
                    "prompt": prompt,
                    "temperature": self.temperature,
                    "top_p": self.top_p,
                    "max_tokens": self.max_tokens,
                }
            ).encode(),
            ContentType="application/json",
        )
        result = json.loads(response["Body"].read().decode())
        output_text = result["choices"][0]["text"]
        return output_text


if __name__ == "__main__":
    from llm_templating import em_german_rag

    # llm = LocalLlamaCpp(
    #     model_path="/home/marin/models/gguf/em_german_leo_mistral.Q5_K_M.gguf",
    #     max_tokens=100,
    # )
    llm = SageMakerLLM(
        "eu-central-1", "sagemaker-runtime", "em-german-leo-mistral-Q8-endpoint", temperature=0.0
    )
    turns = [
        {"speaker": "context", "text": "Die Hauptstadt Deutschlands ist Berlin"},
        {
            "speaker": "context",
            "text": "Zwei plus zwei ist fünf",
            "metadata": {"Url": "https://www.wikipedia.com/math"},
        },
        {"speaker": "question", "text": "Was ist zwei plus zwei?"},
    ]
    print(llm.generate(em_german_rag(turns)))
