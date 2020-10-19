unit uPrincipal;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  uTInject.ConfigCEF, uTInject, uTInject.Constant, uTInject.JS, uInjectDecryptFile,
  uTInject.Console, uTInject.Diversos, uTInject.AdjustNumber, uTInject.Config, uTInject.Classes,
  uDWAbout, uRESTDWBase, Vcl.Imaging.jpeg, uDM, Vcl.AppEvnts, Vcl.Menus, uBotConversa, uBotGestor;

type
  TfrmPrincipal = class(TForm)
    btnConfig: TButton;
    btnFechar: TButton;
    RESTServicePooler: TRESTServicePooler;
    InjectZap: TInject;
    lblVersao: TLabel;
    TrayIcon: TTrayIcon;
    ApplicationEvents: TApplicationEvents;
    Panel2: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    lblStatusWS: TLabel;
    lblMensagem: TLabel;
    Image1: TImage;
    led1WS: TShape;
    led2WS: TShape;
    btnIniciarWS: TButton;
    Panel1: TPanel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    lblStatus: TLabel;
    lblMsgZap: TLabel;
    Image2: TImage;
    led2Zap: TShape;
    led1Zap: TShape;
    btnIniciarZap: TButton;
    procedure InjectZapConnected(Sender: TObject);
    procedure InjectZapDisconnectedBrute(Sender: TObject);
    procedure InjectZapGetMyNumber(Sender: TObject);
    procedure InjectZapGetQrCode(const Sender: TObject; const QrCode: TResultQRCodeClass);
    procedure InjectZapGetStatus(Sender: TObject);
    procedure btnIniciarWSClick(Sender: TObject);
    procedure btnIniciarZapClick(Sender: TObject);
    procedure btnConfigClick(Sender: TObject);
    procedure btnFecharClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure InjectZapDisconnected(Sender: TObject);
    procedure InjectZapGetBatteryLevel(Sender: TObject);
    procedure ApplicationEventsMinimize(Sender: TObject);
    procedure TrayIconDblClick(Sender: TObject);
    procedure InjectZapGetUnReadMessages(const Chats: TChatList);
  private
    Gestor        : TBotManager;
    ConversaAtual : TBotConversa;
    FCabecario: String;
    procedure SetCabecario(const Value: String);

    { Private declarations }
  public
    procedure GestorInteracao(Conversa: TBotConversa);
    procedure EnviarMensagem(AEtapa: Integer; ATexto : String; AAnexo : String = '');
    procedure EnviarAvisoRespostaInvalida;
    procedure EnviarRespostaConfirmacaoPedido(AResposta : String; AContato : String);
    procedure EnviarMenuConfirmacaoPedido;
    property Cabecario : String read FCabecario write SetCabecario;
  end;

var
  frmPrincipal: TfrmPrincipal;

implementation

{$R *.dfm}

uses uConexao, System.IniFiles, uCEFApplicationCore, Winapi.ShellAPI, ubotDAO;

procedure TfrmPrincipal.EnviarRespostaConfirmacaoPedido(AResposta, AContato: String);
var
ATexto : String;
begin

     try
        if UpperCase(AResposta) = '1' then ATexto := botDAO.registrarPedidoConfirmado;
        if Pos(UpperCase(AResposta), '0') > 0 then ATexto :=  botDAO.registrarPedidoNegado;
     finally
         EnviarMensagem(1, ATexto, FCabecario);
     end;

end;

procedure TfrmPrincipal.EnviarAvisoRespostaInvalida;
var
AText : String;
begin

     AText := AText + InjectZap.Emoticons.LoiraMaoNoRosto + ' *Resposta inválida! Tente novamente* \n\n';
     EnviarMensagem(ConversaAtual.Etapa, AText, FCabecario);

end;

procedure TfrmPrincipal.EnviarMensagem(AEtapa: Integer; ATexto, AAnexo: String);
begin
     ConversaAtual.Etapa    := AEtapa;
     ConversaAtual.Pergunta := ATexto;
     ConversaAtual.Resposta := '';

     if AAnexo <> '' then
        InjectZap.SendFile(ConversaAtual.ID, AAnexo, ConversaAtual.Pergunta)
     else
        InjectZap.Send(ConversaAtual.ID, ConversaAtual.Pergunta);

end;

procedure TfrmPrincipal.EnviarMenuConfirmacaoPedido;
var
ATexto : String;
begin

     ConversaAtual.Situacao := saEmAtendimento;
     case botDAO.validaPedido(ConversaAtual.ID) of
          False : begin
                       ATexto := InjectZap.Emoticons.LoiraFazerOq + ' *Desculpe, mas você não possui nenhum pedido para confirmar!*';
                       EnviarMensagem(ConversaAtual.Etapa, ATexto, FCabecario);
                  end;
           True : begin
                       ATexto := 'Deseja confirmar o recebimento do pedido *' + botDAO.NumeroPedido + '\n\n'+
                                 '*, digite a opção correspondente abaixo. \n';
                       ATexto := ATexto + InjectZap.Emoticons.Check + ' - SIM \n\n';
                       ATexto := ATexto + InjectZap.Emoticons.NegativeSquaredCrossMark + ' - NÃO \n\n' +
                                          InjectZap.Emoticons.WarningSign + '(*A não confirmação o pedido ficara sejeito ao cancelamento*)';

                       EnviarMensagem(1, ATexto, FCabecario);
                  end;
     End;
end;

procedure TfrmPrincipal.GestorInteracao(Conversa: TBotConversa);
var
AResposta : String;
begin
     ConversaAtual := Conversa;
     ConversaAtual.Situacao := saEmAtendimento;
     Conversa.Etapa         := 1;
     case Conversa.Situacao of
          saEmAtendimento : begin
                                 case Conversa.Etapa of
                                     1 : begin
                                             //Tratar a resposta menu origem
                                             if botDAO.validaPedido(ConversaAtual.ID) = True then
                                                 begin
                                                     if (Pos(UpperCase(Conversa.Resposta), '1') > 0) or
                                                        (Pos(UpperCase(Conversa.Resposta), '0') > 0) then
                                                            EnviarRespostaConfirmacaoPedido(Conversa.Resposta, ConversaAtual.ID)
                                                     else
                                                            EnviarAvisoRespostaInvalida;
                                                 end;

                                         end;
                                 end;

                            end;
     end;

end;

Procedure DeleteDiretorio(hHandle: THandle; Const sPath : String; Confirm: boolean);
var
OpStruc: TSHFileOpStruct;
FromBuffer, ToBuffer: Array[0..128] of Char;
begin
    fillChar( OpStruc, Sizeof(OpStruc), 0 );
    FillChar( FromBuffer, Sizeof(FromBuffer), 0 );
    FillChar( ToBuffer, Sizeof(ToBuffer), 0 );
    StrPCopy( FromBuffer, sPath);
    With OpStruc Do
        begin
            Wnd:= hHandle;
            wFunc:=FO_DELETE;
            pFrom:= @FromBuffer;
            pTo:= @ToBuffer;
            if not confirm then
                begin
                    fFlags:= FOF_NOCONFIRMATION;
                end;
            fAnyOperationsAborted:=False;
            hNameMappings:=nil;
        //lpszProgressTitle:=nil;
        End;
    ShFileOperation(OpStruc);
end;

function GetVersaoArq: string;
var
  VerInfoSize: DWORD;
  VerInfo: Pointer;
  VerValueSize: DWORD;
  VerValue: PVSFixedFileInfo;
  Dummy: DWORD;
begin
  VerInfoSize := GetFileVersionInfoSize(PChar(
    ParamStr(0)), Dummy);
  GetMem(VerInfo, VerInfoSize);
  GetFileVersionInfo(PChar(ParamStr(0)), 0,
    VerInfoSize, VerInfo);
  VerQueryValue(VerInfo, '\', Pointer(VerValue),
    VerValueSize);
  with VerValue^ do
  begin
    Result := IntToStr(dwFileVersionMS shr 16);
    Result := Result + '.' + IntToStr(
      dwFileVersionMS and $FFFF);
    Result := Result + '.' + IntToStr(
      dwFileVersionLS shr 16);
    Result := Result + '.' + IntToStr(
      dwFileVersionLS and $FFFF);
  end;
  FreeMem(VerInfo, VerInfoSize);
end;

procedure TfrmPrincipal.ApplicationEventsMinimize(Sender: TObject);
begin
  Self.Hide();
  Self.WindowState := wsMinimized;
  TrayIcon.Visible := True;
  TrayIcon.Animate := True;
  TrayIcon.ShowBalloonHint;
end;

procedure TfrmPrincipal.btnConfigClick(Sender: TObject);
begin
    if lblStatusWS.Caption = 'On-Line' then
        begin
            Application.MessageBox('Para alterar a porta é necessário encerrar o servidor!',
                                    'WhatsAppWS', MB_OK + MB_ICONWARNING);
            Exit;
        end
    else
        begin
            frmConfiguracao.ShowModal;
        end;
end;

procedure TfrmPrincipal.btnFecharClick(Sender: TObject);
begin
    if (lblStatusWS.Caption = 'On-Line') or (lblStatus.Caption = 'On-Line') then
        begin
            Application.MessageBox('Algum serviço esta em execução, finalize-os para encerrar a aplicação!',
                                    'WhatsAppWS', MB_OK + MB_ICONWARNING);
            Exit;
        end
    else
        begin
            Close;
        end;

end;

procedure AtivaLed(ALed1, ALed2 : TShape; Ativado : Boolean = True);
begin

     case Ativado of
         False : begin
                     ALed1.Brush.Color := clRed;
                     ALed2.Brush.Color := clRed;
                 end;
          True : begin
                     ALed1.Brush.Color := clLime;
                     ALed2.Brush.Color := clLime;
                 end;
     end;

end;

procedure TfrmPrincipal.btnIniciarWSClick(Sender: TObject);
begin

    if btnIniciarWS.Caption = 'Iniciar' then
        begin
            try

                RESTServicePooler.Active := True;
                btnIniciarWS.Caption := 'Parar';
                lblMensagem.Caption := '';
                lblStatusWS.Caption := 'On-Line';

            except
            on E:Exception do
                begin

                    lblMensagem.Caption := 'Não foi possível ativar o servidor.' + #13 +
                                     E.Message;

                    lblStatusWS.Caption := 'Off-line';

                end;

            end;

        end
    else
        begin

            if btnIniciarZAP.Caption = 'Iniciar' then
                begin
                    RESTServicePooler.Active := True;
                    btnIniciarWS.Caption := 'Iniciar';
                    lblMensagem.Caption := '';
                    lblStatusWS.Caption := 'Off-Line';
                end
            else
                begin
                    case Application.MessageBox('O Serviço do WhatsApp ainda esta aberto para finalizar o WS' +
                                                 'é necessário finalizar o serviço do WhatsApp.' + #13 +
                                                 'Deseja continuar?','Servidor WS',
                                                 MB_YESNO + MB_ICONQUESTION) of
                        ID_YES : begin


                                    btnIniciarZapClick(Self);
                                    RESTServicePooler.Active := True;
                                    btnIniciarWS.Caption := 'Iniciar';
                                    lblMensagem.Caption := '';
                                    lblStatusWS.Caption := 'Off-Line';

                                 end;
                         ID_NO : begin
                                    Exit;
                                 end;
                    end;
                end;

        end;

        if lblStatusWS.Caption = 'On-Line' then
           AtivaLed(led1WS, led2WS) else
           AtivaLed(led1WS, led2WS, False);

end;

procedure TfrmPrincipal.btnIniciarZapClick(Sender: TObject);
begin
    if btnIniciarZAP.Caption = 'Iniciar' then
        begin
            if not InjectZap.Auth(false) then
                begin
                    InjectZap.FormQrCodeType := TFormQrCodeType.Ft_None;
                    InjectZap.FormQrCodeStart;
                end;

            if not InjectZap.FormQrCodeShowing then
                 InjectZap.FormQrCodeShowing := True;

            Gestor := TBotManager.Create(Self);
            Gestor.Simultaneos := 30;
            Gestor.TempoInatividade := (90 * 1000);
            Gestor.OnInteracao := GestorInteracao;

        end
    else
        begin
            InjectZap.Disconnect;
        end;
end;

procedure TfrmPrincipal.FormClose(Sender: TObject; var Action: TCloseAction);
begin
    if (lblStatusWS.Caption <> 'Off-Line') or (lblStatus.Caption <> 'Off-Line') then
        Action := TCloseAction.caNone
    else
        Action := caFree;
end;

procedure TfrmPrincipal.FormCreate(Sender: TObject);
var
FArqIni : TIniFile;
begin

     FCabecario := ExtractFilePath(Application.ExeName) + 'Imagens\Logo.jpg';
     lblVersao.Caption := GetVersaoArq;

     AtivaLed(led1WS, led2WS, False);
     AtivaLed(led1Zap, led2Zap, False);

     RESTServicePooler.ServerMethodClass := Tdm;
     btnIniciarWSClick(Self);

    try
        FArqIni := TIniFile.Create(GetCurrentDir + '\CONFIG.ini');

        if not FArqIni.SectionExists('WHATSAPP') then
            begin
                FArqIni.WriteString('WHATSAPP','SERVER',FArqIni.ReadString('CONEX FIREDAC','SERVER_BDG',''));
                FArqIni.WriteString('WHATSAPP','PATHANEXO','WORK\WHATSAPP\ANEXO');
                FArqIni.WriteString('WHATSAPP','PATHQRCODE','WORK\WHATSAPP\QRCODE');
                FArqIni.WriteInteger('WHATSAPP','PORTA',8082);
            end;

            botDAO.conexaoBDG.Params.Values['Database'] := FArqIni.ReadString('CONEX FIREDAC','BDBDG','');
            botDAO.conexaoBDG.Params.Values['Server']   := FArqIni.ReadString('CONEX FIREDAC','SERVER_BDG','');
            botDAO.conexaoBDG.Open;

            if FArqIni.ReadString('WHATSAPP','SERVER','') <> '' then
                begin
                    gPathQrWhats    := FArqIni.ReadString('WHATSAPP','SERVER','') + '\' +
                                       FArqIni.ReadString('WHATSAPP','PATHQRCODE','');
                    gPathAnexoWhats := FArqIni.ReadString('WHATSAPP','SERVER','') + '\' +
                                       FArqIni.ReadString('WHATSAPP','PATHANEXO','');
                end
            else
                begin
                    gPathQrWhats    := FArqIni.ReadString('WHATSAPP','PATHQRCODE','');
                    gPathAnexoWhats := FArqIni.ReadString('WHATSAPP','PATHANEXO','');
                end;


            gPorta          := FArqIni.ReadInteger('WHATSAPP','PORTA',0);
            RESTServicePooler.ServicePort := gPorta;
            lblMensagem.Caption := 'Porta de conexão: ' + gPorta.ToString;

    finally
        FArqIni.Free;
    end;
end;

procedure TfrmPrincipal.InjectZapConnected(Sender: TObject);
begin
    btnIniciarZAP.Caption := 'Parar';
    lblStatus.Caption := 'On-Line';

    DeleteFile(pChar(gPathQrWhats + '\qrcode.png'));

    AtivaLed(led1Zap, led2Zap);


end;

procedure TfrmPrincipal.InjectZapDisconnected(Sender: TObject);
begin
    DeleteDiretorio(Self.Handle, ExtractFileDir(GetCurrentDir) + '\cache', False);
    DeleteDiretorio(Self.Handle, ExtractFileDir(GetCurrentDir) + '\LogTinject', False);
    DeleteDiretorio(Self.Handle, ExtractFileDir(GetCurrentDir) + '\TInjectAnexos', False);
    DeleteDiretorio(Self.Handle, ExtractFileDir(GetCurrentDir) + '\User Data', False);

    AtivaLed(led1Zap, led2Zap, False);
end;

procedure TfrmPrincipal.InjectZapDisconnectedBrute(Sender: TObject);
begin
    btnIniciarZAP.Caption := 'Iniciar';
    lblStatus.Caption := 'Off-Line';
end;

procedure TfrmPrincipal.InjectZapGetBatteryLevel(Sender: TObject);
begin
  gStatusBAteria := TInject(Sender).BatteryLevel.ToString;
end;

procedure TfrmPrincipal.InjectZapGetMyNumber(Sender: TObject);
begin
      gNumeroConectado := TInject(Sender).MyNumber;
     lblMsgZap.Caption   := 'Conectado: ' + gNumeroConectado;
end;

procedure TfrmPrincipal.InjectZapGetQrCode(const Sender: TObject; const QrCode: TResultQRCodeClass);
var
APicture : TPicture;
begin
     APicture := QrCode.AQrCodeImage;
     APicture.SaveToFile(gPathQrWhats + '\qrcode.png');

     if FileExists(gPathQrWhats + '\qrcode.png') then
         lblMsgZap.Caption := 'Aguardando a autenticação.';
end;

procedure TfrmPrincipal.InjectZapGetStatus(Sender: TObject);
begin
    case TInject(Sender).status of
        Server_ConnectedDown       : lblMsgZap.Caption := TInject(Sender).StatusToStr;
        Server_Disconnected        : lblMsgZap.Caption := 'Off-Line';
        Server_Disconnecting       : lblMsgZap.Caption := 'Desligando o serviço do whatsapp';
        Server_Connected           : begin
                                         lblMsgZap.Caption := 'Conectado com sucesso no serviço do whatsapp';
                                         btnIniciarZAP.Caption := 'Parar';
                                     end;
        Server_Connecting          : lblMsgZap.Caption := 'Aguarde, inicializando serviço do whatsapp';
        Inject_Initializing        : lblMsgZap.Caption := TInject(Sender).StatusToStr;
        Inject_Initialized         : begin
                                         lblMsgZap.Caption := 'Conectado com sucesso no serviço do whatsapp';
                                         btnIniciarZAP.Caption := 'Parar';
                                     end;
        Server_ConnectingNoPhone   : lblMsgZap.Caption := TInject(Sender).StatusToStr;
        Server_ConnectingReaderCode: lblMsgZap.Caption := 'Aguardando a autenticação';
        Server_TimeOut             : lblMsgZap.Caption := TInject(Sender).StatusToStr;
        Inject_Destroying          : begin
                                         lblMsgZap.Caption := 'Finzalizando serviço do whatsapp';
                                         btnIniciarZAP.Caption := 'Iniciar';
                                         lblStatus.Caption := 'Off-Line';
                                         AtivaLed(led1Zap, led2Zap, False);
                                     end;
        Inject_Destroy             : lblMsgZap.Caption := 'Serviço finalizado';

    end;
end;

procedure TfrmPrincipal.InjectZapGetUnReadMessages(const Chats: TChatList);
begin
     Gestor.AdministrarChatList(InjectZap, Chats);
end;

procedure TfrmPrincipal.SetCabecario(const Value: String);
begin
  FCabecario := Value;
end;

procedure TfrmPrincipal.TrayIconDblClick(Sender: TObject);
begin
  TrayIcon.Visible := False;
  Show();
  WindowState := wsNormal;
  Application.BringToFront();
end;

end.
