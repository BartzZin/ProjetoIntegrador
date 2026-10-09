from typing import Annotated

from fastapi import APIRouter, File, Form, UploadFile

from app.modelos.requisicoes import RequisicaoAnalise
from app.modelos.respostas import RespostaAnalise
from app.servicos.servico_analise import ServicoAnalise


roteador = APIRouter(prefix="/api/v1/analises", tags=["analises"])


@roteador.post("/audio", response_model=RespostaAnalise)
async def analisar_audio(
    arquivo_audio: Annotated[UploadFile, File()],
    id_modelo_veiculo: Annotated[int, Form()],
    marca: Annotated[str, Form(min_length=1, max_length=80)],
    modelo: Annotated[str, Form(min_length=1, max_length=80)],
    ano: Annotated[int | None, Form(ge=1886, le=2100)] = None,
    codigo_motor: Annotated[str | None, Form(max_length=80)] = None,
    familia_motor: Annotated[str | None, Form(max_length=80)] = None,
    cilindrada_cc: Annotated[int | None, Form(gt=0, le=20000)] = None,
    cilindros: Annotated[int | None, Form(gt=0, le=16)] = None,
    combustivel: Annotated[str | None, Form(max_length=30)] = None,
    aspiracao: Annotated[str | None, Form(max_length=30)] = None,
    valvulas: Annotated[int | None, Form(gt=0, le=64)] = None,
    tipo_injecao: Annotated[str | None, Form(max_length=50)] = None,
) -> RespostaAnalise:
    requisicao = RequisicaoAnalise(
        id_modelo_veiculo=id_modelo_veiculo,
        marca=marca,
        modelo=modelo,
        ano=ano,
        codigo_motor=codigo_motor,
        familia_motor=familia_motor,
        cilindrada_cc=cilindrada_cc,
        cilindros=cilindros,
        combustivel=combustivel,
        aspiracao=aspiracao,
        valvulas=valvulas,
        tipo_injecao=tipo_injecao,
    )
    return await ServicoAnalise().analisar_audio(arquivo_audio, requisicao)
