from contextlib import asynccontextmanager
from fastapi import FastAPI

from src.database import db


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

@app.get("/")
async def health():
    return {
        "health": "ok"
    }
