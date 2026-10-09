object DMDefeitos: TDMDefeitos
  Height = 200
  Width = 300
  object qryDefeitos: TFDQuery
    Connection = DMBancoDados.Conexao
    SQL.Strings = (
      'select * from defeito'
      'where ativo = 1'
      'order by categoria, nome')
    Left = 48
    Top = 32
  end
  object dsDefeitos: TDataSource
    DataSet = qryDefeitos
    Left = 152
    Top = 32
  end
end
