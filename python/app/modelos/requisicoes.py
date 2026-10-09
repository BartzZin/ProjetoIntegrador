from pydantic import BaseModel, ConfigDict


class RequisicaoAnalise(BaseModel):
    model_config = ConfigDict(str_strip_whitespace=True)

    id_modelo_veiculo: int
    marca: str
    modelo: str
    ano: int | None = None
    codigo_motor: str | None = None
    familia_motor: str | None = None
    cilindrada_cc: int | None = None
    cilindros: int | None = None
    combustivel: str | None = None
    aspiracao: str | None = None
    valvulas: int | None = None
    tipo_injecao: str | None = None
