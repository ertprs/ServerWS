unit uLog;

interface

uses
  System.SysUtils;

procedure GravaLog(AValueLog : String);

var
    AArqLog : TextFile;

implementation


procedure GravaLog(AValueLog : String);
begin

    Writeln(AArqLog, FormatDateTime('dd/mm/yyyy hh:mm:ss', Now) + '    '  + AValueLog);

end;

end.
