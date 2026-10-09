unit F_CadDefeito;

interface

uses
  System.Classes, System.SysUtils, Vcl.Controls, Vcl.DBCtrls, Vcl.DBGrids,
  Vcl.Dialogs, Vcl.ExtCtrls, Vcl.Forms, Vcl.StdCtrls;

type
  TFrmCadDefeito = class(TForm)
    grdDefeitos: TDBGrid;
    grpDados: TGroupBox;
    lblCategoria: TLabel;
    lblComponente: TLabel;
    lblNome: TLabel;
    lblDescricao: TLabel;
    edtCategoria: TDBEdit;
    edtComponente: TDBEdit;
    edtNome: TDBEdit;
    memDescricao: TDBMemo;
    pnlBotoes: TPanel;
    btnNovo: TButton;
    btnEditar: TButton;
    btnSalvar: TButton;
    btnExcluir: TButton;
    btnCancelar: TButton;
    btnFechar: TButton;
    procedure FormCreate(Sender: TObject);
    procedure btnNovoClick(Sender: TObject);
    procedure btnEditarClick(Sender: TObject);
    procedure btnSalvarClick(Sender: TObject);
    procedure btnExcluirClick(Sender: TObject);
    procedure btnCancelarClick(Sender: TObject);
    procedure btnFecharClick(Sender: TObject);
  private
    procedure VincularDados;
    procedure ValidarDados;
  end;

implementation

uses
  DM_Defeitos;

{$R *.dfm}

procedure TFrmCadDefeito.FormCreate(Sender: TObject);
begin
  VincularDados;
  DMDefeitos.AbrirDefeitos;
end;

procedure TFrmCadDefeito.VincularDados;
begin
  grdDefeitos.DataSource := DMDefeitos.dsDefeitos;
  edtCategoria.DataSource := DMDefeitos.dsDefeitos;
  edtComponente.DataSource := DMDefeitos.dsDefeitos;
  edtNome.DataSource := DMDefeitos.dsDefeitos;
  memDescricao.DataSource := DMDefeitos.dsDefeitos;
end;

procedure TFrmCadDefeito.ValidarDados;
begin
  if Trim(DMDefeitos.qryDefeitos.FieldByName('categoria').AsString) = '' then
    raise Exception.Create('Informe a categoria.');
  if Trim(DMDefeitos.qryDefeitos.FieldByName('nome').AsString) = '' then
    raise Exception.Create('Informe o nome do defeito.');
end;

procedure TFrmCadDefeito.btnNovoClick(Sender: TObject);
begin
  DMDefeitos.Novo;
  edtCategoria.SetFocus;
end;

procedure TFrmCadDefeito.btnEditarClick(Sender: TObject);
begin
  DMDefeitos.Editar;
end;

procedure TFrmCadDefeito.btnSalvarClick(Sender: TObject);
begin
  ValidarDados;
  DMDefeitos.Salvar;
end;

procedure TFrmCadDefeito.btnExcluirClick(Sender: TObject);
begin
  if MessageDlg('Desativar o defeito selecionado?', mtConfirmation,
    [mbYes, mbNo], 0) = mrYes then
    DMDefeitos.Excluir;
end;

procedure TFrmCadDefeito.btnCancelarClick(Sender: TObject);
begin
  DMDefeitos.Cancelar;
end;

procedure TFrmCadDefeito.btnFecharClick(Sender: TObject);
begin
  Close;
end;

end.
