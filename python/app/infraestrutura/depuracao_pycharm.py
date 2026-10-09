import os


def depuracao_esta_permitida() -> bool:
    return (
        os.getenv("MODO_DESENVOLVIMENTO", "0") == "1"
        and os.getenv("PYCHARM_DEBUG_ATIVO", "0") == "1"
    )


def conectar_pycharm() -> None:
    if not depuracao_esta_permitida():
        raise RuntimeError("Depuracao PyCharm nao permitida.")

    import pydevd_pycharm

    pydevd_pycharm.settrace(
        os.getenv("PYCHARM_DEBUG_HOST", "127.0.0.1"),
        port=int(os.getenv("PYCHARM_DEBUG_PORT", "5678")),
        stdout_to_server=True,
        stderr_to_server=True,
        suspend=False,
    )
