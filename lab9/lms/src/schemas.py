from pydantic import BaseModel, Field


class PagingParams(BaseModel):
    page: int  = Field(1, ge=0, description="Page of the response list.")
    limit: int = Field(5, ge=0, description="Number of items to show in the list.")
