from contextlib import asynccontextmanager

from fastapi import FastAPI

from src.database import db
from src.student import student_router


@asynccontextmanager
async def lifespan(app: FastAPI):
    await db.init_pool()
    if db.cnx_pool is not None:
        print("[DB]: Connected.")
    yield
    print("[DB]: Disconnectd.")


app = FastAPI(lifespan=lifespan)
app.include_router(student_router)


@app.get("/")
async def health():
    return {"health": "ok"}
