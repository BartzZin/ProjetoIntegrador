object FrmCadDefeito: TFrmCadDefeito
  Left = 0
  Top = 0
  Caption = 'Cadastro de defeitos'
  ClientHeight = 580
  ClientWidth = 850
  Position = poScreenCenter
  OnCreate = FormCreate
  object grdDefeitos: TDBGrid
    Left = 0
    Top = 0
    Width = 850
    Height = 245
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
    Top = 257
    Width = 826
    Height = 250
    Caption = 'Defeito'
    TabOrder = 1
    object lblCategoria: TLabel
      Left = 16
      Top = 28
      Caption = 'Categoria'
    end
    object lblComponente: TLabel
      Left = 216
      Top = 28
      Caption = 'Componente'
    end
    object lblNome: TLabel
      Left = 416
      Top = 28
      Caption = 'Nome'
    end
    object lblDescricao: TLabel
      Left = 16
      Top = 92
      Caption = 'Descricao'
    end
    object edtCategoria: TDBEdit
      Left = 16
      Top = 48
      Width = 176
      Height = 23
      DataField = 'categoria'
      TabOrder = 0
    end
    object edtComponente: TDBEdit
      Left = 216
      Top = 48
      Width = 176
      Height = 23
      DataField = 'componente'
      TabOrder = 1
    end
    object edtNome: TDBEdit
      Left = 416
      Top = 48
      Width = 380
      Height = 23
      DataField = 'nome'
      TabOrder = 2
    end
    object memDescricao: TDBMemo
      Left = 16
      Top = 112
      Width = 780
      Height = 112
      DataField = 'descricao'
      TabOrder = 3
    end
  end
  object pnlBotoes: TPanel
    Left = 0
    Top = 525
    Width = 850
    Height = 55
    Align = alBottom
    TabOrder = 2
    object btnNovo: TButton
      Left = 16
      Top = 12
      Width = 96
      Height = 31
      Caption = 'Novo'
      OnClick = btnNovoClick
      TabOrder = 0
    end
    object btnEditar: TButton
      Left = 124
      Top = 12
      Width = 96
      Height = 31
      Caption = 'Editar'
      OnClick = btnEditarClick
      TabOrder = 1
    end
    object btnSalvar: TButton
      Left = 232
      Top = 12
      Width = 96
      Height = 31
      Caption = 'Salvar'
      OnClick = btnSalvarClick
      TabOrder = 2
    end
    object btnExcluir: TButton
      Left = 340
      Top = 12
      Width = 96
      Height = 31
      Caption = 'Desativar'
      OnClick = btnExcluirClick
      TabOrder = 3
    end
    object btnCancelar: TButton
      Left = 448
      Top = 12
      Width = 96
      Height = 31
      Caption = 'Cancelar'
      OnClick = btnCancelarClick
      TabOrder = 4
    end
    object btnFechar: TButton
      Left = 738
      Top = 12
      Width = 96
      Height = 31
      Caption = 'Fechar'
      OnClick = btnFecharClick
      TabOrder = 5
    end
  end
end
