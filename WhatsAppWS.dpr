program WhatsAppWS;

uses
  Vcl.Forms,
  uTInject.ConfigCEF,
  uPrincipal in 'uPrincipal.pas' {frmPrincipal},
  uDM in 'uDM.pas' {dm: TServerMethodDataModule},
  uConexao in 'uConexao.pas' {frmConfiguracao};

{$R *.res}

begin

  If not GlobalCEFApp.StartMainProcess then
     Exit;

  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmPrincipal, frmPrincipal);
  Application.CreateForm(Tdm, dm);
  Application.CreateForm(TfrmConfiguracao, frmConfiguracao);
  Application.Run;
end.
