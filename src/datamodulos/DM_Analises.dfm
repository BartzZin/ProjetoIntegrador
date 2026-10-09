object DMAnalises: TDMAnalises
  Height = 300
  Width = 560
  object qryHistorico: TFDQuery
    Connection = DMBancoDados.Conexao
    SQL.Strings = (
      'select a.id, a.data_hora, v.marca, v.modelo,'
      '       a.arquivo_relativo, a.qualidade_audio,'
      '       a.classificacao_qualidade, a.versao_modelo_ml,'
      '       a.tempo_processamento_ms'
      'from analise a'
      'join modelo_veiculo v on v.id = a.modelo_veiculo_id'
      'order by a.data_hora desc')
    Left = 40
    Top = 32
  end
  object qryResultados: TFDQuery
    Connection = DMBancoDados.Conexao
    SQL.Strings = (
      'select ar.ordem_resultado, d.nome,'
      '       ar.probabilidade_audio, ar.probabilidade_historica,'
      '       ar.probabilidade_final'
      'from analise_resultado ar'
      'join defeito d on d.id = ar.defeito_id'
      'where ar.analise_id = :analise'
      'order by ar.ordem_resultado')
    Left = 152
    Top = 32
    ParamData = <
      item
        Name = 'ANALISE'
        ParamType = ptInput
      end>
  end
  object qryInserirAnalise: TFDQuery
    Connection = DMBancoDados.Conexao
    SQL.Strings = (
      'insert into analise ('
      ' modelo_veiculo_id, data_hora, arquivo_relativo,'
      ' qualidade_audio, classificacao_qualidade,'
      ' versao_modelo_ml, tempo_processamento_ms)'
      'values (:modelo, :data_hora, :arquivo, :qualidade,'
      ' :classificacao, :versao, :tempo)')
    Left = 272
    Top = 32
    ParamData = <
      item
        Name = 'MODELO'
        DataType = ftInteger
        ParamType = ptInput
      end
      item
        Name = 'DATA_HORA'
        DataType = ftString
        Size = 30
        ParamType = ptInput
      end
      item
        Name = 'ARQUIVO'
        DataType = ftString
        Size = 500
        ParamType = ptInput
      end
      item
        Name = 'QUALIDADE'
        DataType = ftFloat
        ParamType = ptInput
      end
      item
        Name = 'CLASSIFICACAO'
        DataType = ftString
        Size = 50
        ParamType = ptInput
      end
      item
        Name = 'VERSAO'
        DataType = ftString
        Size = 120
        ParamType = ptInput
      end
      item
        Name = 'TEMPO'
        DataType = ftInteger
        ParamType = ptInput
      end>
  end
  object qryInserirResultado: TFDQuery
    Connection = DMBancoDados.Conexao
    SQL.Strings = (
      'insert into analise_resultado ('
      ' analise_id, defeito_id, probabilidade_audio,'
      ' probabilidade_historica, probabilidade_final, ordem_resultado)'
      'values (:analise, :defeito, :audio, :historica, :final, :ordem)')
    Left = 400
    Top = 32
    ParamData = <
      item
        Name = 'ANALISE'
        DataType = ftLargeint
        ParamType = ptInput
      end
      item
        Name = 'DEFEITO'
        DataType = ftInteger
        ParamType = ptInput
      end
      item
        Name = 'AUDIO'
        DataType = ftFloat
        ParamType = ptInput
      end
      item
        Name = 'HISTORICA'
        DataType = ftFloat
        ParamType = ptInput
      end
      item
        Name = 'FINAL'
        DataType = ftFloat
        ParamType = ptInput
      end
      item
        Name = 'ORDEM'
        DataType = ftInteger
        ParamType = ptInput
      end>
  end
  object dsHistorico: TDataSource
    DataSet = qryHistorico
    Left = 40
    Top = 112
  end
  object dsResultados: TDataSource
    DataSet = qryResultados
    Left = 152
    Top = 112
  end
end
