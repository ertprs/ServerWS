unit ubotDAO;

interface

uses
  System.SysUtils, System.Classes, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool,
  FireDAC.Stan.Async, FireDAC.Phys, FireDAC.VCLUI.Wait, FireDAC.Phys.FBDef, FireDAC.Phys.IBBase, FireDAC.Phys.FB, FireDAC.Comp.UI, Data.DB, FireDAC.Comp.Client,
  FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt, FireDAC.Comp.DataSet;

type
  TbotDAO = class(TDataModule)
    conexaoBDG: TFDConnection;
    FDGUIxWaitCursor1: TFDGUIxWaitCursor;
    FDPhysFBDriverLink1: TFDPhysFBDriverLink;
    qryP2PWS: TFDQuery;
    procedure DataModuleCreate(Sender: TObject);
  private
    FNumeroPedido: String;
    FIdPedido: String;
    FEmpresa: String;
    procedure SetNumeroPedido(const Value: String);
    procedure SetIdPedido(const Value: String);
    procedure SetEmpresa(const Value: String);
    { Private declarations }
  public
    { Public declarations }
    function registrarPedidoConfirmado : String;
    function registrarPedidoNegado : String;
    function validaPedido(AContato: String): Boolean;
    function Mask(Mascara, Str : string) : string;


    property NumeroPedido : String read FNumeroPedido write SetNumeroPedido;
    property IdPedido     : String read FIdPedido     write SetIdPedido;
    property Empresa      : String read FEmpresa      write SetEmpresa;
  end;

var
  botDAO: TbotDAO;

implementation

uses
  uTInject.Emoticons, System.AnsiStrings, Vcl.Dialogs;

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

{ TbotDAO }

function TbotDAO.Mask(Mascara, Str : string) : string;
var
    x, p : integer;
begin
    p := 0;
    Result := '';

    if Str.IsEmpty then
        exit;

    for x := 0 to Length(Mascara) - 1 do
    begin
        if Mascara.Chars[x] = '#' then
        begin
            Result := Result + Str.Chars[p];
            inc(p);
        end
        else
            Result := Result + Mascara.Chars[x];

        if p = Length(Str) then
            break;
    end;
end;


procedure TbotDAO.DataModuleCreate(Sender: TObject);
begin
FDPhysFBDriverLink1.VendorHome := ExtractFileDir(GetCurrentDir);
end;

function TbotDAO.registrarPedidoConfirmado : String;
begin

     Try
         with qryP2PWS do
             begin
                 Close;
                 Sql.Clear;
                 Sql.Add('UPDATE P2PWS SET');
                 Sql.Add('RESPPWS = ''T'',');
                 Sql.Add('DTRECPWS = :DATARECEBIMENTO');
                 Sql.Add('WHERE IDPEDPWS = ' + QuotedStr(IdPedido));
                 ParamByName('DATARECEBIMENTO').AsDateTime := Now;
                 ExecSql;

                 Close;
                 Sql.Clear;
                 Sql.Add('UPDATE P3PCR SET');
                 Sql.Add('STATUS = ' + QuotedStr('AGUARDANDO'));
                 Sql.Add('WHERE IDPCR = ' + IdPedido);
                 ExecSql;

                 Result := TInjectEmoticons.AtendenteM +
                          'O pedido *' + NumeroPedido + '* foi confirmado com sucesso! \n\n' +
                          TInjectEmoticons.LoiraAteLogo + ' *Até logo!*';
              end;
     Except
           on E:Exception do
              begin
                  Result := TInjectEmoticons.LoiraMaoNoRosto +
                           'Não foi possivel confirmar o pedido, comunique a ' + Empresa + ' e informe a mensagem abaixo. \n\n' +
                           E.Message;
              end;
     End;

end;

function TbotDAO.registrarPedidoNegado : String;
begin
     Try
         with qryP2PWS do
             begin
                 Close;
                 Sql.Clear;
                 Sql.Add('UPDATE P2PWS SET');
                 Sql.Add('RESPPWS = ''F''');
                 Sql.Add('WHERE IDPEDPWS = ' + QuotedStr(IdPedido));
                 ExecSql;
                 Result := TInjectEmoticons.AtendenteM +
                          'O pedido *' + NumeroPedido + '* foi negado por este motivo ele será cancelado! \n\n'+
                          '*Até logo!*';
              end;
     Except
           on E:Exception do
              begin
                  Result := TInjectEmoticons.LoiraMaoNoRosto +
                           'Não foi possivel cancelar o pedido, comunique a ' + Empresa + ' e informe a mensagem abaixo. \n\n' +
                           E.Message;
              end;
     End;
end;


procedure TbotDAO.SetEmpresa(const Value: String);
begin
  FEmpresa := Value;
end;

procedure TbotDAO.SetIdPedido(const Value: String);
begin
  FIdPedido := Value;
end;

procedure TbotDAO.SetNumeroPedido(const Value: String);
begin
  FNumeroPedido := Value;
end;


function QueryToLog(Q: TFDQuery): string;
var
  i: Integer;
  r: string;
begin
  Result := Q.SQL.Text;
  for i := 0 to Q.Params.Count - 1 do
  begin
    case Q.Params.Items[i].DataType of
      ftString, ftDate, ftDateTime: r := QuotedStr(Q.Params[i].AsString);
    else
      r := Q.Params[i].AsString;
    end;
    Result := ReplaceText(Result, ':' + Q.Params.Items[i].Name, r);
  end;
end;

function TbotDAO.validaPedido(AContato: String): Boolean;
var
S,AFone : String;
begin

     AFone :=  StringReplace(Copy(AContato, 3, Length(AContato)), '@c.us','',[rfReplaceAll]);

     With qryP2PWS do
          begin
              Close;
              Sql.Clear;
              Sql.Add('SELECT * FROM P2PWS');
              Sql.Add('WHERE (FONEPWS = ' + QuotedStr(AFone) + ') AND (RESPPWS IS NULL)');
              Open;
          end;

      qryP2PWS.First;
      if qryP2PWS.RecordCount = 0 then
         begin
              Result := False;
              NumeroPedido := '0';
         end
      else
         begin
              Result := True;
              NumeroPedido := Mask('###.###/##', qryP2PWS.FieldByName('NRPEDPWS').AsString);
              IdPedido     := qryP2PWS.FieldByName('IDPEDPWS').AsString;
         end;
end;

end.
