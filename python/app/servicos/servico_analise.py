import asyncio
from time import perf_counter

from fastapi import UploadFile

from app.modelos.requisicoes import RequisicaoAnalise
from app.modelos.respostas import (
    InformacaoModelo,
    QualidadeAudio,
    RespostaAnalise,
    VeiculoResposta,
)
from app.servicos.servico_modelo import ServicoModelo
from app.servicos.servico_nhtsa import ServicoNHTSA
from app.servicos.servico_preprocessamento_audio import ServicoPreprocessamentoAudio


class ServicoAnalise:
    async def analisar_audio(
        self, arquivo: UploadFile, requisicao: RequisicaoAnalise
    ) -> RespostaAnalise:
        inicio = perf_counter()
        audio = await ServicoPreprocessamentoAudio().processar(arquivo)
        tarefa_contexto = None
        if requisicao.ano is not None:
            tarefa_contexto = asyncio.create_task(
                asyncio.to_thread(
                    ServicoNHTSA.consultar,
                    requisicao.marca,
                    requisicao.modelo,
                    requisicao.ano,
                )
            )
        modelo = ServicoModelo()
        resultados = modelo.prever_problemas(audio.caminho_wav, requisicao)
        contexto_externo = None
        if tarefa_contexto is not None:
            try:
                contexto_externo = await asyncio.wait_for(
                    tarefa_contexto,
                    timeout=3,
                )
            except (OSError, TimeoutError, ValueError):
                # A indisponibilidade externa nunca deve impedir a analise local.
                contexto_externo = None
        if modelo.modelo_carregado:
            aviso = (
                "Classificacao indicativa gerada por modelo experimental. "
                f"Escopo: {modelo.escopo} "
                "Confirme o resultado com inspecao mecanica e nao utilize a "
                "probabilidade como diagnostico conclusivo."
            )
        else:
            aviso = (
                "Audio recebido e validado. Modelo ML ainda nao treinado; nenhuma "
                "probabilidade foi inventada. Resultado indicativo, nao substitui "
                "avaliacao mecanica."
            )
        if contexto_externo is not None:
            aviso += (
                " NHTSA (EUA): "
                f"{contexto_externo.quantidade_reclamacoes} reclamacoes e "
                f"{contexto_externo.quantidade_recalls} recalls para o veiculo "
                "informado; dado contextual, nao e taxa brasileira."
            )
        return RespostaAnalise(
            situacao="sucesso_sem_classificacao" if not modelo.modelo_carregado else "sucesso",
            qualidade_audio=QualidadeAudio(
                indice=audio.indice_qualidade,
                classificacao=audio.classificacao_qualidade,
            ),
            modelo_ml=InformacaoModelo(versao=modelo.versao),
            veiculo=VeiculoResposta(
                marca=requisicao.marca,
                modelo=requisicao.modelo,
                ano=requisicao.ano,
                motor=requisicao.codigo_motor or requisicao.familia_motor,
            ),
            resultados=resultados,
            duracao_segundos=round(audio.duracao_segundos, 3),
            tempo_processamento_ms=round((perf_counter() - inicio) * 1000),
            aviso=aviso,
            contexto_externo=contexto_externo,
        )
