from typing import Any, Optional


def create_insert_stmt(*, table: str, kvs: dict[str, Any]) -> str:
    columns: str = build_str_tuple(list(kvs.keys()))
    values: str = build_str_tuple(list(kvs.values()), wrap_str_in_quotes=True)

    stmt = f"""
        INSERT INTO {table}
            {columns}
        VALUES
            {values};
    """
    print(stmt)
    return stmt


def create_select(
    *, table: str, columns: Optional[tuple[str, ...]] = None, filters: str = ""
) -> str:
    columns_str: str = "" if columns is None else ",".join(columns)

    stmt = f"""
        SELECT {columns_str}
        FROM {table}
        {filters};
    """
    return stmt

def create_delete(
    *, table: str, filters: str = ""
) -> str:

    stmt = f"""
        DELETE FROM {table}
        {filters};
    """
    return stmt


def create_update_stmt(*, table: str, kvs: dict[str, Any], filters: str = "") -> str:
    kvs: list[str] = build_kv_equality_list(kvs)

    kvs_str: str = ", ".join(kvs)

    stmt = f"""
        UPDATE {table}
        SET
            {kvs_str}
        {filters};
    """

    return stmt


def build_kv_equality_list(kvs: dict[str, Any]) -> list[str]:
    result: list[str] = []

    for key, value in kvs.items():
        result.append(build_str_set_equal(key, value))

    return result


def build_str_set_equal(key: str, value: Any, wrap_key_in_quotes: bool = False) -> str:
    if wrap_key_in_quotes:
        key = f"'{key}'"
    if isinstance(value, str):
        value = f"'{value}'"

    return f"{key} = {value}"


def build_str_tuple(values: list[Any], wrap_str_in_quotes: bool = False) -> str:
    str_tuple: str = "("
    len_vals: int = len(values)

    for i in range(len_vals):
        value = values[i]
        if wrap_str_in_quotes and isinstance(value, str):
            value = f"'{value}'"
        str_tuple += str(value)
        if i < len_vals - 1:
            str_tuple += ", "

    str_tuple += ")"

    return str_tuple
