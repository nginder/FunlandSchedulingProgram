unit Funmain;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, FunEmp, FunSheet, FunTime, Fundata,
  Funsched,FunGrid, FunConfig, jpeg, ExtCtrls, DB, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS,FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Stan.Async,FireDAC.Comp.DataSet, FireDAC.Comp.Client;

type
  TForm1 = class(TForm)
    Query1: TFDQuery;
    Image1: TImage;
    Panel1: TPanel;
    Label8: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    Button4: TButton;
    Button5: TButton;
    Button2: TButton;
    Label2: TLabel;
    Button1: TButton;
    procedure Label2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  First_Time_Flag:boolean;


implementation



{$R *.DFM}

procedure TForm1.Button1Click(Sender: TObject);
   {Start employee information form}
begin
   Form2.ShowModal;
end;

procedure TForm1.Button4Click(Sender: TObject);
{exit program}
begin
   close;
end;


procedure TForm1.Button2Click(Sender: TObject);
   {Start button for time sheets/scheduling}
begin
   Form5.showmodal;
   if Newfile<>'' then with Form6 do
      begin
         Day1.Caption:=DateToStr(NewDate)+Chr(13)+Chr(10)+ShortDayNames[DayOfWeek(NewDate)]+'  Mode: '+IntToStr(ModArray[1]);
         Day2.Caption:=DateToStr(NewDate+1)+Chr(13)+Chr(10)+ShortDayNames[DayOfWeek(NewDate+1)]+'  Mode: '+IntToStr(ModArray[2]);
         Day3.Caption:=DateToStr(NewDate+2)+Chr(13)+Chr(10)+ShortDayNames[DayOfWeek(NewDate+2)]+'  Mode: '+IntToStr(ModArray[3]);
         Day4.Caption:=DateToStr(NewDate+3)+Chr(13)+Chr(10)+ShortDayNames[DayOfWeek(NewDate+3)]+'  Mode: '+IntToStr(ModArray[4]);
         Day5.Caption:=DateToStr(NewDate+4)+Chr(13)+Chr(10)+ShortDayNames[DayOfWeek(NewDate+4)]+'  Mode: '+IntToStr(ModArray[5]);
         Day6.Caption:=DateToStr(NewDate+5)+Chr(13)+Chr(10)+ShortDayNames[DayOfWeek(NewDate+5)]+'  Mode: '+IntToStr(ModArray[6]);
         Day7.Caption:=DateToStr(NewDate+6)+Chr(13)+Chr(10)+ShortDayNames[DayOfWeek(NewDate+6)]+'  Mode: '+IntToStr(ModArray[7]);
         form6.showmodal;
      end
   else Close;
end;

procedure TForm1.Button5Click(Sender: TObject);
{run funconfig}
begin
   Form10.ShowModal;
end;

procedure TForm1.FormActivate(Sender: TObject);
begin
   if First_Time_Flag=true then
      begin
         Do_Initial_File_Check;
         First_Time_Flag:=false;
         FillTimeGrids;
      end;
   Button1.Enabled:=true;
   Button2.Enabled:=true;
   Button5.Enabled:=true;
   Button4.Enabled:=true;
   ShfFlag:=true;
   OverFlag:=false;
   LocId:=0;
   GetDates;
   Button2.SetFocus;
   CurMood:=99;  {first time into Form22, TimeEntry will produce new setup}
end;

procedure TForm1.FormCreate(Sender: TObject);

begin
   Form1.Height:=Screen.Height;
   Form1.Width:=Screen.Width;
   Image1.Height:=ClientHeight;
   Image1.Width:=ClientWidth;
   Panel1.Top:=(ClientHeight-Panel1.Height) div 2;
   Panel1.Left:=(ClientWidth-Panel1.Width) div 2;
   First_Time_Flag:=true;
end;

procedure TForm1.Label2Click(Sender: TObject);
{run Fundata form by clicking version number label}
begin
   Form14.ShowModal;
end;

end.
