import sqlite3
from pathlib import Path


class RepositorioDados:
    """Acesso somente leitura ao SQLite para contexto e treinamento."""

    def __init__(self, caminho_banco: Path) -> None:
        self.caminho_banco = caminho_banco

    def conectar_leitura(self) -> sqlite3.Connection:
        uri = f"file:{self.caminho_banco.as_posix()}?mode=ro"
        return sqlite3.connect(uri, uri=True)
