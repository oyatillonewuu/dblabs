from src.config import get_db_config, DbConfig
from mysql.connector.aio import connect as mysql_aio_connect
from mysql.connector.errors import DatabaseError, ProgrammingError
from src.exceptions import DbException


class MySQLDB:
    def __init__(self, config: DbConfig):
        self.config = config
        self.conn = None

    async def connect(self):
        if self.conn is not None:
            raise DbException("Cannot open connection: connection already exists.")
        try:
            self.conn = await mysql_aio_connect(**self.config.model_dump())
        except ProgrammingError as e:
            raise DbException(f"Connection error: Programming error: {e}")
        except DatabaseError as e:
            raise DbException(f"Connection error: Database error: {e}")
        except Exception as e:
            raise DbException(f"Connection error: unknown error occurred: {e}")

    async def close(self):
        if self.conn is not None:
            await self.conn.close()
        self.conn = None

db: MySQLDB = MySQLDB(get_db_config())
