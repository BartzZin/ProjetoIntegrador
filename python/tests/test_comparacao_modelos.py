import pytest

pd = pytest.importorskip("pandas")
pytest.importorskip("sklearn")

from treinamento.comparar_modelos import agregar_gravacoes, calcular_metricas


def test_agregacao_da_o_mesmo_peso_a_gravacoes_de_tamanhos_distintos():
    linhas = [
        {"modelo": "teste", "grupo_gravacao": "normal", "rotulo_real": "NORMAL", "dobra": 1,
         "arquivo": f"normal_{i}.wav", "probabilidade_normal": 0.8, "probabilidade_anomalia": 0.2}
        for i in range(10)
    ]
    linhas.append({"modelo": "teste", "grupo_gravacao": "anomalia", "rotulo_real": "ANOMALIA_NAO_ESPECIFICADA",
                   "dobra": 2, "arquivo": "anomalia.wav", "probabilidade_normal": 0.6, "probabilidade_anomalia": 0.4})
    gravacoes = agregar_gravacoes(pd.DataFrame(linhas))
    assert len(gravacoes) == 2
    assert sorted(gravacoes.quantidade_segmentos) == [1, 10]
    assert calcular_metricas(gravacoes.rotulo_real, gravacoes.rotulo_previsto)["acuracia"] == 0.5


def test_agregacao_rejeita_gravacao_distribuida_em_dobras_diferentes():
    base = {"modelo": "teste", "grupo_gravacao": "mesmo_audio", "rotulo_real": "NORMAL",
            "arquivo": "motor.wav", "probabilidade_normal": 0.9, "probabilidade_anomalia": 0.1}
    dados = pd.DataFrame([{**base, "dobra": 1}, {**base, "dobra": 2}])
    with pytest.raises(ValueError, match="unica dobra"):
        agregar_gravacoes(dados)
