unit Funpay;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, Funsheet,Grids, DB , System.UITypes,
  Fungrid, FunChoic, FireDAC.Comp.Client, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf,
FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.Comp.DataSet,
  FireDAC.Phys, FireDAC.VCLUI.Wait, FireDAC.DApt;

type
  TForm11 = class(TForm)
    PayGrid: TStringGrid;
    Button1: TButton;
    Button2: TButton;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Button4: TButton;
    LB1: TListBox;
    SaveCSV1: TSaveDialog;
    Button3: TButton;
    Button5: TButton;
    Query1: TFDQuery;
    Query2: TFDQuery;
    Table1: TFDTable;
    procedure Button5Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure PayGridSelectCell(Sender: TObject; ACol, ARow: Integer;
      var CanSelect: Boolean);
    procedure PayGridDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect;
      State: TGridDrawState);
    procedure Button1Click(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure PayGridSetEditText(Sender: TObject; ACol, ARow: Longint;
      const Value: String);
    procedure Button2Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form11: TForm11;

implementation

{$R *.DFM}

const
   Col1=100;
   Col2=700;
   Col3=910;
   Col4=1120;
   Col5=1330;
   Col6=1540;
   Col7=1750;
   Col8=1960;
   Col9=2170;

var
   Totals:array[1..7] of real;
   Title,OldSelect:string;
   SelectCol,SelectRow:integer;
   DayPay: array[1..7] of real; 

procedure InTime(S:string;var I:Integer);
   {convert 4 byte string HHMM to minutes since midnight}
var
   H,M:integer;
begin
   H:=StrToInt(Copy(S,1,2));
   M:=StrToInt(Copy(S,3,2));
   I:=H*60+M;
end;

procedure TForm11.Button1Click(Sender: TObject);
   {Exit button}
begin
   Close;
end;

Procedure Roundit(var Y:real);
  {round real number Y off to 2 decimal places}
var
   Z:real;
begin
   Z:=Y*100;
   Y:=Int(Z);
   if Frac(Z)>=0.500 then
      Y:=Y+1;
   Y:=Y/100;
end;

procedure ParseHour(Index:longint);
   {parse "Dat" field for times for employee ID=Index}
var
   S,T,Start,Stop,Plus,Break:String;
   Hours,Y,A,B,C,D:real;
   Entries,Count,Sta,Sto,Minutes,Howers:longint;
   Flag:boolean;
   I:integer; {Temp}
begin
   Minutes:=0;
   Hours:=0;
   S:=Form11.Query1.FieldByName('Dat').AsString;
   T:=Form11.Query1.FieldByName('Dut').AsString;
   if S<>'' then
      begin
         Entries:=Length(S) div 14;
         Count:=0;
         Flag:=true;
         repeat
             Plus:=Copy(S,3,1);
             Break:=Copy(T,1,1);
             Start:=Copy(S,4,4);
             Stop:=Copy(S,8,4);
             Delete(S,1,14);
             if (Start<>'9999') and (Stop<>'9999') then
                begin
                   InTime(Start,Sta);
                   InTime(Stop,Sto);
                   Howers:=Sto-Sta;
                   if Sto<Sta then Howers:=Howers+1440;
                   A:=Howers/60;
                   Y:=Form11.Query1.FieldByName('PayRate').AsFloat*A;
                   Roundit(Y);
                   I:=Form11.Query1.FieldByName('DOW').Asinteger;
                   DayPay[I]:=DayPay[I]+Y;
                   Minutes:=Minutes+Sto-Sta;
                   if Sto<Sta then Minutes:=Minutes+1440;
                   if Break='*' then Minutes:=Minutes-BreakMinutes;
                end
             else
                Flag:=false;
             Inc(Count);
         until (Count>=Entries) or (Flag=false);
         if Flag=false then Hours:=0
         else
            begin
               Hours:=Minutes/60;
               Hours:=Round(100*Hours)/100;
            end;
      end;
   try
      S:=Form11.PayGrid.Cells[1,Index];
      if S='' then
         A:=0
      else
         A:=StrToFloat(Form11.PayGrid.Cells[1,Index]);
      Hours:=Hours+A;
   except

   end;
   if Hours<=0 then S:='0.00'
   else
      S:=FormatFloat('#0.00',Hours);
   with Form11.PayGrid do
      begin
         Cells[1,Index]:=S;
         if Hours>0 then
            begin
               Y:=Form11.Query1.FieldByName('PayRate').AsFloat;
               Roundit(Y);
               S:=FormatFloat('#0.00',Y);
               Cells[2,Index]:=S;
               Y:=Form11.Query1.FieldByName('PayRate').AsFloat*Hours;
               Roundit(Y);
               if Y<=0 then
                  S:=''
               else
                  S:=FormatFloat('##0.00',Y);
               Cells[3,Index]:=S;
               A:=Form11.Query1.FieldByName('FICA').AsFloat*Y;
               Roundit(A);
               if A<=0 then
                  S:=''
               else
                  S:=FormatFloat('##0.00',A);
               Cells[4,Index]:=S;
               if B<=0 then
                  S:=''
               else
                  B:=Form11.Query1.FieldByName('FedW').AsFloat*Y;
               Roundit(B);
               if B<=0 then
                  S:=''
               else
                  S:=FormatFloat('##0.00',B);
               Cells[5,Index]:=S;
               C:=Form11.Query1.FieldByName('StaW').AsFloat*Y;
               Roundit(C);
               if C<=0 then
                  S:=''
               else
                  S:=FormatFloat('##0.00',C);
               Cells[6,Index]:=S;
               D:=A+B+C;
               Roundit(D);
               if D<=0 then
                  S:=''
               else
                  S:=FormatFloat('##0.00',D);
               Cells[7,Index]:=S;
               D:=Y-A-B-C;
               Roundit(D);
               if D<=0 then
                  S:=''
               else
                  S:=FormatFloat('##0.00',D);
               Cells[8,Index]:=S;
            end;
      end;
end;

procedure ParseTime;
   {fill string grid with payroll data}
var
   I,J,LastId,ThisId,Count:integer;
begin
   With Form11 do
      begin
         with PayGrid do
            begin
               ColWidths[0]:=115;
               Cells[1,0]:='Hours';
               Cells[2,0]:='Pay Rate';
               Cells[3,0]:='Gross Pay';
               Cells[4,0]:='FICA';
               Cells[5,0]:='Fed With';
               Cells[6,0]:='State With';
               Cells[7,0]:='Total With';
               Cells[8,0]:='Net Pay';
            end;
         Query1.First;
         LastId:=0;
         Count:=0;
         if Query1.RecordCount>0 then with PayGrid do
            for I:=1 to Query1.RecordCount do
               begin
                  ThisId:=Query1.FieldByName('Id').AsInteger;
                  if ThisId<>LastId then
                     begin
                        LastId:=ThisId;
                        Count:=Count+1;
                        for J:=0 to 8 do Cells[J,Count]:='';
                        Cells[0,Count]:=Query1.FieldByName('Last').ASString+', '+Query1.FieldByName('First').ASString;
                        if Query1.FieldByName('W11').AsString=upCase('Y') then
                           Cells[0,Count]:=Cells[0,Count]+'*';
                        Cells[9,Count]:=Query1.FieldByname('Id').AsString;
                     end;
                  ParseHour(Count);
                  Query1.Next;
               end;
         PayGrid.RowCount:=Count+1;
      end;
end;

procedure GetTotals;
   {get totals from paygrid}
var
   H,X,A,B,C,D:real;
   I,J:integer;
   S:string;
begin
   for I:=1 to 7 do Totals[I]:=0;
   with Form11.PayGrid do
      begin
         for I:=1 to RowCount do
            begin
               S:=Cells[1,I];
               Val(S,H,J);
               Totals[1]:=Totals[1]+H;
               S:=Cells[3,I];
               Val(S,X,J);
               Totals[2]:=Totals[2]+X;
               S:=Cells[4,I];
               Val(S,A,J);
               Totals[3]:=Totals[3]+A;
               if A=0 then Totals[7]:=Totals[7]+X;
               S:=Cells[5,I];
               Val(S,B,J);
               Totals[4]:=Totals[4]+B;
               S:=Cells[6,I];
               Val(S,C,J);
               Totals[5]:=Totals[5]+C;
               S:=Cells[8,I];
               Val(S,D,J);
               Totals[6]:=Totals[6]+D;
            end;
      end;
end;

procedure TForm11.FormActivate(Sender: TObject);
var
   I:integer; {Temp}
   S:string;
   D:TDateTime;
begin
   for I:=1 to 7 do DayPay[I]:=0;
   LB1.Visible:=false;
   LB1.Clear;
   Button5.Caption:='Erin';
   if Screen.PixelsPerInch>96 then
      PayGrid.Canvas.Font.Size:=7
   else
      PayGrid.Canvas.Font.Size:=8;
   Label2.Caption:='';
   Label3.Caption:='';
   Label4.Caption:='';
   Label5.Caption:='';
   Label6.Caption:='';
   Label7.Caption:='';
   with Form13 do
      begin
         Query1.Connection:=funland;
         Query2.Connection:=funland;
         Table1.Connection:=funland;
      end;
   Query1.Close;
   Query1.SQL.Clear;
   Query1.SQL.Add('Select Max(Dat)AS MaxDat from "'+Newfile+'"');
   Query1.Sql.Add('where Typ="T"');
   Query1.Open;
   Query1.First;
   S:=copy(NewFile,5,2)+'/'+copy(Newfile,7,2)+'/'+copy(Newfile,1,4);
   D:=StrtoDate(S);
   S:=DateToStr(D);
   Title:='Employee Payroll For '+S;
   D:=StrToDate(S);
   D:=D+Query1.FieldByName('MaxDat').AsInteger-1;
   Title:=Title+' To '+DateToStr(D);
   Form11.Caption:=Title;
   Query1.Close;
   Query1.SQL.Clear;
   Query1.SQL.Add('Select C.Id,C.Last AS Dut,C.Dat AS DOW,C.First AS Dat,D.Last,D.First,');
   Query1.SQL.Add('D.Payrate,D.FICA,D.FedW,D.StaW,D.W11');
   Query1.SQL.Add('from "'+Newfile+'" C, "employ.db" D');
   Query1.SQL.Add('where (C.Shf="H" or C.Shf="F" or C.Shf="S" or C.Shf="M") and C.Id=D.Empnmbr');
   Query1.SQL.Add('and C.Typ="T"');
   Query1.SQL.Add('Order by D.Last,D.First');
   Query1.Open;
   ParseTime;
   Query1.Close;
   GetTotals;
   S:=FormatFloat('###0.00',Totals[1]);
   Label2.Caption:=S;
   S:=FormatFloat('###0.00',Totals[2]);
   Label3.Caption:=S;
   S:=FormatFloat('###0.00',Totals[3]);
   Label4.Caption:=S;
   S:=FormatFloat('###0.00',Totals[4]);
   Label5.Caption:=S;
   S:=FormatFloat('###0.00',Totals[5]);
   Label6.Caption:=S;
   S:=FormatFloat('###0.00',Totals[6]);
   Label7.Caption:=S;
   SelectCol:=1;
   PayGrid.Col:=1;
   SelectRow:=1;
   PayGrid.Row:=1;
   OldSelect:=PayGrid.Cells[1,1];
   PayGrid.Cells[1,1]:=OldSelect;
end;

procedure TForm11.PayGridSetEditText(Sender: TObject; ACol, ARow: Longint;
  const Value: String);
var
   X,A,B,C:real;
   I:integer;
   S:string;

begin
   with PayGrid do
      begin
         Label2.Caption:='';
         Label3.Caption:='';
         Label4.Caption:='';
         Label5.Caption:='';
         Label6.Caption:='';
         Label7.Caption:='';
         Val(Cells[3,ARow],X,I);
         S:=Cells[3,ARow];
         S:=FormatFloat('####.##',X);
         Val(Cells[4,ARow],A,I);
         S:=Cells[4,ARow];
         S:=FormatFloat('####.##',A);
         Val(Cells[5,ARow],B,I);
         S:=Cells[5,ARow];
         S:=FormatFloat('####.##',B);
         Val(Cells[6,ARow],C,I);
         S:=Cells[6,ARow];
         X:=A+B+C;
         S:=FormatFloat('####.##',X);
         Cells[7,ARow]:=S;
         X:=X-A-B-C;
         S:=FormatFloat('####.##',X);
         Cells[8,ARow]:=S;
      end;
   GetTotals;
   S:=FormatFloat('###0.00',Totals[1]);
   Label2.Caption:=S;
   S:=FormatFloat('###0.0',Totals[2]);
   Label3.Caption:=S;
   S:=FormatFloat('###0.00',Totals[3]);
   Label4.Caption:=S;
   S:=FormatFloat('###0.00',Totals[4]);
   Label5.Caption:=S;
   S:=FormatFloat('###0.00',Totals[5]);
   Label6.Caption:=S;
   S:=FormatFloat('###0.00',Totals[6]);
   Label7.Caption:=S;
end;

procedure PrintHeading;
   {print heading for payroll sheet}
var
  J:integer;
begin
   Stile([fsUnderline]);
   Sise(10);
   Textowt(Col1,300,'Name');
   TextWide('Hours',J);
   Textowt(Col2-J,300,'Hours');
   TextWide('Pay Rate',J);
   Textowt(Col3-J,300,'Pay Rate');
   TextWide('Gross',J);
   Textowt(Col4-J,300,'Gross');
   TextWide('Fica',J);
   Textowt(Col5-J,300,'Fica');
   TextWide('FedW',J);
   Textowt(Col6-J,300,'FedW');
   TextWide('StaW',J);
   Textowt(Col7-J,300,'StaW');
   TextWide('TotW',J);
   Textowt(Col8-J,300,'TotW');
   TextWide('Net Pay',J);
   Textowt(Col9-J,300,'Net Pay');
   Stile([]);
end;

procedure PrintTotals(J:integer);
   {print totals for payroll sheet - J is vertical position}
var
   S:string;
   X:integer;
begin
   GetTotals;
   Stile([fsBold]);
   TextOwt(Col1,J,'TOTALS');
   S:=FormatFloat('####.##',Totals[1]);
   TextWide(S,X);
   Textowt(Col2-X,J,S);
   S:=FormatFloat('####.##',Totals[2]);
   TextWide(S,X);
   Textowt(Col4-X,J,S);
   S:=FormatFloat('####.##',Totals[3]);
   TextWide(S,X);
   Textowt(Col5-X,J,S);
   S:=FormatFloat('####.##',Totals[4]);
   TextWide(S,X);
   Textowt(Col6-X,J,S);
   S:=FormatFloat('####.##',Totals[5]);
   TextWide(S,X);
   Textowt(Col7-X,J,S);
   S:=FormatFloat('####.##',Totals[6]);
   TextWide(S,X);
   Textowt(Col9-X,J,S);
   if Totals[7]>0 then
      begin
         J:=J+60;
         S:='(non-FICA)';
         TextOwt(Col1+30,J,S);
         Stile([fsUnderline]);
         S:=FormatFloat('#####.##',Totals[7]);
         TextWide(S,X);
         Textowt(Col4-X,J,S);
         Textowt(Col9-X,J,S);
         Stile([]);
         J:=J+60;
         S:=FormatFloat('####.##',Totals[2]-Totals[7]);
         TextWide(S,X);
         Textowt(Col4-X,J,S);
         S:=FormatFloat('####.##0',Totals[6]-Totals[7]);
         TextWide(S,X);
         Textowt(Col9-X,J,S);
      end;
end;

procedure TForm11.Button2Click(Sender: TObject);
   {print button}
var
   I,J,K,L:integer;
   X:real;
   S,Mess:string;
   Flag,TitleFlag:boolean;
begin
  PXPY;
  Mess:='Ready to print first page of payroll?';
  Flag:=true;
  TitleFlag:=true;
  J:=360;
  I:=1;
  repeat
     if MessageDlg(Mess,mtConfirmation,[mbYes,mbNo],0)= mrNo then
        Flag:=false
     else
        begin
           Begindok;
           if TitleFlag=true then
              begin
                 Stile([fsBold]);
                 Sise(13);
                 S:='Seaside Amusements, Inc';
                 Textowt(150,150,S);
                 Textowt(150,210,Title);
                 TitleFlag:=false;
              end;
           PrintHeading;
           Stile([]);
           repeat
              Val(PayGrid.Cells[3,I],X,K);
              if X>0 then
                 begin
                    TextOwt(Col1,J,PayGrid.Cells[0,I]);
                    Val(PayGrid.Cells[1,I],X,K);
                    S:=FormatFloat('##0.00',X);
                    TextWide(S,L);
                    TextOwt(Col2-L,J,S);
                    Val(PayGrid.Cells[2,I],X,K);
                    S:=FormatFloat('##0.00',X);
                    TextWide(S,L);
                    TextOwt(Col3-L,J,S);
                    Val(PayGrid.Cells[3,I],X,K);
                    S:=FormatFloat('##0.00',X);
                    TextWide(S,L);
                    TextOwt(Col4-L,J,S);
                    Val(PayGrid.Cells[4,I],X,K);
                    S:=FormatFloat('##0.00',X);
                    TextWide(S,L);
                    TextOwt(Col5-L,J,S);
                    Val(PayGrid.Cells[5,I],X,K);
                    S:=FormatFloat('##0.00',X);
                    TextWide(S,L);
                    TextOwt(Col6-L,J,S);
                    Val(PayGrid.Cells[6,I],X,K);
                    S:=FormatFloat('##0.00',X);
                    TextWide(S,L);
                    TextOwt(Col7-L,J,S);
                    Val(PayGrid.Cells[7,I],X,K);
                    S:=FormatFloat('##0.00',X);
                    TextWide(S,L);
                    TextOwt(Col8-L,J,S);
                    Val(PayGrid.Cells[8,I],X,K);
                    S:=FormatFloat('#00.00',X);
                    TextWide(S,L);
                    TextOwt(Col9-L,J,S);
                    J:=J+60;
                 end;
              Inc(I);
           until (J>2840) or (I>PayGrid.RowCount);
           if (I>PayGrid.RowCount) and (J<2660) then
              begin
                 PrintTotals(J);
                 Flag:=false;
              end
           else
              begin
                 Mess:='Ready to print next page of payroll?';
                 J:=360;
              end;
           EndDok;
        end;
  until (Flag=false) or (I>PayGrid.RowCount);
end;

procedure TForm11.Button4Click(Sender: TObject);
   {save button}
var
   S,T:string;
   I,K:integer;
   X:real;

begin
   {S:='PAY'+Copy(Newfile,1,4)+'.DB';
   FDManager.GetTableNames('funland',S,false,false,Lb1.Items);
   if LB1.Items.Count<1 then
      begin
         AddString:='Create table "'+S+'" ';
         with query2 do
            begin
               close;
               sql.clear;
               sql.add(AddString);
               sql.add(' (PayDate Date, Id SmallInt, Hours Numeric,');
               sql.add('Gross Numeric, Fica Numeric, FedW Numeric, StaW Numeric, NetPay Numeric)');
               execsql;
            end;
      end;
   Form9.ShowModal;
   S:='PAY'+Copy(Newfile,1,4)+'.DB';}
   Table1.Close;
   Table1.TableName:=S;
   T:=DateToStr(PayRollDate);
   with Query2 do
      begin
         close;
         SQL.clear;
         SQL.Add('Select * from "'+S+'"');
         SQL.Add('where PayDate="'+T+'"');
         Open;
      end;
   if Query2.RecordCount>0 then
      begin
         S:='Pay data for '+T+ 'already saved!';
         MessageDlg(S,mtWarning,[mbOk],0);
         T:='';
      end;
   if T<>'' then
      begin
         S:='Confirm saving data to Pay Table for '+T+'?';
         if MessageDlg(S,mtConfirmation,[mbYes,mbNo],0)=mrYes then
         with Table1 do
            begin
               Open;
               for I:=1 to PayGrid.RowCount do
                  begin
                     Val(PayGrid.Cells[3,I],X,K);
                     if X>0 then
                        begin
                           Append;
                           FieldByName('PayDate').AsDateTime:=StrToDate(T);
                           FieldByName('Id').AsInteger:=StrToInt(PayGrid.Cells[9,I]);
                           if PayGrid.Cells[1,I]='' then
                              FieldByName('Hours').AsFloat:=0
                           else
                              FieldByName('Hours').AsFloat:=StrToFloat(PayGrid.Cells[1,I]);
                           if PayGrid.Cells[3,I]='' then
                              FieldByName('Gross').AsFloat:=0
                           else
                              FieldByName('Gross').AsFloat:=StrToFloat(PayGrid.Cells[3,I]);
                           if PayGrid.Cells[4,I]='' then
                              FieldByName('Fica').AsFloat:=0
                           else
                              FieldByName('Fica').AsFloat:=StrToFloat(PayGrid.Cells[4,I]);
                           if PayGrid.Cells[5,I]='' then
                              FieldByName('FedW').AsFloat:=0
                           else
                              FieldByName('FedW').AsFloat:=StrToFloat(PayGrid.Cells[5,I]);
                           if PayGrid.Cells[6,I]='' then
                              FieldByName('StaW').AsFloat:=0
                           else
                              FieldByName('StaW').AsFloat:=StrToFloat(PayGrid.Cells[6,I]);
                           if PayGrid.Cells[8,I]='' then
                              FieldByName('NetPay').AsFloat:=0
                           else
                              FieldByName('Netpay').AsFloat:=StrToFloat(PayGrid.Cells[8,I]);
                           Post;
                        end;
                  end;
               Close;
               S:='Data saved to Pay Table for '+T+'.';
               if MessageDlg(S,mtConfirmation,[mbOk],0)=mrOk then
            end;
      end;
   Query2.Close;
end;

procedure TForm11.PayGridDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
var
   S:string;

begin
   with PayGrid do
      begin
          S:=Cells[ACol,ARow];
          if (ACol=SelectCol) and (ARow=SelectRow) then
             Canvas.Brush.Color:=clSkyBlue
          else Canvas.Brush.Color:=clWindow;
          Canvas.FillRect(Rect);
          if ACol>0 then
             begin
                if ARow>0 then
                   Canvas.TextOut(Rect.Right-Canvas.TextWidth(S)-2,Rect.Top,S)
                else
                   Canvas.TextOut(Rect.Left+((DefaultColWidth-Canvas.TextWidth(S)) div 2),Rect.Top,S);
             end
          else
              begin
                 Canvas.TextOut(Rect.Left+3,Rect.Top,S);
              end;
      end;
end;

procedure TForm11.PayGridSelectCell(Sender: TObject; ACol, ARow: Integer;
  var CanSelect: Boolean);
var
   S:string;
   Test:real;
begin
   with PayGrid do
      begin
         if (ACol<>SelectCol) or (ARow<>SelectRow) then
            begin
               S:=Cells[SelectCol,SelectRow];
               try
                  Test:=STrToFloat(S);
               except
                  On Econverterror do
                     Cells[SelectCol,SelectRow]:=OldSelect;
               end;
               Cells[SelectCol,SelectRow]:=S;
               SelectCol:=ACol;
               SelectRow:=ARow;
               OldSelect:=Cells[SelectCol,SelectRow];
               Cells[SelectCol,SelectRow]:=OldSelect;
            end;
      end;
end;

procedure TForm11.Button3Click(Sender: TObject);
{create and save csv payroll data file}

var
  A: file;
  S,Fn,T:string;
  I,J:integer;

begin
   with SaveCSV1 do
      begin
         Execute();
         S:=Filename;
         Assignfile(A,Fn);
         Rewrite(A);
      end;
   with form11.Paygrid do
      begin
         with Form11.PayGrid do
         for I:=0 to RowCount do
            begin
               T:='"'+Cells[0,I]+'"';
               for J:=1 to 6 do T:=T+','+Cells[J,I];
               writeln(Fn,T)
            end;
          closefile(A);
      end;
end;

procedure TForm11.Button5Click(Sender: TObject);
{'Erin' button to show pay totals by day of week in LB1}
var
   I:integer;
   S:string;
begin
   if Button5.Caption='Erin'then
      begin
         Button5.Caption:='Erin Off';
         for I:=1 to 7 do
            begin
               S:='Day'+InttoStr(I)+' = '+FloatToStr(DayPay[I]);
               LB1.AddItem(S,nil);
            end;
         LB1.Visible:=true;
      end
   else
       begin
          Button5.Caption:='Erin';
          LB1.Visible:=false;
          LB1.Clear;
       end;
end;

end.
