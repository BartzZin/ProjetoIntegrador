unit F_AnaliseAudio;

interface

uses
  Winapi.CommCtrl, Winapi.UxTheme, Winapi.Windows, Winapi.ShellAPI,
  System.Classes, System.SysUtils,
  Vcl.ComCtrls, Vcl.Controls, Vcl.Dialogs, Vcl.Forms, Vcl.Grids,
  Vcl.ExtCtrls, Vcl.StdCtrls;

type
  TFrmAnaliseAudio = class(TForm)
    grpVeiculo: TGroupBox;
    lblMarca: TLabel;
    lblModelo: TLabel;
    cbMarca: TComboBox;
    cbModelo: TComboBox;
    grpAudio: TGroupBox;
    edtArquivoAudio: TEdit;
    btnSelecionarAudio: TButton;
    btnOuvirAudio: TButton;
    btnAnalisar: TButton;
    OpenDialogAudio: TOpenDialog;
    ProgressBar: TProgressBar;
    grpResultado: TGroupBox;
    grdResultados: TStringGrid;
    lblQualidadeAudio: TLabel;
    lblModeloML: TLabel;
    lblDuracao: TLabel;
    lblStatusAnalise: TLabel;
    tmrProgresso: TTimer;
    memObservacoes: TMemo;
    btnFechar: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure cbMarcaChange(Sender: TObject);
    procedure btnSelecionarAudioClick(Sender: TObject);
    procedure btnOuvirAudioClick(Sender: TObject);
    procedure btnAnalisarClick(Sender: TObject);
    procedure btnFecharClick(Sender: TObject);
    procedure tmrProgressoTimer(Sender: TObject);
  private
    FAnaliseEmAndamento: Boolean;
    procedure CarregarMarcas;
    procedure PrepararGrade;
    procedure ApresentarResultado(AResultado: TObject);
    procedure DefinirEstadoAnalise(AEmAndamento: Boolean);
    function ObterIdModeloSelecionado: Integer;
  end;

implementation

uses
  DM_Analises, DM_EnviaDados, DM_Veiculos, uModeloVeiculo,
  uResultadoAnalise;

{$R *.dfm}

procedure TFrmAnaliseAudio.FormCreate(Sender: TObject);
begin
  FAnaliseEmAndamento := False;
  ProgressBar.Style := pbstNormal;
  ProgressBar.State := pbsNormal;
  ProgressBar.Min := 0;
  ProgressBar.Max := 100;
  ProgressBar.Position := 0;
  SetWindowTheme(ProgressBar.Handle, '', '');
  SendMessage(ProgressBar.Handle, PBM_SETBKCOLOR, 0, RGB(232, 240, 235));
  SendMessage(ProgressBar.Handle, PBM_SETBARCOLOR, 0, RGB(34, 197, 94));
  PrepararGrade;
  CarregarMarcas;
end;

procedure TFrmAnaliseAudio.tmrProgressoTimer(Sender: TObject);
begin
  if ProgressBar.Position >= 94 then
    ProgressBar.Position := 4
  else
    ProgressBar.Position := ProgressBar.Position + 3;
end;

procedure TFrmAnaliseAudio.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  CanClose := not FAnaliseEmAndamento;
  if not CanClose then
    MessageDlg('A analise ainda esta em andamento. Aguarde a conclusao.',
      mtInformation, [mbOK], 0);
end;

procedure TFrmAnaliseAudio.DefinirEstadoAnalise(AEmAndamento: Boolean);
begin
  FAnaliseEmAndamento := AEmAndamento;
  cbMarca.Enabled := not AEmAndamento;
  cbModelo.Enabled := not AEmAndamento;
  btnSelecionarAudio.Enabled := not AEmAndamento;
  btnOuvirAudio.Enabled := not AEmAndamento;
  btnAnalisar.Enabled := not AEmAndamento;
  btnFechar.Enabled := not AEmAndamento;

  if AEmAndamento then
  begin
    lblStatusAnalise.Caption := 'Analisando o audio, aguarde...';
    ProgressBar.State := pbsNormal;
    ProgressBar.Style := pbstNormal;
    ProgressBar.Position := 4;
    tmrProgresso.Enabled := True;
  end
  else
  begin
    tmrProgresso.Enabled := False;
    ProgressBar.Style := pbstNormal;
    ProgressBar.Position := 0;
  end;
end;

procedure TFrmAnaliseAudio.PrepararGrade;
begin
  grdResultados.ColCount := 4;
  grdResultados.RowCount := 2;
  grdResultados.FixedRows := 1;
  grdResultados.Cells[0, 0] := 'Classificacao (maior probabilidade primeiro)';
  grdResultados.Cells[1, 0] := 'Audio';
  grdResultados.Cells[2, 0] := 'Historico';
  grdResultados.Cells[3, 0] := 'Final';
  grdResultados.ColWidths[0] := 330;
  grdResultados.ColWidths[1] := 100;
  grdResultados.ColWidths[2] := 100;
  grdResultados.ColWidths[3] := 100;
end;

procedure TFrmAnaliseAudio.CarregarMarcas;
begin
  DMVeiculos.CarregarMarcas(cbMarca.Items);
  if cbMarca.Items.Count > 0 then
  begin
    cbMarca.ItemIndex := 0;
    cbMarcaChange(cbMarca);
  end;
end;

procedure TFrmAnaliseAudio.cbMarcaChange(Sender: TObject);
begin
  DMVeiculos.CarregarModelosDaMarca(cbMarca.Text, cbModelo.Items);
  if cbModelo.Items.Count > 0 then
    cbModelo.ItemIndex := 0;
end;

function TFrmAnaliseAudio.ObterIdModeloSelecionado: Integer;
begin
  if cbModelo.ItemIndex < 0 then
    Exit(0);
  Result := NativeInt(cbModelo.Items.Objects[cbModelo.ItemIndex]);
end;

procedure TFrmAnaliseAudio.btnSelecionarAudioClick(Sender: TObject);
begin
  if OpenDialogAudio.Execute then
    edtArquivoAudio.Text := OpenDialogAudio.FileName;
end;

procedure TFrmAnaliseAudio.btnOuvirAudioClick(Sender: TObject);
begin
  if not FileExists(edtArquivoAudio.Text) then
    raise EFileNotFoundException.Create('Selecione um audio valido.');
  ShellExecute(Handle, 'open', PChar(edtArquivoAudio.Text), nil, nil,
    SW_SHOWNORMAL);
end;

procedure TFrmAnaliseAudio.btnAnalisarClick(Sender: TObject);
var
  Veiculo: TModeloVeiculo;
  ArquivoAudio: string;
begin
  if ObterIdModeloSelecionado = 0 then
    raise Exception.Create('Selecione um veiculo cadastrado.');
  if not FileExists(edtArquivoAudio.Text) then
    raise EFileNotFoundException.Create('Selecione um arquivo de audio valido.');
  Veiculo := DMVeiculos.ObterModeloVeiculo(ObterIdModeloSelecionado);
  if not Assigned(Veiculo) then
    raise Exception.Create('Veiculo nao encontrado.');
  ArquivoAudio := edtArquivoAudio.Text;
  DefinirEstadoAnalise(True);

  try
    DMEnviaDados.AnalisarAudioAsync(ArquivoAudio, Veiculo,
      procedure(Resultado: TResultadoAnaliseCompleto)
      var
        ArquivoRelativo: string;
        IdAnalise: Int64;
      begin
        try
          ArquivoRelativo := DMAnalises.CopiarAudioParaHistorico(
            ArquivoAudio);
          IdAnalise := DMAnalises.CriarAnalise(Veiculo.Id,
            ArquivoRelativo, Resultado);
          ApresentarResultado(Resultado);
          memObservacoes.Lines.Add(Format(
            'Analise #%d salva no historico.', [IdAnalise]));

          if Resultado.Resultados.Count > 0 then
            lblStatusAnalise.Caption := Format(
              'Resultado principal: %s (%.1f%%)',
              [Resultado.Resultados[0].Descricao,
               Resultado.Resultados[0].ProbabilidadeFinal * 100])
          else
            lblStatusAnalise.Caption := 'Analise concluida sem classificacao.';
        except
          on E: Exception do
          begin
            lblStatusAnalise.Caption :=
              'Falha ao salvar o resultado. Tente novamente.';
            MessageDlg('A analise foi processada, mas nao foi possivel ' +
              'salvar o resultado:' + sLineBreak + E.Message,
              mtError, [mbOK], 0);
          end;
        end;
        Veiculo.Free;
        DefinirEstadoAnalise(False);
      end,
      procedure(const MensagemErro: string)
      begin
        Veiculo.Free;
        DefinirEstadoAnalise(False);
        lblStatusAnalise.Caption := 'Falha ao analisar. Tente novamente.';
        MessageDlg('Nao foi possivel concluir a analise:' + sLineBreak +
          MensagemErro, mtError, [mbOK], 0);
      end);
  except
    Veiculo.Free;
    DefinirEstadoAnalise(False);
    raise;
  end;
end;

procedure TFrmAnaliseAudio.ApresentarResultado(AResultado: TObject);
var
  Analise: TResultadoAnaliseCompleto;
  I: Integer;
  Item: TResultadoAnalise;
begin
  Analise := TResultadoAnaliseCompleto(AResultado);
  lblQualidadeAudio.Caption := Format('Indicador de duracao: %s (%.0f%%)',
    [Analise.QualidadeClassificacao, Analise.QualidadeIndice * 100]);
  lblModeloML.Caption := 'Modelo ML: ' + Analise.VersaoModelo;
  lblDuracao.Caption := Format('Duracao: %.2f s | processamento: %d ms',
    [Analise.DuracaoSegundos, Analise.TempoProcessamentoMs]);
  memObservacoes.Lines.Text := Analise.Aviso;

  if Analise.Resultados.Count = 0 then
  begin
    grdResultados.RowCount := 2;
    grdResultados.Cells[0, 1] := 'Modelo ainda nao treinado';
    grdResultados.Cells[1, 1] := '-';
    grdResultados.Cells[2, 1] := '-';
    grdResultados.Cells[3, 1] := '-';
    Exit;
  end;

  grdResultados.RowCount := Analise.Resultados.Count + 1;
  for I := 0 to Analise.Resultados.Count - 1 do
  begin
    Item := Analise.Resultados[I];
    grdResultados.Cells[0, I + 1] := Item.Descricao;
    grdResultados.Cells[1, I + 1] :=
      Format('%.1f%%', [Item.ProbabilidadeAudio * 100]);
    if Item.PossuiProbabilidadeHistorica then
      grdResultados.Cells[2, I + 1] :=
        Format('%.1f%%', [Item.ProbabilidadeHistorica * 100])
    else
      grdResultados.Cells[2, I + 1] := '-';
    grdResultados.Cells[3, I + 1] :=
      Format('%.1f%%', [Item.ProbabilidadeFinal * 100]);
  end;
end;

procedure TFrmAnaliseAudio.btnFecharClick(Sender: TObject);
begin
  Close;
end;

end.
