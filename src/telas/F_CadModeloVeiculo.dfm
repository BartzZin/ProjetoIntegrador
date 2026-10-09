object FrmCadModeloVeiculo: TFrmCadModeloVeiculo
  Left = 0
  Top = 0
  Caption = 'Cadastro de veiculos'
  ClientHeight = 650
  ClientWidth = 980
  Position = poScreenCenter
  OnClose = FormClose
  OnCreate = FormCreate
  object grdModelos: TDBGrid
    Left = 0
    Top = 0
    Width = 980
    Height = 250
    Align = alTop
    ReadOnly = True
    TabOrder = 0
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -12
    TitleFont.Name = 'Segoe UI'
    TitleFont.Style = []
  end
  object grpDados: TGroupBox
    Left = 12
    Top = 262
    Width = 956
    Height = 320
    Caption = 'Dados mecanicos'
    TabOrder = 1
    object lblMarca: TLabel
      Left = 16
      Top = 30
      Caption = 'Marca'
    end
    object lblModelo: TLabel
      Left = 280
      Top = 30
      Caption = 'Modelo'
    end
    object lblAnoInicial: TLabel
      Left = 544
      Top = 30
      Caption = 'Ano inicial'
    end
    object lblAnoFinal: TLabel
      Left = 680
      Top = 30
      Caption = 'Ano final'
    end
    object lblCodigoMotor: TLabel
      Left = 16
      Top = 94
      Caption = 'Codigo do motor'
    end
    object lblFamiliaMotor: TLabel
      Left = 280
      Top = 94
      Caption = 'Familia do motor'
    end
    object lblCilindrada: TLabel
      Left = 544
      Top = 94
      Caption = 'Cilindrada (cc)'
    end
    object lblCilindros: TLabel
      Left = 680
      Top = 94
      Caption = 'Cilindros'
    end
    object lblCombustivel: TLabel
      Left = 16
      Top = 158
      Caption = 'Combustivel'
    end
    object lblAspiracao: TLabel
      Left = 280
      Top = 158
      Caption = 'Aspiracao'
    end
    object lblValvulas: TLabel
      Left = 544
      Top = 158
      Caption = 'Valvulas'
    end
    object lblTipoInjecao: TLabel
      Left = 680
      Top = 158
      Caption = 'Tipo de injecao'
    end
    object edtMarca: TDBEdit
      Left = 16
      Top = 50
      Width = 240
      Height = 23
      DataField = 'marca'
      TabOrder = 0
    end
    object edtModelo: TDBEdit
      Left = 280
      Top = 50
      Width = 240
      Height = 23
      DataField = 'modelo'
      TabOrder = 1
    end
    object edtAnoInicial: TDBEdit
      Left = 544
      Top = 50
      Width = 112
      Height = 23
      DataField = 'ano_inicial'
      TabOrder = 2
    end
    object edtAnoFinal: TDBEdit
      Left = 680
      Top = 50
      Width = 112
      Height = 23
      DataField = 'ano_final'
      TabOrder = 3
    end
    object edtCodigoMotor: TDBEdit
      Left = 16
      Top = 114
      Width = 240
      Height = 23
      DataField = 'codigo_motor'
      TabOrder = 4
    end
    object edtFamiliaMotor: TDBEdit
      Left = 280
      Top = 114
      Width = 240
      Height = 23
      DataField = 'familia_motor'
      TabOrder = 5
    end
    object edtCilindrada: TDBEdit
      Left = 544
      Top = 114
      Width = 112
      Height = 23
      DataField = 'cilindrada_cc'
      TabOrder = 6
    end
    object edtCilindros: TDBEdit
      Left = 680
      Top = 114
      Width = 112
      Height = 23
      DataField = 'cilindros'
      TabOrder = 7
    end
    object cbCombustivel: TDBComboBox
      Left = 16
      Top = 178
      Width = 240
      Height = 23
      DataField = 'combustivel'
      Items.Strings = (
        'FLEX'
        'GASOLINA'
        'ETANOL'
        'DIESEL'
        'ELETRICO'
        'HIBRIDO')
      TabOrder = 8
    end
    object cbAspiracao: TDBComboBox
      Left = 280
      Top = 178
      Width = 240
      Height = 23
      DataField = 'aspiracao'
      Items.Strings = (
        'ASPIRADO'
        'TURBO'
        'SUPERCHARGER')
      TabOrder = 9
    end
    object edtValvulas: TDBEdit
      Left = 544
      Top = 178
      Width = 112
      Height = 23
      DataField = 'valvulas'
      TabOrder = 10
    end
    object cbTipoInjecao: TDBComboBox
      Left = 680
      Top = 178
      Width = 240
      Height = 23
      DataField = 'tipo_injecao'
      Items.Strings = (
        'CARBURADOR'
        'INJECAO_INDIRETA'
        'INJECAO_DIRETA')
      TabOrder = 11
    end
  end
  object pnlBotoes: TPanel
    Left = 0
    Top = 595
    Width = 980
    Height = 55
    Align = alBottom
    TabOrder = 2
    object btnNovo: TButton
      Left = 16
      Top = 12
      Width = 100
      Height = 31
      Caption = 'Novo'
      OnClick = btnNovoClick
      TabOrder = 0
    end
    object btnEditar: TButton
      Left = 128
      Top = 12
      Width = 100
      Height = 31
      Caption = 'Editar'
      OnClick = btnEditarClick
      TabOrder = 1
    end
    object btnSalvar: TButton
      Left = 240
      Top = 12
      Width = 100
      Height = 31
      Caption = 'Salvar'
      OnClick = btnSalvarClick
      TabOrder = 2
    end
    object btnExcluir: TButton
      Left = 352
      Top = 12
      Width = 100
      Height = 31
      Caption = 'Desativar'
      OnClick = btnExcluirClick
      TabOrder = 3
    end
    object btnCancelar: TButton
      Left = 464
      Top = 12
      Width = 100
      Height = 31
      Caption = 'Cancelar'
      OnClick = btnCancelarClick
      TabOrder = 4
    end
    object btnFechar: TButton
      Left = 864
      Top = 12
      Width = 100
      Height = 31
      Caption = 'Fechar'
      OnClick = btnFecharClick
      TabOrder = 5
    end
  end
end
