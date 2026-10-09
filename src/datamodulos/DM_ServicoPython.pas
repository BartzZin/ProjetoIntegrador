unit DM_ServicoPython;

interface

uses
  Winapi.Windows, System.Classes, System.Diagnostics, System.IOUtils,
  System.SysUtils;

type
  TDMServicoPython = class(TDataModule)
  private
    FProcesso: THandle;
  public
    destructor Destroy; override;
    function ApiEstaExecutando: Boolean;
    function LocalizarExecutavelPython: string;
    function ObterCaminhoExecutarApi: string;
    procedure IniciarApiPython;
    procedure EncerrarApiPython;
    function AguardarApiDisponivel(ATimeoutMs: Cardinal = 10000): Boolean;
  end;

var
  DMServicoPython: TDMServicoPython;

implementation

uses
  DM_Configuracao, DM_EnviaDados;

{%CLASSGROUP 'Vcl.Controls.TControl'}
{$R *.dfm}

destructor TDMServicoPython.Destroy;
begin
  if FProcesso <> 0 then
    CloseHandle(FProcesso);
  inherited;
end;

function TDMServicoPython.ApiEstaExecutando: Boolean;
begin
  Result := DMEnviaDados.VerificarApiDisponivel;
end;

function TDMServicoPython.LocalizarExecutavelPython: string;
begin
  Result := TPath.Combine(ExtractFilePath(ParamStr(0)),
    TPath.Combine('python', TPath.Combine('.venv',
      TPath.Combine('Scripts', 'python.exe'))));
  if not FileExists(Result) then
    raise EFileNotFoundException.CreateFmt('Python virtual nao encontrado: %s',
      [Result]);
end;

function TDMServicoPython.ObterCaminhoExecutarApi: string;
begin
  Result := TPath.Combine(ExtractFilePath(ParamStr(0)),
    TPath.Combine('python', 'executar_api.py'));
  if not FileExists(Result) then
    raise EFileNotFoundException.CreateFmt('Entrada da API nao encontrada: %s',
      [Result]);
end;

procedure TDMServicoPython.IniciarApiPython;
var
  Comando, Diretorio: string;
  Inicializacao: TStartupInfo;
  Processo: TProcessInformation;
begin
  if ApiEstaExecutando then
    Exit;
  SetEnvironmentVariable('AUTOSOM_HOST', '127.0.0.1');
  SetEnvironmentVariable('AUTOSOM_PORTA',
    PChar(IntToStr(DMConfiguracao.PortaApi)));
  if DMConfiguracao.ModoDesenvolvimento then
  begin
    SetEnvironmentVariable('MODO_DESENVOLVIMENTO', '1');
    SetEnvironmentVariable('PYCHARM_DEBUG_ATIVO', '1');
  end
  else
  begin
    SetEnvironmentVariable('MODO_DESENVOLVIMENTO', '0');
    SetEnvironmentVariable('PYCHARM_DEBUG_ATIVO', '0');
  end;
  SetEnvironmentVariable('PYCHARM_DEBUG_HOST', '127.0.0.1');
  SetEnvironmentVariable('PYCHARM_DEBUG_PORT',
    PChar(IntToStr(DMConfiguracao.PortaDebugPyCharm)));
  Comando := Format('"%s" "%s"', [LocalizarExecutavelPython,
    ObterCaminhoExecutarApi]);
  Diretorio := TPath.Combine(ExtractFilePath(ParamStr(0)), 'python');
  UniqueString(Comando);
  ZeroMemory(@Inicializacao, SizeOf(Inicializacao));
  Inicializacao.cb := SizeOf(Inicializacao);
  Inicializacao.dwFlags := STARTF_USESHOWWINDOW;
  Inicializacao.wShowWindow := SW_HIDE;
  ZeroMemory(@Processo, SizeOf(Processo));
  if not CreateProcess(nil, PChar(Comando), nil, nil, False,
    CREATE_NO_WINDOW, nil, PChar(Diretorio), Inicializacao, Processo) then
    RaiseLastOSError;
  CloseHandle(Processo.hThread);
  FProcesso := Processo.hProcess;
end;

procedure TDMServicoPython.EncerrarApiPython;
begin
  if FProcesso = 0 then
    Exit;
  TerminateProcess(FProcesso, 0);
  CloseHandle(FProcesso);
  FProcesso := 0;
end;

function TDMServicoPython.AguardarApiDisponivel(
  ATimeoutMs: Cardinal): Boolean;
var
  Cronometro: TStopwatch;
begin
  Cronometro := TStopwatch.StartNew;
  repeat
    if ApiEstaExecutando then
      Exit(True);
    Sleep(200);
  until Cronometro.ElapsedMilliseconds >= ATimeoutMs;
  Result := False;
end;

end.
