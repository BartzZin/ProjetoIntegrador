unit F_CadModeloVeiculo;

interface

uses
  System.Classes, System.SysUtils, Data.DB, Vcl.Controls, Vcl.DBCtrls,
  Vcl.DBGrids, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.Forms, Vcl.StdCtrls;

type
  TFrmCadModeloVeiculo = class(TForm)
    pnlBotoes: TPanel;
    btnNovo: TButton;
    btnEditar: TButton;
    btnSalvar: TButton;
    btnExcluir: TButton;
    btnCancelar: TButton;
    btnFechar: TButton;
    grdModelos: TDBGrid;
    grpDados: TGroupBox;
    lblMarca: TLabel;
    lblModelo: TLabel;
    lblAnoInicial: TLabel;
    lblAnoFinal: TLabel;
    lblCodigoMotor: TLabel;
    lblFamiliaMotor: TLabel;
    lblCilindrada: TLabel;
    lblCilindros: TLabel;
    lblCombustivel: TLabel;
    lblAspiracao: TLabel;
    lblValvulas: TLabel;
    lblTipoInjecao: TLabel;
    edtMarca: TDBEdit;
    edtModelo: TDBEdit;
    edtAnoInicial: TDBEdit;
    edtAnoFinal: TDBEdit;
    edtCodigoMotor: TDBEdit;
    edtFamiliaMotor: TDBEdit;
    edtCilindrada: TDBEdit;
    edtCilindros: TDBEdit;
    cbCombustivel: TDBComboBox;
    cbAspiracao: TDBComboBox;
    edtValvulas: TDBEdit;
    cbTipoInjecao: TDBComboBox;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
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
  DM_Veiculos;

{$R *.dfm}

procedure TFrmCadModeloVeiculo.FormCreate(Sender: TObject);
begin
  VincularDados;
  DMVeiculos.AbrirModelos;
end;

procedure TFrmCadModeloVeiculo.VincularDados;
begin
  grdModelos.DataSource := DMVeiculos.dsModelosVeiculo;
  edtMarca.DataSource := DMVeiculos.dsModelosVeiculo;
  edtModelo.DataSource := DMVeiculos.dsModelosVeiculo;
  edtAnoInicial.DataSource := DMVeiculos.dsModelosVeiculo;
  edtAnoFinal.DataSource := DMVeiculos.dsModelosVeiculo;
  edtCodigoMotor.DataSource := DMVeiculos.dsModelosVeiculo;
  edtFamiliaMotor.DataSource := DMVeiculos.dsModelosVeiculo;
  edtCilindrada.DataSource := DMVeiculos.dsModelosVeiculo;
  edtCilindros.DataSource := DMVeiculos.dsModelosVeiculo;
  cbCombustivel.DataSource := DMVeiculos.dsModelosVeiculo;
  cbAspiracao.DataSource := DMVeiculos.dsModelosVeiculo;
  edtValvulas.DataSource := DMVeiculos.dsModelosVeiculo;
  cbTipoInjecao.DataSource := DMVeiculos.dsModelosVeiculo;
end;

procedure TFrmCadModeloVeiculo.ValidarDados;
begin
  if Trim(DMVeiculos.qryModelosVeiculo.FieldByName('marca').AsString) = '' then
    raise Exception.Create('Informe a marca.');
  if Trim(DMVeiculos.qryModelosVeiculo.FieldByName('modelo').AsString) = '' then
    raise Exception.Create('Informe o modelo.');
end;

procedure TFrmCadModeloVeiculo.btnNovoClick(Sender: TObject);
begin
  DMVeiculos.InserirModeloVeiculo;
  edtMarca.SetFocus;
end;

procedure TFrmCadModeloVeiculo.btnEditarClick(Sender: TObject);
begin
  DMVeiculos.AlterarModeloVeiculo;
  edtMarca.SetFocus;
end;

procedure TFrmCadModeloVeiculo.btnSalvarClick(Sender: TObject);
begin
  ValidarDados;
  DMVeiculos.SalvarModeloVeiculo;
end;

procedure TFrmCadModeloVeiculo.btnExcluirClick(Sender: TObject);
begin
  if MessageDlg('Desativar o modelo selecionado?', mtConfirmation,
    [mbYes, mbNo], 0) = mrYes then
    DMVeiculos.ExcluirModeloVeiculo;
end;

procedure TFrmCadModeloVeiculo.btnCancelarClick(Sender: TObject);
begin
  DMVeiculos.CancelarEdicao;
end;

procedure TFrmCadModeloVeiculo.btnFecharClick(Sender: TObject);
begin
  Close;
end;

procedure TFrmCadModeloVeiculo.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  DMVeiculos.CancelarEdicao;
end;

end.
