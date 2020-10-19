unit uDM;

interface

uses
  System.Classes, uDWDataModule, uDWAbout, uRESTDWServerEvents, uDWJSONObject,
  uRESTDWServerContext, uTInject, ubotDAO;

type
  Tdm = class(TServerMethodDataModule)
    DWServerEvents: TDWServerEvents;
    procedure DWServerEventsEventsSendMessageZapReplyEvent(var Params: TDWParams; var Result: string);
    procedure DWServerEventsEventsdwevent2ReplyEvent(var Params: TDWParams;
      var Result: string);
    procedure DWServerEventsEventsStatusReplyEvent(var Params: TDWParams;
      var Result: string);
    procedure DWServerEventsEventsFinalizaServicoReplyEvent(
      var Params: TDWParams; var Result: string);
    procedure DWServerEventsEventsStatusBateriaReplyEvent(var Params: TDWParams;
      var Result: string);
    procedure DWServerEventsEventsInicializaServicoReplyEvent(
      var Params: TDWParams; var Result: string);
    procedure DWServerEventsEventsRestartReplyEvent(var Params: TDWParams; var Result: string);
    procedure DWServerEventsEventsSendPedidoReplyEvent(var Params: TDWParams;
      var Result: string);

  private
    function MensagemRetornoJson(ACodigo : Integer; AMensagem : String) : String;
    { Private declarations }
  public

    { Public declarations }
  end;

var
  dm: Tdm;
  gNumeroConectado : String;

  gPathQrWhats : String;
  gPathAnexoWhats : String;
  gPorta : Integer;
  gStatusBateria : String;

implementation

uses
  System.SysUtils, uPrincipal, uTInject.Constant, Winapi.Windows, Vcl.Controls,
  Winapi.Messages, Vcl.Forms;

{%CLASSGROUP 'FMX.Controls.TControl'}

{$R *.dfm}

function Tdm.MensagemRetornoJson(ACodigo : Integer; AMensagem : String) : String;
var
ABaseErro : String;
begin

     ABaseErro := '{"Codigo":"%d","Retorno":"%s"}';
     Result := Format(ABaseErro,[ACodigo,AMensagem]);

end;

procedure Tdm.DWServerEventsEventsdwevent2ReplyEvent(var Params: TDWParams;
  var Result: string);
begin

    Result := MensagemRetornoJson(10, gNumeroConectado);

end;

procedure Tdm.DWServerEventsEventsFinalizaServicoReplyEvent(
  var Params: TDWParams; var Result: string);
begin

    if frmPrincipal.lblMsgZap.Caption = 'Serviço finalizado' then
        begin
            Result := MensagemRetornoJson(12, 'O Serviço já se encontra encerrado!');
        end
    else
        begin
            frmPrincipal.InjectZap.Disconnect;
            Result := MensagemRetornoJson(13,'Encerrando processo');
        end;
end;

procedure ClickStartZap;
var
Pt : TPoint;
begin

        Application.ProcessMessages;

        frmPrincipal.FormStyle := TFormStyle.fsStayOnTop;

        {Obtém o point no centro do Button1}
        Pt.x := frmPrincipal.btnIniciarZap.Left + (frmPrincipal.btnIniciarZap.Width div 2);
        Pt.y := frmPrincipal.btnIniciarZap.Top + (frmPrincipal.btnIniciarZap.Height div 2);

        {Converte Pt para as coordenadas da tela }
        Pt := frmPrincipal.Panel1.ClientToScreen(Pt);
        Pt.x := Round(Pt.x * (65535 / Screen.Width));
        Pt.y := Round(Pt.y * (65535 / Screen.Height));

        {Move o mouse}
        Mouse_Event(MOUSEEVENTF_ABSOLUTE or MOUSEEVENTF_MOVE, Pt.x, Pt.y, 0, 0);

        {Simula o pressionamento do botão esquerdo do mouse}
        Mouse_Event(MOUSEEVENTF_ABSOLUTE or MOUSEEVENTF_LEFTDOWN, Pt.x, Pt.y, 0, 0);

        { Simula soltando o botão esquerdo do mouse }
        Mouse_Event(MOUSEEVENTF_ABSOLUTE or MOUSEEVENTF_LEFTUP, Pt.x, Pt.y, 0, 0);

        frmPrincipal.FormStyle := TFormStyle.fsNormal;

end;

procedure Tdm.DWServerEventsEventsInicializaServicoReplyEvent(
  var Params: TDWParams; var Result: string);
begin

     try
        frmPrincipal.btnIniciarZapClick(Self);
        Result := MensagemRetornoJson(14,'A Serviço esta sendo iniciado...');
    Except
    on E:Exception do
       begin
           Result := MensagemRetornoJson(99, E.Message);
       end;

    end;

end;

procedure Tdm.DWServerEventsEventsRestartReplyEvent(var Params: TDWParams; var Result: string);
var
AConectado : Boolean;
begin

     try

        frmPrincipal.InjectZap.Disconnect;

        AConectado := True;

        TThread.CreateAnonymousThread(
        procedure
        begin

             while AConectado do
                   begin

                        Sleep(1000);
                        if frmPrincipal.lblStatus.Caption = 'Off-Line' then
                            begin
                                Sleep(1000);
                                ClickStartZap;
                                AConectado := False;
                            end;

                   end;

        end).Start;

        Result := MensagemRetornoJson(15,'Reiniciando o serviço');

     except
     On E:Exception do
        begin
            Result := MensagemRetornoJson(99,E.Message);
        end;
     end;

end;

procedure Tdm.DWServerEventsEventsSendMessageZapReplyEvent(var Params: TDWParams; var Result: string);
var
ACelular,
AAnexo,
AMensagem : String;
begin

     try
         ACelular  := Params.ItemsString['CelularDestino'].AsString;
         AAnexo    := Params.ItemsString['Anexo'].AsString;
         AMensagem := Params.ItemsString['Mensagem'].AsString;

         if frmPrincipal.InjectZap.Status = TStatusType.Server_Disconnected then
            begin
                 Result := MensagemRetornoJson(16,'WhatsApp não conectado!');
                 Exit;
            end;

         if Length(ACelular) < 11 then
            begin
                 Result := MensagemRetornoJson(17,'Celular inválido!');
                 Exit;
            end;

         if (AAnexo <> '') and (not FileExists(AAnexo)) then
            begin
                 Result := MensagemRetornoJson(18,'Caminho do anexo não encontrado!');
                 Exit;
            end;

         if not frmPrincipal.InjectZap.Auth then
             Exit;

         frmPrincipal.InjectZap.Send(ACelular + '@c.us', AMensagem);

         if AAnexo <> '' then
            frmPrincipal.InjectZap.SendFile(ACelular + '@c.us', AAnexo);

         Result := MensagemRetornoJson(19,'Mensagem Enviada com sucesso');
     except
        On E:Exception do
            begin
                Result := MensagemRetornoJson(99, E.Message);
            end;

     end;

end;

procedure Tdm.DWServerEventsEventsSendPedidoReplyEvent(var Params: TDWParams;
  var Result: string);
var
ACelular,
AAnexo,
APedido,
AMensagem,
ACabecario : String;
begin

     try
         ACelular := Params.ItemsString['Celular'].AsString;
         AAnexo   := Params.ItemsString['Anexo'].AsString;
         APedido  := Params.ItemsString['Pedido'].AsString;
         botDAO.NumeroPedido := APedido;
         AMensagem := AMensagem + 'Olá, mensagem automática \n\n'+
                                  'Pedido *' + APedido + '* para você... \n' +
                                  'Confirme o recebimento para mim! \n\n' +
                                  frmPrincipal.InjectZap.Emoticons.Um + ' para SIM \n\n' +
                                  frmPrincipal.InjectZap.Emoticons.Zero + ' para NÃO \n\n' +
                                  '*Obrigado!*';

         if frmPrincipal.InjectZap.Status = TStatusType.Server_Disconnected then
            begin
                 Result := MensagemRetornoJson(16,'WhatsApp não conectado!');
                 Exit;
            end;

         if Length(ACelular) < 11 then
            begin
                 Result := MensagemRetornoJson(17,'Celular inválido!');
                 Exit;
            end;

         if (AAnexo <> '') and (not FileExists(AAnexo)) then
            begin
                 Result := MensagemRetornoJson(18,'Caminho do anexo não encontrado!');
                 Exit;
            end;

         if not frmPrincipal.InjectZap.Auth then
            Exit;

         frmPrincipal.InjectZap.SendFile(ACelular + '@c.us', AAnexo);
         Sleep(1000);
         frmPrincipal.InjectZap.SendFile(ACelular + '@c.us', frmPrincipal.Cabecario, AMensagem);

         Result := MensagemRetornoJson(19,'Mensagem Enviada com sucesso');
     except
        On E:Exception do
            begin
                Result := MensagemRetornoJson(99, E.Message);
            end;

     end;


end;

procedure Tdm.DWServerEventsEventsStatusBateriaReplyEvent(var Params: TDWParams;
  var Result: string);
begin

    frmPrincipal.InjectZap.GetBatteryStatus;

    Result := MensagemRetornoJson(20, gStatusBateria);

end;

procedure Tdm.DWServerEventsEventsStatusReplyEvent(var Params: TDWParams;
  var Result: string);
var
AResult : String;
begin

    try
        case frmPrincipal.InjectZap.Status of
            Server_ConnectedDown       : AResult := frmPrincipal.InjectZap.StatusToStr;
            Server_Disconnected        : AResult := 'Off-Line';
            Server_Disconnecting       : AResult := 'Desligando o serviço';
            Server_Connected           : AResult := 'On-Line';
            Server_Connecting          : AResult := 'inicializando o serviço';
            Inject_Initializing        : AResult := frmPrincipal.InjectZap.StatusToStr;
            Inject_Initialized         : AResult := 'On-Line';
            Server_ConnectingNoPhone   : AResult := frmPrincipal.InjectZap.StatusToStr;
            Server_ConnectingReaderCode: AResult := frmPrincipal.InjectZap.StatusToStr;
            Server_TimeOut             : AResult := frmPrincipal.InjectZap.StatusToStr;
            Inject_Destroying          : AResult := 'Finzalizando';
            Inject_Destroy             : AResult := 'Off-Line';
        end;

            if frmPrincipal.lblMsgZap.Caption = 'Aguardando a autenticação.' then
                Result := MensagemRetornoJson(55, frmPrincipal.lblMsgZap.Caption) else
                Result := MensagemRetornoJson(55, AResult);
    Except
        On E:Exception do
            begin
                Result := MensagemRetornoJson(99, E.Message);
            end;

    end;

end;

end.
