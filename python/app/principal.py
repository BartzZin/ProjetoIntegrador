import os

from fastapi import FastAPI

from app.api.rotas_analise import roteador as roteador_analise
from app.api.rotas_contexto import roteador as roteador_contexto
from app.api.rotas_saude import roteador as roteador_saude


app = FastAPI(
    title="AutoSom Diagnostico API",
    description="API local de apoio à triagem automotiva por áudio.",
    version="0.1.0",
)
app.include_router(roteador_saude)
app.include_router(roteador_analise)
app.include_router(roteador_contexto)

if os.getenv("MODO_DESENVOLVIMENTO", "0") == "1":
    from app.api.rotas_debug import roteador as roteador_debug

    app.include_router(roteador_debug)
