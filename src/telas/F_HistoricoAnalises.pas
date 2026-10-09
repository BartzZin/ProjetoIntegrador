unit F_HistoricoAnalises;

interface

uses
  Winapi.Windows, Winapi.ShellAPI, System.Classes, System.IOUtils,
  System.SysUtils, Data.DB, Vcl.Controls, Vcl.DBGrids, Vcl.ExtCtrls,
  Vcl.Forms, Vcl.StdCtrls;

type
  TFrmHistoricoAnalises = class(TForm)
    grdAnalises: TDBGrid;
    grdResultados: TDBGrid;
    pnlBotoes: TPanel;
    btnAtualizar: TButton;
    btnAbrirAudio: TButton;
    btnFechar: TButton;
    lblAnalises: TLabel;
    lblResultados: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure grdAnalisesCellClick(Column: TColumn);
    procedure btnAtualizarClick(Sender: TObject);
    procedure btnAbrirAudioClick(Sender: TObject);
    procedure btnFecharClick(Sender: TObject);
  private
    procedure AtualizarResultados;
  end;

implementation

uses
  DM_Analises;

{$R *.dfm}

procedure TFrmHistoricoAnalises.FormCreate(Sender: TObject);
begin
  grdAnalises.DataSource := DMAnalises.dsHistorico;
  grdResultados.DataSource := DMAnalises.dsResultados;
  DMAnalises.AbrirHistorico;
  AtualizarResultados;
end;

procedure TFrmHistoricoAnalises.AtualizarResultados;
begin
  if DMAnalises.qryHistorico.IsEmpty then
  begin
    DMAnalises.qryResultados.Close;
    Exit;
  end;
  DMAnalises.AbrirResultados(
    DMAnalises.qryHistorico.FieldByName('id').AsLargeInt);
end;

procedure TFrmHistoricoAnalises.grdAnalisesCellClick(Column: TColumn);
begin
  AtualizarResultados;
end;

procedure TFrmHistoricoAnalises.btnAtualizarClick(Sender: TObject);
begin
  DMAnalises.AbrirHistorico;
  AtualizarResultados;
end;

procedure TFrmHistoricoAnalises.btnAbrirAudioClick(Sender: TObject);
var
  Caminho: string;
begin
  if DMAnalises.qryHistorico.IsEmpty then
    Exit;
  Caminho := TPath.Combine(ExtractFilePath(ParamStr(0)),
    DMAnalises.qryHistorico.FieldByName('arquivo_relativo').AsString);
  if not FileExists(Caminho) then
    raise EFileNotFoundException.CreateFmt('Audio nao encontrado: %s',
      [Caminho]);
  ShellExecute(Handle, 'open', PChar(Caminho), nil, nil, SW_SHOWNORMAL);
end;

procedure TFrmHistoricoAnalises.btnFecharClick(Sender: TObject);
begin
  Close;
end;

end.
