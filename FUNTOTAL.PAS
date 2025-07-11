unit Funtotal;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, Grids, ExtCtrls;

type
  TForm7 = class(TForm)
    Button5: TButton;
    Label12: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    Label15: TLabel;
    RG1: TRadioGroup;
    Bevel1: TBevel;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    Panel5: TPanel;
    Panel6: TPanel;
    Panel7: TPanel;
    StringGrid1: TStringGrid;
    StringGrid2: TStringGrid;
    StringGrid3: TStringGrid;
    StringGrid4: TStringGrid;
    StringGrid5: TStringGrid;
    StringGrid6: TStringGrid;
    StringGrid7: TStringGrid;
    StringGrid8: TStringGrid;
    StringGrid9: TStringGrid;
    StringGrid10: TStringGrid;
    StringGrid11: TStringGrid;
    StringGrid12: TStringGrid;
    StringGrid13: TStringGrid;
    StringGrid14: TStringGrid;
    StringGrid15: TStringGrid;
    StringGrid16: TStringGrid;
    StringGrid17: TStringGrid;
    StringGrid18: TStringGrid;
    StringGrid19: TStringGrid;
    StringGrid20: TStringGrid;
    StringGrid21: TStringGrid;
    StringGrid22: TStringGrid;
    StringGrid23: TStringGrid;
    StringGrid24: TStringGrid;
    StringGrid25: TStringGrid;
    StringGrid26: TStringGrid;
    StringGrid27: TStringGrid;
    StringGrid28: TStringGrid;
    Panel8: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    procedure Button5Click(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure RG1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form7: TForm7;
  Tots:array[0..6,0..10,0..3] of longint;

implementation

{$R *.DFM}


procedure TForm7.Button5Click(Sender: TObject);
begin
   Close;
end;

procedure TForm7.FormActivate(Sender: TObject);
var
   S:string;
   J:longint;
begin
   Panel8.Left:=0;
   for J:=0 to 10 do
      begin
         StringGrid1.Cells[0,J]:=IntToStr(Tots[0,J,0]);
         StringGrid2.Cells[0,J]:=IntToStr(Tots[0,J,1]);
         StringGrid3.Cells[0,J]:=IntToStr(Tots[0,J,2]);
         StringGrid4.Cells[0,J]:=IntToStr(Tots[0,J,3]);
         StringGrid5.Cells[0,J]:=IntToStr(Tots[1,J,0]);
         StringGrid6.Cells[0,J]:=IntToStr(Tots[1,J,1]);
         StringGrid7.Cells[0,J]:=IntToStr(Tots[1,J,2]);
         StringGrid8.Cells[0,J]:=IntToStr(Tots[1,J,3]);
         StringGrid9.Cells[0,J]:=IntToStr(Tots[2,J,0]);
         StringGrid10.Cells[0,J]:=IntToStr(Tots[2,J,1]);
         StringGrid11.Cells[0,J]:=IntToStr(Tots[2,J,2]);
         StringGrid12.Cells[0,J]:=IntToStr(Tots[2,J,3]);
         StringGrid13.Cells[0,J]:=IntToStr(Tots[3,J,0]);
         StringGrid14.Cells[0,J]:=IntToStr(Tots[3,J,1]);
         StringGrid15.Cells[0,J]:=IntToStr(Tots[3,J,2]);
         StringGrid16.Cells[0,J]:=IntToStr(Tots[3,J,3]);
         StringGrid17.Cells[0,J]:=IntToStr(Tots[4,J,0]);
         StringGrid18.Cells[0,J]:=IntToStr(Tots[4,J,1]);
         StringGrid19.Cells[0,J]:=IntToStr(Tots[4,J,2]);
         StringGrid20.Cells[0,J]:=IntToStr(Tots[4,J,3]);
         StringGrid21.Cells[0,J]:=IntToStr(Tots[5,J,0]);
         StringGrid22.Cells[0,J]:=IntToStr(Tots[5,J,1]);
         StringGrid23.Cells[0,J]:=IntToStr(Tots[5,J,2]);
         StringGrid24.Cells[0,J]:=IntToStr(Tots[5,J,3]);
         StringGrid25.Cells[0,J]:=IntToStr(Tots[6,J,0]);
         StringGrid26.Cells[0,J]:=IntToStr(Tots[6,J,1]);
         StringGrid27.Cells[0,J]:=IntToStr(Tots[6,J,2]);
         StringGrid28.Cells[0,J]:=IntToStr(Tots[6,J,3]);
      end;
   Panel1.Visible:=true;
   Panel2.Visible:=false;
   Panel3.Visible:=false;
   Panel4.Visible:=false;
   Panel5.Visible:=false;
   Panel6.Visible:=false;
   Panel7.Visible:=false;
end;

procedure TForm7.RG1Click(Sender: TObject);
begin
   with RG1 do
      begin
          Panel1.Visible:=false;
          Panel2.Visible:=false;
          Panel3.Visible:=false;
          Panel4.Visible:=false;
          Panel5.Visible:=false;
          Panel6.Visible:=false;
          Panel7.Visible:=false;
          case Itemindex of
            0:begin
                 Panel1.Visible:=true;
                 Panel8.left:=0;
              end;
            1:begin
                 Panel2.Visible:=true;
                 Panel8.left:=64;
              end;
            2:begin
                 Panel3.Visible:=true;
                 Panel8.left:=128;
              end;
            3:begin
                 Panel4.Visible:=true;
                 Panel8.left:=192;
              end;
            4:begin
                 Panel5.Visible:=true;
                 Panel8.left:=256;
              end;
            5:begin
                 Panel6.Visible:=true;
                 Panel8.left:=320;
              end;
            6:begin
                 Panel7.Visible:=true;
                 Panel8.left:=384;
              end;
          end;
      end;
end;

end.
