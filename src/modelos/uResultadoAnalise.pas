unit uResultadoAnalise;

interface

uses
  System.Generics.Collections;

type
  TResultadoAnalise = class
  public
    Codigo: string;
    Descricao: string;
    ProbabilidadeAudio: Double;
    ProbabilidadeHistorica: Double;
    PossuiProbabilidadeHistorica: Boolean;
    ProbabilidadeFinal: Double;
  end;

  TResultadoAnaliseCompleto = class
  private
    FResultados: TObjectList<TResultadoAnalise>;
  public
    Situacao: string;
    QualidadeIndice: Double;
    QualidadeClassificacao: string;
    VersaoModelo: string;
    DuracaoSegundos: Double;
    TempoProcessamentoMs: Integer;
    Aviso: string;
    constructor Create;
    destructor Destroy; override;
    property Resultados: TObjectList<TResultadoAnalise> read FResultados;
  end;

implementation

constructor TResultadoAnaliseCompleto.Create;
begin
  inherited Create;
  FResultados := TObjectList<TResultadoAnalise>.Create(True);
end;

destructor TResultadoAnaliseCompleto.Destroy;
begin
  FResultados.Free;
  inherited;
end;

end.
