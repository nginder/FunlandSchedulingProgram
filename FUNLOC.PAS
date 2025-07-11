unit Funloc;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, DB , Grids, DBGrids, FunGrid, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf,
FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Comp.Client, FireDAC.Stan.Param, FireDAC.DatS,
FireDAC.DApt.Intf, FireDAC.Comp.DataSet, FireDAC.DApt, FireDAC.Phys,
  FireDAC.VCLUI.Wait;

type
  TForm4 = class(TForm)
    DBGrid1: TDBGrid;
    DataSource1: TDataSource;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Query1: TFDQuery;
    procedure Button2Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure Button3Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form4: TForm4;

implementation

{$R *.DFM}

procedure TForm4.Button2Click(Sender: TObject);
{Cancel button}
begin
   LocFlag:=false;
   close;
end;

procedure TForm4.Button1Click(Sender: TObject);
{OK button}
begin
   LocFlag:=true;
   LocLast:=Query1.FieldByName('LAST').AsString;
   LocFirst:=Query1.FieldByName('First').AsString;
   LocId:=Query1.FieldByName('Empnmbr').AsInteger;
   LocShf:=Query1.FieldByName('Shift').AsString;

   close;
end;

procedure TForm4.FormActivate(Sender: TObject);
var
   Flag:boolean;
begin
   if LocId= 0 then
      begin
         Query1.Connection:=Form13.funland;
         Button3.Caption:='Sorted By Last';
         Query1.Close;
         Query1.SQL.Clear;
         Query1.SQL.Add('Select Last,First,Empnmbr,Shift from "Employ.db"');
         if ShfFlag=false then
            Query1.SQL.Add('where Shift=Hourly" or Shift="Fifteen"');
         Query1.SQL.Add('Order by Last,First');
         Query1.Open;
      end
   else with Query1 do
      begin
         Open;
         Flag:=false;
         First;
         repeat
            if LocId=FieldByName('Empnmbr').AsInteger then
               Flag:=true;
            Next;
         until (eof=true) or (Flag=true);
         if (eof=false) and (Flag=true) then
            Prior;
      end;
end;

procedure TForm4.Button3Click(Sender: TObject);
{change sort button}
begin
   Query1.Close;
   Query1.SQL.Clear;
   Query1.SQL.Add('Select Last,First,Empnmbr,Shift from "Employ.db"');
   if ShfFlag=false then
      Query1.SQL.Add('where Shift="Hourly" or Shift="Fifteen"');
   if Button3.Caption='Sorted By Number' then
      begin
         Query1.SQL.Add('Order by Last, First');
         Button3.Caption:='Sorted By Last';
      end
   else if Button3.Caption='Sorted By Last' then
      begin
         Query1.SQL.Add('Order by First,Last');
         Button3.Caption:='Sorted By First';
      end
   else
      begin
         Query1.SQL.Add('Order by Empnmbr');
         Button3.Caption:='Sorted By Number';
      end;

   Query1.Open;
end;

end.
