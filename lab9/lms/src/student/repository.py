from mysql.connector.aio.abstracts import MySQLCursorAbstract
from mysql.connector.types import RowType

from src.database import db
from src.database import utils as db_utils

from .schemas import Student, StudentCreate, StudentList


async def fetch_students(*, limit: int, page: int) -> StudentList:
    offset: int = limit * (page - 1)
    stmt: str = f"""
        SELECT * FROM
            students
        LIMIT {limit}
        OFFSET {offset};
    """
    print(stmt)

    cur: MySQLCursorAbstract = await db.conn.cursor()
    await cur.execute(stmt)
    result: list[RowType | tuple] = await cur.fetchall()

    students: list[Student] = [
        Student(
            id=row[0],
            name=row[1],
            email=row[2],
            major=row[3],
            year=row[4]
        ) for row in result
    ]

    return StudentList(students=students)


async def create_student(student_data: StudentCreate):
    insert_stmt: str = db_utils.create_insert_stmt(
        table="students", kvs=student_data.model_dump()
    )

    cur: MySQLCursorAbstract = await db.conn.cursor()
    await cur.execute(insert_stmt)
