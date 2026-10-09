object FrmConfiguracao: TFrmConfiguracao
  Left = 0
  Top = 0
  Caption = 'Configuracoes'
  ClientHeight = 440
  ClientWidth = 650
  Position = poScreenCenter
  OnCreate = FormCreate
  object lblUrlApi: TLabel
    Left = 24
    Top = 28
    Caption = 'URL da API'
  end
  object lblPortaApi: TLabel
    Left = 430
    Top = 28
    Caption = 'Porta'
  end
  object lblPortaDebug: TLabel
    Left = 24
    Top = 180
    Caption = 'Porta do servidor de debug PyCharm'
  end
  object lblEstado: TLabel
    Left = 24
    Top = 238
    Width = 600
    Height = 20
    Caption = 'API: verificando'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'Segoe UI'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object edtUrlApi: TEdit
    Left = 24
    Top = 50
    Width = 382
    Height = 23
    TabOrder = 0
  end
  object edtPortaApi: TEdit
    Left = 430
    Top = 50
    Width = 100
    Height = 23
    NumbersOnly = True
    TabOrder = 1
  end
  object chkIniciarPythonAutomaticamente: TCheckBox
    Left = 24
    Top = 96
    Width = 300
    Height = 21
    Caption = 'Iniciar API Python automaticamente'
    TabOrder = 2
  end
  object chkModoDesenvolvimento: TCheckBox
    Left = 24
    Top = 132
    Width = 300
    Height = 21
    Caption = 'Modo desenvolvimento'
    TabOrder = 3
  end
  object edtPortaDebugPyCharm: TEdit
    Left = 24
    Top = 202
    Width = 140
    Height = 23
    NumbersOnly = True
    TabOrder = 4
  end
  object btnSalvar: TButton
    Left = 24
    Top = 286
    Width = 112
    Height = 34
    Caption = 'Salvar'
    Default = True
    OnClick = btnSalvarClick
    TabOrder = 5
  end
  object btnTestarApi: TButton
    Left = 148
    Top = 286
    Width = 112
    Height = 34
    Caption = 'Testar API'
    OnClick = btnTestarApiClick
    TabOrder = 6
  end
  object btnIniciarApi: TButton
    Left = 272
    Top = 286
    Width = 112
    Height = 34
    Caption = 'Iniciar API'
    OnClick = btnIniciarApiClick
    TabOrder = 7
  end
  object btnEncerrarApi: TButton
    Left = 396
    Top = 286
    Width = 112
    Height = 34
    Caption = 'Encerrar API'
    OnClick = btnEncerrarApiClick
    TabOrder = 8
  end
  object btnConectarPyCharm: TButton
    Left = 24
    Top = 338
    Width = 236
    Height = 34
    Caption = 'Conectar processo ao PyCharm'
    OnClick = btnConectarPyCharmClick
    TabOrder = 9
  end
  object btnFechar: TButton
    Left = 514
    Top = 390
    Width = 112
    Height = 34
    Caption = 'Fechar'
    OnClick = btnFecharClick
    TabOrder = 10
  end
end
