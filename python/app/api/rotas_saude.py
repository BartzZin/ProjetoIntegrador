from fastapi import APIRouter

from app.modelos.respostas import RespostaSaude
from app.servicos.servico_modelo import ServicoModelo


roteador = APIRouter(prefix="/api/v1", tags=["saude"])


@roteador.get("/saude", response_model=RespostaSaude)
def verificar_saude() -> RespostaSaude:
    modelo = ServicoModelo()
    return RespostaSaude(
        situacao="ok",
        modelo_carregado=modelo.modelo_carregado,
        versao_modelo=modelo.versao,
    )
