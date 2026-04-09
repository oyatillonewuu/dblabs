from typing import Any


def create_insert_stmt(*, table: str, kvs: dict[str, Any]):
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
