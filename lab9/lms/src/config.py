from functools import lru_cache

from dotenv import load_dotenv
from pydantic import Field
from pydantic_settings import BaseSettings, SettingsConfigDict

load_dotenv()


class DbConfig(BaseSettings):
    user: str
    password: str
    database: str
    host: str = "127.0.0.1"
    port: int = Field(default=3306, ge=0)
    pool_size: int = 5
    pool_name: str = "db_pool"

    model_config = SettingsConfigDict(env_prefix="db_")


@lru_cache
def get_db_config():
    return DbConfig()  # type: ignore
