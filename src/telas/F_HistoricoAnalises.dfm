object FrmHistoricoAnalises: TFrmHistoricoAnalises
  Left = 0
  Top = 0
  Caption = 'Historico de analises'
  ClientHeight = 650
  ClientWidth = 1000
  Position = poScreenCenter
  OnCreate = FormCreate
  object lblAnalises: TLabel
    Left = 12
    Top = 12
    Caption = 'Analises realizadas'
  end
  object lblResultados: TLabel
    Left = 12
    Top = 346
    Caption = 'Resultados da analise selecionada'
  end
  object grdAnalises: TDBGrid
    Left = 12
    Top = 34
    Width = 976
    Height = 292
    ReadOnly = True
    TabOrder = 0
    OnCellClick = grdAnalisesCellClick
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -12
    TitleFont.Name = 'Segoe UI'
    TitleFont.Style = []
  end
  object grdResultados: TDBGrid
    Left = 12
    Top = 368
    Width = 976
    Height = 212
    ReadOnly = True
    TabOrder = 1
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -12
    TitleFont.Name = 'Segoe UI'
    TitleFont.Style = []
  end
  object pnlBotoes: TPanel
    Left = 0
    Top = 595
    Width = 1000
    Height = 55
    Align = alBottom
    TabOrder = 2
    object btnAtualizar: TButton
      Left = 16
      Top = 12
      Width = 110
      Height = 31
      Caption = 'Atualizar'
      OnClick = btnAtualizarClick
      TabOrder = 0
    end
    object btnAbrirAudio: TButton
      Left = 138
      Top = 12
      Width = 110
      Height = 31
      Caption = 'Abrir audio'
      OnClick = btnAbrirAudioClick
      TabOrder = 1
    end
    object btnFechar: TButton
      Left = 874
      Top = 12
      Width = 110
      Height = 31
      Caption = 'Fechar'
      OnClick = btnFecharClick
      TabOrder = 2
    end
  end
end
