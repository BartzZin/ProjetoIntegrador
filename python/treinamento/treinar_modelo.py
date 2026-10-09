from __future__ import annotations

import argparse
from datetime import datetime, timezone
import hashlib
import json
from pathlib import Path
import sys
from typing import Any


RAIZ_PYTHON = Path(__file__).resolve().parents[1]
if str(RAIZ_PYTHON) not in sys.path:
    sys.path.insert(0, str(RAIZ_PYTHON))

import joblib
import pandas as pd
from sklearn.compose import ColumnTransformer
from sklearn.ensemble import RandomForestClassifier
from sklearn.impute import SimpleImputer
from sklearn.metrics import (
    accuracy_score,
    balanced_accuracy_score,
    classification_report,
    confusion_matrix,
    f1_score,
)
from sklearn.model_selection import StratifiedGroupKFold, cross_val_predict
from sklearn.pipeline import Pipeline
from sklearn.preprocessing import OneHotEncoder, StandardScaler

from app.servicos.servico_caracteristicas_audio import (
    construir_registro_modelo,
)
from app.servicos.servico_modelo import DESCRICOES_PADRAO


COLUNAS_OBRIGATORIAS = {
    "arquivo",
    "rotulo",
    "grupo_gravacao",
    "fonte",
    "licenca",
    "nivel_confirmacao",
}
COLUNAS_CATEGORICAS = [
    "codigo_motor",
    "familia_motor",
    "combustivel",
    "aspiracao",
    "tipo_injecao",
]
COLUNAS_MECANICAS_NUMERICAS = [
    "cilindrada_cc",
    "cilindros",
    "valvulas",
]


def _texto_opcional(valor: Any) -> str | None:
    if pd.isna(valor) or not str(valor).strip():
        return None
    return str(valor).strip()


def _numero_opcional(valor: Any) -> float | None:
    if pd.isna(valor) or not str(valor).strip():
        return None
    return float(valor)


def carregar_manifesto(caminho: Path, nivel_minimo: int) -> pd.DataFrame:
    dados = pd.read_csv(caminho, dtype=str, keep_default_na=False)
    faltantes = COLUNAS_OBRIGATORIAS - set(dados.columns)
    if faltantes:
        raise ValueError(f"Colunas obrigatorias ausentes: {sorted(faltantes)}")
    dados["rotulo"] = dados["rotulo"].str.strip().str.upper()
    dados["grupo_gravacao"] = dados["grupo_gravacao"].str.strip()
    if (dados["grupo_gravacao"] == "").any():
        raise ValueError("Toda amostra deve possuir grupo_gravacao.")
    rotulos_desconhecidos = set(dados["rotulo"]) - set(DESCRICOES_PADRAO)
    if rotulos_desconhecidos:
        raise ValueError(
            f"Rotulos nao suportados pela API/Delphi: {sorted(rotulos_desconhecidos)}"
        )
    if (dados["fonte"].str.strip() == "").any() or (
        dados["licenca"].str.strip() == ""
    ).any():
        raise ValueError("Toda amostra deve registrar fonte e licenca de uso.")
    rotulos_por_grupo = dados.groupby("grupo_gravacao")["rotulo"].nunique()
    if (rotulos_por_grupo > 1).any():
        raise ValueError("Um grupo_gravacao nao pode possuir mais de um rotulo.")

    niveis = pd.to_numeric(dados["nivel_confirmacao"], errors="coerce").fillna(0)
    dados = dados.loc[niveis >= nivel_minimo].copy()
    if dados.empty:
        raise ValueError("Nenhuma amostra atende ao nivel minimo de confirmacao.")

    def resolver(nome: str) -> Path:
        caminho_audio = Path(nome)
        if not caminho_audio.is_absolute():
            caminho_audio = caminho.parent / caminho_audio
        return caminho_audio.resolve()

    dados["caminho_audio"] = dados["arquivo"].map(resolver)
    ausentes = [str(item) for item in dados["caminho_audio"] if not item.is_file()]
    if ausentes:
        exemplo = "\n".join(ausentes[:5])
        raise FileNotFoundError(f"Arquivos de audio nao encontrados:\n{exemplo}")
    if dados["rotulo"].nunique() < 2:
        raise ValueError("O treinamento exige pelo menos duas classes.")
    return dados.reset_index(drop=True)


def validar_duplicatas(dados: pd.DataFrame) -> None:
    por_hash: dict[str, tuple[str, str]] = {}
    for linha in dados.itertuples(index=False):
        digest = hashlib.sha256(Path(linha.caminho_audio).read_bytes()).hexdigest()
        anterior = por_hash.get(digest)
        atual = (linha.rotulo, linha.grupo_gravacao)
        if anterior and anterior != atual:
            raise ValueError(
                "O mesmo audio aparece em rotulos ou grupos diferentes: "
                f"{anterior} e {atual}."
            )
        por_hash[digest] = atual


def extrair_dataset(dados: pd.DataFrame) -> pd.DataFrame:
    registros: list[dict[str, Any]] = []
    total = len(dados)
    for indice, linha in enumerate(dados.to_dict(orient="records"), start=1):
        contexto = {
            campo: _texto_opcional(linha.get(campo)) for campo in COLUNAS_CATEGORICAS
        }
        contexto.update(
            {
                campo: _numero_opcional(linha.get(campo))
                for campo in COLUNAS_MECANICAS_NUMERICAS
            }
        )
        registros.append(
            construir_registro_modelo(Path(linha["caminho_audio"]), contexto)
        )
        print(f"Extraindo caracteristicas: {indice}/{total}", end="\r", flush=True)
    print()
    return pd.DataFrame(registros)


def construir_pipeline(colunas_audio: list[str], semente: int) -> Pipeline:
    colunas_numericas = colunas_audio + COLUNAS_MECANICAS_NUMERICAS
    transformador_numerico = Pipeline(
        [
            ("imputacao", SimpleImputer(strategy="median")),
            ("escala", StandardScaler()),
        ]
    )
    transformador_categorico = Pipeline(
        [
            ("imputacao", SimpleImputer(strategy="constant", fill_value="DESCONHECIDO")),
            (
                "one_hot",
                OneHotEncoder(handle_unknown="ignore", min_frequency=2),
            ),
        ]
    )
    preprocessamento = ColumnTransformer(
        [
            ("audio_mecanica", transformador_numerico, colunas_numericas),
            ("contexto", transformador_categorico, COLUNAS_CATEGORICAS),
        ]
    )
    classificador = RandomForestClassifier(
        n_estimators=400,
        min_samples_leaf=2,
        class_weight="balanced_subsample",
        random_state=semente,
        n_jobs=-1,
    )
    return Pipeline(
        [("preprocessamento", preprocessamento), ("classificador", classificador)]
    )


def avaliar_validacao_cruzada(
    pipeline: Pipeline,
    caracteristicas: pd.DataFrame,
    rotulos: pd.Series,
    grupos: pd.Series,
    semente: int,
) -> dict[str, Any]:
    grupos_por_classe = (
        pd.DataFrame({"rotulo": rotulos, "grupo": grupos})
        .drop_duplicates()
        .groupby("rotulo")["grupo"]
        .nunique()
    )
    numero_dobras = min(5, int(grupos_por_classe.min()))
    if numero_dobras < 2:
        raise ValueError(
            "Cada classe precisa de ao menos dois grupos de gravacao independentes."
        )
    validacao = StratifiedGroupKFold(
        n_splits=numero_dobras, shuffle=True, random_state=semente
    )
    previstos = cross_val_predict(
        pipeline,
        caracteristicas,
        rotulos,
        groups=grupos,
        cv=validacao,
        method="predict",
        n_jobs=1,
    )
    classes = sorted(rotulos.unique().tolist())
    return {
        "dobras": numero_dobras,
        "acuracia": round(float(accuracy_score(rotulos, previstos)), 6),
        "acuracia_balanceada": round(
            float(balanced_accuracy_score(rotulos, previstos)), 6
        ),
        "f1_macro": round(float(f1_score(rotulos, previstos, average="macro")), 6),
        "matriz_confusao": confusion_matrix(
            rotulos, previstos, labels=classes
        ).tolist(),
        "relatorio_classes": classification_report(
            rotulos, previstos, labels=classes, output_dict=True, zero_division=0
        ),
    }


def _resumo_coluna(dados: pd.DataFrame, coluna: str) -> dict[str, int]:
    if coluna not in dados.columns:
        return {}
    valores = dados[coluna].replace("", "NAO_INFORMADO")
    return {str(chave): int(valor) for chave, valor in valores.value_counts().items()}


def treinar(
    manifesto: Path,
    saida: Path,
    versao: str,
    nivel_minimo: int,
    semente: int,
    escopo: str,
) -> dict[str, Any]:
    dados = carregar_manifesto(manifesto, nivel_minimo)
    validar_duplicatas(dados)
    caracteristicas = extrair_dataset(dados)
    colunas_audio = [
        coluna
        for coluna in caracteristicas.columns
        if coluna not in COLUNAS_CATEGORICAS + COLUNAS_MECANICAS_NUMERICAS
    ]
    for coluna in COLUNAS_MECANICAS_NUMERICAS:
        caracteristicas[coluna] = pd.to_numeric(
            caracteristicas[coluna], errors="coerce"
        )
    pipeline = construir_pipeline(colunas_audio, semente)
    metricas = avaliar_validacao_cruzada(
        pipeline,
        caracteristicas,
        dados["rotulo"],
        dados["grupo_gravacao"],
        semente,
    )
    pipeline.fit(caracteristicas, dados["rotulo"])

    classes = [str(item) for item in pipeline.classes_]
    descricoes = {
        classe: DESCRICOES_PADRAO.get(classe, classe.replace("_", " ").title())
        for classe in classes
    }
    artefato = {
        "versao": versao,
        "pipeline": pipeline,
        "descricoes_classes": descricoes,
        "colunas_audio": colunas_audio,
        "max_resultados": min(4, len(classes)),
        "escopo": escopo,
    }
    fontes = []
    if {"fonte", "licenca"}.issubset(dados.columns):
        fontes = (
            dados[["fonte", "licenca"]]
            .drop_duplicates()
            .replace("", "NAO_INFORMADO")
            .to_dict(orient="records")
        )
    metadados = {
        "versao": versao,
        "data_treinamento_utc": datetime.now(timezone.utc).isoformat(),
        "algoritmo": "RandomForest + MFCC/espectro + contexto mecanico",
        "classes": classes,
        "quantidade_amostras": int(len(dados)),
        "quantidade_grupos": int(dados["grupo_gravacao"].nunique()),
        "amostras_por_classe": _resumo_coluna(dados, "rotulo"),
        "amostras_por_familia_motor": _resumo_coluna(dados, "familia_motor"),
        "nivel_confirmacao_minimo": nivel_minimo,
        "fontes": fontes,
        "metricas_validacao_grupos": metricas,
        "observacao": (
            "As dobras sao separadas por grupo_gravacao para impedir que janelas "
            "do mesmo audio aparecam no treino e no teste."
        ),
        "escopo": escopo,
    }

    saida.mkdir(parents=True, exist_ok=True)
    temporario = saida / "modelo_audio.joblib.tmp"
    joblib.dump(artefato, temporario)
    temporario.replace(saida / "modelo_audio.joblib")
    (saida / "metadados_modelo.json").write_text(
        json.dumps(metadados, ensure_ascii=False, indent=2), encoding="utf-8"
    )
    return metadados


def main() -> None:
    raiz_projeto = Path(__file__).resolve().parents[2]
    parser = argparse.ArgumentParser(
        description="Treina e avalia o classificador acustico do AutoSom."
    )
    parser.add_argument(
        "--manifesto",
        type=Path,
        default=raiz_projeto / "audios" / "dataset_local" / "manifesto.csv",
    )
    parser.add_argument(
        "--saida", type=Path, default=raiz_projeto / "python" / "modelos_treinados"
    )
    parser.add_argument("--versao", default=datetime.now().strftime("%Y.%m.%d.1"))
    parser.add_argument("--nivel-minimo", type=int, default=2, choices=range(0, 5))
    parser.add_argument("--semente", type=int, default=42)
    parser.add_argument(
        "--escopo",
        default="Modelo experimental; consulte os metadados do dataset.",
    )
    argumentos = parser.parse_args()
    metadados = treinar(
        argumentos.manifesto.resolve(),
        argumentos.saida.resolve(),
        argumentos.versao,
        argumentos.nivel_minimo,
        argumentos.semente,
        argumentos.escopo,
    )
    print(json.dumps(metadados["metricas_validacao_grupos"], indent=2))
    print(f"Modelo salvo em {argumentos.saida.resolve()}")


if __name__ == "__main__":
    main()
