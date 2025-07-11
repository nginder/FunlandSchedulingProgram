unit Fungroups;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, FunGrid, System.UITypes;

type
  TForm21 = class(TForm)
    RG1: TRadioGroup;
    Button1: TButton;
    RG2: TRadioGroup;
    RG3: TRadioGroup;
    RG4: TRadioGroup;
    RG5: TRadioGroup;
    RG6: TRadioGroup;
    RG7: TRadioGroup;
    Button2: TButton;
    Button3: TButton;
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form21: TForm21;
  Formset: TFormatSettings;

implementation

{$R *.dfm}

procedure TForm21.Button1Click(Sender: TObject);
{cancel button without saving changes}
begin
   Close;
end;

procedure TForm21.FormActivate(Sender: TObject);
{intialize item indices for RG boxes from 'C' record}
begin
   RG1.Caption:=Formset.ShortDayNames[DayOfWeek(NewDate)];
   RG2.Caption:=Formset.ShortDayNames[DayOfWeek(NewDate+1)];
   RG3.Caption:=Formset.ShortDayNames[DayOfWeek(NewDate+2)];
   RG4.Caption:=Formset.ShortDayNames[DayOfWeek(NewDate+3)];
   RG5.Caption:=Formset.ShortDayNames[DayOfWeek(NewDate+4)];
   RG6.Caption:=Formset.ShortDayNames[DayOfWeek(NewDate+5)];
   RG7.Caption:=Formset.ShortDayNames[DayOfWeek(NewDate+6)];
end;

procedure TForm21.Button3Click(Sender: TObject);
{Change all modes to Day One}
begin
   with Form21 do
      begin
         RG2.ItemIndex:=RG1.ItemIndex;
         RG3.ItemIndex:=RG1.ItemIndex;
         RG4.ItemIndex:=RG1.ItemIndex;
         RG5.ItemIndex:=RG1.ItemIndex;
         RG6.ItemIndex:=RG1.ItemIndex;
         RG7.ItemIndex:=RG1.ItemIndex;
      end;
end;

procedure TForm21.Button2Click(Sender: TObject);
{save daily mode changes to weekly file}
var
   I:integer;
   S:string;
begin
   S:='Are you sure you want to save mode changes?';
   if MessageDlg(S,mtConfirmation,[mbYes,mbNo],0)= mrYes then
      begin
         ModArray[1]:=RG1.ItemIndex;
         ModArray[2]:=RG2.ItemIndex;
         ModArray[3]:=RG3.ItemIndex;
         ModArray[4]:=RG4.ItemIndex;
         ModArray[5]:=RG5.ItemIndex;
         ModArray[6]:=RG6.ItemIndex;
         ModArray[7]:=RG7.ItemIndex;
         S:='       ';
         for I:=7 downto 1 do
            S:=IntToStr(ModArray[I])+S;
         SetMode(S);
         ModeChangeFlag:=true;
      end;
   Close;
end;

end.
