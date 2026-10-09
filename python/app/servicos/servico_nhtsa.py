from __future__ import annotations

from collections import Counter
from functools import lru_cache
import json
from typing import Any
from urllib.parse import urlencode
from urllib.request import Request, urlopen

from app.modelos.respostas import ContextoExterno


BASE_NHTSA = "https://api.nhtsa.gov"


def _consultar_json(caminho: str, parametros: dict[str, str]) -> dict[str, Any]:
    url = f"{BASE_NHTSA}{caminho}?{urlencode(parametros)}"
    requisicao = Request(url, headers={"User-Agent": "AutoSom-Diagnostico/0.1"})
    with urlopen(requisicao, timeout=10) as resposta:  # noqa: S310 - dominio fixo
        return json.loads(resposta.read().decode("utf-8"))


def _texto_componente(item: dict[str, Any]) -> str | None:
    valor = item.get("components") or item.get("Component")
    if isinstance(valor, str) and valor.strip():
        return valor.strip()
    return None


class ServicoNHTSA:
    @staticmethod
    @lru_cache(maxsize=128)
    def consultar(marca: str, modelo: str, ano: int) -> ContextoExterno:
        parametros = {
            "make": marca.strip(),
            "model": modelo.strip(),
            "modelYear": str(ano),
        }
        reclamacoes = _consultar_json(
            "/complaints/complaintsByVehicle", parametros
        ).get("results", [])
        recalls = _consultar_json("/recalls/recallsByVehicle", parametros).get(
            "results", []
        )
        contagem = Counter(
            componente
            for item in reclamacoes
            if isinstance(item, dict)
            for componente in [_texto_componente(item)]
            if componente
        )
        principais = [item for item, _ in contagem.most_common(5)]
        quantidade_reclamacoes = len(reclamacoes)
        quantidade_recalls = len(recalls)
        if not reclamacoes and not recalls:
            observacao = (
                "Sem correspondencia para marca/modelo/ano na consulta NHTSA. "
                "Isso nao comprova ausencia de defeitos."
            )
        else:
            observacao = (
                "Dados publicos dos Estados Unidos, usados apenas como contexto. "
                "Nao representam taxa de falha nem estatistica da frota brasileira."
            )
        return ContextoExterno(
            fonte="NHTSA - Estados Unidos",
            quantidade_reclamacoes=quantidade_reclamacoes,
            quantidade_recalls=quantidade_recalls,
            componentes_reclamados=principais,
            observacao=observacao,
        )
