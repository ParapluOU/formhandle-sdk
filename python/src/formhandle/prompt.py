"""Interactive prompt helpers."""


def ask(question: str) -> str:
    try:
        return input(question).strip()
    except (EOFError, KeyboardInterrupt):
        print()
        raise SystemExit(1)


def confirm(question: str) -> bool:
    answer = ask(f"{question} (y/N) ")
    return answer.lower() in ("y", "yes")
