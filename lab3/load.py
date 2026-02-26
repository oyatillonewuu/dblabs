import subprocess
import sys
from enum import Enum
from pathlib import Path

DEFDIR: Path = Path("./data")


class DBType(Enum):
    docker = 1
    pure = 0
    invalid = -1


def get_db_type(dbtype: str) -> DBType:
    if dbtype == "docker":
        return DBType.docker
    elif dbtype == "pure":
        return DBType.pure
    return DBType.invalid


def get_base_cmd(
    *, db_type: DBType, dbname: str, uname: str, pwd: str, container: str | None = None
):
    common: list[str] = [f"-u{uname}", f"-p{pwd}", dbname]
    if db_type == DBType.docker:
        return ["docker", "exec", container, "mysql"] + common
    return ["mysql"] + common


def collect_files() -> list[Path]:
    return [item for item in DEFDIR.iterdir() if item.is_file()]


def print_files_order(files: list[Path]):
    for i, file in enumerate(files):
        print(f"{i + 1}. ", file.name)


def main():
    DEFDIR.mkdir(exist_ok=True)
    dbtype: DBType | str = input("db type(default=docker, pure): ") or "docker"
    dbname: str = input("db name: ")
    uname: str = input("uname(default=root): ") or "root"
    pwd: str = input("pwd: ")
    container: str | None = None

    dbtype = get_db_type(dbtype)

    if dbtype == dbtype.invalid:
        print("Error: invalid db type", file=sys.stderr)
        return 1

    if dbtype == DBType.docker:
        container = input("Container name: ")

    base_cmd: list[str] = get_base_cmd(
        db_type=dbtype, dbname=dbname, uname=uname, pwd=pwd, container=container
    )

    files: list[Path] = collect_files()
    print_files_order(files)
    exec_order: list[int] = list(range(len(files)))

    order: str = input("Enter order(0 to default): ")

    if order != "0":
        exec_order = [int(num.strip()) - 1 for num in order.split(" ")]

    print(dbname, uname, pwd, container)
    print(exec_order)

    for i in exec_order:
        file: Path = files[i]
        print(file, file.resolve())
        print(base_cmd)

        with open(file.resolve(), "r") as f:
            proc = subprocess.run(
                base_cmd, stdin=f, capture_output=True, text=True, check=True
            )

            if proc.returncode != 0:
                print(f"Error: failed to load {file.name}.", file=sys.stderr)
                print(f"{proc.stderr}", file=sys.stderr)
                return 1

    return 0


if __name__ == "__main__":
    sys.exit(main())
