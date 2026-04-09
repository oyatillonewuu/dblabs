from types import CoroutineType
from typing import Union

from mysql.connector.aio.abstracts import MySQLConnectionAbstract
from mysql.connector.aio.pooling import PooledMySQLConnection
from src.config import get_db_config, DbConfig
from mysql.connector.aio import connect as mysql_aio_connect
from mysql.connector.errors import DatabaseError, ProgrammingError
from src.exceptions import DbException


class MySQLDB:
    def __init__(self, config: DbConfig):
        self.config = config
        self._conn: Union[MySQLConnectionAbstract, PooledMySQLConnection, None] = None

    async def connect(self):
        if self._conn is not None:
            raise DbException("Cannot open connection: connection already exists.")
        try:
            self._conn = await mysql_aio_connect(**self.config.model_dump())
        except ProgrammingError as e:
            raise DbException(f"Connection error: Programming error: {e}")
        except DatabaseError as e:
            raise DbException(f"Connection error: Database error: {e}")
        except Exception as e:
            raise DbException(f"Connection error: unknown error occurred: {e}")

    async def close(self):
        if self._conn is not None:
            await self._conn.close()
        self._conn = None

    async def get_cursor(self):
        self.check_conn_alive()
        return await self._conn.cursor()

    async def cursor_execute(self, stmt: str):
        self.check_conn_alive()
        await self._conn.cursor().execute(stmt)
        await self.commit()

    async def commit(self):
        self.check_conn_alive()
        await self.conn.commit()

    def check_conn_alive(self):
        if self._conn is None:
            raise DbException("Cannot retrieve connection: no open connection.")

    @property
    def conn(self) -> Union[MySQLConnectionAbstract, PooledMySQLConnection]:
        self.check_conn_alive()
        return self._conn

db: MySQLDB = MySQLDB(get_db_config())
