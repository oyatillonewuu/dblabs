from typing import Optional

from pydantic import BaseModel, EmailStr, Field


class Student(BaseModel):
    id: int
    name: str
    email: str
    major: str
    year: int


class StudentCreate(BaseModel):
    name: str = Field(max_length=100)
    email: EmailStr
    major: str = Field(max_length=50)
    year: int = Field(gt=0)


class StudentUpdate(BaseModel):
    name: Optional[str] = Field(max_length=100)


class StudentList(BaseModel):
    students: list[Student]
