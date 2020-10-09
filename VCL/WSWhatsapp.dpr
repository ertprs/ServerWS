program WSWhatsapp;

uses
  Vcl.Forms,
  uDM in 'uDM.pas' {dm},
  uPrincipal in 'uPrincipal.pas' {Form1};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(Tdm, dm);
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
