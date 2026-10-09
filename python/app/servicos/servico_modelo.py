from __future__ import annotations

import json
from pathlib import Path
from typing import Any

from app.infraestrutura.configuracao import Configuracao
from app.modelos.requisicoes import RequisicaoAnalise
from app.modelos.respostas import ResultadoProblema


DESCRICOES_PADRAO = {
    "NORMAL": "Funcionamento sem anomalia acustica detectada",
    "FALHA_IGNICAO_MARCHA_IRREGULAR": "Falha de ignicao ou marcha irregular",
    "CORREIA_POLIA_ROLAMENTO": "Ruido de correia, polia ou rolamento",
    "RUIDO_METALICO_MOTOR": "Ruido metalico interno do motor",
    "ANOMALIA_NAO_ESPECIFICADA": "Anomalia acustica que requer inspecao mecanica",
}


class ServicoModelo:
    def __init__(self) -> None:
        configuracao = Configuracao()
        caminho = configuracao.diretorio_modelos / "metadados_modelo.json"
        caminho_modelo = configuracao.diretorio_modelos / "modelo_audio.joblib"
        self.modelo_carregado = False
        self.versao = "baseline-nao-treinado"
        self.escopo = "Nenhum modelo treinado instalado."
        self.erro_carregamento: str | None = None
        self._artefato: dict[str, Any] | None = None
        self._metadados: dict[str, Any] = {}
        if caminho.exists():
            self._metadados = json.loads(caminho.read_text(encoding="utf-8"))
            self.versao = str(self._metadados.get("versao", self.versao))
            self.escopo = str(self._metadados.get("escopo", self.escopo))
        if caminho_modelo.exists():
            try:
                import joblib

                artefato = joblib.load(caminho_modelo)
                if not isinstance(artefato, dict) or "pipeline" not in artefato:
                    raise ValueError("Artefato de modelo incompativel.")
                self._artefato = artefato
                self.versao = str(artefato.get("versao", self.versao))
                self.escopo = str(artefato.get("escopo", self.escopo))
                self.modelo_carregado = True
            except (ImportError, OSError, ValueError, TypeError) as erro:
                self.erro_carregamento = str(erro)

    def prever_problemas(
        self, caminho_audio: Path, requisicao: RequisicaoAnalise
    ) -> list[ResultadoProblema]:
        if not self.modelo_carregado or self._artefato is None:
            # O projeto não deve apresentar probabilidades artificiais antes do treino.
            return []

        import pandas as pd

        from app.servicos.servico_caracteristicas_audio import (
            construir_registro_modelo,
        )

        contexto = requisicao.model_dump()
        registro = construir_registro_modelo(caminho_audio, contexto)
        pipeline = self._artefato["pipeline"]
        probabilidades = pipeline.predict_proba(pd.DataFrame([registro]))[0]
        classes = [str(valor) for valor in pipeline.classes_]
        descricoes = {
            **DESCRICOES_PADRAO,
            **self._artefato.get("descricoes_classes", {}),
        }
        ordenados = sorted(
            zip(classes, probabilidades, strict=True),
            key=lambda item: float(item[1]),
            reverse=True,
        )
        limite = int(self._artefato.get("max_resultados", 4))
        return [
            ResultadoProblema(
                codigo=codigo,
                descricao=descricoes.get(codigo, codigo.replace("_", " ").title()),
                probabilidade_audio=round(float(probabilidade), 6),
                probabilidade_historica=None,
                probabilidade_final=round(float(probabilidade), 6),
            )
            for codigo, probabilidade in ordenados[:limite]
        ]
