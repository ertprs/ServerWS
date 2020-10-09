unit uWhatsApp;

interface

procedure EnviaMsg(FCelular, FMensagem, FAnexo : String; FSaveLog : Boolean = False);


implementation

uses uPrincipal;

procedure EnviaMsg(FCelular, FMensagem, FAnexo : String; FSaveLog : Boolean = False);
begin

     frmPrincipal.InjectZap.Send(FCelular, FMensagem);
     frmPrincipal.InjectZap.SendFile(FCelular, FAnexo);

end;

end.
