unit DM_Analises;

interface

uses
  System.Classes, System.Generics.Collections, System.IOUtils, System.SysUtils,
  Data.DB, FireDAC.Comp.Client, FireDAC.Stan.Param, uResultadoAnalise;

type
  TDMAnalises = class(TDataModule)
    qryHistorico: TFDQuery;
    qryResultados: TFDQuery;
    qryInserirAnalise: TFDQuery;
    qryInserirResultado: TFDQuery;
    dsHistorico: TDataSource;
    dsResultados: TDataSource;
  private
    function ObterIdDefeito(const ACodigo: string): Integer;
  public
    function CopiarAudioParaHistorico(const AArquivoOrigem: string): string;
    function CriarAnalise(AIdModeloVeiculo: Integer;
      const AArquivoRelativo: string; const AResultado: TResultadoAnaliseCompleto): Int64;
    procedure SalvarResultados(AIdAnalise: Int64;
      AResultados: TObjectList<TResultadoAnalise>);
    procedure AbrirHistorico;
    procedure AbrirResultados(AIdAnalise: Int64);
  end;

var
  DMAnalises: TDMAnalises;

implementation

uses
  DM_BancoDados;

{%CLASSGROUP 'Vcl.Controls.TControl'}
{$R *.dfm}

function TDMAnalises.CopiarAudioParaHistorico(
  const AArquivoOrigem: string): string;
var
  Diretorio, NomeDestino: string;
begin
  if not FileExists(AArquivoOrigem) then
    raise EFileNotFoundException.CreateFmt('Audio nao encontrado: %s',
      [AArquivoOrigem]);
  Diretorio := TPath.Combine(ExtractFilePath(ParamStr(0)),
    TPath.Combine('audios', 'analisados'));
  ForceDirectories(Diretorio);
  NomeDestino := FormatDateTime('yyyymmdd_hhnnss_zzz', Now) + '_' +
    TPath.GetFileName(AArquivoOrigem);
  TFile.Copy(AArquivoOrigem, TPath.Combine(Diretorio, NomeDestino), False);
  Result := TPath.Combine(TPath.Combine('audios', 'analisados'), NomeDestino);
end;

function TDMAnalises.CriarAnalise(AIdModeloVeiculo: Integer;
  const AArquivoRelativo: string;
  const AResultado: TResultadoAnaliseCompleto): Int64;
begin
  DMBancoDados.IniciarTransacao;
  try
    qryInserirAnalise.Prepare;
    qryInserirAnalise.ParamByName('modelo').AsInteger := AIdModeloVeiculo;
    qryInserirAnalise.ParamByName('data_hora').AsString :=
      FormatDateTime('yyyy-mm-dd"T"hh:nn:ss', Now);
    qryInserirAnalise.ParamByName('arquivo').AsString := AArquivoRelativo;
    qryInserirAnalise.ParamByName('qualidade').AsFloat :=
      AResultado.QualidadeIndice;
    qryInserirAnalise.ParamByName('classificacao').AsString :=
      AResultado.QualidadeClassificacao;
    qryInserirAnalise.ParamByName('versao').AsString := AResultado.VersaoModelo;
    qryInserirAnalise.ParamByName('tempo').AsInteger :=
      AResultado.TempoProcessamentoMs;
    qryInserirAnalise.ExecSQL;
    Result := DMBancoDados.Conexao.ExecSQLScalar('select last_insert_rowid()');
    SalvarResultados(Result, AResultado.Resultados);
    DMBancoDados.ConfirmarTransacao;
  except
    DMBancoDados.CancelarTransacao;
    raise;
  end;
end;

function TDMAnalises.ObterIdDefeito(const ACodigo: string): Integer;
begin
  if SameText(ACodigo, 'NORMAL') then
    Exit(1);
  if SameText(ACodigo, 'FALHA_IGNICAO_MARCHA_IRREGULAR') then
    Exit(2);
  if SameText(ACodigo, 'CORREIA_POLIA_ROLAMENTO') then
    Exit(3);
  if SameText(ACodigo, 'RUIDO_METALICO_MOTOR') then
    Exit(4);
  if SameText(ACodigo, 'ANOMALIA_NAO_ESPECIFICADA') then
    Exit(5);
  Result := 0;
end;

procedure TDMAnalises.SalvarResultados(AIdAnalise: Int64;
  AResultados: TObjectList<TResultadoAnalise>);
var
  I, IdDefeito: Integer;
  Resultado: TResultadoAnalise;
begin
  qryInserirResultado.Prepare;
  for I := 0 to AResultados.Count - 1 do
  begin
    Resultado := AResultados[I];
    IdDefeito := ObterIdDefeito(Resultado.Codigo);
    if IdDefeito = 0 then
      Continue;
    qryInserirResultado.ParamByName('analise').AsLargeInt := AIdAnalise;
    qryInserirResultado.ParamByName('defeito').AsInteger := IdDefeito;
    qryInserirResultado.ParamByName('audio').AsFloat :=
      Resultado.ProbabilidadeAudio;
    if Resultado.PossuiProbabilidadeHistorica then
      qryInserirResultado.ParamByName('historica').AsFloat :=
        Resultado.ProbabilidadeHistorica
    else
      qryInserirResultado.ParamByName('historica').Clear;
    qryInserirResultado.ParamByName('final').AsFloat :=
      Resultado.ProbabilidadeFinal;
    qryInserirResultado.ParamByName('ordem').AsInteger := I + 1;
    qryInserirResultado.ExecSQL;
  end;
end;

procedure TDMAnalises.AbrirHistorico;
begin
  qryHistorico.Close;
  qryHistorico.Open;
end;

procedure TDMAnalises.AbrirResultados(AIdAnalise: Int64);
begin
  qryResultados.Close;
  qryResultados.ParamByName('analise').AsLargeInt := AIdAnalise;
  qryResultados.Open;
end;

end.
