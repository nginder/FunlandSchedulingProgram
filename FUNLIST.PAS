unit Funlist;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, Grids, DBGrids, DB , StdCtrls, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf,
FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Comp.Client, FireDAC.Stan.Param, FireDAC.DatS,
FireDAC.DApt.Intf, FireDAC.Comp.DataSet;

type
  TForm8 = class(TForm)
clock : TFDConnection;
    Query1: TFDQuery;
    DataSource1: TDataSource;
    DBGrid1: TDBGrid;
    Table1: TFDTable;
    Button2: TButton;
    procedure FormActivate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form8: TForm8;

implementation

{$R *.DFM}

procedure TForm8.FormActivate(Sender: TObject);
begin
   Query1.Close;
   Query1.SQL.Clear;
   {Query1.SQL.Add('select * from employ96 union 19970221 on  employ96.empnmbr=19970221.id');}
   Query1.ExecSQL;
end;

end.
