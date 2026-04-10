from typing import Any

from mysql.connector.types import RowType

from src.database import db
from src.database import utils as db_utils

from .exceptions import StudentDeleteFailure, StudentDoesNotExist
from .schemas import Student, StudentCreate, StudentList, StudentUpdate


async def fetch_students(*, limit: int, page: int) -> StudentList:
    offset: int = limit * (page - 1)
    stmt: str = f"""
        SELECT * FROM
            students
        LIMIT {limit}
        OFFSET {offset};
    """

    async with await db.get_conn() as conn:
        async with await conn.cursor() as cur:
            await cur.execute(stmt)
            result: list[RowType | tuple] = await cur.fetchall()

    students: list[Student] = [get_student_from_row(row) for row in result]

    return StudentList(students=students)


async def create_student(student_data: StudentCreate) -> int:
    insert_stmt: str = db_utils.create_insert_stmt(
        table="students", kvs=student_data.model_dump()
    )

    async with await db.get_conn() as conn:
        async with await conn.cursor() as cur:
            await cur.execute(insert_stmt)
            student_id: int = cur.lastrowid
            await conn.commit()

    return student_id


async def update_student(*, student_id, update_data: StudentUpdate):
    await require_student_exists(student_id)

    update_stmt: str = db_utils.create_update_stmt(
        table="students",
        kvs=update_data.model_dump(exclude_unset=True, exclude_none=True),
        filters=f"""
            WHERE
                id = {student_id}
        """,
    )
    async with await db.get_conn() as conn:
        async with await conn.cursor() as cur:
            await cur.execute(update_stmt)
            await conn.commit()


async def get_student(student_id) -> Student:
    stmt: str = db_utils.create_select(
        table="students",
        columns=None,
        filters=f"""
            WHERE id = {student_id}
            LIMIT 1
        """,
    )

    async with await db.get_conn() as conn:
        async with await conn.cursor() as cur:
            await cur.execute(stmt)
            row = await cur.fetchone()
            if row is None:
                raise StudentDoesNotExist

    return get_student_from_row(row)


async def delete_student(student_id: int):
    await require_student_exists(student_id)
    stmt: str = db_utils.create_delete(
        table="students",
        filters=f"""
            WHERE id = {student_id}
        """,
    )
    async with await db.get_conn() as conn:
        async with await conn.cursor() as cur:
            await cur.execute(stmt)
            await conn.commit()
            if cur.rowcount <= 0:
                raise StudentDeleteFailure


async def require_student_exists(student_id: int):
    stmt: str = db_utils.create_select(
        table="students",
        columns=("id",),
        filters=f"""
            WHERE id = {student_id}
            LIMIT 1
        """,
    )
    async with await db.get_conn() as conn:
        async with await conn.cursor() as cur:
            await cur.execute(stmt)
            row = await cur.fetchone()

            if row is None:
                raise StudentDoesNotExist


def get_student_from_row(row: tuple[Any, ...]) -> Student:
    return Student(id=row[0], name=row[1], email=row[2], major=row[3], year=row[4])
