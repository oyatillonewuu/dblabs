from fastapi import HTTPException

from src.schemas import PagingParams
from src.student import repository
from src.student.schemas import Student, StudentCreate, StudentUpdate, StudentList
from .exceptions import StudentDoesNotExist, StudentDeleteFailure, StudentDeleteFailureHTTP, StudentDoesNotExistHTTP


async def get_students(paging_params: PagingParams) -> StudentList:
    return await repository.fetch_students(
        limit=paging_params.limit, page=paging_params.page
    )


async def create_student(student_data: StudentCreate) -> int:
    return await repository.create_student(student_data)


async def update_student(student_id: int, update_data: StudentUpdate):
    try:
        await repository.update_student(student_id=student_id, update_data=update_data)
    except StudentDoesNotExist:
        raise StudentDoesNotExistHTTP(student_id)


async def get_student(student_id: int) -> Student:
    try:
        return await repository.get_student(student_id)
    except StudentDoesNotExist:
        raise StudentDoesNotExistHTTP(student_id)


async def delete_student(student_id: int) -> Student:
    try:
        await repository.delete_student()
    except StudentDoesNotExist:
        raise StudentDoesNotExistHTTP(student_id)
    except StudentDeleteFailure:
        raise StudentDeleteFailureHTTP(student_id)
    