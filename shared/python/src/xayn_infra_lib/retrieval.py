from abc import ABC, abstractmethod
from typing import List, Optional

import json
import requests


class SearchProvider(ABC):
    @abstractmethod
    def search(self, query: str, count: int) -> List[str]:
        pass


class MockSearchProvider(SearchProvider):
    def search(self, query: str, count: int = 2) -> List[str]:
        return ["The capital of Germany is Berlin", "two plus two is five"]


class Xayn(SearchProvider):
    def __init__(
        self,
        endpoint: str,
        frontoffice_token: str = "",
        return_property: str = "snippet",
        enable_hybrid_search: bool = False,
    ):
        self.endpoint = endpoint
        self.frontoffice_token = frontoffice_token
        self.return_property = return_property
        self.enable_hybrid_search = enable_hybrid_search
        self.headers = {
            "authorizationToken": self.frontoffice_token,
            "Content-Type": "application/json",
        }

    def search(
        self,
        query: str,
        count: int = 10,
    ) -> Optional[List[str]]:
        payload = {
            "document": {"query": query},
            "count": count,
            "include_properties": self.return_property != "",
            "enable_hybrid_search": self.enable_hybrid_search,
        }

        response = requests.post(
            self.endpoint, headers=self.headers, data=json.dumps(payload)
        )
        if response.status_code == 200:
            breakpoint()
            results = []
            for document in response.json()["documents"]:
                if (
                    "properties" in document
                    and self.return_property in document["properties"]
                ):
                    results.append(document["properties"][self.return_property])
                else:
                    results.append(document["id"])
            return results
        else:
            print(response.status_code)
            print(response.json())
            # TODO: use logger?
            return None


if __name__ == "__main__":
    search_engine = Xayn("http://localhost:3082/semantic_search", "none")
    print(search_engine.search("What is the capital of Germany?"))
