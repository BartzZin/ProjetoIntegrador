unit F_Principal;

interface

uses
  Winapi.Windows, Winapi.Messages, System.Classes, System.SysUtils,
  Vcl.Controls, Vcl.Forms, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls;

type
  TFrmPrincipal = class(TForm)
    pnlMenu: TPanel;
    btnNovaAnalise: TButton;
    btnVeiculos: TButton;
    btnDefeitos: TButton;
    btnHistorico: TButton;
    btnConfiguracoes: TButton;
    pnlConteudo: TPanel;
    lblTitulo: TLabel;
    lblDescricao: TLabel;
    StatusBar: TStatusBar;
    procedure btnNovaAnaliseClick(Sender: TObject);
    procedure btnVeiculosClick(Sender: TObject);
    procedure btnDefeitosClick(Sender: TObject);
    procedure btnHistoricoClick(Sender: TObject);
    procedure btnConfiguracoesClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    procedure AtualizarEstadoApi;
  end;

var
  FrmPrincipal: TFrmPrincipal;

implementation

uses
  DM_BancoDados, DM_Configuracao, DM_EnviaDados, DM_ServicoPython,
  F_AnaliseAudio, F_CadDefeito, F_CadModeloVeiculo, F_Configuracao,
  F_HistoricoAnalises;

{$R *.dfm}

procedure TFrmPrincipal.btnNovaAnaliseClick(Sender: TObject);
var
  Formulario: TFrmAnaliseAudio;
begin
  Formulario := TFrmAnaliseAudio.Create(Self);
  try
    Formulario.ShowModal;
  finally
    Formulario.Free;
  end;
end;

procedure TFrmPrincipal.btnVeiculosClick(Sender: TObject);
var
  Formulario: TFrmCadModeloVeiculo;
begin
  Formulario := TFrmCadModeloVeiculo.Create(Self);
  try
    Formulario.ShowModal;
  finally
    Formulario.Free;
  end;
end;

procedure TFrmPrincipal.btnDefeitosClick(Sender: TObject);
var
  Formulario: TFrmCadDefeito;
begin
  Formulario := TFrmCadDefeito.Create(Self);
  try
    Formulario.ShowModal;
  finally
    Formulario.Free;
  end;
end;

procedure TFrmPrincipal.btnHistoricoClick(Sender: TObject);
var
  Formulario: TFrmHistoricoAnalises;
begin
  Formulario := TFrmHistoricoAnalises.Create(Self);
  try
    Formulario.ShowModal;
  finally
    Formulario.Free;
  end;
end;

procedure TFrmPrincipal.btnConfiguracoesClick(Sender: TObject);
var
  Formulario: TFrmConfiguracao;
begin
  Formulario := TFrmConfiguracao.Create(Self);
  try
    Formulario.ShowModal;
  finally
    Formulario.Free;
  end;
  AtualizarEstadoApi;
end;

procedure TFrmPrincipal.FormShow(Sender: TObject);
begin
  DMConfiguracao.CarregarConfiguracoes;
  try
    DMBancoDados.InicializarBanco;
    StatusBar.Panels[0].Text := 'SQLite: conectado';
  except
    on E: Exception do
      StatusBar.Panels[0].Text := 'SQLite: erro - ' + E.Message;
  end;
  if DMConfiguracao.IniciarPythonAutomaticamente and
    not DMServicoPython.ApiEstaExecutando then
  begin
    try
      DMServicoPython.IniciarApiPython;
      DMServicoPython.AguardarApiDisponivel;
    except
      on E: Exception do
        StatusBar.Panels[1].Text := 'API: erro ao iniciar - ' + E.Message;
    end;
  end;
  AtualizarEstadoApi;
end;

procedure TFrmPrincipal.AtualizarEstadoApi;
begin
  if DMEnviaDados.VerificarApiDisponivel then
    StatusBar.Panels[1].Text := 'API: online | modelo: ' +
      DMEnviaDados.ObterVersaoModelo
  else
    StatusBar.Panels[1].Text := 'API: offline';
end;

end.
