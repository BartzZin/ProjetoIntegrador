object FrmAnaliseAudio: TFrmAnaliseAudio
  Left = 0
  Top = 0
  Caption = 'Analise sonora automotiva'
  ClientHeight = 700
  ClientWidth = 900
  Position = poScreenCenter
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  object grpVeiculo: TGroupBox
    Left = 16
    Top = 12
    Width = 868
    Height = 92
    Caption = 'Veiculo'
    TabOrder = 0
    object lblMarca: TLabel
      Left = 16
      Top = 26
      Caption = 'Marca'
    end
    object lblModelo: TLabel
      Left = 286
      Top = 26
      Caption = 'Modelo / ano / motor'
    end
    object cbMarca: TComboBox
      Left = 16
      Top = 46
      Width = 246
      Height = 23
      Style = csDropDownList
      OnChange = cbMarcaChange
      TabOrder = 0
    end
    object cbModelo: TComboBox
      Left = 286
      Top = 46
      Width = 558
      Height = 23
      Style = csDropDownList
      TabOrder = 1
    end
  end
  object grpAudio: TGroupBox
    Left = 16
    Top = 116
    Width = 868
    Height = 130
    Caption = 'Audio'
    TabOrder = 1
    object edtArquivoAudio: TEdit
      Left = 16
      Top = 30
      Width = 600
      Height = 23
      ReadOnly = True
      TabOrder = 0
    end
    object btnSelecionarAudio: TButton
      Left = 628
      Top = 27
      Width = 104
      Height = 29
      Caption = 'Selecionar'
      OnClick = btnSelecionarAudioClick
      TabOrder = 1
    end
    object btnOuvirAudio: TButton
      Left = 740
      Top = 27
      Width = 104
      Height = 29
      Caption = 'Ouvir'
      OnClick = btnOuvirAudioClick
      TabOrder = 2
    end
    object btnAnalisar: TButton
      Left = 340
      Top = 58
      Width = 188
      Height = 38
      Caption = 'ANALISAR'
      Default = True
      OnClick = btnAnalisarClick
      TabOrder = 3
    end
    object lblStatusAnalise: TLabel
      Left = 16
      Top = 99
      Width = 828
      Height = 15
      Alignment = taCenter
      AutoSize = False
      Caption = 'Pronto para analisar.'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clGrayText
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
    end
    object ProgressBar: TProgressBar
      Left = 16
      Top = 116
      Width = 828
      Height = 10
      Smooth = True
      State = pbsNormal
      TabOrder = 4
    end
  end
  object grpResultado: TGroupBox
    Left = 16
    Top = 258
    Width = 868
    Height = 382
    Caption = 'Resultado'
    TabOrder = 2
    object lblQualidadeAudio: TLabel
      Left = 16
      Top = 252
      Caption = 'Indicador de duracao: aguardando'
    end
    object lblModeloML: TLabel
      Left = 16
      Top = 278
      Caption = 'Modelo ML: aguardando'
    end
    object lblDuracao: TLabel
      Left = 300
      Top = 252
      Caption = 'Duracao: aguardando'
    end
    object grdResultados: TStringGrid
      Left = 16
      Top = 28
      Width = 828
      Height = 205
      DefaultRowHeight = 25
      Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect]
      TabOrder = 0
    end
    object memObservacoes: TMemo
      Left = 16
      Top = 306
      Width = 828
      Height = 58
      ReadOnly = True
      ScrollBars = ssVertical
      TabOrder = 1
    end
  end
  object btnFechar: TButton
    Left = 780
    Top = 652
    Width = 104
    Height = 32
    Caption = 'Fechar'
    OnClick = btnFecharClick
    TabOrder = 3
  end
  object OpenDialogAudio: TOpenDialog
    Filter = 'Audios suportados|*.wav;*.mp3;*.ogg;*.opus;*.m4a|Todos os arquivos|*.*'
    Options = [ofHideReadOnly, ofFileMustExist, ofEnableSizing]
    Left = 32
    Top = 648
  end
  object tmrProgresso: TTimer
    Enabled = False
    Interval = 35
    OnTimer = tmrProgressoTimer
    Left = 80
    Top = 648
  end
end
