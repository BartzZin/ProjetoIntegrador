object DMVeiculos: TDMVeiculos
  Height = 240
  Width = 420
  object qryModelosVeiculo: TFDQuery
    Connection = DMBancoDados.Conexao
    SQL.Strings = (
      'select * from modelo_veiculo'
      'where ativo = 1'
      'order by marca, modelo, ano_inicial')
    Left = 48
    Top = 32
  end
  object qryModeloVeiculo: TFDQuery
    Connection = DMBancoDados.Conexao
    SQL.Strings = (
      'select * from modelo_veiculo where id = :id')
    Left = 176
    Top = 32
    ParamData = <
      item
        Name = 'ID'
        ParamType = ptInput
      end>
  end
  object qryMarcas: TFDQuery
    Connection = DMBancoDados.Conexao
    Left = 296
    Top = 32
  end
  object dsModelosVeiculo: TDataSource
    DataSet = qryModelosVeiculo
    Left = 48
    Top = 112
  end
end
