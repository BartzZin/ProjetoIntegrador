"""Compara classificadores sem substituir o modelo instalado no AutoSom.

Todas as previsoes exportadas sao feitas fora do treino da respectiva dobra.
"""
from __future__ import annotations

import argparse
from collections import Counter
from datetime import datetime, timezone
import hashlib
from importlib.metadata import version
import json
from pathlib import Path
import platform
import sys
from typing import Any
import wave

RAIZ_PYTHON = Path(__file__).resolve().parents[1]
if str(RAIZ_PYTHON) not in sys.path:
    sys.path.insert(0, str(RAIZ_PYTHON))

import numpy as np
import pandas as pd
from sklearn.base import clone
from sklearn.dummy import DummyClassifier
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import accuracy_score, balanced_accuracy_score
from sklearn.metrics import classification_report, confusion_matrix, f1_score
from sklearn.model_selection import StratifiedGroupKFold

from treinamento.treinar_modelo import (
    COLUNAS_CATEGORICAS, COLUNAS_MECANICAS_NUMERICAS,
    carregar_manifesto, construir_pipeline, extrair_dataset, validar_duplicatas,
)

CLASSES = ["ANOMALIA_NAO_ESPECIFICADA", "NORMAL"]


def calcular_metricas(reais: Any, previstos: Any) -> dict[str, Any]:
    return {
        "acuracia": float(accuracy_score(reais, previstos)),
        "acuracia_balanceada": float(balanced_accuracy_score(reais, previstos)),
        "f1_macro": float(f1_score(reais, previstos, labels=CLASSES, average="macro", zero_division=0)),
        "matriz_confusao": confusion_matrix(reais, previstos, labels=CLASSES).tolist(),
        "relatorio_classes": classification_report(reais, previstos, labels=CLASSES, output_dict=True, zero_division=0),
    }


def agregar_gravacoes(previsoes: pd.DataFrame) -> pd.DataFrame:
    """Cada gravacao tem um voto, obtido pela media de suas probabilidades."""
    agrupado = previsoes.groupby(["modelo", "grupo_gravacao"], sort=True)
    if (agrupado["rotulo_real"].nunique() != 1).any() or (agrupado["dobra"].nunique() != 1).any():
        raise ValueError("Gravacoes precisam ter um unico rotulo e uma unica dobra.")
    resultado = agrupado.agg(
        rotulo_real=("rotulo_real", "first"), dobra=("dobra", "first"),
        quantidade_segmentos=("arquivo", "count"),
        probabilidade_anomalia=("probabilidade_anomalia", "mean"),
        probabilidade_normal=("probabilidade_normal", "mean"),
    ).reset_index()
    # Empates seguem a ordem das classes usada por sklearn (anomalia primeiro).
    resultado["rotulo_previsto"] = np.where(
        resultado["probabilidade_normal"] > resultado["probabilidade_anomalia"],
        "NORMAL", "ANOMALIA_NAO_ESPECIFICADA",
    )
    return resultado


def auditar_dataset(dados: pd.DataFrame) -> dict[str, Any]:
    registros = []
    hashes_pcm: dict[str, str] = {}
    for linha in dados.itertuples(index=False):
        caminho = Path(linha.caminho_audio)
        with wave.open(str(caminho), "rb") as wav:
            pcm = wav.readframes(wav.getnframes())
            assinatura = f"{wav.getnchannels()}:{wav.getsampwidth()}:{wav.getframerate()}".encode() + pcm
            digest_pcm = hashlib.sha256(assinatura).hexdigest()
            if digest_pcm in hashes_pcm:
                raise ValueError(f"Audio PCM duplicado: {linha.arquivo} e {hashes_pcm[digest_pcm]}")
            hashes_pcm[digest_pcm] = linha.arquivo
            registros.append({
                "arquivo": linha.arquivo,
                "sha256": hashlib.sha256(caminho.read_bytes()).hexdigest(),
                "sha256_pcm": digest_pcm,
                "duracao_segundos": wav.getnframes() / wav.getframerate(),
                "taxa_amostragem": wav.getframerate(), "canais": wav.getnchannels(),
                "grupo_gravacao": linha.grupo_gravacao, "rotulo": linha.rotulo,
            })
    return {
        "amostras": len(dados), "grupos": int(dados.grupo_gravacao.nunique()),
        "segmentos_por_classe": dict(Counter(dados.rotulo)),
        "grupos_por_classe": dados.groupby("rotulo").grupo_gravacao.nunique().to_dict(),
        "contexto": {c: sorted(dados[c].unique().tolist()) for c in COLUNAS_CATEGORICAS + COLUNAS_MECANICAS_NUMERICAS},
        "fontes": dados[["fonte", "licenca", "nivel_confirmacao"]].drop_duplicates().to_dict("records"),
        "arquivos": registros,
    }


def comparar(manifesto: Path, saida: Path, semente: int = 42) -> dict[str, Any]:
    if saida.resolve() == (RAIZ_PYTHON / "modelos_treinados").resolve():
        raise ValueError("Use uma saida separada dos modelos instalados.")
    dados = carregar_manifesto(manifesto, nivel_minimo=2)
    if sorted(dados.rotulo.unique()) != CLASSES:
        raise ValueError("Esta comparacao requer NORMAL e ANOMALIA_NAO_ESPECIFICADA.")
    validar_duplicatas(dados)
    auditoria = auditar_dataset(dados)
    if min(auditoria["grupos_por_classe"].values()) < 5:
        raise ValueError("A comparacao de cinco dobras exige ao menos cinco grupos por classe.")
    caracteristicas = extrair_dataset(dados)
    colunas_audio = [c for c in caracteristicas if c not in COLUNAS_CATEGORICAS + COLUNAS_MECANICAS_NUMERICAS]
    for coluna in COLUNAS_MECANICAS_NUMERICAS:
        caracteristicas[coluna] = pd.to_numeric(caracteristicas[coluna], errors="coerce")
    if not np.isfinite(caracteristicas[colunas_audio].to_numpy()).all():
        raise ValueError("Caracteristicas acusticas nao finitas.")

    floresta = construir_pipeline(colunas_audio, semente)
    majoritario = clone(floresta).set_params(classificador=DummyClassifier(strategy="most_frequent"))
    logistica = clone(floresta).set_params(classificador=LogisticRegression(
        C=1, class_weight="balanced", solver="lbfgs", max_iter=2000, random_state=semente,
    ))
    modelos = {"majoritaria": majoritario, "random_forest": floresta, "regressao_logistica": logistica}
    cv = StratifiedGroupKFold(n_splits=5, shuffle=True, random_state=semente)
    divisoes = list(cv.split(caracteristicas, dados.rotulo, dados.grupo_gravacao))
    registros = []; metricas_dobras = []; divisao_exportada = []
    for dobra, (treino, validacao) in enumerate(divisoes, start=1):
        grupos_treino = set(dados.iloc[treino].grupo_gravacao)
        grupos_validacao = set(dados.iloc[validacao].grupo_gravacao)
        if grupos_treino & grupos_validacao:
            raise ValueError("Sobreposicao de grupos entre treino e validacao.")
        if dados.iloc[treino].rotulo.nunique() != 2 or dados.iloc[validacao].rotulo.nunique() != 2:
            raise ValueError("Toda dobra precisa conter as duas classes.")
        divisao_exportada.append({
            "dobra": dobra, "grupos_treino": sorted(grupos_treino), "grupos_validacao": sorted(grupos_validacao),
            "segmentos_treino": dict(Counter(dados.iloc[treino].rotulo)),
            "segmentos_validacao": dict(Counter(dados.iloc[validacao].rotulo)),
        })
        for nome, original in modelos.items():
            pipeline = clone(original)
            pipeline.fit(caracteristicas.iloc[treino], dados.iloc[treino].rotulo)
            previstos = pipeline.predict(caracteristicas.iloc[validacao])
            probabilidades = pipeline.predict_proba(caracteristicas.iloc[validacao])
            indice_classes = {c: i for i, c in enumerate(pipeline.classes_)}
            metrica = calcular_metricas(dados.iloc[validacao].rotulo, previstos)
            metricas_dobras.append({"modelo": nome, "dobra": dobra, **{k: metrica[k] for k in ["acuracia", "acuracia_balanceada", "f1_macro"]}})
            for pos, indice in enumerate(validacao):
                linha = dados.iloc[indice]
                registros.append({
                    "modelo": nome, "dobra": dobra, "arquivo": linha.arquivo,
                    "grupo_gravacao": linha.grupo_gravacao, "rotulo_real": linha.rotulo,
                    "rotulo_previsto": previstos[pos],
                    "probabilidade_anomalia": float(probabilidades[pos, indice_classes[CLASSES[0]]]),
                    "probabilidade_normal": float(probabilidades[pos, indice_classes[CLASSES[1]]]),
                })
            print(f"Dobra {dobra}/5 {nome}: F1 macro = {metrica['f1_macro']:.4f}", flush=True)

    previsoes = pd.DataFrame(registros)
    gravacoes = agregar_gravacoes(previsoes)
    por_dobra = pd.DataFrame(metricas_dobras)
    resumo = {}
    linhas_resumo = []
    for nome in modelos:
        segmentos_modelo = previsoes[previsoes.modelo == nome]
        grupos_modelo = gravacoes[gravacoes.modelo == nome]
        metricas_segmentos = calcular_metricas(segmentos_modelo.rotulo_real, segmentos_modelo.rotulo_previsto)
        metricas_gravacoes = calcular_metricas(grupos_modelo.rotulo_real, grupos_modelo.rotulo_previsto)
        dobras_modelo = por_dobra[por_dobra.modelo == nome]
        variacao = {c: {"media": float(dobras_modelo[c].mean()), "desvio_padrao": float(dobras_modelo[c].std(ddof=0)), "minimo": float(dobras_modelo[c].min()), "maximo": float(dobras_modelo[c].max())} for c in ["acuracia", "acuracia_balanceada", "f1_macro"]}
        resumo[nome] = {"segmentos": metricas_segmentos, "gravacoes": metricas_gravacoes, "dobras": variacao}
        for unidade, metrica in [("segmentos", metricas_segmentos), ("gravacoes", metricas_gravacoes)]:
            linhas_resumo.append({"modelo": nome, "unidade": unidade, **{k: metrica[k] for k in ["acuracia", "acuracia_balanceada", "f1_macro"]}, "recall_normal": metrica["relatorio_classes"]["NORMAL"]["recall"], "recall_anomalia": metrica["relatorio_classes"][CLASSES[0]]["recall"]})

    referencia = RAIZ_PYTHON / "modelos_treinados/metadados_modelo.json"
    anteriores = {}
    if referencia.is_file():
        metadados_instalados = json.loads(referencia.read_text(encoding="utf-8"))
        anteriores = metadados_instalados.get("metricas_validacao_grupos", {})
    rf = resumo["random_forest"]["segmentos"]
    reproducao = {c: {"anterior": anteriores[c], "atual": rf[c], "coincide_6_casas": round(rf[c], 6) == anteriores[c]} for c in ["acuracia", "acuracia_balanceada", "f1_macro"] if c in anteriores}
    resultado = {
        "data_utc": datetime.now(timezone.utc).isoformat(), "semente": semente,
        "classes_ordem_matriz": CLASSES, "dobras": 5, "nivel_confirmacao_minimo": 2,
        "sha256_manifesto": hashlib.sha256(manifesto.read_bytes()).hexdigest(),
        "quantidade_caracteristicas_audio": len(colunas_audio), "colunas_audio": colunas_audio,
        "parametros": {
            "majoritaria": {"strategy": "most_frequent"},
            "random_forest": {"n_estimators": 400, "min_samples_leaf": 2, "class_weight": "balanced_subsample", "random_state": semente},
            "regressao_logistica": {"C": 1, "class_weight": "balanced", "solver": "lbfgs", "max_iter": 2000, "random_state": semente},
        },
        "ambiente": {"python": platform.python_version(), "sistema": platform.platform(), **{p: version(p) for p in ["numpy", "pandas", "scikit-learn", "librosa", "soundfile", "joblib"]}},
        "reproducao_modelo_atual": reproducao, "resultados": resumo,
        "observacao": "Resultados exploratorios de validacao cruzada de gravacoes de um unico veiculo; sem teste externo ou ajuste de hiperparametros. Desvio das dobras nao e intervalo de confianca.",
    }
    saida.mkdir(parents=True, exist_ok=True)
    for nome, objeto in [("metricas.json", resultado), ("auditoria_dataset.json", auditoria), ("divisoes.json", divisao_exportada)]:
        (saida / nome).write_text(json.dumps(objeto, ensure_ascii=False, indent=2), encoding="utf-8")
    for nome, tabela in [("previsoes_segmentos.csv", previsoes), ("previsoes_gravacoes.csv", gravacoes), ("metricas_dobras.csv", por_dobra), ("resumo_metricas.csv", pd.DataFrame(linhas_resumo))]:
        tabela.to_csv(saida / nome, index=False, encoding="utf-8-sig")
    caracteristicas.to_csv(saida / "caracteristicas.csv", index=False, encoding="utf-8-sig")
    return resultado


def main() -> None:
    raiz = RAIZ_PYTHON.parent
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--manifesto", type=Path, default=raiz / "audios/dataset_local/ai_mechanic/manifesto.csv")
    parser.add_argument("--saida", type=Path, default=raiz / "output/experimentos")
    parser.add_argument("--semente", type=int, default=42)
    args = parser.parse_args()
    resultado = comparar(args.manifesto.resolve(), args.saida.resolve(), args.semente)
    print(json.dumps(resultado["resultados"], ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
