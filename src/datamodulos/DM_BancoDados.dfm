object DMBancoDados: TDMBancoDados
  Height = 240
  Width = 320
  object Conexao: TFDConnection
    LoginPrompt = False
    Left = 40
    Top = 24
  end
  object DriverSQLite: TFDPhysSQLiteDriverLink
    Left = 136
    Top = 24
  end
  object qryExecucao: TFDQuery
    Connection = Conexao
    Left = 40
    Top = 96
  end
  object qryConsulta: TFDQuery
    Connection = Conexao
    Left = 136
    Top = 96
  end
end
