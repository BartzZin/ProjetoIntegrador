unit DM_Configuracao;

interface

uses
  System.Classes, System.IniFiles, System.SysUtils;

type
  TDMConfiguracao = class(TDataModule)
  private
    FUrlApi: string;
    FPortaApi: Integer;
    FIniciarPythonAutomaticamente: Boolean;
    FModoDesenvolvimento: Boolean;
    FPortaDebugPyCharm: Integer;
    function ObterCaminhoIni: string;
  public
    procedure CarregarConfiguracoes;
    procedure SalvarConfiguracoes;
    function ObterUrlApi: string;
    function EstaEmModoDesenvolvimento: Boolean;
    function ObterPortaDebugPyCharm: Integer;
    property UrlApi: string read FUrlApi write FUrlApi;
    property PortaApi: Integer read FPortaApi write FPortaApi;
    property IniciarPythonAutomaticamente: Boolean
      read FIniciarPythonAutomaticamente write FIniciarPythonAutomaticamente;
    property ModoDesenvolvimento: Boolean
      read FModoDesenvolvimento write FModoDesenvolvimento;
    property PortaDebugPyCharm: Integer
      read FPortaDebugPyCharm write FPortaDebugPyCharm;
  end;

var
  DMConfiguracao: TDMConfiguracao;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}
{$R *.dfm}

function TDMConfiguracao.ObterCaminhoIni: string;
begin
  Result := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))) +
    'autosom.ini';
end;

procedure TDMConfiguracao.CarregarConfiguracoes;
var
  Ini: TIniFile;
begin
  Ini := TIniFile.Create(ObterCaminhoIni);
  try
    FUrlApi := Ini.ReadString('API', 'Url', 'http://127.0.0.1');
    FPortaApi := Ini.ReadInteger('API', 'Porta', 8000);
    FIniciarPythonAutomaticamente := Ini.ReadBool('Python',
      'IniciarAutomaticamente', False);
    FModoDesenvolvimento := Ini.ReadBool('Desenvolvimento', 'Ativo', False);
    FPortaDebugPyCharm := Ini.ReadInteger('Desenvolvimento',
      'PortaDebugPyCharm', 5678);
  finally
    Ini.Free;
  end;
end;

procedure TDMConfiguracao.SalvarConfiguracoes;
var
  Ini: TIniFile;
begin
  Ini := TIniFile.Create(ObterCaminhoIni);
  try
    Ini.WriteString('API', 'Url', FUrlApi);
    Ini.WriteInteger('API', 'Porta', FPortaApi);
    Ini.WriteBool('Python', 'IniciarAutomaticamente',
      FIniciarPythonAutomaticamente);
    Ini.WriteBool('Desenvolvimento', 'Ativo', FModoDesenvolvimento);
    Ini.WriteInteger('Desenvolvimento', 'PortaDebugPyCharm',
      FPortaDebugPyCharm);
  finally
    Ini.Free;
  end;
end;

function TDMConfiguracao.ObterUrlApi: string;
begin
  while FUrlApi.EndsWith('/') do
    Delete(FUrlApi, Length(FUrlApi), 1);
  Result := Format('%s:%d', [FUrlApi, FPortaApi]);
end;

function TDMConfiguracao.EstaEmModoDesenvolvimento: Boolean;
begin
  Result := FModoDesenvolvimento;
end;

function TDMConfiguracao.ObterPortaDebugPyCharm: Integer;
begin
  Result := FPortaDebugPyCharm;
end;

end.
