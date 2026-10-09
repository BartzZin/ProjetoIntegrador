unit DM_EnviaDados;

interface

uses
  System.Classes, System.JSON, System.SysUtils,
  REST.Client, REST.Types, uModeloVeiculo, uResultadoAnalise;

type
  TAnaliseAudioConcluida = reference to procedure(
    AResultado: TResultadoAnaliseCompleto);
  TAnaliseAudioErro = reference to procedure(const AMensagem: string);

  TDMEnviaDados = class(TDataModule)
    RESTClient: TRESTClient;
    ReqSaude: TRESTRequest;
    RespSaude: TRESTResponse;
    ReqAnalise: TRESTRequest;
    RespAnalise: TRESTResponse;
    ReqDebugPyCharm: TRESTRequest;
    RespDebugPyCharm: TRESTResponse;
  public
    function VerificarApiDisponivel: Boolean;
    function ObterVersaoModelo: string;
    function AnalisarAudio(const ACaminhoAudio: string;
      const AVeiculo: TModeloVeiculo): TResultadoAnaliseCompleto;
    procedure AnalisarAudioAsync(const ACaminhoAudio: string;
      const AVeiculo: TModeloVeiculo;
      const AConcluida: TAnaliseAudioConcluida;
      const AErro: TAnaliseAudioErro);
    procedure ConfigurarRequisicaoAnalise(const ACaminhoAudio: string;
      const AVeiculo: TModeloVeiculo);
    function InterpretarRespostaAnalise(
      const AJson: string): TResultadoAnaliseCompleto;
    function ConectarDepuradorPyCharm: Boolean;
  end;

var
  DMEnviaDados: TDMEnviaDados;

implementation

uses
  DM_Configuracao;

{%CLASSGROUP 'Vcl.Controls.TControl'}
{$R *.dfm}

function TDMEnviaDados.VerificarApiDisponivel: Boolean;
begin
  RESTClient.BaseURL := DMConfiguracao.ObterUrlApi;
  try
    ReqSaude.Execute;
    Result := (RespSaude.StatusCode = 200) and
      SameText(RespSaude.JSONValue.GetValue<string>('situacao'), 'ok');
  except
    Result := False;
  end;
end;

function TDMEnviaDados.ObterVersaoModelo: string;
begin
  Result := '';
  if Assigned(RespSaude.JSONValue) then
    Result := RespSaude.JSONValue.GetValue<string>('versao_modelo', '');
end;

procedure TDMEnviaDados.ConfigurarRequisicaoAnalise(
  const ACaminhoAudio: string; const AVeiculo: TModeloVeiculo);

  procedure AdicionarInteiroOpcional(const ANome: string; AValor: Integer);
  begin
    if AValor > 0 then
      ReqAnalise.AddParameter(ANome, IntToStr(AValor), pkGETorPOST);
  end;

  procedure AdicionarTextoOpcional(const ANome, AValor: string);
  begin
    if Trim(AValor) <> '' then
      ReqAnalise.AddParameter(ANome, AValor, pkGETorPOST);
  end;

begin
  RESTClient.BaseURL := DMConfiguracao.ObterUrlApi;
  ReqAnalise.Params.Clear;
  ReqAnalise.AddParameter('id_modelo_veiculo', IntToStr(AVeiculo.Id),
    pkGETorPOST);
  ReqAnalise.AddParameter('marca', AVeiculo.Marca, pkGETorPOST);
  ReqAnalise.AddParameter('modelo', AVeiculo.Modelo, pkGETorPOST);
  AdicionarInteiroOpcional('ano', AVeiculo.AnoInicial);
  AdicionarTextoOpcional('codigo_motor', AVeiculo.CodigoMotor);
  AdicionarTextoOpcional('familia_motor', AVeiculo.FamiliaMotor);
  AdicionarInteiroOpcional('cilindrada_cc', AVeiculo.CilindradaCC);
  AdicionarInteiroOpcional('cilindros', AVeiculo.Cilindros);
  AdicionarTextoOpcional('combustivel', AVeiculo.Combustivel);
  AdicionarTextoOpcional('aspiracao', AVeiculo.Aspiracao);
  AdicionarInteiroOpcional('valvulas', AVeiculo.Valvulas);
  AdicionarTextoOpcional('tipo_injecao', AVeiculo.TipoInjecao);
  ReqAnalise.AddFile('arquivo_audio', ACaminhoAudio,
    TRESTContentType.ctAPPLICATION_OCTET_STREAM);
end;

function TDMEnviaDados.AnalisarAudio(const ACaminhoAudio: string;
  const AVeiculo: TModeloVeiculo): TResultadoAnaliseCompleto;
begin
  if not FileExists(ACaminhoAudio) then
    raise EFileNotFoundException.CreateFmt('Audio nao encontrado: %s',
      [ACaminhoAudio]);
  ConfigurarRequisicaoAnalise(ACaminhoAudio, AVeiculo);
  ReqAnalise.Execute;
  if not (RespAnalise.StatusCode in [200, 201]) then
    raise Exception.CreateFmt('API retornou HTTP %d: %s',
      [RespAnalise.StatusCode, RespAnalise.Content]);
  Result := InterpretarRespostaAnalise(RespAnalise.Content);
end;

procedure TDMEnviaDados.AnalisarAudioAsync(const ACaminhoAudio: string;
  const AVeiculo: TModeloVeiculo;
  const AConcluida: TAnaliseAudioConcluida;
  const AErro: TAnaliseAudioErro);
begin
  if not FileExists(ACaminhoAudio) then
    raise EFileNotFoundException.CreateFmt('Audio nao encontrado: %s',
      [ACaminhoAudio]);

  ConfigurarRequisicaoAnalise(ACaminhoAudio, AVeiculo);
  ReqAnalise.ExecuteAsync(
    procedure
    var
      Resultado: TResultadoAnaliseCompleto;
    begin
      if not (RespAnalise.StatusCode in [200, 201]) then
      begin
        if Assigned(AErro) then
          AErro(Format('API retornou HTTP %d: %s',
            [RespAnalise.StatusCode, RespAnalise.Content]));
        Exit;
      end;

      Resultado := nil;
      try
        Resultado := InterpretarRespostaAnalise(RespAnalise.Content);
        if Assigned(AConcluida) then
          AConcluida(Resultado);
      except
        on E: Exception do
          if Assigned(AErro) then
            AErro(E.Message);
      end;
      Resultado.Free;
    end,
    True,
    True,
    procedure(AObjetoErro: TObject)
    var
      Mensagem: string;
    begin
      if AObjetoErro is Exception then
        Mensagem := Exception(AObjetoErro).Message
      else
        Mensagem := 'Falha desconhecida ao comunicar com a API Python.';
      if Assigned(AErro) then
        AErro(Mensagem);
    end);
end;

function TDMEnviaDados.InterpretarRespostaAnalise(
  const AJson: string): TResultadoAnaliseCompleto;
var
  Raiz, Item: TJSONValue;
  Objeto: TJSONObject;
  ArrayResultados: TJSONArray;
  Resultado: TResultadoAnalise;
begin
  Result := TResultadoAnaliseCompleto.Create;
  Raiz := TJSONObject.ParseJSONValue(AJson);
  if not Assigned(Raiz) then
  begin
    Result.Free;
    raise EConvertError.Create('Resposta JSON invalida.');
  end;
  try
    Result.Situacao := Raiz.GetValue<string>('situacao', '');
    Result.QualidadeIndice := Raiz.GetValue<Double>('qualidade_audio.indice', 0);
    Result.QualidadeClassificacao :=
      Raiz.GetValue<string>('qualidade_audio.classificacao', '');
    Result.VersaoModelo := Raiz.GetValue<string>('modelo_ml.versao', '');
    Result.DuracaoSegundos := Raiz.GetValue<Double>('duracao_segundos', 0);
    Result.TempoProcessamentoMs :=
      Raiz.GetValue<Integer>('tempo_processamento_ms', 0);
    Result.Aviso := Raiz.GetValue<string>('aviso', '');

    ArrayResultados := Raiz.GetValue<TJSONArray>('resultados');
    if Assigned(ArrayResultados) then
      for Item in ArrayResultados do
      begin
        Objeto := Item as TJSONObject;
        Resultado := TResultadoAnalise.Create;
        Resultado.Codigo := Objeto.GetValue<string>('codigo', '');
        Resultado.Descricao := Objeto.GetValue<string>('descricao', '');
        Resultado.ProbabilidadeAudio :=
          Objeto.GetValue<Double>('probabilidade_audio', 0);
        Resultado.PossuiProbabilidadeHistorica :=
          Assigned(Objeto.GetValue('probabilidade_historica')) and
          not (Objeto.GetValue('probabilidade_historica') is TJSONNull);
        if Resultado.PossuiProbabilidadeHistorica then
          Resultado.ProbabilidadeHistorica :=
            Objeto.GetValue<Double>('probabilidade_historica', 0);
        Resultado.ProbabilidadeFinal :=
          Objeto.GetValue<Double>('probabilidade_final', 0);
        Result.Resultados.Add(Resultado);
      end;
  finally
    Raiz.Free;
  end;
end;

function TDMEnviaDados.ConectarDepuradorPyCharm: Boolean;
begin
  RESTClient.BaseURL := DMConfiguracao.ObterUrlApi;
  try
    ReqDebugPyCharm.Execute;
    Result := RespDebugPyCharm.StatusCode = 200;
  except
    Result := False;
  end;
end;

end.
