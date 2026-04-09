from typing import Annotated

from fastapi import APIRouter, Body, Query

from src.schemas import PagingParams
from src.student.schemas import StudentCreate

from . import service

api = APIRouter(prefix="/students")


@api.get("")
async def get_students(paging_params: Annotated[PagingParams, Query()]):
    return await service.get_students(paging_params)


@api.post("/create")
async def create_student(student_data: Annotated[StudentCreate, Body()]):
    await service.create_student(student_data)
    return {"message": "Successfully created."}
