unit Funsheet;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, Spin, ExtCtrls, Grids, Calendar, Mask, FileCtrl,
  FunGrid, FunFill, ComCtrls , DB, System.UITypes;

type
  TForm5 = class(TForm)
    Button2: TButton;
    Label2: TLabel;
    Panel3: TPanel;
    LB1: TListBox;
    Panel1: TPanel;
    Button1: TButton;
    Panel2: TPanel;
    Panel4: TPanel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Panel5: TPanel;
    Label7: TLabel;
    LB2: TListBox;
    SpinButton2: TSpinButton;
    Calendar1: TCalendar;
    procedure SpinButton2DownClick(Sender: TObject);
    procedure SpinButton2UpClick(Sender: TObject);
    procedure Calendar1Change(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure LB1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);

  private
    { Private declarations }
  public
    { Public declarations }
    DateStr:String;
  end;

var
  Form5: TForm5;
  Formset:TFormatSettings;


implementation

{$R *.DFM}

procedure FillLB1;
  {fill list box 1 with month/day strings from Form13.List1}
var
   I:longint;
   M,D,Y,S:string;
begin
   with Form5 do
      begin
         LB1.Clear;
         for I:=Form13.List1.Items.Count-1 downto 0 do
            begin
               M:=Copy(Form13.List1.Items[I],6,2);
               D:=Copy(Form13.List1.Items[I],8,2);
               Y:=Copy(Form13.List1.Items[I],2,4);
               S:=M+'/'+D+'/'+Y;
               LB1.Items.Add(S);
            end;
         if LB1.Items.Count>0 then
            begin
               LB1.ItemIndex:=0;
               Panel5.Caption:=LB1.Items[LB1.ItemIndex];
            end
         else Panel5.Caption:='';
         LB1.Refresh;
      end;
end;

procedure TForm5.SpinButton2DownClick(Sender: TObject);
begin
   Calendar1.PrevMonth;
end;

procedure TForm5.SpinButton2UpClick(Sender: TObject);
begin
   Calendar1.NextMonth;
end;

procedure TForm5.Calendar1Change(Sender: TObject);
begin
   with Calendar1 do
      begin
         DateStr:=DateToStr(CalendarDate);
         NewDate:=CalendarDate;
         Panel2.caption:=Formset.LongMonthNames[Month];
         Panel4.caption:=datestr;
      end;
end;

procedure TForm5.FormActivate(Sender: TObject);
begin
   NewFile:='';
   try
      Calendar1.CalendarDate:=StrToDate(DateStr);
   except
      On EConvertError DO;
   end;
   Calendar1.OnChange(Calendar1);  
   FillLB1;
end;

procedure TForm5.Button1Click(Sender: TObject);
   {New Button}
var
   D,M,Y:word;
   S,AddString,Ds,Ms,Ys:string;
   Flag:boolean;
   I:integer;
begin
   Flag:=false;
   DecodeDate(NewDate,Y,M,D);
   Ds:=IntToStr(D);
   if D<10 then Ds:='0'+Ds;
   Ms:=IntToStr(M);
   if M<10 then Ms:='0'+Ms;
   Ys:=IntToStr(Y);
   S:=Ys+Ms+Ds+'.DB';
   with Form13.List1 do
      for I:=1 to Items.Count do if Flag=false then
         if S=Form13.List1.Items[I-1] then
            begin
               Flag:=true;
               MessageDlg('This file already exists!',mterror,[mbOk],0);
            end;
   if Flag=false then
      begin
         AddString:=Ys+Ms+Ds;
         Make_New_Weekly_File(AddString);
         FillLB1;
      end;
end;

procedure TForm5.Button2Click(Sender: TObject);
   {Continue Button}
var
   Y,M,D:word;
   Ys,Ms,Ds:String;
begin
   if Panel5.Caption<>'' then
  begin
   NewDate:=StrToDate(Panel5.Caption);
   {if (NewDate<SchoolEnd-5) or (NewDate>LaborDay) then  
       MaxFifteenHours:=MaxFifteenHoursSchool
    else MaxFifteenHours:=MaxFifteenHoursSeason;}
   if Form5.LB1.Items.Count>0 then
      begin
         DecodeDate(NewDate,Y,M,D);
         Ds:=IntToStr(D);
         if D<10 then Ds:='0'+Ds;
         Ms:=IntToStr(M);
         if M<10 then Ms:='0'+Ms;
         Ys:=IntToStr(Y);
         NewFile:=YS+MS+DS+'.db';
         Nufile:=Newfile;
         OldFile:='';
         OlderFile:='';
         with LB1 do if ItemIndex<Items.Count-1 then
            begin
               OldDate:=StrToDate(Items[ItemIndex+1]);
               OldOffset:=Trunc(NewDate-OldDate);
               DecodeDate(OldDate,Y,M,D);
               Ds:=IntToStr(D);
               if D<10 then Ds:='0'+Ds;
               Ms:=IntToStr(M);
               if M<10 then Ms:='0'+Ms;
               Ys:=IntToStr(Y);
               OldFile:=YS+MS+DS+'.db';
            end;
         with LB1 do if ItemIndex<Items.Count-2 then
            begin
               OlderDate:=StrToDate(Items[ItemIndex+2]);
               OlderOffset:=Trunc(NewDate-OlderDate);
               DecodeDate(OlderDate,Y,M,D);
               Ds:=IntToStr(D);
               if D<10 then Ds:='0'+Ds;
               Ms:=IntToStr(M);
               if M<10 then Ms:='0'+Ms;
               Ys:=IntToStr(Y);
               OlderFile:=YS+MS+DS+'.db';
            end;
         Form13.LB2.Items:=LB1.Items;
         EmpFlag:=true;
         Form13.ShowModal;
      end;
    end;
   Close;
end;

procedure TForm5.LB1Click(Sender: TObject);
begin
   Panel5.Caption:=Form5.LB1.Items[Form5.LB1.ItemIndex];
end;

procedure TForm5.FormCreate(Sender: TObject);
begin
   DateStr:=DateToStr(Now);
end;




end.
