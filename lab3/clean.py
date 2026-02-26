import sys
from enum import Enum
from pathlib import Path

DEFDIR: Path = Path("./csv").resolve()
DESTDIR: Path = Path("./data").resolve()


class SQType(Enum):
    quoted = 1
    pure = 0
    invalid = -1


def which_sql(line: str) -> SQType:
    type_: SQType = SQType.invalid

    if line.startswith("INSERT"):
        type_ = SQType.pure
    elif line.startswith('"INSERT'):
        type_ = SQType.quoted

    return type_


def main():
    DESTDIR.mkdir(exist_ok=True)

    files: list[Path] = [item for item in DEFDIR.iterdir() if item.is_file()]
    print(files)

    content: list[str] | str = ""
    for file in files:
        filename: str = file.stem + ".sql"
        print(filename)
        print(file.resolve())

        with open(file.resolve(), "r") as src:
            content = src.read()

        content = content.split("\n")
        line1: str = content[0]
        line2: str = content[1] if len(content) >= 2 else ""

        t1: SQType = which_sql(line1)
        t2: SQType = which_sql(line2)

        if t1 == SQType.invalid and t2 == SQType.invalid:
            print("Error: Preliminary check: invalid SQL format.", file=sys.stderr)
            return 1

        sqtype: SQType = t1

        if t1 == SQType.invalid:
            sqtype = t2

        if sqtype == SQType.quoted:
            content = [item.strip('"') for item in content]

        print("\n".join(content))
        with open(DESTDIR / Path(filename), "w") as dest_file:
            print("opened")
            dest_file.write("\n".join(content))

    return 0


if __name__ == "__main__":
    sys.exit(main())
