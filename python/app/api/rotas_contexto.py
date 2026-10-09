import asyncio

from fastapi import APIRouter, HTTPException, Query

from app.modelos.respostas import ContextoExterno
from app.servicos.servico_nhtsa import ServicoNHTSA


roteador = APIRouter(prefix="/api/v1/contexto", tags=["contexto externo"])


@roteador.get("/nhtsa", response_model=ContextoExterno)
async def consultar_nhtsa(
    marca: str = Query(min_length=1, max_length=80),
    modelo: str = Query(min_length=1, max_length=80),
    ano: int = Query(ge=1900, le=2100),
) -> ContextoExterno:
    try:
        return await asyncio.to_thread(ServicoNHTSA.consultar, marca, modelo, ano)
    except (OSError, TimeoutError, ValueError) as erro:
        raise HTTPException(
            status_code=503,
            detail=f"Consulta NHTSA temporariamente indisponivel: {erro}",
        ) from erro
