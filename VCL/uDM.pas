unit uDM;

interface

uses
  System.Classes, uDWDataModule, uDWAbout, uRESTDWServerEvents, uDWJSONObject, uRESTDWServerContext;

type
  Tdm = class(TServerMethodDataModule)
    DWServerEvents: TDWServerEvents;
    procedure DWServerEventsEventshoraReplyEvent(var Params: TDWParams; var Result: string);
    procedure DWServerEventsEventsSendMessageZapReplyEvent(var Params: TDWParams; var Result: string);

  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  dm: Tdm;

implementation

uses
  System.SysUtils, uPrincipal;

{%CLASSGROUP 'FMX.Controls.TControl'}

{$R *.dfm}


procedure Tdm.DWServerEventsEventshoraReplyEvent(var Params: TDWParams; var Result: string);
begin

     Result := '{"hora":"' + FormatDateTime('hh:nn:ss', now) + '"}';

end;

function MensagemRetornoJson(AMensagem : String) : String;
var
ABaseErro : String;
begin

     ABaseErro := '{"Retorno":"%s"}';
     Result := Format(ABaseErro,[AMensagem]);

end;

procedure Tdm.DWServerEventsEventsSendMessageZapReplyEvent(var Params: TDWParams; var Result: string);
var
ACelular,
AAnexo,
AMensagem : String;
begin

     ACelular  := Params.ItemsString['CelularDestino'].AsString;
     AAnexo    := Params.ItemsString['Anexo'].AsString;
     AMensagem := Params.ItemsString['Mensagem'].AsString;

     if not frmPrincipal.swWhatsApp.IsChecked then
        begin
             Result := MensagemRetornoJson('WhatsApp não conectado!');
             Exit;
        end;

     if Length(ACelular) < 13 then
        begin
             Result := MensagemRetornoJson('Celular inválido!');
             Exit;
        end;

     if (AAnexo <> '') and (not FileExists(AAnexo)) then
        begin
             Result := MensagemRetornoJson('Caminho do anexo não encontrado!');
             Exit;
        end;

     if not frmPrincipal.InjectZap.Auth then
         Exit;

     frmPrincipal.InjectZap.Send(ACelular + '@c.us', AMensagem);

     if AAnexo <> '' then
        frmPrincipal.InjectZap.SendFile(ACelular + '@c.us', AAnexo);

     Result := MensagemRetornoJson('Mensagem Enviada com sucesso');

end;

end.
