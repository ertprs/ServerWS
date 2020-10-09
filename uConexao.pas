unit uConexao;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls,
  System.IniFiles, uDM;

type
  TfrmConfiguracao = class(TForm)
    Button1: TButton;
    edtPorta: TEdit;
    Label1: TLabel;
    Bevel1: TBevel;
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmConfiguracao: TfrmConfiguracao;
  AIniFile : TIniFile;

implementation

{$R *.dfm}

uses uPrincipal;

procedure TfrmConfiguracao.Button1Click(Sender: TObject);
begin

    try
        AIniFile := TIniFile.Create(GetCurrentDir + '\CONFIG.ini');

        AIniFile.WriteInteger('WHATSAPP','PORTA',StrToInt(edtPorta.Text));
        gPorta := StrToInt(edtPorta.Text);
        frmPrincipal.RESTServicePooler.ServicePort := gPorta;
        frmPrincipal.lblMensagem.Caption := 'Porta de conexão: ' + gPorta.ToString;
    finally
        AIniFile.Free;
        Close;
    end;
end;

procedure TfrmConfiguracao.FormCreate(Sender: TObject);
begin
    try
        AIniFile := TIniFile.Create(GetCurrentDir + '\CONFIG.ini');

        edtPorta.Text := AIniFile.ReadInteger('WHATSAPP','PORTA',0).ToString;
    finally
        AIniFile.Free;
    end;
end;

end.
