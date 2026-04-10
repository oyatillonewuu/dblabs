import sys
from typing import Union

from mysql.connector import Error as MySQLError
from mysql.connector.aio import MySQLConnectionPool as AsyncMySQLConnectionPool

from src.config import DbConfig, get_db_config
from src.exceptions import DbException


class MySQLDB:
    def __init__(self, config: DbConfig):
        self.config = config
        self._cnx_pool: Union[AsyncMySQLConnectionPool, None] = None

    async def init_pool(self):
        self.validate_pool_closed()
        try:
            self._cnx_pool = AsyncMySQLConnectionPool(**self.config.model_dump())
            await self._cnx_pool.initialize_pool()
        except MySQLError as err:
            print(f"[DB Pool]: error: {err}")
            sys.exit(1)

    async def get_conn(self):
        self.validate_pool_open()
        return await self._cnx_pool.get_connection()  # type: ignore

    def validate_pool_closed(self):
        if self._cnx_pool is not None:
            raise DbException("Cannot initate pool: pool is already open.")

    def validate_pool_open(self):
        if self._cnx_pool is None:
            raise DbException("Cannot access pool: pool is not open.")

    @property
    def cnx_pool(self):
        return self._cnx_pool


db: MySQLDB = MySQLDB(get_db_config())
