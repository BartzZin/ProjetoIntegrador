from pathlib import Path

import pytest

from app.infraestrutura.configuracao import Configuracao


RAIZ = Path(__file__).resolve().parents[2]


@pytest.mark.parametrize("arquivo,classe", [
    ("01_motor_normal_bmw_m54.wav", "NORMAL"),
    ("02_motor_anomalia_bmw_m54.wav", "ANOMALIA_NAO_ESPECIFICADA"),
])
def test_api_com_modelo_instalado_e_audio_de_demonstracao(monkeypatch, cliente_api, arquivo, classe):
    modelos = RAIZ / "python/modelos_treinados"
    audio = RAIZ / "audios/demonstracao" / arquivo
    if not (modelos / "modelo_audio.joblib").is_file() or not audio.is_file():
        pytest.skip("Teste de integracao requer modelo treinado e audio local de demonstracao.")
    monkeypatch.setattr(Configuracao, "diretorio_modelos", property(lambda self: modelos))
    saude = cliente_api.get("/api/v1/saude").json()
    assert saude["modelo_carregado"]
    campos = {"id_modelo_veiculo": "1", "marca": "BMW", "modelo": "Demonstracao AI Mechanic", "ano": "2004",
              "codigo_motor": "M54B25", "familia_motor": "BMW_M54", "cilindrada_cc": "2494", "cilindros": "6",
              "combustivel": "GASOLINA", "aspiracao": "ASPIRADO", "valvulas": "24", "tipo_injecao": "ELETRONICA"}
    resposta = cliente_api.post("/api/v1/analises/audio", data=campos,
                               files={"arquivo_audio": (arquivo, audio.read_bytes(), "audio/wav")})
    assert resposta.status_code == 200
    corpo = resposta.json()
    assert corpo["situacao"] == "sucesso"
    assert corpo["modelo_ml"]["versao"] == saude["versao_modelo"]
    resultados = corpo["resultados"]
    assert resultados[0]["codigo"] == classe
    assert {r["codigo"] for r in resultados} == {"NORMAL", "ANOMALIA_NAO_ESPECIFICADA"}
    assert sum(r["probabilidade_audio"] for r in resultados) == pytest.approx(1, abs=1e-5)
    assert resultados[0]["probabilidade_audio"] >= resultados[1]["probabilidade_audio"]
    assert all(r["probabilidade_historica"] is None for r in resultados)
    assert all(r["probabilidade_final"] == r["probabilidade_audio"] for r in resultados)
