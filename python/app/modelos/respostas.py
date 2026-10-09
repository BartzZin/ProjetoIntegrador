from pydantic import BaseModel, Field


class RespostaSaude(BaseModel):
    situacao: str
    modelo_carregado: bool
    versao_modelo: str


class QualidadeAudio(BaseModel):
    indice: float = Field(ge=0, le=1)
    classificacao: str


class InformacaoModelo(BaseModel):
    versao: str


class VeiculoResposta(BaseModel):
    marca: str
    modelo: str
    ano: int | None
    motor: str | None


class ResultadoProblema(BaseModel):
    codigo: str
    descricao: str
    probabilidade_audio: float = Field(ge=0, le=1)
    probabilidade_historica: float | None = Field(default=None, ge=0, le=1)
    probabilidade_final: float = Field(ge=0, le=1)


class ContextoExterno(BaseModel):
    fonte: str
    quantidade_reclamacoes: int = Field(ge=0)
    quantidade_recalls: int = Field(ge=0)
    componentes_reclamados: list[str] = Field(default_factory=list)
    observacao: str


class RespostaAnalise(BaseModel):
    situacao: str
    qualidade_audio: QualidadeAudio
    modelo_ml: InformacaoModelo
    veiculo: VeiculoResposta
    resultados: list[ResultadoProblema]
    duracao_segundos: float
    tempo_processamento_ms: int
    aviso: str
    contexto_externo: ContextoExterno | None = None
