from contextlib import asynccontextmanager
from fastapi import FastAPI

from src.database import db
from src.student import student_router

@asynccontextmanager
async def lifespan(app: FastAPI):
    await db.connect()
    if db.conn is not None:
        print("[DB]: Connected.")
    yield
    await db.close()
    if db.conn is None:
        print("[DB]: Disconnectd.")


app = FastAPI(lifespan=lifespan)
app.include_router(student_router)

@app.get("/")
async def health():
    return {
        "health": "ok"
    }
