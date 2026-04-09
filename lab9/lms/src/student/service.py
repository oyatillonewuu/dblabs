from src.schemas import PagingParams
from src.student import repository
from src.student.schemas import StudentCreate, StudentList


async def get_students(paging_params: PagingParams) -> StudentList:
    return await repository.fetch_students(
        limit=paging_params.limit, page=paging_params.page
    )


async def create_student(student_data: StudentCreate):
    await repository.create_student(student_data)
