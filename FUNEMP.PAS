unit Funemp;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, ExtCtrls, Mask, DBCtrls, DB , System.UITypes,
  Funloc, FunGrid, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Comp.Client, FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.Comp.DataSet,
  FireDAC.Phys, FireDAC.VCLUI.Wait, FireDAC.DApt;

type
  TForm2 = class(TForm)
    Panel1: TPanel;
    Button2: TButton;
    Button1: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Button7: TButton;
    Button8: TButton;
    DataSource1: TDataSource;
    Last: TDBEdit;
    First: TDBEdit;
    MI: TDBEdit;
    AL1: TDBEdit;
    AL2: TDBEdit;
    CSZ: TDBEdit;
    Shift: TDBComboBox;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label1: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Panel2: TPanel;
    StaAmt: TDBEdit;
    FedAmt: TDBEdit;
    Salary: TDBEdit;
    Payrate: TDBEdit;
    FedWith: TDBEdit;
    StaWith: TDBEdit;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    Label15: TLabel;
    Label16: TLabel;
    Label17: TLabel;
    Label18: TLabel;
    Label19: TLabel;
    Label20: TLabel;
    FICA: TDBEdit;
    Label21: TLabel;
    Label22: TLabel;
    Status: TDBComboBox;
    Label23: TLabel;
    Label24: TLabel;
    DBText1: TDBText;
    Bevel1: TBevel;
    Label8: TLabel;
    SName: TDBEdit;
    Fullname: TDBEdit;
    SocSec: TDBEdit;
    Phone: TDBEdit;
    DOB: TDBEdit;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    Button6: TButton;
    Table1: TFDTable;
    Query1: TFDQuery;
    procedure Button6Click(Sender: TObject);
    procedure ShiftDrawItem(Control: TWinControl; Index: Integer; Rect: TRect;
      State: TOwnerDrawState);
    procedure CheckBox1Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button8Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormActivate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form2: TForm2;

implementation

uses Fundata, FunNew, funlock;

{$R *.DFM}

function CheckData:boolean;
{check birthdate and shift}
var
   Flag,CFlag:boolean;
   S,NewShf:string;
   BDate:TDateTime;
   I:integer;
begin
   with Form2 do
      begin
         Flag:=false;
         CFlag:=true;
         S:=Copy(Shift.Items[Shift.Itemindex],1,1);
         if (S='H') or (S='M') or (S='F') then
            begin
               if DOB.Text='' then
                  begin
                     S:='Please enter birthdate first before assigning shift.';
                     I:=MessageDlg(S,mtWarning,[mbOk],0);
                     CFlag:=false;
                  end
              else
                 begin
                    BDate:=StrToDate(DOB.Text);
                    if BDate>FourteenYearsOld then
                       begin   {here if less than 14}
                          S:='This person is currently too young to work at Funland'+#10+'Please change birthdate or change shift to "Special".';
                          I:=MessageDlg(S,mtWarning,[mbOk],0);
                          CFlag:=false;
                       end
                    else if BDate>SixteenYearsOld then
                       begin   {here if 14-15 and wrong Shf}
                          if S<>'F' then
                             begin
                                Flag:=true;
                                NewShf:='Fifteen';
                             end;
                       end
                    else if (BDate<=SixteenYearsOld)and (BDate>EighteenYearsOld) then
                       begin   {here if 16-17 and wrong Shf}
                          if S<>'M' then
                             begin
                                Flag:=true;
                                NewShf:='Minor';
                             end;
                       end
                    else if (BDate<EighteenYearsOld) and (S<>'H') then
                       begin {here 18+ and wrong Shf}
                          Flag:=true;
                          NewShf:='Hourly';
                       end;
                    if Flag=true then
                       begin
                          S:='Based on entered birthdate, '+NewShf+' is the correct shift!'+#10+'Please change birthdate or shift.';
                          I:=MessageDlg(S,mtwarning,[mbOk],0);
                          CFlag:=false;
                       end;
                 end;
            end;
         CheckData:=CFlag;
      end;
end;

procedure TForm2.Button1Click(Sender: TObject);
   {Exit button}
begin
   if CheckData=true then Close;
end;

procedure TForm2.Button4Click(Sender: TObject);
   {Previous Button}
begin
  if CheckData=true then
   with Table1 do
      begin
        Prior;
        if (FieldByName('Int').AsString<>upcase('Y')) then
           CheckBox1.Checked:=false
        else CheckBox1.Checked:=true;
        if (FieldByName('W11').AsString<>upcase('Y')) then
           CheckBox2.Checked:=false
        else CheckBox2.Checked:=true;
      end;
end;

procedure TForm2.Button3Click(Sender: TObject);
   {Next Button}
begin
  if CheckData=true then
   with Table1 do
      begin
        Next;
        if (FieldByName('Int').AsString<>upcase('Y')) then
           CheckBox1.Checked:=false
        else CheckBox1.Checked:=true;
        if (FieldByName('W11').AsString<>upcase('Y')) then
           CheckBox2.Checked:=false
        else CheckBox2.Checked:=true;
      end;
end;

procedure TForm2.Button5Click(Sender: TObject);
   {Locate button}
var
   Foun:boolean;
begin
 if CheckData=true then
  begin
   LocFlag:=false;
   Form4.ShowModal;
   Form4.Query1.Close;
   if LocFlag=true then with Table1 do
      begin
         First;
         Foun:=false;
         repeat
           if (FieldByName('Last').AsString=LocLast)
              and (FieldByName('First').AsString=LocFirst) then
              Foun:=true;
           if Foun=false then Next;
         until (EOF=true) or (Foun=true);
      end;
   if (Table1.FieldByName('Int').AsString<>upcase('Y')) then
      CheckBox1.Checked:=false
   else CheckBox1.Checked:=true;
   if (Table1.FieldByName('W11').AsString<>upcase('Y')) then
           CheckBox2.Checked:=false
        else CheckBox2.Checked:=true;
  end;
end;

procedure TForm2.Button8Click(Sender: TObject);
{undo button}
begin
   Table1.Cancel;
end;

procedure TForm2.Button2Click(Sender: TObject);
   {New button}
begin
 if CheckData=true then
  begin
   form15.Showmodal;
   if Conflag=true then with Table1 do
      begin
         Last;
         Edit;
         Append;
         FieldByName('Empnmbr').AsInteger:=NewNum;
         FieldByName('ECode').AsString:=IntToStr(NewNum);
         FieldByName('Last').AsString:=Form15.Last.Text;
         FieldByName('First').AsString:=Form15.First.Text;
         {if I<100 then
            Table1.FieldByName('ECode').AsString:=' '+Table1.FieldByName('ECode').AsString;
         if I<10 then
            Table1.FieldByName('ECode').AsString:='  '+Table1.FieldByName('ECode').AsString;}
         Table1.Post;
         CheckBox1.Checked:=false;
      end;
  end;
end;

procedure TForm2.FormClose(Sender: TObject; var Action: TCloseAction);
begin
   try
      Table1.Edit;
      Table1.Post;
      Table1.Close;
   finally
   end;
end;

procedure TForm2.FormActivate(Sender: TObject);
begin
   Table1.Connection:=Form13.funland;
   EmpTrainNum:=0;
   with Table1 do
      begin
        Open;
        if (FieldByName('Int').AsString<>upcase('Y')) then
           CheckBox1.Checked:=false
        else CheckBox1.Checked:=true;
        if (FieldByName('W11').AsString<>upcase('Y')) then
           CheckBox2.Checked:=false
        else CheckBox2.Checked:=true;
      end;
end;

procedure TForm2.CheckBox1Click(Sender: TObject);
begin
   with Table1 do
      begin
         Edit;
         if CheckBox1.Checked=true then
            FieldByName('Int').AsString:='Y'
         else FieldByName('Int').AsString:='';
         if Checkbox2.Checked=true then
            FieldByName('W11').AsString:='Y'
        else FieldByName('W11').AsString:='';
         Post;
      end;
end;

procedure TForm2.ShiftDrawItem(Control: TWinControl; Index: Integer;
  Rect: TRect; State: TOwnerDrawState);
  {Display shift in Shift list box in proper color}
  {Shift colors are constants found in FunGrid unit}
var
   S:string;
begin
   with Shift do
      begin
         S:=Shift.Items[Index];
         Canvas.Font.Color := clWhite;
         Canvas.Font.Style:=[fsBold];
         if Pos('Hourly',S)>0 then
           Canvas.Brush.Color := HourlyColor
         else if Pos('Minor',S)>0 then
           Canvas.Brush.Color := MinorColor
         else if Pos('Special',S)>0 then
           Canvas.Brush.Color:=SpecialColor
         else if Pos('Fifteen',S)>0 then
           Canvas.Brush.Color:=FifteenColor
         else if Pos('TheFamily',S)>0 then
            begin
               Canvas.Brush.Color := FamColor;
               S:='Family';
            end
         else if Pos('XEmployee',S)>0 then
            begin
               Canvas.Brush.Color := ExEmpColor;
               S:='Exemployee';
            end;
         Canvas.FillRect(Rect);
         Canvas.TextOut(Rect.Left,Rect.Top,S);
      end;
end;

procedure TForm2.Button6Click(Sender: TObject);
{training button}
begin
 if CheckData=true then
  begin
   with Table1 do
      begin
          EmpTrainNum:=FieldByName('Empnmbr').AsInteger;
      end;
   Form17.ShowModal;
  end;
end;

end.
