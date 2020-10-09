object dm: Tdm
  OldCreateOrder = False
  Encoding = esUtf8
  Height = 284
  Width = 356
  object DWServerEvents: TDWServerEvents
    IgnoreInvalidParams = False
    Events = <
      item
        Routes = [crAll]
        NeedAuthorization = True
        DWParams = <
          item
            TypeObject = toParam
            ObjectDirection = odIN
            ObjectValue = ovString
            ParamName = 'CelularDestino'
            Encoded = False
          end
          item
            TypeObject = toParam
            ObjectDirection = odIN
            ObjectValue = ovString
            ParamName = 'Mensagem'
            Encoded = False
          end
          item
            TypeObject = toParam
            ObjectDirection = odIN
            ObjectValue = ovString
            ParamName = 'Anexo'
            Encoded = False
          end
          item
            TypeObject = toParam
            ObjectDirection = odIN
            ObjectValue = ovBoolean
            ParamName = 'Save'
            Encoded = False
          end>
        JsonMode = jmPureJSON
        Name = 'SendMessage'
        EventName = 'SendMessage'
        OnlyPreDefinedParams = False
        OnReplyEvent = DWServerEventsEventsSendMessageZapReplyEvent
      end
      item
        Routes = [crAll]
        NeedAuthorization = True
        DWParams = <>
        JsonMode = jmPureJSON
        Name = 'NumeroConectado'
        EventName = 'NumeroConectado'
        OnlyPreDefinedParams = False
        OnReplyEvent = DWServerEventsEventsdwevent2ReplyEvent
      end
      item
        Routes = [crAll]
        NeedAuthorization = True
        DWParams = <>
        JsonMode = jmPureJSON
        Name = 'Status'
        EventName = 'Status'
        OnlyPreDefinedParams = False
        OnReplyEvent = DWServerEventsEventsStatusReplyEvent
      end
      item
        Routes = [crAll]
        NeedAuthorization = True
        DWParams = <>
        JsonMode = jmPureJSON
        Name = 'Stop'
        EventName = 'Stop'
        OnlyPreDefinedParams = False
        OnReplyEvent = DWServerEventsEventsFinalizaServicoReplyEvent
      end
      item
        Routes = [crAll]
        NeedAuthorization = True
        DWParams = <>
        JsonMode = jmPureJSON
        Name = 'StatusBateria'
        EventName = 'StatusBateria'
        OnlyPreDefinedParams = False
        OnReplyEvent = DWServerEventsEventsStatusBateriaReplyEvent
      end
      item
        Routes = [crAll]
        NeedAuthorization = True
        DWParams = <>
        JsonMode = jmPureJSON
        Name = 'Start'
        EventName = 'Start'
        OnlyPreDefinedParams = False
        OnReplyEvent = DWServerEventsEventsInicializaServicoReplyEvent
      end
      item
        Routes = [crAll]
        NeedAuthorization = True
        DWParams = <>
        JsonMode = jmPureJSON
        Name = 'Restart'
        EventName = 'Restart'
        OnlyPreDefinedParams = False
        OnReplyEvent = DWServerEventsEventsRestartReplyEvent
      end>
    ContextName = 'ServerWhats'
    Left = 132
    Top = 112
  end
end
