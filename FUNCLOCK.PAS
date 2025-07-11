unit funclock;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls, System.UITypes,
  Forms, Dialogs, StdCtrls, ExtCtrls, FileCtrl, DB , FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf,
FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Comp.Client, FireDAC.Stan.Param, FireDAC.DatS,
FireDAC.DApt.Intf, FireDAC.Comp.DataSet;

type
  Tform12 = class(TForm)
funland : TFDConnection;
    Panel3: TPanel;
    Label1: TLabel;
    Label7: TLabel;
    LB1: TListBox;
    Panel5: TPanel;
    Label2: TLabel;
    FileListBox1: TFileListBox;
    Button2: TButton;
    RG1: TRadioGroup;
    Label3: TLabel;
    Button1: TButton;
    Button3: TButton;
    Button4: TButton;
    Query1: TFDQuery;
    Table1: TFDTable;
    Query2: TFDQuery;
    procedure FormActivate(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure LB1Click(Sender: TObject);
    procedure FileListBox1Change(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure RG1Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  form12: Tform12;
  ClockDate:TDateTime;
  ClockFile:string;
  Times:array[1..12] of longint;

implementation

{$R *.DFM}

procedure FillLB1;
  {fill list box 1 with month/day strings from FileListbox1}
var
   I:longint;
   M,D,Y,S:string;
begin
   with Form12 do
      begin
         LB1.Clear;
         for I:=FileListBox1.Items.Count-1 downto 0 do
            begin
               M:=Copy(FileListBox1.Items[I],5,2);
               D:=Copy(FileListBox1.Items[I],7,2);
               Y:=Copy(FileListBox1.Items[I],3,2);
               S:=M+'/'+D+'/'+Y;
               LB1.Items.Add(S);
            end;
         if LB1.Items.Count>0 then
            begin
               LB1.ItemIndex:=0;
               Panel5.Caption:=LB1.Items[LB1.ItemIndex];
            end;
         LB1.Refresh;
      end;
end;

procedure Tform12.FormActivate(Sender: TObject);
var
   Y,M,D:word;
   S:string;
begin
   ClockFile:='';
   DecodeDate(Now,Y,M,D);
   S:=IntToStr(Y)+'*.db';
   FileListBox1.Directory:='C:\Funland';
   FileListBox1.Mask:=S;
   RG1.Items.Clear;
   RG1.Enabled:=false;
   Button1.Enabled:=false;
   Button3.Enabled:=false;
end;

procedure Tform12.Button2Click(Sender: TObject);
   {Continue}
var
   Y,M,D:word;
   Ys,Ms,Ds,S:String;
begin
   ClockDate:=StrToDate(Panel5.Caption);
   if Form12.LB1.Items.Count>0 then
      begin
         DecodeDate(ClockDate,Y,M,D);
         Ds:=IntToStr(D);
         if D<10 then Ds:='0'+Ds;
         Ms:=IntToStr(M);
         if M<10 then Ms:='0'+Ms;
         Ys:=IntToStr(Y);
         ClockFile:=YS+MS+DS+'.db';
         with RG1 do
            begin
               Items.Clear;
               S:=DateToStr(ClockDate);
               Items.Add(S);
               S:=DateToStr(ClockDate+1);
               Items.Add(S);
               S:=DateToStr(ClockDate+2);
               Items.Add(S);
               S:=DateToStr(ClockDate+3);
               Items.Add(S);
               S:=DateToStr(ClockDate+4);
               Items.Add(S);
               S:=DateToStr(ClockDate+5);
               Items.Add(S);
               S:=DateToStr(ClockDate+6);
               Items.Add(S);
               Enabled:=true;
            end;
      end;
end;

procedure Tform12.LB1Click(Sender: TObject);
begin
     Panel5.Caption:=Form12.LB1.Items[Form12.LB1.ItemIndex];
end;

procedure Tform12.FileListBox1Change(Sender: TObject);
begin
   FillLB1;
   if Form12.LB1.Items.Count>0 then
      Panel5.Caption:=Form12.LB1.Items[Form12.LB1.ItemIndex];
end;

procedure Tform12.Button4Click(Sender: TObject);
   {Cancel button}
begin
   Close;
end;

procedure Tform12.RG1Click(Sender: TObject);
begin
   Button1.Enabled:=true;
   Button3.Enabled:=true;
end;

procedure MakeNew;
   {make new WEEKLY.DBF file}
begin
   with form12.query1 do
      begin
         close;
         sql.clear;
         sql.add('Create Table "C:\Funland\weekly.DBF"');
         sql.add(' (Empnum Char(10), Name Char(30), Dept Numeric (10,0), DateIn Char(8),');
         sql.add('TimeIn Char(4),DateOut Char(8), TimeOut Char(4),');
         sql.add('Hours Numeric(5,2),Rate Numeric(5,2), Tips Numeric(6), Tipped Numeric(10),');
         sql.add('Job Char(12), Break Numeric(1))');
         execsql;
      end;
end;

function CheckDate(CDate:string):boolean;
   {check for time\date data in WEEKLY.DBF}
begin
   with form12.query1 do
      begin
         close;
         sql.clear;
         sql.add('Select * from "C:\Funland\weekly.dbf"');
         sql.add('where DateIn='+CDate);
         Open;
         if recordcount>0 then
            CheckDate:=true
         else CheckDate:=false;
      end;
end;

procedure GetDateString(TDate:TDateTime;var Ys,Ms,Ds:string);
   {convert date time to date string}
var
   Y,M,D:word;
begin
   DecodeDate(TDate,Y,M,D);
   Ds:=IntToStr(D);
   if D<10 then Ds:='0'+Ds;
   Ms:=IntToStr(M);
   if M<10 then Ms:='0'+Ms;
   Ys:=IntToStr(Y);
end;

procedure ParseString(S:string);
   {Parse string for times}
var
   P:String;
   I,Count:longint;
begin
   Count:=1;
   for I:=1 to 12 do Times[I]:=0;
   for I:=1 to Length(S) do
      begin
         P:=S[I];
         if (P>='0') and (P<='9') then
               Times[Count]:=Times[Count]*10+StrToInt(P)
         else if P=':' then
            begin
               Count:=Count+1;
               if Count>12 then Count:=12;
            end
         else if (P='-') or (P=#13) then
            case Count of
               1,2:Count:=3;
               3,4:Count:=5;
               5,6:Count:=7;
               7,8:Count:=9;
               9,10:Count:=11;
            end;
      end;
end;

procedure Convert(S:string;var H,M:integer);
   {Convert S from HHMM to integers}
var
   I,Code:integer;
begin
   Val(Copy(S,1,2),I,Code);
   if I=0 then I:=12
   else if I>12 then I:=I-12;
   H:=I;
   Val(Copy(S,3,2),M,Code);
end;

procedure PutString(S:string;var V:string;I:integer);

begin
   Insert(S,V,I);
end;

procedure Assemble(var T:string);
   {assemble a string from times array}
var
   S:string;
begin
   T:='';
   if Times[1]>0 then
      begin
         T:=IntToStr(Times[1]);
         if Times[1]<10 then
            T:=' '+T;
         S:=IntToStr(Times[2]);
         if Times[2]<10 then
            S:='0'+S;
         T:=T+':'+S+'-';
         if Times[3]>0 then
            if Times[3]<9 then T:=T+' '+InttoStr(Times[3])
            else T:=T+IntToStr(Times[3]);
         S:=IntToStr(Times[4]);
         if Times[4]<10 then
            S:='0'+S;
         T:=T+':'+S;
         if Times[5]>0 then T:=T+Chr(13)+Chr(10);
      end;
   if Times[5]>0 then
      begin
         S:=IntToStr(Times[5]);
         if Times[5]<10 then
            S:=' '+S;
         T:=T+S;
         S:=IntToStr(Times[6]);
         if Times[6]<10 then
            S:='0'+S;
         T:=T+':'+S+'-';
         if Times[7]>0 then
            if Times[7]<9 then T:=T+' '+InttoStr(Times[3])
            else T:=T+IntToStr(Times[7]);
         S:=IntToStr(Times[8]);
         if Times[8]<10 then
            S:='0'+S;
         T:=T+':'+S;
         if Times[9]>0 then T:=T+Chr(13)+Chr(10);
      end;
   if Times[9]>0 then
      begin
         S:=IntToStr(Times[9]);
         if Times[9]<10 then
            S:=' '+S;
         T:=T+S;
         S:=IntToStr(Times[10]);
         if Times[10]<10 then
            S:='0'+S;
         T:=T+':'+S+'-';
         if Times[11]>0 then
            if Times[11]<9 then T:=T+' '+InttoStr(Times[11])
            else T:=T+IntToStr(Times[11]);
         S:=IntToStr(Times[12]);
         if Times[12]<10 then
            S:='0'+S;
         T:=T+':'+S;
      end;
end;

procedure Checkout(Id:integer;InDate,InTime,OutDate,OutTime:String);
   {move a checkout time from weekly.dbf to time sheet}
var
   S,T,Temp:string;
   H,M:integer;
begin
   Str(Id,T);
   S:=IntToStr(Form12.RG1.ItemIndex+1);
   S:='M'+S;
   with Form12.Query2 do
      begin
         close;
         Sql.Clear;
         SQl.Add('Select * from "C:\Funland\'+ClockFile+'"');
         SQL.Add('where Id='+T);
         UpdateOptions.RequestLive:=true;
         Open;
         if RecordCount>0 then
            begin
               First;
               T:=FieldByName(S).AsString;
               Temp:=T;
               Parsestring(T);
               Convert(InTime,H,M);
               if Times[3]<=0 then
                  begin
                     if (H=Times[1]) and (M=Times[2]) then
                        begin
                           Convert(OutTime,H,M);
                           Times[3]:=H;
                           Times[4]:=M;
                           Assemble(T);
                        end;
                  end
               else if Times[7]<=0 then
                  begin
                     if (H=Times[5]) and (M=Times[6]) then
                        begin
                           Convert(Outtime,H,M);
                           Times[7]:=H;
                           Times[8]:=M;
                           Assemble(T);
                        end;
                  end
               else if Times[11]<=0 then
                  begin
                     if (H=Times[9]) and (M=Times[10]) then
                        begin
                           Convert(Outtime,H,M);
                           Times[11]:=H;
                           Times[12]:=M;
                           Assemble(T);
                        end;
                  end;
               if T<>Temp then
                  begin
                     Edit;
                     FieldByName(S).AsString:=T;
                     Post;
                  end;
            end;
      end;
end;

procedure Tform12.Button1Click(Sender: TObject);
   {import button}
var
   I,Code,Empnmbr:integer;
   S,InDate,OutDate,CDate,Ys,Ms,Ds,InTime,OutTime:string;
begin
   if FileExists('C:\Funland\Weekly.DBF')=false then
      MessageDlg('No data available for import!',mtError,[mbCancel],0)
   else
      begin
         Screen.Cursor:=crHourglass;
         GetDateString(ClockDate,Ys,Ms,Ds);
         ClockFile:=Ys+Ms+Ds+'.DB';
         GetDateString(ClockDate+RG1.Itemindex,Ys,Ms,Ds);
         CDate:=Ys+Ms+Ds;
         if CheckDate(CDate)=false then
            MessageDlg('No data available for import!',mtError,[mbCancel],0)
         else with query1 do
            begin
               First;
               for I:=1 to RecordCount do
                  begin
                     OutTime:=FieldbyName('TimeOut').AsString;
                     if OutTime<>'9999' then
                        begin
                           InDate:=FieldByname('DateIn').AsString;
                           OutDate:=FieldByName('DateOut').AsString;
                           InTime:=FieldByName('TimeIn').AsString;
                           S:=FieldByName('Empnum').AsString;
                           Val(S,Empnmbr,Code);
                           Checkout(Empnmbr,InDate,InTime,OutDate,OutTime);
                        end;
                     Next;
                  end;
            end;
          Screen.Cursor:=crDefault;
      end;
end;

procedure Addone(LName,FName,Id,CDate:String;I:integer);
   {add a record to weekly.dbf}
var
   J,Code:integer;
   S:String;
begin
   with Form12.Table1 do
      begin
         Edit;
         Append;
         FieldByName('Name').AsString:=FName+' '+LName;
         Val(Id,J,Code);
         if J<10 then
            FieldByName('EmpNum').AsString:='         '+Id
         else if J<100 then
            FieldByName('EmpNum').AsString:='        '+Id
         else FieldByname('EmpNum').AsString:='       '+Id;
         FieldByName('DateIn').AsString:=CDate;
         if Times[I]<10 then
            J:=Times[I]+12
         else J:=Times[I];
         S:=IntToStr(Times[I+1]);
         if Times[I+1]<9 then
            S:='0'+S;
         S:=IntToStr(J)+S;
         FieldByName('TimeIn').AsString:=S;
         FieldByName('DateOut').AsString:=CDate;
         fieldByName('TimeOut').AsString:='9999';
         FieldByName('Dept').AsFloat:=1;
         Post;
      end;
end;

procedure Tform12.Button3Click(Sender: TObject);
   {export button}
var
   I:integer;
   S,T,CDate,Ys,Ms,Ds,LName,FName,Id:string;
   Flag:boolean;
begin
   with RG1 do
      case ItemIndex of
         0:S:='M1';
         1:S:='M2';
         2:S:='M3';
         3:S:='M4';
         4:S:='M5';
         5:S:='M6';
         6:S:='M7';
      end;
   if FileExists('C:\Funland\Weekly.DBF')=false then
      MakeNew;
   GetDateString(ClockDate,Ys,Ms,Ds);
   ClockFile:=Ys+Ms+Ds+'.DB';
   GetDateString(ClockDate+RG1.Itemindex,Ys,Ms,Ds);
   CDate:=Ys+Ms+Ds;
   Flag:=true;
   if CheckDate(CDate)=true then
      if MessageDlg('Data for this date found. Continue anyway?',mtConfirmation,[mbYes,mbNo],0)=mrNo then
         Flag:=false;
   if Flag=true then
      begin
         Screen.Cursor:=crHourglass;
         with form12.query1 do
            begin
               close;
               sql.clear;
               sql.add('Select Last,First,Id,'+S+' from "C:\Funland\'+ClockFile+'"');
               sql.add('where '+S+'<>'''' and Shift=''Hourly''');
               sql.add('order by Id');
               Open;
               First;
               with Form12.Table1 do
                  begin
                     TableName:='c:\funland\weekly.dbf';
                     Open;
                  end;
               for I:=1 to RecordCount do
                  begin
                     T:=FieldByName(S).AsString;
                     ParseString(T);
                     if (Times[3]=0) and (Times[1]<>0) then
                        begin
                           LName:=Fieldbyname('Last').AsString;
                           FName:=Fieldbyname('First').AsString;
                           Id:=Fieldbyname('Id').AsString;
                           Addone(LName,FName,Id,CDate,1);
                        end;
                     if (Times[7]=0) and (Times[5]<>0) then
                        begin
                           LName:=Fieldbyname('Last').AsString;
                           FName:=Fieldbyname('First').AsString;
                           Id:=Fieldbyname('Id').AsString;
                           Addone(LName,FName,Id,CDate,5);
                        end;
                     if (Times[11]=0) and (Times[9]<>0) then
                        begin
                           LName:=Fieldbyname('Last').AsString;
                           FName:=Fieldbyname('First').AsString;
                           Id:=Fieldbyname('Id').AsString;
                           Addone(LName,FName,Id,CDate,9);
                        end;
                     Next;
                  end;
               Form12.Table1.Close;
            end;
          Screen.Cursor:=crDefault;
         close;
      end;
end;

end.
