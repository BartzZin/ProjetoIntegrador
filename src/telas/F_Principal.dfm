object FrmPrincipal: TFrmPrincipal
  Left = 0
  Top = 0
  Caption = 'AutoSom Diagnostico'
  ClientHeight = 560
  ClientWidth = 900
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  OnShow = FormShow
  TextHeight = 15
  object pnlMenu: TPanel
    Left = 0
    Top = 0
    Width = 190
    Height = 537
    Align = alLeft
    BevelOuter = bvNone
    Color = 3158064
    ParentBackground = False
    TabOrder = 0
    object btnNovaAnalise: TButton
      Left = 16
      Top = 72
      Width = 158
      Height = 41
      Caption = 'Nova analise'
      TabOrder = 0
      OnClick = btnNovaAnaliseClick
    end
    object btnVeiculos: TButton
      Left = 16
      Top = 128
      Width = 158
      Height = 41
      Caption = 'Veiculos'
      TabOrder = 1
      OnClick = btnVeiculosClick
    end
    object btnDefeitos: TButton
      Left = 16
      Top = 184
      Width = 158
      Height = 41
      Caption = 'Defeitos'
      TabOrder = 2
      OnClick = btnDefeitosClick
    end
    object btnHistorico: TButton
      Left = 16
      Top = 240
      Width = 158
      Height = 41
      Caption = 'Historico'
      TabOrder = 3
      OnClick = btnHistoricoClick
    end
    object btnConfiguracoes: TButton
      Left = 16
      Top = 296
      Width = 158
      Height = 41
      Caption = 'Configuracoes'
      TabOrder = 4
      OnClick = btnConfiguracoesClick
    end
  end
  object pnlConteudo: TPanel
    Left = 190
    Top = 0
    Width = 710
    Height = 537
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 1
    object lblTitulo: TLabel
      Left = 48
      Top = 56
      Width = 281
      Height = 37
      Caption = 'AutoSom Diagnostico'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -27
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblDescricao: TLabel
      Left = 48
      Top = 104
      Width = 540
      Height = 45
      AutoSize = False
      Caption =
        'Sistema de apoio a triagem automotiva por analise acustica. O re' +
        'sultado nao substitui avaliacao mecanica.'
      WordWrap = True
    end
  end
  object StatusBar: TStatusBar
    Left = 0
    Top = 537
    Width = 900
    Height = 23
    Panels = <
      item
        Text = 'SQLite: aguardando'
        Width = 280
      end
      item
        Text = 'API: aguardando'
        Width = 400
      end>
  end
end
