program WhatsAppWS;

uses
  Vcl.Forms,
  uTInject.ConfigCEF,
  uBotConversa in 'uBotConversa.pas',
  ubotDAO in 'ubotDAO.pas' {botDAO: TDataModule},
  uBotGestor in 'uBotGestor.pas',
  uConexao in 'uConexao.pas' {frmConfiguracao},
  uDM in 'uDM.pas' {dm: TServerMethodDataModule},
  uLog in 'uLog.pas',
  uPrincipal in 'uPrincipal.pas' {frmPrincipal},
  uWhatsApp in 'uWhatsApp.pas';

{$R *.res}

begin

  If not GlobalCEFApp.StartMainProcess then
     Exit;

  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TbotDAO, botDAO);
  Application.CreateForm(Tdm, dm);
  Application.CreateForm(TfrmPrincipal, frmPrincipal);
  Application.CreateForm(TfrmConfiguracao, frmConfiguracao);
  Application.Run;
end.
