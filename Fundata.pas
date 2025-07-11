unit Fundata;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Grids, DBGrids, ExtCtrls, DBCtrls, Db ,FunGrid, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf,
FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Comp.Client, FireDAC.Stan.Param, FireDAC.DatS,
FireDAC.DApt.Intf, FireDAC.Comp.DataSet, FireDAC.Comp.BatchMove, FireDAC.Phys,
  FireDAC.VCLUI.Wait, FireDAC.DApt, FireDAC.Phys.ADSWrapper, FireDAC.Phys.ADS;

type
  TForm14 = class(TForm)
    DataSource1: TDataSource;
    DBNavigator1: TDBNavigator;
    DB1: TDBGrid;
    Button1: TButton;
    Button2: TButton;
    DataSource2: TDataSource;
    Button3: TButton;
    BatchMove1: TFDBatchMove;
    Table1: TFDTable;
    Query1: TFDQuery;
    Query2: TFDQuery;
    Table2: TFDTable;
    procedure Button3Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form14: TForm14;

implementation

{$R *.DFM}

procedure TForm14.Button1Click(Sender: TObject);
begin
   Close;
end;

procedure TForm14.FormActivate(Sender: TObject);
begin
   with Form13 do
      begin
         Table1.Connection:=funland;
         Table2.Connection:=funland;
         Query1.Connection:=funland;
         Query2.Connection:=funland;
      end;
   Table1.Active:=true;
   DB1.Height:=Form14.Height-120;
end;

procedure TForm14.FormClose(Sender: TObject; var Action: TCloseAction);
begin
   Table1.Active:=false;
end;

procedure TForm14.Button2Click(Sender: TObject);
{sort employ.db by Shift, Last, First}

begin
     begin
        {use fireDAC to backup employ.db??}
        {Batchmove1.Source:=Table1;
        {Batchmove1.Destination:=Table2;
        {Batchmove1.Execute;
        with Query1 do
           begin
              close;
              Sql.Clear;
              Sql.Add('select * from "employ.db" ');
              Sql.Add('where Shift= "Hourly" or Shift="Fifteen" ');
              Sql.Add('order by Last, First');
              Open;
           end;
        with Query2 do
           begin
              close;
              Sql.Clear;
              Sql.Add('select * from "employ.db" ');
              Sql.Add('where Shift= "Special" or Shift="TheFamily" or Shift="XEmployee"');
              Sql.Add('order by Last, First');
              Open;
           end;
         Table1.Active:=false;
         Table1.EmptyTable;
         BatchMove1.Source:=Query1;
         BatchMove1.Destination:=Table1;
         BatchMove1.Mode:=dmAppend;
         BatchMove1.Execute;
         BatchMove1.Source:=Query2;
         BatchMove1.Execute;
         Table1.Active:=true;             }
     end;
end;

procedure TForm14.Button3Click(Sender: TObject);
{sort employ.db by Number, Last, First}
begin
   {use fireDAC to backup employ.db??}
   {Batchmove1.Source:=Table1;
   {Batchmove1.Destination:=Table2;
   Batchmove1.Execute;
   with Query1 do
      begin
         close;
         Sql.Clear;
         Sql.Add('select * from "employ.db" ');
         Sql.Add('order by Empnmbr');
         Open;
      end;
   Table1.Active:=false;
   Table1.EmptyTable;
   BatchMove1.Source:=Query1;
   BatchMove1.Destination:=Table1;
   BatchMove1.Mode:=dmAppend;
   BatchMove1.Execute;
   Table1.Active:=true;}
end;

end.
