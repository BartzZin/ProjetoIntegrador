from fastapi import APIRouter, HTTPException

from app.infraestrutura.depuracao_pycharm import (
    conectar_pycharm,
    depuracao_esta_permitida,
)


roteador = APIRouter(prefix="/api/v1/debug", tags=["desenvolvimento"])


@roteador.post("/pycharm/conectar")
def conectar_debug_pycharm() -> dict[str, str]:
    if not depuracao_esta_permitida():
        raise HTTPException(status_code=404, detail="Recurso indisponivel.")
    conectar_pycharm()
    return {"situacao": "conectado"}
