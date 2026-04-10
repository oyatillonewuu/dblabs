from typing import Annotated

from fastapi import APIRouter, Body, Query

from src.schemas import PagingParams
from src.student.schemas import StudentCreate, StudentUpdate

from . import service

api = APIRouter(prefix="/students")


@api.get("")
async def get_students(paging_params: Annotated[PagingParams, Query()]):
    return await service.get_students(paging_params)


@api.get("/{student_id}")
async def get_student(student_id: int):
    return await service.get_student(student_id)


@api.post("/create")
async def create_student(student_data: Annotated[StudentCreate, Body()]):
    student_id: int = await service.create_student(student_data)
    return {"student_id": student_id, "message": "Successfully created."}


@api.patch("/{student_id}/update")
async def update_student(
    student_id: int, update_data: Annotated[StudentUpdate, Body()]
):
    await service.update_student(student_id, update_data)
    return {"message": "Successfully updated."}


@api.delete("/{student_id}/delete")
async def delete_student(student_id: int):
    await service.delete_student(student_id)
    return {"student_id": student_id, "message": "Successfully deleted."}
