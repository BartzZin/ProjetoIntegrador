unit uModeloVeiculo;

interface

type
  TModeloVeiculo = class
  public
    Id: Integer;
    Marca: string;
    Modelo: string;
    AnoInicial: Integer;
    AnoFinal: Integer;
    CodigoMotor: string;
    FamiliaMotor: string;
    CilindradaCC: Integer;
    Cilindros: Integer;
    Combustivel: string;
    Aspiracao: string;
    Valvulas: Integer;
    TipoInjecao: string;
  end;

implementation

end.
