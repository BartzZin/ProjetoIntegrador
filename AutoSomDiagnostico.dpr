program AutoSomDiagnostico;

uses
  Vcl.Forms,
  F_Principal in 'src\telas\F_Principal.pas' {FrmPrincipal},
  DM_BancoDados in 'src\datamodulos\DM_BancoDados.pas' {DMBancoDados: TDataModule},
  DM_Configuracao in 'src\datamodulos\DM_Configuracao.pas' {DMConfiguracao: TDataModule},
  DM_EnviaDados in 'src\datamodulos\DM_EnviaDados.pas' {DMEnviaDados: TDataModule},
  DM_ServicoPython in 'src\datamodulos\DM_ServicoPython.pas' {DMServicoPython: TDataModule},
  DM_Veiculos in 'src\datamodulos\DM_Veiculos.pas' {DMVeiculos: TDataModule},
  DM_Defeitos in 'src\datamodulos\DM_Defeitos.pas' {DMDefeitos: TDataModule},
  DM_Analises in 'src\datamodulos\DM_Analises.pas' {DMAnalises: TDataModule},
  F_AnaliseAudio in 'src\telas\F_AnaliseAudio.pas' {FrmAnaliseAudio},
  F_CadModeloVeiculo in 'src\telas\F_CadModeloVeiculo.pas' {FrmCadModeloVeiculo},
  F_CadDefeito in 'src\telas\F_CadDefeito.pas' {FrmCadDefeito},
  F_HistoricoAnalises in 'src\telas\F_HistoricoAnalises.pas' {FrmHistoricoAnalises},
  F_Configuracao in 'src\telas\F_Configuracao.pas' {FrmConfiguracao},
  uModeloVeiculo in 'src\modelos\uModeloVeiculo.pas',
  uResultadoAnalise in 'src\modelos\uResultadoAnalise.pas';

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'AutoSom Diagnostico';
  Application.CreateForm(TDMConfiguracao, DMConfiguracao);
  Application.CreateForm(TDMBancoDados, DMBancoDados);
  Application.CreateForm(TDMEnviaDados, DMEnviaDados);
  Application.CreateForm(TDMServicoPython, DMServicoPython);
  Application.CreateForm(TDMVeiculos, DMVeiculos);
  Application.CreateForm(TDMDefeitos, DMDefeitos);
  Application.CreateForm(TDMAnalises, DMAnalises);
  Application.CreateForm(TFrmPrincipal, FrmPrincipal);
  Application.Run;
end.
