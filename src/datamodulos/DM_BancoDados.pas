unit DM_BancoDados;

interface

uses
  System.Classes, System.IOUtils, System.SysUtils,
  FireDAC.Comp.Client, FireDAC.Phys.SQLite, FireDAC.Phys.SQLiteDef,
  FireDAC.Stan.Def, FireDAC.Stan.Async, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.VCLUI.Wait, FireDAC.DApt;

type
  TDMBancoDados = class(TDataModule)
    Conexao: TFDConnection;
    DriverSQLite: TFDPhysSQLiteDriverLink;
    qryExecucao: TFDQuery;
    qryConsulta: TFDQuery;
  private
    procedure ExecutarScript(const AConteudo: string);
  public
    procedure InicializarBanco;
    procedure CriarEstruturaSeNecessario;
    procedure ConfigurarConexao;
    function ObterCaminhoBanco: string;
    procedure IniciarTransacao;
    procedure ConfirmarTransacao;
    procedure CancelarTransacao;
  end;

var
  DMBancoDados: TDMBancoDados;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}
{$R *.dfm}

function TDMBancoDados.ObterCaminhoBanco: string;
begin
  Result := TPath.Combine(ExtractFilePath(ParamStr(0)),
    TPath.Combine('dados', 'diagnostico_automotivo.db'));
end;

procedure TDMBancoDados.ConfigurarConexao;
begin
  ForceDirectories(ExtractFilePath(ObterCaminhoBanco));
  Conexao.Close;
  Conexao.FormatOptions.MapRules.Clear;
  with Conexao.FormatOptions.MapRules.Add do
  begin
    SourceDataType := dtWideMemo;
    TargetDataType := dtWideString;
  end;
  Conexao.FormatOptions.OwnMapRules := True;
  Conexao.Params.Clear;
  Conexao.Params.DriverID := 'SQLite';
  Conexao.Params.Database := ObterCaminhoBanco;
  Conexao.Params.Add('LockingMode=Normal');
  Conexao.LoginPrompt := False;
end;

procedure TDMBancoDados.InicializarBanco;
begin
  ConfigurarConexao;
  Conexao.Open;
  Conexao.ExecSQL('PRAGMA foreign_keys = ON');
  Conexao.ExecSQL('PRAGMA busy_timeout = 5000');
  Conexao.ExecSQL('PRAGMA journal_mode = WAL');
  CriarEstruturaSeNecessario;
end;

procedure TDMBancoDados.CriarEstruturaSeNecessario;
var
  CaminhoSchema: string;
begin
  CaminhoSchema := TPath.Combine(ExtractFilePath(ParamStr(0)),
    TPath.Combine('dados', 'schema.sql'));
  if not FileExists(CaminhoSchema) then
    raise EFileNotFoundException.CreateFmt('Schema nao encontrado: %s',
      [CaminhoSchema]);
  ExecutarScript(TFile.ReadAllText(CaminhoSchema, TEncoding.UTF8));
end;

procedure TDMBancoDados.ExecutarScript(const AConteudo: string);
var
  Comando: string;
  Comandos: TArray<string>;
begin
  Comandos := AConteudo.Split([';']);
  for Comando in Comandos do
    if Trim(Comando) <> '' then
      Conexao.ExecSQL(Trim(Comando));
end;

procedure TDMBancoDados.IniciarTransacao;
begin
  Conexao.StartTransaction;
end;

procedure TDMBancoDados.ConfirmarTransacao;
begin
  if Conexao.InTransaction then
    Conexao.Commit;
end;

procedure TDMBancoDados.CancelarTransacao;
begin
  if Conexao.InTransaction then
    Conexao.Rollback;
end;

end.
