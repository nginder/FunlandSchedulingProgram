unit Funchoic;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, Grids, Calendar, Spin, StdCtrls , DB, ExtCtrls,
  FileCtrl;

type
  TForm9 = class(TForm)
    Label2: TLabel;
    Panel1: TPanel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Panel2: TPanel;
    SpinButton2: TSpinButton;
    Calendar1: TCalendar;
    Panel4: TPanel;
    Button2: TButton;
    procedure Button2Click(Sender: TObject);
    procedure SpinButton2DownClick(Sender: TObject);
    procedure SpinButton2UpClick(Sender: TObject);
    procedure Calendar1Change(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }

  end;

var
  Form9: TForm9;
  PayStr:string;
  PayRollDate:TDateTime;
  Formset:TFormatSettings;

implementation

{$R *.DFM}

procedure TForm9.Button2Click(Sender: TObject);
   {continue button}
begin
   close;
end;

procedure TForm9.SpinButton2DownClick(Sender: TObject);
begin
   Calendar1.PrevMonth;
end;

procedure TForm9.SpinButton2UpClick(Sender: TObject);
begin
   Calendar1.NextMonth;
end;

procedure TForm9.Calendar1Change(Sender: TObject);
begin
    with Calendar1 do
      begin
         PayStr:=DateToStr(CalendarDate);
         PayRollDate:=CalendarDate;
         Panel2.Caption:=Formset.LongMonthNames[Month];
         Panel4.caption:=PayStr;
      end;
end;

procedure TForm9.FormActivate(Sender: TObject);
begin
   try
      Calendar1.CalendarDate:=StrToDate(PayStr);
   except
      On EConvertError DO;
   end;
   Calendar1.OnChange(Calendar1);
end;

procedure TForm9.FormCreate(Sender: TObject);
begin
   PayStr:=DateToStr(Now);
end;

end.
