from fastapi import HTTPException, status


class StudentDoesNotExist(Exception):
    pass


class StudentDeleteFailure(Exception):
    pass


class StudentDoesNotExistHTTP(HTTPException):
    def __init__(self, student_id: int):
        super().__init__(
            detail=f"Student with id = {student_id} does not exist.",
            status_code=status.HTTP_404_NOT_FOUND,
        )


class StudentDeleteFailureHTTP(HTTPException):
    def __init__(self, student_id: int):
        super().__init__(
            detail=f"Failed to delete student with id = {student_id}.",
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
        )
