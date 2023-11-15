from pydantic import BaseModel


class QuestionRequest(BaseModel):
    query: str
