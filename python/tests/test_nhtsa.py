from app.servicos import servico_nhtsa
from app.servicos.servico_nhtsa import ServicoNHTSA


def test_contexto_nhtsa_agrega_componentes(monkeypatch) -> None:
    ServicoNHTSA.consultar.cache_clear()

    def resposta(caminho: str, parametros: dict[str, str]) -> dict:
        assert parametros == {"make": "Acura", "model": "RDX", "modelYear": "2012"}
        if caminho.startswith("/complaints"):
            return {
                "results": [
                    {"components": "ENGINE"},
                    {"components": "ENGINE"},
                    {"components": "SERVICE BRAKES"},
                ]
            }
        return {"results": [{"Component": "AIR BAGS"}]}

    monkeypatch.setattr(servico_nhtsa, "_consultar_json", resposta)
    resultado = ServicoNHTSA.consultar("Acura", "RDX", 2012)
    assert resultado.quantidade_reclamacoes == 3
    assert resultado.quantidade_recalls == 1
    assert resultado.componentes_reclamados[:2] == ["ENGINE", "SERVICE BRAKES"]


def test_rota_nhtsa(monkeypatch, cliente_api) -> None:
    ServicoNHTSA.consultar.cache_clear()
    monkeypatch.setattr(
        servico_nhtsa,
        "_consultar_json",
        lambda caminho, parametros: {"results": []},
    )
    resposta = cliente_api.get(
        "/api/v1/contexto/nhtsa",
        params={"marca": "Volkswagen", "modelo": "Gol", "ano": 2015},
    )
    assert resposta.status_code == 200
    assert resposta.json()["quantidade_reclamacoes"] == 0
    assert "nao comprova ausencia" in resposta.json()["observacao"]
