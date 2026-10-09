object DMEnviaDados: TDMEnviaDados
  Height = 280
  Width = 480
  object RESTClient: TRESTClient
    Accept = 'application/json'
    BaseURL = 'http://127.0.0.1:8000'
    Params = <>
    SynchronizedEvents = False
    Left = 32
    Top = 24
  end
  object ReqSaude: TRESTRequest
    Client = RESTClient
    Method = rmGET
    Params = <>
    Resource = 'api/v1/saude'
    Response = RespSaude
    SynchronizedEvents = False
    Left = 128
    Top = 24
  end
  object RespSaude: TRESTResponse
    Left = 224
    Top = 24
  end
  object ReqAnalise: TRESTRequest
    Client = RESTClient
    Method = rmPOST
    Params = <>
    Resource = 'api/v1/analises/audio'
    Response = RespAnalise
    SynchronizedEvents = False
    Left = 128
    Top = 96
  end
  object RespAnalise: TRESTResponse
    Left = 224
    Top = 96
  end
  object ReqDebugPyCharm: TRESTRequest
    Client = RESTClient
    Method = rmPOST
    Params = <>
    Resource = 'api/v1/debug/pycharm/conectar'
    Response = RespDebugPyCharm
    SynchronizedEvents = False
    Left = 128
    Top = 168
  end
  object RespDebugPyCharm: TRESTResponse
    Left = 264
    Top = 168
  end
end
