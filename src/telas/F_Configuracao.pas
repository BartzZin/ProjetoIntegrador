unit F_Configuracao;

interface

uses
  System.Classes, System.SysUtils, Vcl.Controls, Vcl.Dialogs, Vcl.Forms,
  Vcl.StdCtrls;

type
  TFrmConfiguracao = class(TForm)
    lblUrlApi: TLabel;
    lblPortaApi: TLabel;
    lblPortaDebug: TLabel;
    edtUrlApi: TEdit;
    edtPortaApi: TEdit;
    chkIniciarPythonAutomaticamente: TCheckBox;
    chkModoDesenvolvimento: TCheckBox;
    edtPortaDebugPyCharm: TEdit;
    btnSalvar: TButton;
    btnTestarApi: TButton;
    btnIniciarApi: TButton;
    btnEncerrarApi: TButton;
    btnConectarPyCharm: TButton;
    btnFechar: TButton;
    lblEstado: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure btnSalvarClick(Sender: TObject);
    procedure btnTestarApiClick(Sender: TObject);
    procedure btnIniciarApiClick(Sender: TObject);
    procedure btnEncerrarApiClick(Sender: TObject);
    procedure btnConectarPyCharmClick(Sender: TObject);
    procedure btnFecharClick(Sender: TObject);
  private
    procedure CarregarCampos;
    procedure AplicarCampos;
    procedure AtualizarEstado;
  end;

implementation

uses
  DM_Configuracao, DM_EnviaDados, DM_ServicoPython;

{$R *.dfm}

procedure TFrmConfiguracao.FormCreate(Sender: TObject);
begin
  DMConfiguracao.CarregarConfiguracoes;
  CarregarCampos;
  AtualizarEstado;
end;

procedure TFrmConfiguracao.CarregarCampos;
begin
  edtUrlApi.Text := DMConfiguracao.UrlApi;
  edtPortaApi.Text := IntToStr(DMConfiguracao.PortaApi);
  chkIniciarPythonAutomaticamente.Checked :=
    DMConfiguracao.IniciarPythonAutomaticamente;
  chkModoDesenvolvimento.Checked := DMConfiguracao.ModoDesenvolvimento;
  edtPortaDebugPyCharm.Text := IntToStr(DMConfiguracao.PortaDebugPyCharm);
end;

procedure TFrmConfiguracao.AplicarCampos;
var
  Porta, PortaDebug: Integer;
begin
  if Trim(edtUrlApi.Text) = '' then
    raise Exception.Create('Informe a URL da API.');
  if not TryStrToInt(edtPortaApi.Text, Porta) or (Porta < 1) or
    (Porta > 65535) then
    raise Exception.Create('Porta da API invalida.');
  if not TryStrToInt(edtPortaDebugPyCharm.Text, PortaDebug) or
    (PortaDebug < 1) or (PortaDebug > 65535) then
    raise Exception.Create('Porta de debug invalida.');
  DMConfiguracao.UrlApi := Trim(edtUrlApi.Text);
  DMConfiguracao.PortaApi := Porta;
  DMConfiguracao.IniciarPythonAutomaticamente :=
    chkIniciarPythonAutomaticamente.Checked;
  DMConfiguracao.ModoDesenvolvimento := chkModoDesenvolvimento.Checked;
  DMConfiguracao.PortaDebugPyCharm := PortaDebug;
end;

procedure TFrmConfiguracao.AtualizarEstado;
begin
  if DMEnviaDados.VerificarApiDisponivel then
    lblEstado.Caption := 'API online | modelo: ' +
      DMEnviaDados.ObterVersaoModelo
  else
    lblEstado.Caption := 'API offline';
end;

procedure TFrmConfiguracao.btnSalvarClick(Sender: TObject);
begin
  AplicarCampos;
  DMConfiguracao.SalvarConfiguracoes;
  ShowMessage('Configuracoes salvas.');
end;

procedure TFrmConfiguracao.btnTestarApiClick(Sender: TObject);
begin
  AplicarCampos;
  AtualizarEstado;
end;

procedure TFrmConfiguracao.btnIniciarApiClick(Sender: TObject);
begin
  AplicarCampos;
  DMServicoPython.IniciarApiPython;
  if not DMServicoPython.AguardarApiDisponivel then
    raise Exception.Create('A API nao respondeu dentro do tempo esperado.');
  AtualizarEstado;
end;

procedure TFrmConfiguracao.btnEncerrarApiClick(Sender: TObject);
begin
  DMServicoPython.EncerrarApiPython;
  AtualizarEstado;
end;

procedure TFrmConfiguracao.btnConectarPyCharmClick(Sender: TObject);
begin
  AplicarCampos;
  if not DMConfiguracao.ModoDesenvolvimento then
    raise Exception.Create('Ative o modo desenvolvimento primeiro.');
  if not DMEnviaDados.ConectarDepuradorPyCharm then
    raise Exception.Create('Nao foi possivel conectar ao servidor de debug.');
  ShowMessage('Processo Python conectado ao PyCharm.');
end;

procedure TFrmConfiguracao.btnFecharClick(Sender: TObject);
begin
  Close;
end;

end.
