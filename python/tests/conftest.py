import sys
from pathlib import Path

import pytest
from fastapi.testclient import TestClient


sys.path.insert(0, str(Path(__file__).resolve().parents[1]))


@pytest.fixture(autouse=True)
def isolar_arquivos_de_teste(tmp_path: Path, monkeypatch: pytest.MonkeyPatch):
    from app.infraestrutura.configuracao import Configuracao
    from app.servicos import servico_nhtsa
    from app.servicos.servico_nhtsa import ServicoNHTSA

    monkeypatch.setattr(
        Configuracao,
        "diretorio_audios_analisados",
        property(lambda self: tmp_path / "audios" / "analisados"),
    )
    monkeypatch.setattr(
        Configuracao,
        "diretorio_modelos",
        property(lambda self: tmp_path / "modelos_treinados"),
    )
    ServicoNHTSA.consultar.cache_clear()
    monkeypatch.setattr(
        servico_nhtsa,
        "_consultar_json",
        lambda caminho, parametros: {"results": []},
    )


@pytest.fixture
def cliente_api():
    from app.principal import app

    return TestClient(app)
