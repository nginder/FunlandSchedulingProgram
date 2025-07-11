unit Fungrid;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, System.UITypes,
  Grids, Db , Gauges, StdCtrls, ExtCtrls, Printers, DateUtils,SyncObjs, FireDAC.Comp.Client, FireDAC.Stan.Intf, FireDAC.Stan.Option,
FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Stan.Param,
FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.Comp.DataSet, FireDAC.DApt,
  FireDAC.Phys, FireDAC.VCLUI.Wait, FireDAC.Phys.MSSQL, FireDAC.Phys.MSSQLDef,
  FireDAC.Phys.ODBCBase, FireDAC.Phys.ODBC, FireDAC.Phys.ODBCDef;

type
  TForm13 = class(TForm)
    Ga1: TGauge;
    SG1: TStringGrid;   {holds time/pos data for each emp as calc from YYYYMMDD.db}
                        {col=0 is emp Id string; col=1 is emp name as <first>$d$a<last>;}
                          {col=2 is shift 'H' or 'F' or 'M' etc.; cols=3-9 represent days of week 1-7}
    Label1: TLabel;
    Timer1: TTimer;
    LB2: TListBox;
    HG1: TStringGrid;
    ColorGrid: TStringGrid;
    List1: TListBox;
    TimeGridP: TStringGrid;
    JobGrid: TStringGrid;
    Queue: TStringGrid; {holds time data from Funtimes.db}
                            {col=0 is time string id; col=1 is time string; col=2 is time data}
                          {Also used to hold data for clockin / clockout }
    SG2: TStringGrid;
    funland: TFDConnection;
    Query1: TFDQuery;
    Query2: TFDQuery;
    Table1: TFDTable;     {not currently used}
    procedure FormActivate(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);

  private
    { Private declarations }
  public
    { Public declarations }
  end;

const
   HistDays = 14; {Number of days to check back for job/employee history}
   {Following are the font display colors for the various Shifts}
   FamColor = clOlive;
   HourlyColor = clBlack;
   SpecialColor = clBlue;
   ExEmpColor = clMedGray;
   FifteenColor = clRed;
   MinorColor = clTeal;
   Col0 = 100; {override first column width for grids in funtime.pas}
   Col1 = 80;  {override remaining column width for grids}
   BreakMinutes = 30; {break length in minutes}
   ETranMax = 100; {current width of ETran field in Training.db is 100 char.s'}
   MaxEmp = 300; {maximum number of employee entries for training array Traine}
   MaxJob = 200; {maximum number of job entries for training array Traine}
   MaxFifteenHoursSeason  = 38;  {maximum hours 14-15 year olds can be scheduled in season}
   MaxFifteenHoursSchool  = 16;  {maximum hours 14-15 year olds can be schedule while school in session}
   MaxFifteenDaysPerWeek = 6;  {Maximum no. of days per week 14-15 year olds can be scheduled}
   SchoolEndMonth = 6;         {Set maximum school ending date to June 15}
   SchoolEndDay = 1;
   MaxFifteenHoursPerDay = 8;  {Max. total hours allowed per day 14-15 year olds}
   Sevencode = 1140;  {Minutes since midnight for 7:00 pm}
   SevenThirtyCode = '+30'; {Time code for 7:30- time entry}
   EightThirtyCode = '+13'; {Time code for 8:30- time entry}
   B14 = '              ';  {fill for .txt fields}
   B4 = '    ';
   MaxEntries = 10;  {maximum no. of time entries allowed for each employee per day}
   UPMark = 'U';    {unpaid break marker in timedata}
   PdMark = 'u';    {paid break marker in timedata}
   OffMark = '/';    {this is 1st character in a time string - indicates an off time entry}
                     {next 8 constants are first char in T records - all newly entries have '='}
   NewMark = '+';  {all new T Rec.s will have this char. until altered by Sync}
   SaNI = '+';    {these three entries for standalone shift: not clocked in or not clocked out or done}
   SaNO = '-';
   SaD = '*';
   CSNI = '{';  {these two entries for start of chain: not clocked in or clocked in [done]}
   CSD = '[';
   CENO = '}'; {these two entries for end of chain: not clocked out or clocked out [done]}
   CED = ']';
   CLk = 'x';   {this entry for link in chain - no clocking in or out needed}
   LocalDriveAlias = 'C:/funland';
   RemoteDriveAlias = 'T:/SummerFPF2020';
   LocalAlias ='Funland';
   RemoteAlias ='Funland1';
   Max_Sched_Display_Cols = 10; {max. no. of columns to be displayed in FunSched}
   DefaultModeNumber = 0 ;  {default Mode no.for each day}
   TLBackColor1 = clRed;     {background colors for time entry lines in FunEntry}
   TLBackColor2 = clSkyBlue;
   TLBackColor3 = clLime;
   TLBackColor4 = clYellow;
   TLBackColor5 = clSilver;
   TLBackNormal = clWhite;
   PColor1 = clRed;       {background colors for time entry lines in schedule printouts}
   PColor2 = clSkyBlue;
   PColor3 = clLime;
   PColor4 = clYellow;
   FontOff = 'Verdana';     {font names for time entries either inactive or active}
   FontOn = 'Arial Black';
   ExOff = clSilver;   {font colors for Extra time entry either inactive or active}
   ExOn = clCream;
   Pan1On = clCream;    {font colors for Panel1 of Time Entry}
   Pan1Off = clSilver;

   type                     {typed file record fields}
    FunFileRec = record
      Typ:			string[1];
		  RecN:			string[4];
		  Id:				string[4];
		  Shif:			string[1];
		  Daye:			string[1];
		  Star:			string[4];
		  First:		string[14];
		  Last:			string[42];
	end;

var
  Form13:TForm13;
  Nufile,OldFile,OlderFile:string;
  Schedfile, SchedStr,SchedDate:string;
  OldDate,OlderDate:TDateTime;
  NewDate:TDateTime;   {current time sheet date}
  PX,PY:real;
  LastPage,LastPageH,OldOffset,OlderOffset,Offset,EmpTrainNum:integer;
  EmpFlag,ShfFlag,TrainFlag,Sortflag:boolean;
  Aliass,Aliass1,TempAlias,TextFileAlias:string;  {contains current database alias & temporary txt alias}
  RPath:string; {path string for remote drive}
  RevNum:integer;  {employee number under review in sched}
  CurrentData,OldData:string[60];  {training data variables}
  Traine: array[1..MaxEmp,1..MaxJob]of integer;  {training data array}
  Jarray:array[1..Maxjob] of integer;  {holds job number translations from place no.'s to actual job no.s}
  LocFirst,LocLast,LocShf:string; {locate employee variables used in Funloc}
  LocFlag:boolean;
  LocId:longint;
  NStar,ThisId:integer;
  NewStr,ExStr:string;       {NewStr is SG1 data string w/out RecNo used for processing/unprocessing clicks}
  NamShf:string;   {NamShf=shift of currently selected name label}
                   {...possible values: M=minor,H=hourly,P=parttime}
  SixteenYearsOld, EighteenYearsOld,
    FourteenYearsOld,LaborDay,SchoolEnd:TDateTime;  {Age level time variables}
  MaxFifteenMInutes:real;  {max. hrs. weekly work for 14-15 year olds set in funsheet.pas}
  FMins: array[1..7] of integer;  {holds daily scheduled minutes for this emp/ this week}
  GMins: array[1..7] of integer;  {holds daily real minutes for this emp/ this week}
  TCount:integer; {Count of records in YYMMDD.DB file}
  Y,M,D:word;
  Filemask,Newfile:string;
  Rarray:array[1..MaxEmp,0..1] of integer;
  LastEntry,Daze,NewDaze:integer;
  Chckflag:boolean;
  CFile,BFile:file of FunFileRec;  {typed file variables}
  RecIn,RecOut: FunFileRec;   {variables for passing YYYYMMDD.db record values}
  OverFlag: boolean;   {set to true when override input requires adding new I records - append new records nonalphabetically}
  ListBoxFlag: boolean; {set to false to display time labels in ListBox1; true = name labels}
  Modarray:array[1..7] of integer;  {Holds mode no. for each day for current weekly file}
  Tiparray:array[1..7,1..5] of string; {Holds names of types of time entries for current weekly file}
  Labarray:array[1..5,1..10] of string; {Holds time entry id+tname+':'+lab field for each time entry/for each type}
  RowTimes:array[1..5,1..4] of integer;  {hold row no. and max cols and background color info for the five types in SChG1}
  CountArray:array[1..5,1..10] of integer; {holds count of available employees for each time label}
  ModeChangeFlag:boolean;  {set to true when daily mode changes are made in Form21 - FunGroups}
  CurMood:integer;     {mode which Form22, Time entry is currently set up for}
  CurMode:integer;  {current mode for this day}
  CurCol, CurRow:integer;  {current col [DoW] and row [Emp] passed to FunEntry from FunTime}
  DragFlag:boolean;  {true for drag between rows of SchgG1; false for drag from listboxes}
  TestArray:array[1..50] of string[20]; {holds test results for duplicate records test}
  CompFlag:boolean;  {true if automatic time compression is to occur}
  Ct,FileCount:integer;

procedure FillColorGrid(Flag:boolean);
procedure Do_it(Sho:boolean);
procedure PXPY;
Procedure TextOwt(X,Y:integer;S:string);
Procedure Movetwo(X,Y:integer);
Procedure Linetwo(X,Y:integer);
Procedure BeginDok;
Procedure EndDok;
procedure Stile(S:TFontStyles);
Procedure Sise(S:integer);
Procedure Wide(S:integer);
Procedure CountEnt(S:string;var Count:integer);
Procedure AdjCount(TCount:integer;var TCS:string);
procedure UnAdjCount(TCS:string;var TCount:integer);
Procedure DoCount(var TCount:integer;var TCS:string);
Procedure SetLastPages;
Procedure TextWide(S:string;var X:integer);
Procedure GetDates;
procedure RotCheck(Emp,Jb,NewVal:integer);
procedure FillTraine;
procedure Make_New_Weekly_File(AddString:string);
procedure Do_Initial_File_Check;
procedure Get_New_Emp_No(var NewNum:integer);
procedure Add_New_Name_To_Timesheet(var Flag:boolean);
procedure Save_Name(ID,F,L:string);
procedure Save_EditedName_in_Txtfile(ID,F,L:string);
procedure Delete_Name_in_Txtfile(ID:string);
procedure Delete_Name_Plus(ID:string);
procedure FillTimeGrids;
procedure InTime(S:string;var I:Integer);
procedure OutTime(I:integer;var S:string);
procedure Add_Drop_To_File(NewStr,NamShf:string;NStar,ThisId,ThisDay,TCount:integer);
procedure DoDeleteRec(ThisRec:integer);
procedure Modify_TFirst_Record(ThisRec:integer;var S:string);
procedure FindRecord(Nmbr,TId:integer;var CurRec:integer);
procedure ModifyRecord(CurRec,ColId:string;Dest:string);
procedure ChangePosition(Rex:integer;Dest:string);
procedure GetInfo(Nmbr:integer;var FName,LName,Shf:string);
procedure AddTrainingData;
procedure Regen;
procedure Sync(var RFlag:boolean);
procedure ModifyBreak(WrecN:integer;T:string);
procedure FillQueue(Offset:integer);
procedure Modify_Clock_Record(RecNo,S:string);
procedure SetMode(T:string);
procedure DoTime(Flag:boolean;var U:String);
procedure FillTiparray;
procedure FillLabarray;
procedure MakeNewStr(Ind:integer);
procedure TestEmp(var X:integer);
procedure GetName(var S:string);
procedure SortSG1(var S:string);
procedure FillJobGrid;

implementation
uses FunTime;
{$R *.DFM}

procedure SortSG1(var S:string);
{sort an SG1 entry by start times}
var
   I,J,Ents:integer;
   T,U:string;
begin
   T:=S;
   CountEnt(S,Ents);
   if Ents>0 then for I:=1 to Ents-1 do
      for J:=I+1 to Ents do
         if StrToInt(Copy(T,(I-1)*30+18,4))>StrToInt(Copy(T,(J-1)*30+18,4)) then
            begin
               U:=Copy(T,(I-1)*30+1,30);
               Delete(T,(I-1)*30+1,30);
               Insert(U,T,(J-1)*30+1);
            end;
   S:=T;
end;

procedure MakeNewStr(Ind:integer);
{make proper NewStr for adding to files}
{Ind is index in TimeGridP}
var
   S:string;
begin
   with Form13 do
      begin
         S:=TimeGridP.Cells[0,Ind];
         if Copy(S,1,1)='-' then
               NewStr:=Offmark+Copy(S,2,2)
            else NewStr:=NewMark+S;             {build proper time id with prefix in NewStr}
         S:=TimeGridp.Cells[2,Ind];                   {this will be child string identifier in time data string}
         if TimeGridP.Cells[4,Ind]<>'' then      {if this time record has the UPBreak field not blank then set 1st char of string to UPMark}
            begin                    {   this indicates that this entry contains an unpaid/paid break}
               Delete(S,1,1);
               Insert(UPMark,S,1);
            end;
         NewStr:=NewStr+Copy(S,4,4)+Copy(S,Length(S)-6,4)+
            S+#13#10;    {NewStr=full string for this entry less record no.}
      end;
end;

procedure GetName(var S:string);
   {S=Employee Id; return w/S=Employee name from ColorGrid}
var
   I,J,K:integer;
   Flag:boolean;
begin
    with Form13.ColorGrid do
        begin
           Flag:=false;
           J:=StrToInt(S);
           K:=1;
           repeat
              I:=StrToInt(Cells[0,K]);
              if I=J then
                 begin
                    Flag:=true;
                    S:=Cells[1,K];
                 end;
              Inc(K);
           until (Flag=true) or (K>=RowCount+1);
        end;
   if Flag=false then S:='';
end;

procedure GetDates;
{Get fourteenyearsold, sixteenyearsold and eighteenyearsold dates from Today}
{Also SchoolEnd and LaborDay are set}
var
   Y,YD,M,D:word;
begin
   DecodeDate(Today(),Y,M,D);
   YD:=Y;
   Y:=Y-14;
   FourteenYearsOld:=EncodeDate(Y,M,D);
   Y:=Y-2;
   SixteenYearsOld:=EncodeDate(Y,M,D);
   Y:=Y-2;
   EighteenYearsOld:=EncodeDate(Y,M,D);
   M:=9;
   D:=7;
   LaborDay:=EncodeDate(YD,M,D);
   LaborDay:=StartofTheWeek(LaborDay);
   M:=SchoolEndMonth;
   D:=SchoolEndDay;
   SchoolEnd:=EncodeDate(YD,M,D);
end;

procedure SetLastPages;
   {set last pages for Hourly}
begin
   LastPageH:=Form13.SG1.RowCount div 13;
   if Form13.SG1.RowCount mod 13 > 0 then
      Inc(LastPageH);
end;

procedure CountEnt(S:string;var Count:integer);
   {count time entries in string S}
var
   I:integer;
   T:string;    {what am I doing with T here?}
begin
   Count:=0;
   I:=1;
   while I>0 do
      begin
         I:=Pos(#10,S);
         if I>0 then
            begin
               T:=Copy(S,1,I-2);
               Delete(S,1,I);
               Inc(Count);
            end;
      end;
end;

procedure SetMode(T:string);
   {save mode changes in yyyymmdd.db}
var
   S,CurFile:string;
   Rec:FunFileRec;
   Len:integer;
begin
   with Form13.Query1 do
      begin
         Close;
         UpdateOptions.RequestLive:=true;
         SQL.Clear;
         S:='Select First from "'+Nufile+'"';
         SQL.Add(S);
         SQL.Add('where Typ=''C''');
         Open;
         Edit;
         FieldByName('First').AsString:=T;
         Post;
         Close;
      end;
   Len:=Length(Newfile)-2;
   CurFile:=TempAlias+Copy(Newfile,1,Len)+'txt';
   Assignfile(BFile,CurFile);        {BFile is current YYYYMMDD.txt file}
   Reset(BFile);
   Read(BFile,Rec);
   Rec.First:=T;
   seek(BFile,FilePos(BFile)-1);
   write(BFile,Rec);
   closefile(BFile);
end;

procedure AdjCount(TCount:integer;var TCS:string);
   {adjust value in tcount for values over 999 - result is 3 byte string TCS}
var
   J:integer;
begin
   if TCount<1000 then
      begin
         TCS:=IntToStr(TCount);
         if TCount<10 then
            TCS:='00'+TCS
         else if TCount<100 then
            TCS:='0'+TCS;
      end
   else
      begin
         TCS:=IntToStr(TCount);
         TCS:=Copy(TCS,Length(TCS)-1,2);
         J:=TCount div 100;
         TCS:=Chr(55+J)+TCS;
      end;
end;

procedure UnAdjCount(TCS:string;var TCount:integer);
   {unadjust value in TCS for values over 999 - result is TCount}
var
   S,T:string;
begin
   S:=Copy(TCS,1,1);
   T:=Copy(TCS,2,2);
   if S='0' then TCount:=StrToInt(TCS)
   else
      begin
         TCount:=StrToInt(T);
         if S= 'A' then TCount:=1000+TCount
         else if S='B' then TCount:=1100+TCount
         else if S='C' then TCount:=1200+TCount
         else if S='D' then TCount:=1300+TCount
         else if S='E' then TCount:=1400+TCount
         else if S='F' then TCount:=1500+TCount
         else if S='G' then TCount:=1600+TCount
         else if S='H' then TCount:=1700+TCount
         else if S='I' then TCount:=1800+TCount
         else if S='J' then TCount:=1900+TCount
         else if S='K' then TCount:=2000+TCount
         else if S='L' then TCount:=2100+TCount
         else if S='M' then TCount:=2200+TCount
         else if S='N' then TCount:=2300+TCount
         else if S='O' then TCount:=2400+TCount
         else if S='P' then TCount:=2500+TCount
         else if S='Q' then TCount:=2600+TCount
         else if S='R' then TCount:=2700+TCount
         else if S='S' then TCount:=2800+TCount
         else if S='T' then TCount:=2900+TCount
         else if S='U' then TCount:=3000+TCount
         else if S='V' then TCount:=3100+TCount
         else if S='W' then TCount:=3200+TCount
         else if S='X' then TCount:=3300+TCount
         else if S='Y' then TCount:=3400+TCount
         else if S='Z' then TCount:=3500+TCount
         else if S='[' then TCount:=3600+TCount
         else if S='\' then TCount:=3700+TCount
         else if S=']' then TCount:=3800+TCount
         else TCount:=StrToInt(TCS);
      end;
end;

procedure SetCount(TCount:integer);
   {set current record number in yyyymmdd.db from TCount}
var
   S,CurFile:string;
   Rec:FunFileRec;
   Len:integer;
begin
   with Form13.Query1 do
      begin
         Close;
         UpdateOptions.RequestLive:=true;
         SQL.Clear;
         S:='Select Id from "'+Nufile+'"';
         SQL.Add(S);
         SQL.Add('where Typ="C"');
         Open;
         Edit;
         FieldByName('Id').AsInteger:=TCount;
         Post;
         Close;
      end;
   Len:=Length(Newfile)-2;
   CurFile:=TempAlias+Copy(Newfile,1,Len)+'txt';
   Assignfile(BFile,CurFile);        {BFile is current YYYYMMDD.txt file}
   Reset(BFile);
   S:=IntToStr(TCount);            {change}
   if TCount<1000 then S:=' '+S;
   if TCount<100 then S:=' '+S;
   if TCount<10 then S:=' '+S;
   Read(BFile,Rec);
   Rec.Id:=S;
   seek(BFile,FilePos(BFile)-1);
   write(BFile,Rec);
   closefile(BFile);
end;

procedure DoCount(var TCount:integer;var TCS:string);
   {get next available record number string from yyyymmdd.db,}
   {increment it and save to yyyymmdd.db}
   {return next available integer value in TCount}
   {'adjusted' 3 byte CURRENT string value in TCS }
var
   S:string;
begin
   with Form13.Query1 do
      begin
         Close;
         SQL.Clear;
         S:='Select Id from "'+Nufile+'"';
         SQL.Add(S);
         SQL.Add('where Typ="C"');
         Open;
         TCount:=FieldByName('Id').AsInteger;
         Close;
      end;
   AdjCount(TCount,TCS);
   Inc(TCount);
   SetCount(TCount);
end;

procedure InTime(S:string;var I:Integer);
   {convert 4 char string HHMM to minutes since midnight}
var
   H,M:integer;
begin
   if S='9999' then I:=9999
   else
      begin
         H:=StrToInt(Copy(S,1,2));
         M:=StrToInt(Copy(S,3,2));
         I:=H*60+M;
      end;
end;

procedure OutTime(I:integer;var S:string);
{convert I minutes since midnight to four char string HHMM}
var
   H,M:integer;
   T:string;
begin
   H:=I div 60;
   M:=I mod 60;
   S:=InttoStr(H);
   if H<10 then S:='0'+S;
   T:=IntToStr(M);
   if M<10 then T:='0'+T;
   S:=S+T;
end;

Procedure TextOwt(X,Y:integer;S:string);
   {Use PX & PY to modify X,Y for printing text}
begin
   X:=Round(X*PX);
   Y:=Round(Y*PY);
   Printer.Canvas.TextOut(X,Y,S);
end;

Procedure Movetwo(X,Y:integer);
   {Use PX & PY to modify X,Y for moving to a point}
begin
   X:=Round(X*PX);
   Y:=Round(Y*PY);
   Printer.Canvas.MoveTo(X,Y);
end;

Procedure Linetwo(X,Y:integer);
   {Use PX & PY to modify X,Y for drawing a line to a point}
begin
   X:=Round(X*PX);
   Y:=Round(Y*PY);
   Printer.Canvas.LineTo(X,Y);
end;

Procedure PXPY;
   {set up printer offsets before printing}
var
   S:string;
begin
   S:='WWWWWW';
   with Printer do
      begin
         Orientation:=poportrait;
         with Canvas do
            begin
               Font.Name:='Arial';
               Font.Size:=12;
               Font.Style:=[];
               PX:=Textwidth(S)/300;
               PY:=TextHeight(S)/57;
            end;
      end;
end;

procedure BeginDok;
   {shell for printer begindoc}
begin
   Printer.BeginDoc;
end;

procedure EndDok;
   {shell for printer enddoc}
begin
   Printer.EndDoc;
end;

procedure Stile(S:TFontStyles);
   {shell for printer font style}
begin
   Printer.Canvas.Font.Style:=S;
end;

procedure Sise(S:Integer);
   {shell for printer font size}
begin
   Printer.Canvas.Font.Size:=S;
end;

procedure Wide(S:Integer);
   {shell for printer pen width}
begin
   Printer.Canvas.Pen.Width:=S;
end;

procedure TextWide(S:string;var X:integer);
   {get adjusted textwidth for string S as X=no. of pixels}
begin
   X:=Round(Printer.Canvas.TextWidth(S)/PX);
end;

procedure GetPrevFileName(var FName:string;var Offs:integer);
   {get previous filename from LB2}
   {offs is offset from schedule date}
var
   Ys,Ms,Ds:string;
   TDate,SDate:TDateTime;
   Y,M,D:word;
begin
    with Form13.LB2 do if ItemIndex>-1 then
       begin
          TDate:=StrToDate(Items[ItemIndex]);
          SDate:=StrToDate(SchedStr);
          Offs:=Trunc(SDate-TDate);
          DecodeDate(TDate,Y,M,D);
          Ds:=IntToStr(D);
          if D<10 then Ds:='0'+Ds;
          Ms:=IntToStr(M);
          if M<10 then Ms:='0'+Ms;
          Ys:=IntToStr(Y);
          FName:=YS+MS+DS+'.db';
          ItemIndex:=ItemIndex-1;
       end;
end;

procedure FillHistGrid;      {Is this being used at all????}
   {fill history grid from LB2 filenames}
var
   W,I,J,K,L,N,IDS,ProRec,TotRec,Id,Count,Pos,TId,Offs,ThisOff:integer;
   S,T,U:string;
   Flag:boolean;
   R:real;
begin
   with Form13 do
      begin
         Label1.Caption:='Building history database';
         Ga1.Progress:=0;
         Ga1.Repaint;
         Application.ProcessMessages;
         LB2.ItemIndex:=LB2.Items.Count-1;
         TotRec:=LB2.Items.Count;
         ProRec:=0;
         for I:=1 to LB2.Items.Count do
            begin
               GetPrevFileName(S,Offs);
               with Query1 do
                  begin
                     SQL.Clear;
                     S:='Select * from "'+S+'"';
                     SQL.Add(S);
                     SQL.Add('where Typ="T" and Star>0');
                     if Offs<7 then
                        begin
                           S:='and Dat<='+IntToStr(Offs);
                           SQL.Add(S);
                        end;
                     SQL.Add('order by Dat');
                     Open;
                     Last;
                     repeat
                        Id:=FieldByName('Id').AsInteger;
                        S:=FieldByname('Last').AsString;
                        ThisOff:=Offs-FieldByname('Dat').AsInteger+1;
                        Count:=Length(S) div 14;
                        for J:=1 to Count do
                           begin
                              T:=Copy(S,(J-1)*14+1,14);
                              Pos:=StrToInt(Copy(T,12,3));
                              if Pos<>999 then
                                 begin
                                    K:=1;
                                    repeat
                                       if StrToInt(HG1.Cells[0,K])=Pos then
                                          begin
                                             TId:=StrToInt(Copy(T,1,3));
                                             L:=0;
                                             Flag:=false;
                                             repeat
                                                Inc(L);
                                                IDS:=Length(HG1.Cells[L,0]) div 3;
                                                if IDS>0 then
                                                   begin
                                                      N:=0;
                                                      repeat
                                                         Inc(N);
                                                         W:=STrToInt(Copy(HG1.Cells[L,0],(N-1)*3+1,3));
                                                         if W=TId then
                                                            Flag:=true;
                                                      until (Flag=true) or (N>=IDS);
                                                   end;
                                             until (Flag=true) or (L>=HG1.ColCount);
                                             if Flag=true then
                                                begin
                                                   IDS:=Length(HG1.Cells[K,L]) div 6;
                                                   Flag:=false;
                                                   if IDS>0 then
                                                      begin
                                                         N:=0;
                                                         repeat
                                                            Inc(N);
                                                            if Id=StrToInt(Copy(HG1.Cells[K,L],(N-1)*6+1,3)) then
                                                            Flag:=true;
                                                         until (Flag=true) or (N>=IDS);
                                                      end;
                                                   if Flag=false then
                                                      begin
                                                         U:=IntToStr(ThisOff);
                                                         if ThisOff<10 then U:='00'+U
                                                         else if ThisOff<100 then U:='0'+U;
                                                         U:=IntToStr(Id)+U;
                                                         if Id<10 then U:='00'+U
                                                         else if Id<100 then U:='0'+U;
                                                         HG1.Cells[L,K]:=U+HG1.Cells[L,K];
                                                         K:=HG1.RowCount;
                                                      end;
                                                end;
                                          end;
                                       Inc(K);
                                    until K>=HG1.RowCount;
                                 end;
                           end;
                        Prior;
                     until Bof=true;
                     Close;
                  end;
               Inc(ProRec);
               R:=(ProRec/TotRec)*100;
               Ga1.Progress:=Round(R);
               Ga1.Repaint;
               Application.ProcessMessages;
            end;
      end;
end;

procedure FillColorGrid(Flag:boolean);
   {fill ColorGrid with employee id and display color}
var
   I,J:integer;
   S,T:string;
begin
   with Form13 do
      begin
         with Query1 do
            begin
               Close;
               Sql.Clear;
               Sql.Add('select * from employ.db');
               if Flag=true then Sql.Add('order by Empnmbr')
               else Sql.Add('order by SchedName');
               Open;
               First;
               ColorGrid.RowCount:=RecordCount;
               for I:=1 to RecordCount do
                  begin
                     for J:=0 to 4 do ColorGrid.Cells[J,I]:='';
                     S:=FieldByName('SchedName').AsString;
                     if S='' then
                        S:=FieldByName('First').AsString+' '+Copy(FieldByName('Last').AsString,1,1);
                     ColorGrid.Cells[1,I]:=S;
                     ColorGrid.Cells[3,I]:=FieldByname('First').AsString;
                     ColorGrid.Cells[4,I]:=FieldByName('Last').AsString;
                     J:=FieldByName('Empnmbr').AsInteger;
                     T:=IntToStr(J);
                     if J<10 then T:='00'+T
                     else if J<100 then T:='0'+T;
                     ColorGrid.Cells[0,I]:=T;
                     S:=FieldByname('Shift').AsString;
                     if S='Minor' then ColorGrid.Cells[2,I]:=IntToStr(MinorColor)
                     else if S='Hourly' then ColorGrid.Cells[2,I]:=IntToStr(HourlyColor)
                     else if S='Special' then ColorGrid.Cells[2,I]:=IntToStr(SpecialColor)
                     else if S='Fifteen' then ColorGrid.Cells[2,I]:=IntToStr(FifteenColor)
                     else if S='TheFamily' then ColorGrid.Cells[2,I]:=IntToStr(FamColor)
                     else ColorGrid.Cells[2,I]:=IntToStr(ExEmpColor);
                     Next;
                  end;
               Close;
            end;
      end;
end;

procedure Do_it(Sho:boolean);
   {process records from mmddyyyy.db to SG1 - hourly}
   {...Sho is true to show progress gauge}
var
   I,J,K,NewId,OldId,CurId,Resp,GridX,TotRec,ProRec:integer;
   S,T,U,CurShf,EmpShf,NewShf,NewShfFull,OldShfFull:string;
   EmpBDate:TDatetime;
   Flag,SkipNoFlag,SkipYesFlag:boolean;
   R:real;
begin
   with Form13 do
      begin
         ProRec:=0;
         SkipNoFlag:=false;
         SkipYesFlag:=false;
         if Sho=true then         {if Sho is true, set up progress gauge}
            begin
               Ga1.Progress:=0;
               Ga1.Repaint;
               Application.ProcessMessages;
            end;
         with Query1 do   {get total # of records from YYYYMMDD.db}
            begin
               Sql.Clear;
               Sql.Add('select Id,Shf,Last,First');
               Sql.Add('from "'+Nufile+'"');
               Open;
               TotRec:=RecordCount;
               if TotRec=0 then TotRec:=1;
            end;

         with Query1 do   {get employee names from YYYYMMDD.db for SG1}
            begin
               Close;
               UpdateOptions.RequestLive:=true;
               Sql.Clear;
               Sql.Add('select Id,Shf,Last,First');
               Sql.Add('from "'+Nufile+'"');
               Sql.Add('where Typ=''I''');
               Open;
               First;
               I:=0;
               if (RecordCount>0) and (Sho=true)then   {do shift/birthdate checks here}
                   repeat
                        Flag:=false;
                        CurId:=FieldByName('Id').AsInteger;
                        CurShf:=FieldByName('Shf').AsString;
                        with Query2 do
                           begin
                              Close;
                              UpdateOptions.RequestLive:=true;
                              Sql.Clear;
                              Sql.Add('select Empnmbr, BirthDate, Shift');
                              Sql.Add('from "EMPLOY.DB"');
                              Sql.Add('where Empnmbr='+IntToStr(CurId));
                              Open;
                           end;
                        if Query2.RecordCount>0 then
                           begin
                              EmpShf:=Query2.FieldByName('Shift').AsString;
                              EmpBDate:=Query2.FieldByName('BirthDate').AsDateTime;
                              if EmpBDate>SixteenYearsOld then
                                  begin   {here if 14-15 and wrong Shf}
                                     if CurShf<>'F' then
                                        begin
                                           Flag:=true;
                                           NewShf:='F';
                                           NewShfFull:='Fifteen';
                                        end;
                                  end
                              else if (EmpBDate<=SixteenYearsOld)and (EmpBDate>EighteenYearsOld) then
                                  begin   {here if 16-17 and wrong Shf}
                                     if CurShf<>'M' then
                                        begin
                                           Flag:=true;
                                           NewShf:='M';
                                           NewShfFull:='Minor';
                                        end;
                                  end
                              else if (EmpBDate<EighteenYearsOld) and (CurShf<>'H') then
                                  begin {here 18+ and wrong Shf}
                                     Flag:=true;
                                     NewShf:='H';
                                     NewShfFull:='Hourly';
                                  end;
                           end;
                        Query2.Close;
                        if (Flag=true) and (SkipYesFlag=false) then {here if changes to age/shift mismatches need to be made}
                           begin
                              T:=Query1.FieldByName('Shf').AsString;
                              if T='F' then OldShfFull:='Fifteen'
                                 else if T='M' then OldShfFull:='Minor'
                                    else OldShfFull:='Hourly';
                              U:=DateToStr(EmpBDate);
                              S:=Query1.FieldByName('First').AsString+' '+Query1.FieldByName('Last').AsString+' has the wrong shift on this time sheet.'+#10
                                    +'Change '+OldShfFull+ ' to '+ NewShfFull+'?'+#10
                                    +'(Birthdate: '+U+')';
                              Resp:=MessageDlg(S,mtwarning,[mbYes,mbIgnore,mbYesToAll,mbNoToAll],0);
                              if Resp=mrNo then  Flag:=false
                              else if Resp=mrYesToAll then
                                 SkipYesFlag:=true
                              else if Resp=mrNoToAll then
                                 SkipNoFlag:=true;
                           end;
                        if (Flag=true) and (SkipNoFlag=false) then
                            begin   {change shift in time sheet here}
                               Query1.Edit;
                               Query1.FieldByName('Shf').AsString:=NewShf;
                               Query1.Post;
                               Query2.Edit;
                               Query2.FieldByName('Shift').AsString:=NewShfFull;
                               Query2.Post;
                            end;
                        Inc(I);
                        Next;
                  until (I>=RecordCount) or (SkipNoFlag=true);
            end;
         with SG1 do {process name strings from YYYYMMDD.db to SG1 grid - one row per employee}
            begin
               Query1.First;
               RowCount:=1;
               for I:=1 to Query1.RecordCount do
                  begin
                     Rows[RowCount-1].Clear;
                     Cells[0,RowCount-1]:=Query1.FieldByName('Id').AsString;
                     Cells[1,RowCount-1]:=Query1.FieldByName('First').AsString+#13#10
                        +' '+Query1.FieldByName('Last').AsString;
                     Cells[2,RowCount-1]:=Query1.FieldByName('Shf').AsString;
                     Query1.Next;
                     RowCount:=RowCount+1;
                     Inc(ProRec);
                     if Sho=true then
                        begin
                           R:=(ProRec/TotRec)*100;
                           Ga1.Progress:=Round(R);
                           Ga1.Repaint;
                           Application.ProcessMessages;
                        end;
                  end;
               RowCount:=RowCount-1;
            end;
         with Query1 do   {get hourly time data, i.e. 'T' records, from YYYYMMDD.db for SG1}
            begin
               Close;
               UpdateOptions.RequestLive:=true;
               Sql.Clear;
               Sql.Add('select Id,Dat,Star,Shf,First,Last,RecN');
               Sql.Add('from "'+Nufile+'"');
               Sql.Add('where Typ=''T''');
               Sql.Add('order by Id,Dat,Star');
               Open;
               First;
            end;
         with SG1 do   {process time data from YYYYMMDD.db to SG1 grid}
            begin
               OldId:=0;   {OldId = employee id of current row of SG1}
               for I:=1 to Query1.RecordCount do   {Process thru every T record found}
                  begin
                     NewId:=Query1.FieldByName('Id').AsInteger; {NewId = employee id field of current record in Query1}
                     if NewId<>OldId then  {here if this is not the right row of SG1 for the T record being processed}
                        begin
                           GridX:=0;       {GridX=row pointer in SG1}
                           Flag:=false;    {Flag=true when proper row in SG! is found}
                           repeat          {set GridX to proper row in SG1}
                               CurId:=StrToInt(Cells[0,GridX]);
                               if CurId=NewId then
                                  begin
                                     Flag:=true;
                                     OldId:=NewId;
                                  end
                               else Inc(GridX);
                           until (Flag=true) or (GridX=RowCount);
                        end;
                     if NewId=CurId then     {if somehow no proper row is found, ignore this T record}
                        begin                {otherwise, process T record to proper column}
                           J:=Query1.FieldByName('Dat').AsInteger;   {J=day of week for this T record}
                           S:=Query1.FieldByName('First').AsString  {1st half of parent string, length of 11 chars.}
                              +Query1.FieldByName('Last').AsString  {2nd half of parent string, length of 14 chars.}
                              +#13#10;
                           K:=Query1.FieldByName('RecN').AsInteger;
                           AdjCount(K,T);                           {adjust record no. for RecN's above 999}
                           Cells[J+2,GridX]:=Cells[J+2,GridX]+T+S;   {days of week columns are 3-9}
                        end;                          {add adjusted RecN+First+Last fields+#d#a to data already present (multiple entries for this day if any)}
                     Query1.Next;
                     Inc(ProRec);
                     if Sho=true then         {update progress gauge if necessary}
                        begin
                           R:=(ProRec/TotRec)*100;
                           Ga1.Progress:=Round(R);
                           Ga1.Repaint;
                           Application.ProcessMessages;
                        end;
                  end;
            end;
         with Query1 do  {fill mode array here}
            begin
               Close;
               SQL.Clear;
               S:='Select Id,First from "'+Nufile+'"';
               SQL.Add(S);
               SQL.Add('where Typ=''C''');
               Open;
               First;
               if RecordCount>0 then S:=FieldByName('First').AsString
               else S:='0000000';
               for I:=1 to 7 do
                  ModArray[I]:=StrToInt(S[I]);
            end;
         Query1.Close;
         Query2.Close;
      end;
end;

procedure FillTiparray;
{fill tiparray with type names for each day of week based on mode for each day}
var
   I,J,K,L,Mood,Count:integer;
   S:string;
   Flag:boolean;
begin
   for I:=1 to 7 do for J:=1 to 5 do Tiparray[I,J]:='';  {clear type array}
   with Form13.TimeGridP do for I:=1 to 7 do  {do one loop for each day}
      begin
         Mood:=Modarray[I];   {Mood=mode for this day}
         Count:=0;   {no. of time entries for this day; max of 5}
         for J:=0 to RowCount-1 do      {fill time line name labels first}
            begin
               try
                  K:=StrToInt(Cells[8,J]);  {get mode for this TimeGridP entry}
               except on Econverterror do
                  K:=-1;
               end;
               S:=Cells[10,J];           {get type from TimeGridP}
               if (S<>'') and (K=Mood)and (Count<5) then {if this is right mode and valid type and not all lines used then continue}
                 begin
                    Flag:=false;
                    for L:=1 to 5 do
                    if S=Tiparray[I,L] then Flag:=true;        {is this a new type?}
                    if Flag=false then      {here if new type}
                      begin
                         Count:=Count+1;
                         Tiparray[I,Count]:=S;
                      end;
                 end;
            end;
      end;
end;

procedure FillLabarray;
{fill Labarray with id's and tname's and lab field for each time entry type}
var
   I,J,K,M:integer;
   Cnt:array[1..5] of integer;
   S:string;
begin
   M:=Modarray[Offset];       {M = mode for this day}
   for I:=1 to 5 do           {process each type found on this day}
       begin
          Cnt[I]:=1;
          for J:=1 to 10 do Labarray[I,J]:='';  {clear data string for this day}
          S:=Tiparray[Offset,I];           {S=Type name string}
          with Form13.TimeGridP do for K:=0 to RowCount do  if Cells[8,K]<>'' then
             if ((Cells[10,K]=S) and (StrToInt(Cells[8,K])=M)) or ((M=0) and (Copy(Cells[10,K],1,9)=Copy(S,1,9))) then {if Type and mode are right}
                begin
                   Labarray[I,Cnt[I]]:=Cells[0,K]+Cells[7,K]+'&'+Cells[1,K];  {put id and tname and lab field in labarrau}
                   Cnt[I]:=Cnt[I]+1;
                end;
       end;
end;

procedure FillTimeGrids;
{fill timegrids with time data from Funtimes.db}
{one grid has 'P' data, the other 'C';}
var
   I,J:integer;
   S:string;
begin
   with Form13 do with Query1 do
      begin
         Sql.Clear;
         Sql.Add('Select * from Funtimes.Db');
         Open;
         First;
         TimeGridP.RowCount:=RecordCount;
         for I:=1 to RecordCount do
            begin
               J:=FieldByName('Id').AsInteger;
               S:=IntToStr(Abs(J));
               if (Abs(J)<10) and (Abs(J)>0) then S:='0'+S;
               if J<0 then S:='-'+S;
               TimeGridP.Cells[0,I-1]:=S;
               TimeGridP.Cells[1,I-1]:=FieldByName('Lab').AsString;
               TimeGridP.Cells[2,I-1]:=FieldByName('TData').AsString;
               TimeGridP.Cells[3,I-1]:=FieldByName('NoShow').AsString;
               TimeGridP.Cells[4,I-1]:=FieldByName('UPBreak').AsString; {use this field for potential unpaid evening break}
               TimeGridP.Cells[5,I-1]:=FieldByName('AltId').AsString;
               TimeGridP.Cells[6,I-1]:=FieldByName('Star').AsString;
               TimeGridP.Cells[7,I-1]:=FieldByName('TName').AsString;
               TimeGridP.Cells[8,I-1]:=FieldByName('Mode').AsString;
               TimeGridP.Cells[9,I-1]:=FieldByName('Abbr').AsString;
               TimeGridP.Cells[10,I-1]:=FieldByName('Tipe').AsString;
               Next;
            end;
         Close;
      end;

end;

procedure CheckType(var S:string);
{check to see if type S is in Tiparray; offset is day of week}
var
   I:integer;
   Flag:boolean;
begin
   Flag:=false;
   for I:=1 to 5 do if Tiparray[Offset,I]=S then Flag:=true;
   if Flag=false then S:='';
   if (CurMode=0) and (S<>'Game/Ride') then S:=''; {In Mode=0 add only Games or Rides Jobs to JobGrid}
end;

procedure FillJobGrid;
{fill JobGrid}
var
   I,J:integer;
   S:string;
begin
   with Form13 do
      begin
         for I:=1 to MaxJob do Jarray[I]:=0;
         with Query1 do {setup position row names}
            begin
               close;
               Sql.clear;
               Sql.Add('Select Tipe, Name, Num1');
               Sql.Add('from "FUNJOBS.Db"');
               Sql.Add('where Type="I"');
               Open;
               JobGrid.RowCount:=RecordCount;
               First;
               J:=0;
               for I:=0 to RecordCount-1 do with JobGrid do
                  begin
                     S:=FieldByName('Tipe').AsString;
                     if (CurMode=0) and ((S='Rides') or (S='Games')) then
                              S:='Game/Ride';
                     CheckType(S);
                     if S<>'' then
                        begin
                           Cells[0,J]:=FieldByName('Name').AsString;
                           Jarray[J]:=FieldByName('Num1').AsInteger;
                           S:=IntToStr(Jarray[J]);
                           if Length(S)=1 then S:='00'+S
                           else if Length(S)=2 then S:='0'+S;
                           Cells[0,J]:=Cells[0,J]+'<'+S;
                           Cells[1,J]:=FieldByName('Tipe').AsString;
                           if (CurMode=0) and ((Cells[1,J]='Rides') or (Cells[1,J]='Games')) then
                              Cells[1,J]:='Game/Ride';
                           J:=J+1;
                        end;
                     Next;
                  end;
               close;
            end;
      end;
end;

procedure FillQueue(Offset:integer);
{fill queue with data from yymmdd.txt for Offset [day] to use for clockin / clockout}
var
   S,CurFile:string;
   Rec:FunFileRec;
   I,J,Len,TotRec,CurRec:integer;
   R:real;
begin
   Form13.Ga1.Progress:=0;
   Form13.Ga1.Repaint;
   Application.ProcessMessages;
   CurRec:=0;
   Len:=Length(Newfile)-2;
   CurFile:=TempAlias+Copy(Newfile,1,Len)+'txt';
   Assignfile(BFile,CurFile);        {BFile is current YYYYMMDD.txt file}
   Reset(BFile);
   Form13.Queue.RowCount:=1;
   with Form13.Queue do while not Eof(BFile) do
      begin
         Read(BFile,Rec);
         if Rec.Typ='C'then
            begin
               TotRec:=StrToInt(Rec.Id);
            end;
         if (Rec.Typ='T') or (Rec.Typ='t') then
            begin
               I:=StrToInt(Rec.Daye); {read only proper day's info}
               if I=Offset then
                  begin
                     S:=Copy(Rec.First,1,1);
                     if S<>'/' then  {if this is an 'off all day' entry then skip}
                        begin
                           Cells[0,RowCount-1]:=Rec.RecN;
                           Cells[1,RowCount-1]:=Rec.Id;
                           S:=Rec.Star;
                           if Length(S)<4 then S:=' '+S;
                           Cells[2,RowCount-1]:=S;
                           Cells[3,RowCount-1]:=Rec.First;
                           RowCount:=RowCount+1;
                        end;
                  end;
            end;
         Inc(CurRec);
         R:=(CurRec/TotRec)*100;
         Form13.Ga1.Progress:=Round(R);
         Form13.Ga1.Repaint;
         Application.ProcessMessages;
      end;
   if Form13.Queue.RowCount>1 then Form13.Queue.RowCount:=Form13.Queue.RowCount-1;
   closefile(BFile);
end;

procedure TForm13.FormActivate(Sender: TObject);
begin
   if EmpFlag=true then
      begin
         Label1.Caption:='Building employee worksheet database';
         Do_it(true);
      end
   else
      begin
         {FillHistGrid;}
         Label1.Caption:='Reading employee clock in/out file';
         FillQueue(Offset);
      end;
   timer1.Enabled:=true;
end;

procedure TForm13.Timer1Timer(Sender: TObject);
begin
   Timer1.Enabled:=false;
   Close;
end;

{Procedures and functions for employee training checks follow here}

Procedure PrepRotationData;
{process rotation data from Funjobs.db to Traine array}
{load Rarray with [X,0]=Job# and [Y,0]=Rotation #}
var
   I,X,Y:integer;
   S:string;
begin
   with Form13 do
     begin
        for X:=1 to MaxEmp do for Y:=1 to 2 do Rarray[X,Y]:=0;
        LastEntry:=0;
        with Query2 do
           begin
              close;
              UpdateOptions.RequestLive:=true;
              Sql.clear;
              Sql.Add('Select *');
              Sql.Add('from "FunJobs.Db"');
              Sql.Add('where Type="R"');
              Sql.Add('order by Num2');
              Open;
              First;
              if RecordCount>1 then for I:=1 to RecordCount-1 do
                  begin
                     LastEntry:=LastEntry+1;
                     X:=FieldByName('Num2').AsInteger;
                     S:=FieldByName('Name').AsString;
                     Y:=StrToInt(S);
                     Rarray[LastEntry,0]:=X;
                     Rarray[LastEntry,1]:=Y;
                     Next;
                  end;
              close;
           end;
     end;
end;

procedure RotCheck(Emp,Jb,NewVal:integer);
{check for job JB to be in a rotation using Rarray }
{if found, change all rotation entries for Emp in Traine array to NewVal}
var
  I,J,Match:integer;
begin
   Match:=0;
   I:=0;
   while (Match=0) and (I<=LastEntry) do
      begin
         I:=I+1;
         if JB=Rarray[I,1] then Match:=Rarray[I,0];
      end;
   if Match<>0 then for I:=1 to LastEntry do
      if Rarray[I,0]=Match then
         begin
            J:=Rarray[I,1];
            if NewVal=200 then Traine[Emp,J]:=Traine[Emp,J]+200
             else
              Traine[Emp,J]:=NewVal;
         end;
end;

procedure AddTrainingData;
{add training data from Training.db to Traine array}
{'1' indicates already trained; '0' indicates not trained in each position}
{Add 200 to Traine value if trained}
var
   I,J,X,Y:integer;
   S:string;
   T:string[100];
begin
   with Form13 do
     begin
        with Query2 do
           begin
              close;
              UpdateOptions.RequestLive:=true;
              Sql.clear;
              Sql.Add('Select *');
              Sql.Add('from "Training.Db"');
              Sql.Add('order by EId');
              Open;
              First;
              if RecordCount>1 then for I:=1 to RecordCount-1 do
                  begin
                     S:=FieldByName('EId').AsString;
                     X:=StrToInt(S);
                     T:=FieldByName('ETran').AsString;
                     for Y:=1 to Length(T) do
                        begin
                           S:=T[Y];
                           if S='1' then
                              begin
                                 J:=Jarray[Y];
                                 if Traine[X,J]<200 then
                                     begin;
                                        Traine[X,J]:=Traine[X,J]+200;
                                        RotCheck(X,J,200);
                                     end;
                              end;
                        end;
                     Next;
                  end;
              close;
           end;
     end;
end;

Procedure FindOccur(SFile:string; SOff:integer);
{fill Traine array [x,y] from SFile=YYYYMMDD.db and less than or equal SOff['set']}
{where x is employee number and y is job number}
{exclude all 8:30 [Star=2030] occurrences}
var
   I,Offs,J,Count,X,Y,Min:integer;
   S,T,Dest:string;
begin
   Offs:=SOff;
   if Offs<1 then Offs:=0;
   if Sortflag=true then Min:=0
   else Min:=1;
   with Form13.Query1 do if Offs>0 then
      begin
       Close;
       Sql.clear;
       Sql.Add('Select *');
       S:='from "'+SFile+'"';
       Sql.Add(S);
       S:='where Typ="T" and Dat<='+IntToStr(SOff)+'and Star<>"2030" and Star<>"1930"'; {exclude 8:30 and 7:30 entries}
       Sql.Add(S);
       S:='order by Dat';
       Sql.Add(S);
       Open;
       First;
     end;
   if Offs>0 then
       for I:=1 to Form13.Query1.RecordCount do
          begin
             S:=Form13.Query1.FieldByName('Last').AsString;
             T:=Form13.Query1.FieldByName('Id').AsString;
             NewDaze:=Daze+8-Form13.Query1.FieldbyName('Dat').AsInteger;
             X:=StrToInt(T);
             Count:=Length(S) div 14;
             for J:=1 to Count do
               begin
                  Dest:=Copy(S,12,3);
                  Delete(S,1,14);
                  if Dest<>'999' then
                     begin
                        Y:=StrToInt(Dest);
                        if (NewDaze<Traine[X,Y]) or (Traine[X,Y]<=Min) then
                           begin
                              Traine[X,Y]:=NewDaze;  {change this to reflect days ago?}
                              RotCheck(X,Y,NewDaze);
                           end;
                     end;
               end;
            Form13.Query1.Next;
        end;
   Form13.Query1.Close;
end;


Procedure FillTraine;
{Fill Traine array with employee/job data for use with training check}
{0=never; 1=today; 2=yesterday...199=198 days ago}
{Schedfile= current yyyymmdd.db; Offset= current day offset: 1=Fri,7=Thur}
{Daze and NewDaze are used to calculate days ago for Traine array entry}
var
   I,Indx,X,Y:integer;
   Sfile:string;
begin
   Daze:=Offset-7; {set initial days ago}
   NewDaze:=0;
   for X:=1 to MaxEmp do for Y:=1 to MaxJob do Traine[X,Y]:=0;
   PrepRotationData;   {LB2 has yyyymmdd strings; Count:=total # of .db files}
   Indx:=0;
   with Form13.List1 do if Schedfile<>'' then
      for I:=Items.Count-1 downto 0 do
         begin
            SFile:=Items[I]+'.db';
            if SFile=SchedFile then Indx:=I; {find schedfile in lb2; Indx points to it in LB2}
         end;
      if Indx>0 then with Form13.List1 do
         begin
            Sfile:=SchedFile;  {check schedfile first for occurrences - only use Offset=today and lower}
            for I:=Offset downto 1 do
                 begin
                    FindOccur(SFile,Offset);
                 end;
            while Indx>0 do    {check all days of earlier yyyymmdd.db's for occurrences}
               begin
                  Indx:=Indx-1;
                  SFile:=Items[Indx];
                  Daze:=Daze+7;
                  FindOccur(SFile,7);
               end;
         end;
end;

{File operations begin here}
{Hopefully all file operations from all other units will be located here}

procedure Fill_List1;
{fill list1 with current YYYYMMDD.db}
var
  Y,M,D:word;
begin
   with Form13 do
      begin
         List1.Clear;   
         DecodeDate(Now,Y,M,D);
         FileMask:=IntToStr(Y)+'%.db';
         Funland.GetTableNames('','',Filemask,List1.Items);
      end;
end;

procedure GetInfo(Nmbr:integer;var FName,LName,Shf:string);
   {get info:firstname,lastname and shift as strings from employ.db}
var
   S:string;
begin
   FName:='';
   LName:='';
   Shf:='';
   with Form13 do
      begin
         with Query1 do      {Get shift}
            begin
               Close;
               Sql.clear;
               Sql.Add('Select *');
               S:='from "employ.db"';
               Sql.Add(S);
               S:='where Empnmbr='+IntToStr(Nmbr);
               Sql.Add(S);
               Open;
               First;
               if RecordCount>0 then
                  begin
                     Shf:=Copy(FieldByName('Shift').AsString,1,1);
                     FName:=FieldByName('First').AsString;
                     LName:=FieldByName('Last').AsString;
                  end;
               if Shf='X' then Shf:='';
               Close;
            end;
      end;
end;


procedure FindRecord(Nmbr,TId:integer;var CurRec:integer);
   {use Query1 to check for records in yyyymmdd.db for employee Id=Nmbr}
   {if Typ='I', search for I record;}
   {if Typ='T', search for T records w/ Offset [schedule day of week]}
var
   S:string;
   I:integer;
begin
   with Form13.Query1 do
      begin
         Currec:=-1;
         Close;
         UpdateOptions.RequestLive:=true;
         Sql.clear;
         Sql.Add('Select *');
         S:='from "'+Newfile+'"';
         Sql.Add(S);
         S:='where Typ="T" and Dat='+IntToStr(Offset)+'and Id='+IntToStr(Nmbr);
         Sql.Add(S);
         Open;
         First;
         if RecordCount>0 then for I:=1 to RecordCount do
            begin
               if TId=StrToInt(Copy(FieldByName('First').AsString,2,2)) then
                  CurRec:=FieldByName('RecN').AsInteger;
            end;
         Close;
      end;
end;

procedure Modify_RecX_in_Txtfile(CurRec,Las:string);
  {modify last field of Record Num=Nmbr in YYYYMMDD.txt}
var
  J,Len:integer;
  CurFile:string;
  CFlag:boolean;
  Rec:FunFileRec;
begin
   Len:=Length(Newfile)-2;
   CurFile:=TempAlias+Copy(Newfile,1,Len)+'txt';
   Assignfile(BFile,CurFile);        {BFile is current YYYYMMDD.txt file}
   Reset(BFile);
   CFlag:=false;
   while not (Eof(BFile)) and (CFlag=false) do
      begin
         Read(BFile,Rec);
         if Rec.Typ='T' then
            begin
               J:=CompareText(CurRec,Rec.RecN);    {find matching record Nmbr}
               if J=0 then
                  begin
                     seek(BFile,FilePos(BFile)-1);
                     read(BFile,Rec);
                     Rec.Last:=Las;
                     seek(BFile,FilePos(BFile)-1);
                     write(BFile,Rec);
                     CFlag:=true;
                  end;
            end;
      end;
   closefile(BFile);
end;


procedure ModifyRecord(CurRec,ColId:string;Dest:string);
   {use results of query1 to modify last field of record in yyyymmdd.db and .txt}
   {Nmbr is record # in .db and .txt}
   {ColId is Time Id# for column in SchG1 [found in RowCount+1]}
   {for T records, earlier call to FindRecord returns appropriate record RecN
      from yyyymdd.db or no record at all}
var
   I,J,Count:integer;
   S,T,U:string;
   Flag:boolean;
begin
   with Form13 do
      begin
         Flag:=False;
         I:=0;
         Query1.Open;
         Query1.First;
         if Query1.RecordCount>0 then   {if record[s] matching Empr and Offset [Day] continue here}
            repeat
               Inc(I);   {I= index count of records in Query1}
               S:=Query1.FieldByName('Last').AsString;
               Count:=Length(S) div 14;      {Count=# of child strings in Last field for this record}
               J:=0;
               repeat         {search each child string in Last field; J is index }
                  Inc(J);
                  T:=Copy(S,(J-1)*14+2,2);   {T=next child string in Last field}
                  U:=Copy(ColId,2,2);
                  if StrToInt(U)=StrToInt(T) then
                     begin
                        Delete(S,(J-1)*14+12,3);
                        Insert(Dest,S,(J-1)*14+12);
                        Flag:=true;
                        with Query1 do
                           begin
                              Edit;
                              FieldByName('Last').AsString:=S;
                              Post;
                           end;
                     end;
               until (J=Count) or (Flag=true);
               Query1.Next;
            until (I>=Query1.RecordCount) or (Flag=true);
         Query1.Close;
         if Flag=true then Modify_RecX_in_Txtfile(CurRec,S);
      end;
end;

procedure ChangePosition(Rex:integer;Dest:string);
{change position char.'s in Last field for record = Rex}
var
   S,T:string;
begin
   with Form13 do
      begin
         with Query1 do
            begin
               Close;
               UpdateOptions.RequestLive:=true;
               Sql.clear;
               Sql.Add('Select *');
               S:='from "'+Newfile+'"';
               Sql.Add(S);
               S:='where Typ="T" and RecN='+IntToStr(Rex);
               Sql.Add(S);
               Open;
               First;
            end;
         if Query1.RecordCount>0 then
            begin
               S:=Query1.FieldByName('Last').AsString;
               Delete(S,12,3);
               Insert(Dest,S,12);
               with Query1 do
                  begin
                     Edit;
                     FieldByName('Last').AsString:=S;
                     Post;
                  end;
            end;
         Query1.Close;
         AdjCount(Rex,T);
         Modify_RecX_in_Txtfile(T,S);
      end;

end;

procedure ModifyBreak(WrecN:integer;T:string);
{modify LAST field of record number=WreN in .db and.txt to change unpaid/paid status}
{T=child srring of entry with break in it}
var
   S,U,V:string;
begin
   with Form13.Query1 do
      begin
         V:=IntToStr(WrecN);
         if WrecN<1000 then V:='0'+V;
         if WrecN<100 then V:='0'+V;
         if WrecN<10 then V:='0'+V;
         Close;
         UpdateOptions.RequestLive:=true;
         Sql.clear;
         Sql.Add('Select *');
         S:='from "'+Newfile+'"';
         Sql.Add(S);
         S:='where Typ="T" and RecN='+V;
         Sql.Add(S);
         Open;
         First;
         if RecordCount=1 then
            begin
               Edit;
               FieldByName('Last').AsString:=T;
               Post;
               U:=IntToStr(WrecN);
               if WrecN<1000 then U:='0'+U;
               if WrecN<100 then U:='0'+U;
               if WrecN<10 then U:='0'+U;
               Modify_RecX_in_Txtfile(U,T);
            end;
         Close;
      end;
end;

procedure Make_New_I_Record(var Rec:FunFileRec);
{make a new 'I' entry for YYYYMMDD.txt}
var
  J,K,Len:integer;
  S:string;

begin
   Rec.Typ:='I';
   Rec.RecN:=B4;
   K:=LocId;
   S:=IntToStr(LocId);
   if K<1000 then S:=' '+S;
   if K<100 then S:=' '+S;
   if K<10 then S:=' '+S;
   Rec.Id:=S;
   Rec.Shif:=LocShf;
   S:='';
   Rec.Daye:=' ';
   Rec.Star:=B4;
   S:=LocFirst+'~';
   Len:=Length(S);
   if Len<14 then for J:=Len to 14 do S:=S+'~';
   Rec.First:=S;
   S:=LocLast+'~';
   Len:=Length(S);
   if Len<42 then for J:=Len to 42 do S:=S+'~';
   Rec.Last:=S;
end;

procedure Make_New_Weekly_File(AddString:string);
{produce weekly file YYYYMMDD.db or .txt here}

var
   I,J,Len:integer;
   S,T:string;
   {M:text;}
   Rec:FunFileRec;
   FFile:file of FunFileRec;
begin
   with Form13 do
      begin
         with query1 do
            begin
               close;
               sql.clear;
               sql.add('Create table "'+AddString+'.db"');
               sql.add(' (Typ Char(1), RecN SmallInt, Id SmallInt, Shf Char(1), Dat SmallInt,');
               sql.add('Star SmallInt, First Char(15), Last Char(255))');
               execsql;
            end;
         with query2 do
            begin
               close;
               sql.clear;
               sql.add('Select Empnmbr,Last,First,Shift from "Employ.DB"');
               sql.add('where Status="Active" and ((Shift="Hourly") or (Shift="Fifteen") or (Shift="Minor"))');
               sql.add('order by Last,First');
               execsql;
            end;
         Table1.TableName:=AddString+'.db';
         TCount:=1;
         Table1.Open;
         Query2.Open;
         Query2.Last;
         S:=TempAlias+AddString+'.txt';      {this will need to be changed later!!}
         Assignfile(FFile,S);
         Rewrite(FFile);
         Rec.Typ:='C';
         Rec.RecN:=B4;
         Rec.Id:='   1';
         Rec.Shif:=' ';
         Rec.Daye:=' ';
         Rec.Star:=B4;
         {make default mode entry for First field and fill Mode array}
         T:='       ';
         for I:=1 to 7 do
            begin
               ModArray[I]:=DefaultModeNumber;
               T:=IntToStr(DefaultModeNumber)+T;
            end;
         Rec.First:=T;
         Rec.Last:=B14+B14+B14;
         write(FFile,Rec);
         Query2.First;
         for I:= 1 to Query2.RecordCount do with Query2 do
            begin
               Table1.Append;
               Rec.Typ:='I';
               Rec.RecN:=B4;
               J:=FieldByName('Empnmbr').AsInteger;
               S:=FieldByName('Empnmbr').AsString;
               if J<1000 then S:=' '+S;
               if J<100 then S:=' '+S;
               if J<10 then S:=' '+S;
               Rec.Id:=S;
               Rec.Shif:=FieldByName('Shift').AsString;
               S:='';
               Rec.Daye:=' ';
               Rec.Star:=B4;
               S:=FieldByName('First').AsString+'~';
               Len:=Length(S);
               if Len<15 then for J:=Len to 14 do S:=S+'~';
               Rec.First:=S;
               S:=FieldByName('Last').AsString+'~';
               Len:=Length(S);
               if Len<45 then for J:=Len to 43 do S:=S+'~';
               S:=S+'!';
               Rec.Last:=S;
               write(FFile,Rec);
               Table1.FieldByName('Id').AsInteger:=FieldByName('Empnmbr').AsInteger;
               Table1.FieldByName('First').AsString:=FieldByName('First').AsString;
               Table1.FieldByName('Last').AsString:=FieldByName('Last').AsString;
               Table1.FieldByName('Typ').AsString:='I';
               Table1.fieldByName('Shf').AsString:=FieldByName('Shift').AsString;
               Table1.Post;
               Next;
            end;
         Table1.First;
         Table1.Insert;
         Table1.FieldByName('Id').AsInteger:=TCount;
         Table1.FieldByName('Typ').AsString:='C';
         Table1.FieldByName('First').AsString:=T;
         Closefile(FFile);
         Table1.Post;
         Table1.Close;
         Query1.Close;
         Query2.Close;
         Fill_List1;
      end;
end;

function MakeDriveMapping(DriveLetter: string; DirectoryPath: string; Username: string;
  Password: string; RestoreAtLogon: Boolean):DWORD;

var

  NetResource: TNetResource;
  dwFlags: DWORD;


begin
  with NetResource do
    begin
    dwType := RESOURCETYPE_DISK;
    lpLocalName := PChar(DriveLetter);
    lpRemoteName := PChar(DirectoryPath);
    lpProvider := nil;
    end;

    if (RestoreAtLogon) then
      dwFlags := CONNECT_UPDATE_PROFILE
    else
      dwFlags := CONNECT_TEMPORARY;


    WNetCancelConnection2('T:',dwFlags,false);
    Result := WNetAddConnection2(NetResource, nil, nil, dwFlags);  {New connection}
        {'\\CHRISTOPHERFE4F\Users\Public\Documents\SummerFPF2020\TextFiles'}
       {WNetAddConnection2(NetResource, 'admin', 'Funland-969727', dwFlags);}   {Old connection}
    if Result = ERROR_BAD_USERNAME then ShowMessage('Crap');     //need to log here
end;


procedure Do_Initial_File_Check;
{check for aliases and valid employ.db, funtime.db and training.db}
var
   Test: Int64;
   I,J: integer;
   MessStr,S,T:string;
   LocalFlag:boolean;
begin
 with Form13 do
  begin
   List1.Clear;
   funland.GetTableNames('','','',List1.Items);
   if List1.Items.Count>1 then LocalFlag:=true
   else
      begin
         LocalFlag:=false;
         MessStr:='Warning: Local alias [Funland] not Found!'+#13+#10+
                    'Click ''Cancel'' to terminate program';
         I:=MessageDlg(MessStr,mtWarning,[mbCancel],0);
         FDManager.Close;
      end;
   LocalFlag:=true;
   {???continue here for remote alias}
  { try
   except
      MessStr:='Warning: Network drive alias [Funland1] not Found!'+#13+#10+
                'Continue initialization with local drive?';
      I:=MessageDlg(MessStr,mtWarning,[mbOk,mbCancel],0);
      if I=mrCancel then Close
      else LocalFlag:=true;
   end; }
   if LocalFlag=false then  {???Nathan???}
      {Continue here to map server drive - if RemoteAlias not found}
      try
         MakeDriveMapping('T:', '\\CHRISTOPHERFE4F\Users\Public\Documents', 'admin', 'Funland-969727', True);
      except
         MessStr:='Cannot connect to server.'+#13+#10+
                   'Continue initialization with local drive?';
         I:=MessageDlg(MessStr,mtWarning,[mbOk,mbCancel],0);
         if I=mrCancel then FDManager.Close
         else LocalFlag:=true;
   end;
   if LocalFlag=true  then   {here if local drive only}
      begin
         Aliass:=LocalAlias;
         Aliass1:=LocalAlias;
         Query1.Connection:=funland;
         Query2.Connection:=funland;
         Table1.Connection:=funland;
         TempAlias:=LocalDriveAlias;
         TextFileAlias:=LocalDriveAlias;
      end
   else                     {here if both local and remote drives}
      begin
         Aliass:=LocalAlias;;
         Aliass1:=RemoteAlias;
         {FDManager.GetAliasParams(Aliass1,List1.Items);
         List1.Items[0]:='Path='+RemoteDriveAlias;
         FDManager.ModifyConnectionDef(Aliass1,List1.Items);}
         Query1.Connection:=funland;
         Query2.Connection:=funland;
         Table1.Connection:=funland;
         TempAlias:=RemoteDriveAlias;
         TextFileAlias:=RemoteDriveAlias;
      end;
   MessStr:='Force Local Drive? ';  {This is added temporarily}
   I:=MessageDlg(MessStr,mtWarning,[mbYes,mbNo],0);
   if I=mrYes then
      begin
         Aliass:=LocalAlias;;
         Aliass1:=LocalAlias;
         Query1.Connection:=funland;
         Query2.Connection:=funland;
         Table1.Connection:=funland;
         TempAlias:=LocalDriveAlias;
         TextFileAlias:=LocalDriveAlias;
      end;
   Funland.GetTableNames('','','EMPLOY.DB',List1.Items);
   if List1.Items.Count<0 then
      begin
         MessStr:='Warning: Employee Data File [Employ.db] Not Found!'+#13+#10+
            'Click ''Cancel'' to terminate program';
         I:=MessageDlg(MessStr,mtWarning,[mbCancel],0);
         Close;
      end;
   RPath:='';   {???get remote drive path and check for remote lock files}
   {if Aliass1=RemoteAlias then
      begin
         FDManager.GetAliasParams(Aliass1,List1.Items);
         if List1.Items.Count>0 then
            begin
               S:=List1.Items[0];
               I:=Pos('=',S);
               if I<>-1 then
                  RPath:=Copy(S,I+1,Length(S)-I);
               if FileExists(RPath+'paradox.lck') then
                  begin
                     MessStr:='Warning: Data Files may be locked'+#13+#10+
                        'Click ''Ok'' to continue, ''Cancel'' to run local drive';
                     I:=MessageDlg(MessStr,mtWarning,[mbok,mbCancel],0);
                     if I=MrCancel then Aliass1:=LocalAlias;
                  end;
            end;
      end;}
   Funland.GetTableNames('','','funtimes.db',List1.Items);
   if List1.Items.Count<1 then
      begin
         with query1 do
            try
               close;
               sql.clear;
               sql.add('Create table "Funtimes.db"');
               sql.add(' (Id SmallInt, PorC Char(1), Star SmallInt,');
               sql.add('Lab Char(11), TData Char(255), UPBreak Char(1))');
               execsql;
               Close;
               Sql.clear;
               Sql.add('Select * from "Funtimes.db"');
               UpdateOptions.RequestLive:=true;
               Open;
               First;
               Insert;
               FieldByName('Id').AsInteger:=1;
               FieldByName('PorC').ASString:='C';
               FieldByName('Star').AsInteger:=1000;
               FieldByName('Lab').ASString:='10:00- 1:00';
               FieldByName('TData').AsString:='10001300';
               Post;
               Insert;
               FieldByName('Id').AsInteger:=2;
               FieldByName('PorC').ASString:='C';
               FieldByName('Star').AsInteger:=1300;
               FieldByName('Lab').ASString:=' 1:00- 5:00';
               FieldByName('TData').AsString:='13001700';
               Post;
               Insert;
               FieldByName('Id').AsInteger:=3;
               FieldByName('PorC').ASString:='C';
               FieldByName('Star').AsInteger:=1700;
               FieldByName('Lab').ASString:=' 5:00- 7:00';
               FieldByName('TData').AsString:='17001900';
               Post;
               Insert;
               FieldByName('Id').AsInteger:=4;
               FieldByName('PorC').ASString:='C';
               FieldByName('Star').AsInteger:=1900;
               FieldByName('Lab').ASString:=' 7:00-     ';
               FieldByName('TData').AsString:='19009999';
               Post;
               Insert;
               FieldByName('Id').AsInteger:=5;
               FieldByName('PorC').ASString:='C';
               FieldByName('Star').AsInteger:=1300;
               FieldByName('Lab').ASString:=' 1:00- 1:30';
               FieldByName('TData').AsString:='13001330';
               Post;
               Insert;
               FieldByName('Id').AsInteger:=6;
               FieldByName('PorC').ASString:='C';
               FieldByName('Star').AsInteger:=1700;
               FieldByName('Lab').ASString:=' 5:00- 5:30';
               FieldByName('TData').AsString:='17001730';
               Post;
               Insert;
               FieldByName('Id').AsInteger:=7;
               FieldByName('PorC').ASString:='C';
               FieldByName('Star').AsInteger:=1330;
               FieldByName('Lab').ASString:=' 1:30- 5:00';
               FieldByName('TData').AsString:='13301700';
               Post;
               Insert;
               FieldByName('Id').AsInteger:=8;
               FieldByName('PorC').ASString:='C';
               FieldByName('Star').AsInteger:=1730;
               FieldByName('Lab').ASString:=' 5:30- 7:00';
               FieldByName('TData').AsString:='17301900';
               Post;
               Insert;
               FieldByName('Id').AsInteger:=9;
               FieldByName('PorC').ASString:='P';
               FieldByName('Star').AsInteger:=1700;
               FieldByName('Lab').ASString:=' 5:00-     ';
               FieldByName('TData').AsString:='+0317001900999+0419009999999';
               Post;
               Insert;
               FieldByName('Id').AsInteger:=10;
               FieldByName('PorC').ASString:='P';
               FieldByName('Star').AsInteger:=1000;
               FieldByName('Lab').ASString:='10:00- 1:00';
               FieldByName('TData').AsString:='+110001300999';
               Post;
               Insert;
               FieldByName('Id').AsInteger:=11;
               FieldByName('PorC').ASString:='P';
               FieldByName('Star').AsInteger:=1300;
               FieldByName('Lab').ASString:=' 1:00- 5:00';
               FieldByName('TData').AsString:='+0213001700999';
               Post;
               Insert;
               FieldByName('Id').AsInteger:=12;
               FieldByName('PorC').ASString:='P';
               FieldByName('Star').AsInteger:=1900;
               FieldByName('Lab').ASString:=' 7:00-     ';
               FieldByName('TData').AsString:='+0419009999999';
               Post;
               Insert;
               FieldByName('Id').AsInteger:=-1;
               FieldByName('PorC').AsString:='C';
               FieldByName('Star').AsInteger:=9999;
               FieldByName('Lab').AsString:='Off All Day';
               FieldByName('TData').AsString:='00009999';
               Post;
               Insert;
               FieldByName('Id').AsInteger:=-2;
               FieldByName('PorC').AsString:='P';
               FieldByName('Star').AsInteger:=9999;
               FieldByName('Lab').AsString:='Off All Day';
               FieldByName('TData').AsString:='-0100009999999';
               Post;
               UpdateOptions.RequestLive:=false;
            except
               on EFDDBEngineException do
                  begin
                  end;
            end;
      end;
   List1.Clear;       {make new training data file if one does not exist}
   Funland.GetTableNames('','','Training.db',List1.Items);
   if List1.Items.Count<0 then
      begin
         with query1 do
            try
               close;
               sql.clear;
               sql.add('Create table "Training.db"');
               sql.add(' (EId SmallInt, ETran Char(100))');
               execsql;
               Close;
            except
               on EFDDBEngineException do
                  begin
                  end;
            end;
      end;
   Fill_List1;
   Query1.Close;
  end;
end;

procedure Get_New_Emp_No(var NewNum:integer);
{get next available employee number from employ.db}
var
   I:integer;
   Flag:boolean;
begin
   with Form13.Query1 do
      begin
         Close;
         SQL.Clear;
         SQL.Add('select EmpNmbr from "Employ.db"');
         SQL.Add('order by EmpNmbr');
         Open;
         First;
         I:=0;
         Flag:=false;
         if RecordCount>0 then
            begin
               repeat
                  Inc(I);
                  if I<>FieldByName('EmpNmbr').AsInteger then
                  Flag:=true;
                  Next;
               until (Flag=true) or (Eof=true);
               if Flag=true then
                  NewNum:=I
               else
                  NewNum:=RecordCount+1;
            end
         else
            NewNum:=1;
         Close;
      end;
end;

procedure Add_New_Name_To_TxtFile(Flag:boolean);
{add a new nameto yyyymmdd.txt}
{Flag=true for alphabetical add}
{Records are read from old BFile to new CFile with new I file added at appropriate spot}
var
  J,K,Len:integer;
  CurFile,BacFile:string;
  CFlag:boolean;
  S:string;
  Rec,TRec:FunFileRec;

begin
   Len:=Length(Newfile)-2;
   CurFile:=TempAlias+Copy(Newfile,1,Len)+'txt';
   BacFile:=TempAlias+Copy(Newfile,1,Len)+'bac';
   Assignfile(BFile,CurFile);        {BFile is current YYYYMMDD.txt file}
   Rename(BFile,BacFile);
   Reset(BFile);
   Assignfile(CFile,CurFile);         {CFile will be new YYYYMMDD.txt file}
   Rewrite(CFile);
   CFlag:=false;    {CFlag will be set true when new I record is inserted}
   read(BFile,Rec); {write 'C'q record to new file - no update!}
   write(CFile,Rec);
   while not Eof(BFile) do
      begin
         Read(BFile,Rec);
         if CFlag=false then
          begin
           if Rec.Typ='I' then  {sort through only 'I' records}
            begin
               if Flag=true then   {continue here if alphabetical add}
                  begin
                     K:=Pos('~',Rec.Last);
                     if K>0 then S:=Copy(Rec.Last,1,K-1)
                     else S:=Rec.Last;
                     J:=CompareText(LocLast,S);
                     if J<=0 then        {Here if last name is same or less}
                       if J=0 then
                        begin                 {Here if last name is the same}
                           K:=Pos('~',Rec.First);
                           if K>0 then S:=Copy(Rec.First,1,K-1)
                           else S:=Rec.First;
                           if CompareText(LocFirst,S)<=0 then {here if first name is same or less}
                              begin
                                 CFlag:=true;    {insert new I record here}
                                 TRec:=Rec;
                                 Make_New_I_Record(Rec);
                                 write(CFile,Rec);
                                 Rec:=TRec;
                              end;
                        end
                       else          {here if last name is less}
                        begin
                           CFlag:=true;    {insert new I record here}
                           TRec:=Rec;
                           Make_New_I_Record(Rec);
                           write(CFile,Rec);
                           Rec:=TRec;
                        end;
                  end;
            end
           else      {here for T records}
            begin
               if CFlag=false then  {if this is nonalphabetical and 1st T record}
                  begin              {add new record after last of I records}
                     CFlag:=true;
                     TRec:=Rec;
                     Make_New_I_Record(Rec);
                     write(CFile,Rec);
                     Rec:=TRec;
                  end;
            end;
          end;
         write(CFile,Rec);
      end;
   if CFlag=false then   {here for non-alph add if no T records in file}
      begin
         Make_New_I_Record(Rec);
         write(CFile,Rec);
      end;
   closefile(CFile);
   closefile(BFile);
   erase(Bfile);
end;

procedure Add_New_Name_To_Timesheet(var Flag:boolean);
{add a new name to yyyymmdd.db}
{return flag =true for alphabetical add}
var
   I,J:integer;
begin
   with Form13.Query1 do
      begin
         Close;
         UpdateOptions.RequestLive:=true;
         Sql.Clear;
         Sql.Add('Select * from "'+Newfile+'"');
         Sql.Add('where Typ="I"');
         Sql.Add(' and ((Shf="H") or (Shf="F") or (Shf="M"))');
         Open;
         if (OverFlag=false) and ((MessageDlg('Place new name alphabetically?',mtConfirmation,[mbYes,mbNo],0))=mrYes)  then
            begin   {continue here maybe???? }
               First;
               I:=1;
               while (I<=RecordCount) and (Flag=false) do
                  begin
                     J:=CompareText(LocLast,FieldByName('Last').AsString);
                     if J=0 then
                        begin
                           if CompareText(LocFirst,FieldByName('First').AsString)<=0 then
                              Flag:=true
                           else
                              begin
                                 Inc(I);
                                 Next;
                              end;
                        end
                     else if J>0 then
                        begin
                           Inc(I);
                           Next;
                        end
                     else Flag:=true;
                  end;
            end
               else
                  Last;
         if Flag=true then
            Insert
         else Append;
         FieldByName('Typ').AsString:='I';
         FieldByName('Id').AsInteger:=LocId;
         FieldByName('Last').AsString:=LocLast;
         FieldByName('First').AsString:=LocFirst;
         if NamShf<>'F' then
            begin
               if NamShf<>'H' then
                  FieldByName('Shf').AsString:='M'
               else FieldByName('Shf').AsString:='H';
            end
         else FieldByName('Shf').AsString:='F';
         Add_New_Name_To_TxtFile(Flag);
         Post;
         Close;
      end;
end;

procedure Save_EditedName_in_Txtfile(ID,F,L:string);
 {save edited name in YYYYMMDD.txt records}
 {ID is employee ID, F,L are new first,last names}
var
  J,K,Len:integer;
  CurFile:string;
  CFlag:boolean;
  Rec:FunFileRec;
begin
   Len:=Length(Newfile)-2;
   CurFile:=TempAlias+Copy(Newfile,1,Len)+'txt';
   Assignfile(CFile,Curfile);
   Reset(CFile);
   F:=F+'~';
   Len:=Length(F);
   if Len<15 then for J:=Len to 14 do F:=F+'~';
   L:=L+'~';
   Len:=Length(L);
   if Len<45 then for J:=Len to 43 do L:=L+'~';
   L:=L+'!';
   K:=StrToInt(ID);
   if K<1000 then ID:=' '+ID;
   if K<100 then ID:=' '+ID;
   if K<10 then ID:=' '+ID;
   CFlag:=false;
   while (EOF(CFile)=false) and (CFlag=false) do
      begin
         read(CFile,Rec);
         if Rec.Typ='I' then
            begin
               J:=CompareText(ID,Rec.Id);
               if J=0 then CFlag:=true;
            end;
      end;
   if CFlag=true then
      begin
         seek(CFile,FilePos(CFile)-1);
         read(CFile,Rec);
         Rec.First:=F;
         Rec.Last:=L;
         seek(CFile,FilePos(CFile)-1);
         write(CFile,Rec);
      end;
   Close(CFile);
end;

procedure Save_Name(ID,F,L:string);
{save modified timesheet name with ID, F irst L ast}
var
   S:string;
begin
   with Form13.Query1 do
      begin
         Close;
         UpdateOptions.RequestLive:=true;
         Sql.Clear;
         Sql.Add('Select * from "'+Newfile+'"');
         Sql.Add('where Typ="I"');
         S:=' and Shf="'+NamShf+'" and Id='+ID;
         Sql.Add(S);
         Open;
         First;
         Edit;
         FieldByName('First').AsString:=F;
         FieldByName('Last').AsString:=L;
         Post;
         Close;
         Save_EditedName_in_Txtfile(ID,F,L);
      end;
end;

procedure Delete_RecN_in_Txtfile(ThisRec:integer);
  {delete record=RecN in YYYYMMDD.txt}
var
  J,Len:integer;
  S,CurFile,BacFile:string;
  Rec:FunFileRec;
begin
   S:=IntToStr(ThisRec);
   if ThisRec<1000 then S:='0'+S;
   if ThisRec<100 then S:='0'+S;
   if ThisRec<10 then S:='0'+S;
   Len:=Length(Newfile)-2;
   CurFile:=TempAlias+Copy(Newfile,1,Len)+'txt';
   BacFile:=TempAlias+Copy(Newfile,1,Len)+'bac';
   Assignfile(BFile,CurFile);        {BFile is current YYYYMMDD.txt file}
   Assignfile(CFile,Bacfile);
   {$I-}
   erase(CFile);
   J:=IOResult;
   {$I+}
   Rename(BFile,BacFile);
   Reset(BFile);
   Assignfile(CFile,CurFile);         {CFile will be new YYYYMMDD.txt file}
   Rewrite(CFile);
   while not Eof(BFile) do
      begin
         Read(BFile,Rec);
         J:=CompareText(S,Rec.RecN);    {move only nonmatching records to new file}
         if J<>0 then write(CFile,Rec);
      end;
   close(CFile);
   close(BFile);
   erase(Bfile);
end;

procedure Delete_Name_in_Txtfile(ID:string);
  {delete all records with this ID in YYYYMMDD.txt}
var
  J,Len:integer;
  CurFile,BacFile:string;
  Rec:FunFileRec;
begin
   Len:=Length(Newfile)-2;
   CurFile:=TempAlias+Copy(Newfile,1,Len)+'txt';
   BacFile:=TempAlias+Copy(Newfile,1,Len)+'bac';
   Assignfile(BFile,CurFile);        {BFile is current YYYYMMDD.txt file}
   Rename(BFile,BacFile);
   Reset(BFile);
   Assignfile(CFile,CurFile);         {CFile will be new YYYYMMDD.txt file}
   Rewrite(CFile);
   while not Eof(BFile) do
      begin
         Read(BFile,Rec);
         J:=CompareText(ID,Rec.Id);    {move only nonmatching records to new file}
         if J<>0 then write(CFile,Rec);
      end;
   close(CFile);
   close(BFile);
   erase(Bfile);
end;

procedure Delete_Name_Plus(ID:string);
{delete all records in YYYYMMDD.db and .txt with Id=ID}
var
   K:integer;
   H:string;
begin
   with Form13.Query2 do
      begin
         Close;
         SQL.Clear;
         H:='Delete from "'+Newfile+'" ';
         SQL.Add(H);
         H:='where Id='+ID+'"';
         SQL.Add(H);
         ExecSQL;
         Close;
         Do_it(false);
         K:=StrToInt(ID);
         if K<1000 then ID:=' '+ID;
         if K<100 then ID:=' '+ID;
         if K<10 then ID:=' '+ID;
         Delete_Name_in_Txtfile(ID);
      end;
end;

procedure Add_Drop_To_File(NewStr,NamShf:string;NStar,ThisId,ThisDay,TCount:integer);
{add this drop entry to YYYYMMDD.db and .txt files as a new T record}
var
   I,K,Len,OStar:integer;
   S,CurFile:string;
   Rec:FunFileRec;
   Flag:boolean;
begin
  with Form13.Query1 do
     begin
        Close;
        UpdateOptions.RequestLive:=true;
        Sql.Clear;
        Sql.Add('Select * from "'+Newfile+'"');
        S:='where Typ="T" and Id='+IntToStr(ThisId)+' and Dat='+IntToStr(ThisDay);
        Sql.Add(S);
        Open;
        First;
        Flag:=false;
        while (not EOF) and (Flag=false) do
           begin
              S:=Copy(FieldByName('First').ASString,4,4);
              InTime(S,OStar);
              if OStar>NStar then Flag:=true
              else Next;
           end;
        if Flag=true then Insert
        else Append;
        FieldByName('RecN').AsInteger:=TCount-1;
        FieldByName('Id').AsInteger:=ThisId;
        FieldByName('Typ').AsString:='T';
        FieldByName('Shf').AsString:=NamShf;
        FieldByName('Dat').AsInteger:=ThisDay;
        FieldByName('Star').AsInteger:=StrToInt(Copy(NewStr,4,4));
        FieldByName('First').AsString:=Copy(Newstr,1,11);
        FieldByName('Last').AsString:=Copy(Newstr,12,Length(Newstr)-13);
        Post;
        Close;
     end;
  Len:=Length(Newfile)-2;
  CurFile:=TempAlias+Copy(Newfile,1,Len)+'txt';
  Assignfile(CFile,Curfile);
  Reset(CFile);
  Seek(CFile,FileSize(CFile));
  Rec.Typ:='T';
  I:=TCount-1;
  S:=IntToStr(I);
  if I<1000 then S:='0'+S;
  if I<100 then S:='0'+S;
  if I<10 then S:='0'+S;
  Rec.RecN:=S;
  K:=ThisId;
  S:=IntToStr(ThisId);
  if K<1000 then S:=' '+S;
  if K<100 then S:=' '+S;
  if K<10 then S:=' '+S;
  Rec.Id:=S;
  Rec.Shif:=NamShf;
  Rec.Daye:=IntToStr(ThisDay);
  Rec.Star:=Copy(NewStr,4,4);
  Rec.First:=Copy(Newstr,1,11);
  Rec.Last:=Copy(Newstr,12,Length(Newstr)-13);
  write(CFile,Rec);
  Close(CFile);
end;

procedure DoDeleteRec(ThisRec:integer);
   {delete recN from yyyymmdd.db}
var
   H,S:string;
begin
   S:=IntToStr(ThisRec);
   with Form13.Query2 do
      begin
         Close;
         SQL.Clear;
         H:='Delete from "'+Newfile+'" ';
         SQL.Add(H);
         H:='where RecN='+S;
         SQL.Add(H);
         ExecSQL;
         Close;
      end;
   Delete_RecN_in_Txtfile(ThisRec);
end;

procedure Modify_TFirst_Record(ThisRec:integer;var S:string);
{modify First field of ThisRec in YYYYMMDD.db and .txt; return Last field in S}
var
   T,U,CurFile:string;
   J,Len:integer;
   Rec:FunFileRec;
   CFlag:boolean;
begin
     with Form13.Query1 do
        begin
           Close;
           UpdateOptions.RequestLive:=true;
           SQL.Clear;
           T:='Select * from "'+Newfile+'"';
           SQL.Add(T);
           T:='where RecN='+IntToStr(ThisRec);
           SQL.Add(T);
           Open;
           Edit;
           T:=Copy(FieldByName('First').AsString,1,3);{T=Time id# of this entry}
           U:=T+S;
           FieldByName('First').AsString:=T+S;
           S:=FieldByName('Last').AsString;
           Post;
           Close;
        end;
     T:=IntToStr(ThisRec);
     if ThisRec<1000 then T:='0'+T;
     if ThisRec<100 then T:='0'+T;
     if ThisRec<10 then T:='0'+T;
     Len:=Length(Newfile)-2;
     CurFile:=TempAlias+Copy(Newfile,1,Len)+'txt';
     Assignfile(BFile,CurFile);        {BFile is current YYYYMMDD.txt file}
     Reset(BFile);
     CFlag:=false;
     while (not Eof(BFile)) and (Cflag=false) do
        begin
           Read(BFile,Rec);
           if Rec.Typ='T' then
              begin
                 J:=CompareText(T,Rec.RecN);    {find proper record number to modify}
                 if J=0 then CFlag:=true;
              end;
        end;
     if Cflag=true then     {if found, add modified first field record to file}
        begin
           seek(BFile,Filepos(BFile)-1);
           Rec.First:=U;
           write(BFile,Rec);
        end;
     closefile(BFile);
end;

procedure Modify_Clock_Record(RecNo,S:string);
{modify a record in yyyymmdd.txt}
{RecNo is record number; S is Rec.First field}
var
   J,Len:integer;
   CFlag:boolean;
   CurFile:string;
   Rec:FunFileRec;
begin
   Len:=Length(Newfile)-2;
   CurFile:=TempAlias+Copy(Newfile,1,Len)+'txt';
   Assignfile(BFile,CurFile);        {BFile is current YYYYMMDD.txt file}
   Reset(BFile);
   CFlag:=false;
   while (not Eof(BFile)) and (Cflag=false) do
      begin
         Read(BFile,Rec);
         if (Rec.Typ='T') or (Rec.Typ='t') then
            begin
               J:=CompareText(RecNo,Rec.RecN);    {find proper record number to modify}
               if J=0 then CFlag:=true;
            end;
      end;
   if Cflag=true then     {if found, add modified first field record to file}
      begin
         seek(BFile,Filepos(BFile)-1);
         Rec.First:=S;
         Rec.Typ:='t';
         write(BFile,Rec);
      end;
   closefile(BFile);
end;

procedure FindBacRec(OldRec:integer;var Rec:FunFileRec;CFlag:boolean);
{check backup file for RecN matching OldRec}
var
   I:integer;
begin
   reset(BFile);
   while not (Eof(BFile)) and (CFlag=false) do
      begin
         Read(BFile,Rec);
         if (Rec.Typ='T') or (Rec.Typ='t') then   {read each 'T' record}
             begin
                I:=StrToInt(Rec.RecN);   {if Rec.RecN is the same as old record no. return with data in Rec and CFlag=true}
                if I=OldRec then
                   CFlag:=true;
             end;
      end;
end;

procedure Regen;
{regenerate yyyymmdd.txt from Newfile (current yyyymmdd.db file)}
var
  I,J,K,Len,EId,OldRec,NewRec:integer;
  CurFile,BacFile:string;
  BFlag,CFlag:boolean;
  S,SRecN:string;
  Rec:FunFileRec;

begin
   CFlag:=true;
   Len:=Length(Newfile)-2;
   CurFile:=TempAlias+Copy(Newfile,1,Len)+'txt';
   BacFile:=TempAlias+Copy(Newfile,1,Len)+'bac';
   Assignfile(CFile,BacFile);        {CFile is possible current YYYYMMDD.bac file}
   {$I-}
   Reset(CFile);
   if Ioresult=0 then    {if a backup file found for this yyyymmdd, delete it}
      begin
         Close(CFile);
         Erase(CFile);
      end;
   Closefile(CFile);
   assignfile(BFile,Curfile);
   K:=IOResult;
   Reset(BFile);
   if IOresult=0 then    {if already a current file found for this yyyymmdd}
      begin              {   rename it to .bac file}
         CloseFile(BFile);
         Rename(BFile,BacFile);   {BFile will be used to remake CFile}
         BFlag:=true;
      end
   else BFlag:=false;   {here if no .bac file exists}
   Assignfile(CFile,CurFile);         {CFile will be new YYYYMMDD.txt file}
   Rewrite(CFile);
   K:=IOResult;
   {$I+}
   with Form13 do
      with Query1 do
         begin
            Close;
            UpdateOptions.RequestLive:=true;
            SQL.Clear;
            S:='Select * from "'+Newfile+'"';
            SQL.Add(S);
            Open;
            NewRec:=1;
            Form6.SyncLabel.Visible:=true;
            if RecordCount>0 then for I:=1 to RecordCount do
               begin
                  Form6.SyncLabel.Caption:='Regening '+IntToStr(I)+ ' of '+IntToStr(RecordCount);
                  Form6.SyncLabel.Repaint;
                  Application.ProcessMessages;
                  OldRec:=FieldByName('RecN').AsInteger;
                  Edit;
                  if FieldByName('Typ').AsString='T' then  {Update new record number in .db}
                      FieldByName('RecN').AsInteger:=NewRec
                  else FieldByName('RecN').AsString:='';
                  Post;
                  SRecN:=IntToStr(NewRec);
                  if NewRec<1000 then SRecN:='0'+SRecn;  {Get new record number ready for .txt}
                  if NewRec<100 then SRecN:='0'+SRecN;
                  if NewRec<10 then SRecN:='0'+SRecN;
                  if FieldByName('Typ').AsString='C' then {if first record then copy data from .db to Rec for .txt}
                     begin
                        Rec.Typ:='C';
                        Rec.RecN:=B4;
                        Rec.Id:='   1';  {this is temporary record count}
                        Rec.Shif:=' ';
                        Rec.Daye:=' ';
                        Rec.Star:=B4;
                        S:=FieldByname('First').AsString+'~'; {weekday modes here}
                        Len:=Length(S);
                        if Len<14 then for J:=Len to 14 do S:=S+'~';  {pad it out to 14 char.s}
                        Rec.First:=S;
                        S:=FieldByName('Last').AsString+'~';   {set record Last field - last name for I rec.s; data for t rec.s}
                        Len:=Length(S);
                        if Len<42 then for J:=Len to 42 do S:=S+'~';  {pad it out to 42 char.s}
                        Rec.Last:=S;
                     end
                  else if FieldByName('Typ').AsString='I' then   {here for name records}
                     begin
                        Rec.Typ:='I';
                        Rec.RecN:=B4;
                        Rec.Id:=FieldByName('Id').AsString;
                        Rec.Shif:=FieldByName('Shf').AsString;
                        Rec.Daye:=FieldByName('Dat').AsString;
                        Rec.Star:=FieldByName('Star').AsString;
                        S:=FieldByname('First').AsString+'~';
                        Len:=Length(S);
                        if Len<14 then for J:=Len to 14 do S:=S+'~';  {pad it out to 14 char.s}
                        Rec.First:=S;
                        S:=FieldByName('Last').AsString+'~';   {set record Last field - last name for I rec.s; data for t rec.s}
                        Len:=Length(S);
                        if Len<42 then for J:=Len to 42 do S:=S+'~';  {pad it out to 42 char.s}
                        Rec.Last:=S;
                     end
                  else if FieldByName('Typ').AsString='T' then    {here for a T record}
                     begin
                        if BFlag=true then  {if there is a .bac file, try to find OldRec}
                           begin
                              CFlag:=false;
                              FindBacRec(OldRec,Rec,CFlag);  {if OldRec found, then Rec is set to data from .bac}
                           end;
                        if (BFlag=false) or (CFlag=false) then   {if no OldRec found or no .bac file, make new record from YYYYMMDD.db}
                           begin
                              Rec.RecN:=SRecN;
                              Rec.Typ:=FieldByName('Typ').AsString;
                              S:=FieldByName('Id').AsString;  {set record Emp Id no.}
                              J:=StrToInt(S);
                              if J<1000 then S:=' '+S;
                              if J<100 then S:=' '+S;
                              if J<10 then S:=' '+S;
                              Rec.Id:=S;
                              S:=Copy(FieldByName('Shf').AsString,1,1); {set record Emp shift}
                              if S='' then S:=' ';
                              Rec.Shif:=S;
                              Rec.Daye:=FieldByName('Dat').AsString;
                              S:=Copy(FieldByName('Star').AsString,1,4); {set record Start Shift time}
                              J:=StrToInt(S);
                              if J<1000 then S:='0'+S;
                              if J<100 then S:='0'+S;
                              if J<10 then S:='0'+S;
                              Rec.Star:=S;
                              S:=FieldByname('First').AsString+'~';
                              Len:=Length(S);
                              if Len<14 then for J:=Len to 14 do S:=S+'~';  {pad it out to 14 char.s}
                              Rec.First:=S;
                              S:=FieldByName('Last').AsString+'~';   {set record Last field - last name for I rec.s; data for t rec.s}
                              Len:=Length(S);
                              if Len<42 then for J:=Len to 42 do S:=S+'~';  {pad it out to 42 char.s}
                              Rec.Last:=S;
                           end;
                     end;
                  if FieldByName('Typ').AsString='T' then NewRec:=NewRec+1;
                  write(CFile,Rec);
                  Next;
               end;
            First;
            S:=IntToStr(NewRec);
            if NewRec<1000 then S:='0'+S;
            if NewRec<100 then S:='0'+S;
            if NewRec<10 then S:='0'+S;
            Edit;
            FieldByName('Id').AsString:=S;
            Post;
            reset(CFile);
            read(CFile,Rec);
            Rec.Id:=S;
            reset(Cfile);
            write(CFile,Rec);
            if BFlag=true then CloseFile(BFile);
            Closefile(CFile);
         end;
end;

procedure Remote_TRec(var NRec:FunFileRec);
{process building a new T record from data supplied remotely for override entry}
{enter with valid data in Rec.Id, REc.Shif, Rec.Day and sign-in time in proper place in Rec.First}
var
   I,Str,Sto,Sig,Len,X:integer;
   S,T,NewStar,NewFir,NewLas,U:string;
begin
   NRec.Typ:='T';      {change record type from 't' to 'T'}
   DoCount(TCount,U); {get next available record number in TCount}
   S:=IntToStr(TCount);
   if TCount<1000 then S:='0'+S;
   if TCount<100 then S:='0'+S;
   if TCount<10 then S:='0'+S;
   NRec.RecN:=S;                {Add new record number}
   S:=Copy(NRec.First,4,4);
   Sig:=StrToInt(S);              {Sig=sign-in time}
   NewStar:='';
   NewFir:='';
   NewLas:='';
   with Form13.TimeGridP do for I:=0 to RowCount-1 do
      begin
         S:=Cells[2,I];   {S=time data field for this parenttime entry}
         Len:=Length(Cells[2,I]);  {Len = length of time data field}
         T:=Copy(S,4,4);
         Str:=StrToInt(T);  {Str=Start time for this time entry}
         T:=Copy(S,8,4);
         T:=Cells[6,I];
         X:=StrToInt(T);    {X=Star field for this entry}
         if (Sig<=Str) and (Len=14)    {find last start time >= to sign in time}
           and (X>0) and (X<9999) then           {Star field must be >0 and less than 9999}
            begin                               {also must be single child field - only adding one entry to timesheet with override}
               NewStar:=Copy(S,4,4);
               T:=Copy(NRec.First,1,1)+Cells[0,I]+Copy(NRec.First,4,4)+Copy(Cells[2,I],8,7);
               NewFir:=T;
               NewLas:=Cells[2,I];
            end;
      end;
   if NewStar<>'' then
      begin
         NRec.Star:=NewStar;
         NRec.First:=NewFir;
         NRec.Last:=NewLas;
      end;
end;

procedure Sync(var RFlag:boolean);
{sync Newfile (current yyyymmdd.db file) with input text file (yyyymmdd.txt)}
{The input file changes only the start/stop times in the parent field of records}
{  except if it is an override record in which case the entire record must be }
{   rebuilt in the .txt file and also appended to the .db file}
{Override record must provde emp. id and shift, day of week, and start time}
{    unless this is first record of the week for an employee which means new I record also}
var
   I,J,Len,TRecN,SId,Dy,Str:integer;
   S,Ln,Curfile,T:string;
   Rec:FunFileRec;
   BFile:file of FunFileRec;
   CFlag:boolean;
begin
 with Form13 do
  begin
   Len:=Length(Newfile)-2;
   CurFile:=TempAlias+Copy(Newfile,1,Len)+'txt';
   Assignfile(BFile,CurFile);        {BFile is current YYYYMMDD.txt file}
   Reset(BFile);
   FileCount:=FileSize(Bfile);
   Form6.SyncLabel.Visible:=true;
   with Query2 do   {get all T records from Newfile}
      begin
         Close;
         UpdateOptions.RequestLive:=true;
         Sql.clear;
         Sql.Add('Select * from "'+Newfile+'" where Typ="T"');
         Open;
         First;
      end;
   if Query2.RecordCount>0 then
      {while Eof(BFile)=false do}
      for Ct:=1 to FileSize(BFile) do
         begin
            Form6.SyncLabel.Caption:='Syncing '+IntToStr(Ct)+ ' of '+IntToStr(FileCount);
            Form6.SyncLabel.Repaint;
            Application.ProcessMessages;
            Seek(BFile,Ct-1);
            Read(Bfile,Rec);   {check only 't' (updated) records from BFile}
            if Rec.Typ='t'then
                if Rec.RecN='9999' then
                  begin
                     S:='Record= 9999 Unscheduled';
                     Form6.LB2.Items.Add(S);
                     T:=Rec.Id;
                     GetName(T);
                     S:='    Name= '+T;
                     Form6.LB2.Items.Add(S);
                     S:='    FilePos= '+IntToStr(Ct);
                     Form6.LB2.Items.Add(S);
                     S:='    Day= '+Rec.Daye+' Start= '+Copy(Rec.First,4,4);
                     Form6.LB2.Items.Add(S);
                  end
               else  {otherwise process updated T record here}
                  begin
                     CFlag:=false;
                     with Query2 do   {find correct RecN in .db and update First field}
                        begin
                           Close;
                           Sql.clear;
                           Sql.Add('Select * from "'+Newfile+'" where Typ="T" and RecN='+Rec.RecN);
                           Open;
                           First;
                           if RecordCount>0 then  {Record numbers match}
                              begin
                                 CFlag:=true;
                                 SId:=FieldByName('Id').AsInteger;
                                 if StrToInt(Rec.Id)=SId then   {Emp Id numbers match}
                                    begin
                                       Dy:=FieldByname('Dat').AsInteger;
                                       if StrToInt(Rec.Daye)=Dy then  {DoW matches}
                                          begin
                                             Str:=FieldByName('Star').AsInteger;
                                             Ln:=FieldByName('Last').AsString;
                                             if (StrToInt(Rec.Star)=Str) then
                                                begin
                                                   if StrToInt(Copy(Rec.First,8,4))>StrToInt(Copy(Rec.Last,4,4)) then  {clocked out time > start time?}
                                                      begin
                                                         S:=Copy(Rec.First,1,11);
                                                         Edit;
                                                         FieldByName('First').AsString:=S;
                                                         Post;
                                                         RFlag:=true;
                                                         Rec.Typ:='T';        {reset 'updated record' marker}
                                                         seek(BFile,FilePos(BFile)-1);
                                                         write(BFile,Rec);
                                                      end
                                                   else
                                                      begin    {Add time mismatch error info to Form6.LB2}
                                                         S:='Record= '+Rec.RecN+ ' Time mismatch';
                                                         Form6.LB2.Items.Add(S);
                                                         T:=Rec.Id;
                                                         GetName(T);
                                                         S:='   Name= '+T;
                                                         Form6.LB2.Items.Add(S);
                                                         S:='   Day= '+Rec.Daye;
                                                         Form6.LB2.Items.Add(S);
                                                         S:='   Rec.First= '+Rec.First;
                                                         Form6.LB2.Items.Add(S);
                                                         S:='  Rec.Last= '+Rec.Last;
                                                         Form6.LB2.Items.Add(S);
                                                      end;
                                                end
                                             else
                                                begin    {Add start time error info to Form6.LB2}
                                                   S:='Record= '+IntToStr(J)+ ' Start mismatch';
                                                   Form6.LB2.Items.Add(S);
                                                end
                                          end
                                       else
                                          begin   {add day error info to Form6.LB2}
                                             S:='Record= '+IntToStr(J)+ ' Day mismatch';
                                             Form6.LB2.Items.Add(S);
                                          end;
                                    end
                                 else  {no Id match}
                                    begin {add Id error info to Form6.LB2}
                                       S:='Record= '+IntToStr(J)+ ' Emp Id mismatch';
                                       Form6.LB2.Items.Add(S);
                                    end;
                              end;
                        end;
                     if CFlag=false then
                        begin   {here if no matching record found}
                           S:='Record= '+IntToStr(J)+ ' No record match';
                           Form6.LB2.Items.Add(S);
                        end;
                  end;
         end; {end of main loop}
   Form6.SyncLabel.Visible:=false;
   Query2.Close;
   closefile(BFile);

   {this section currently not needed - no new employees can be added remotely 5/28/2020}
   {here if new I records need to be added to files}
   {with Queue do
      if RowCount>1 then
        begin
         OverFlag:=true;
         CFlag:=false;
         for I:=RowCount-1 downto 1 do
            begin
               LocId:=StrToInt(Cells[0,I-1]);
               LocFirst:=Cells[1,I-1];
               LocLast:=Cells[2,I-1];
               NamShf:=Cells[3,I-1];
               Add_New_Name_To_Timesheet(CFlag);
               for J:=0 to 3 do Cells[J,I-1]:='';
            end;
         RowCount:=1;
         OverFlag:=false;
        end;}
  end;
end;


procedure DoTime(Flag:boolean;var U:String);
   {convert 8 byte alphabetical string HHMMHHMM to "12:00-10:00" format}
   {Flag is true if 'a' for 'am' is to be included}
   {Star is position of '-'}
var
   S,T:string;
   I:integer;
   PM:boolean;
begin
   I:=StrToInt(Copy(U,1,2));
   if I>=12 then
      begin
         PM:=true;
         I:=I-12;
      end
   else PM:=false;
   if I=0 then I:=12;
   S:=IntToStr(I);
   if I<10 then S:=' '+S;
   I:=StrToInt(Copy(U,3,2));
   T:=IntToStr(I);
   if I<10 then T:='0'+T;
   S:=S+':'+T;
   if (PM=false) and (Flag=true) then S:=S+'a-'
   else S:=S+'-';
   I:=StrToInt(Copy(U,5,4));
   if I<>9999 then
      begin
         I:=StrToInt(Copy(U,5,2));
         if I>=12 then
            begin
               PM:=true;
               I:=I-12;
            end
         else PM:=false;
         if I=0 then I:=12;
         T:=IntToStr(I);
         if I<10 then T:=' '+T;
         S:=S+T;
         I:=StrToInt(Copy(U,7,2));
         T:=IntToStr(I);
         if I<10 then T:='0'+T;
         S:=S+':'+T;
         if (PM=false) and (Flag=true) then
            S:=S+'a';
      end;
   U:=S;
end;

procedure TestEmp(var X:integer);
{test current yyyymmdd.db for duplicate entries}
var
   I,J,K,L,Y:integer;
   S:string;
begin
   with Form13 do
      begin
         Y:=0;
         with Query1 do
            begin
               Close;
               UpdateOptions.RequestLive:=true;
               SQL.Clear;
               S:='Select * from "'+Nufile+'"';
               SQL.Add(S);
               SQL.Add('where Typ="I"');
               Open;
               First;
            end;
         if Query1.RecordCount>0 then for I:=1 to Query1.RecordCount do
            begin
               L:=Query1.FieldByName('Id').AsInteger;
               with Query2 do
                  begin
                     Close;
                     UpdateOptions.RequestLive:=true;
                     SQL.Clear;
                     S:='Select * from "'+Nufile+'"';
                     SQL.Add(S);
                     SQL.Add('where Typ="T" and Id='+IntToStr(L));
                     Open;
                  end;
               Queue.RowCount:=0;
               if Query2.RecordCount>0 then  for J:=1 to Query2.RecordCount do  with Queue do
                  begin
                     Cells[0,RowCount]:=Query2.FieldByName('Dat').AsString;
                     Cells[1,RowCount]:=Query2.FieldByName('Star').AsString;
                     Cells[2,RowCount]:=Query2.FieldByName('First').AsString;
                     Cells[3,Rowcount]:=Query2.FieldByName('RecN').AsString;
                     Cells[4,RowCount]:=Query2.FieldByName('Last').AsString;
                     Cells[5,RowCount]:=Query2.FieldByName('Id').AsString;
                     RowCount:=RowCount+1;
                     Query2.Next;
                  end;
               if Queue.RowCount>0 then with Queue do
                  begin
                     L:=1;
                     for J:=1 to Rowcount-2 do
                        begin
                           for K:=L+1 to RowCount-1 do
                              begin
                                 if Cells[0,J]=Cells[0,K] then  {if same day}
                                  begin
                                    if (Copy(Cells[2,J],2,2)='99') and (Copy(Cells[2,K],2,2)='99') then
                                       begin   {if  two extra times}
                                          if Y<=45 then
                                             begin
                                                S:=Cells[5,J];
                                                GetName(S);
                                                if StrToInt(Cells[3,J])<10 then Cells[3,J]:='0'+Cells[3,J];
                                                if StrToInt(Cells[3,J])<100 then Cells[3,J]:='0'+Cells[3,J];
                                                if StrToInt(Cells[3,J])<1000 then Cells[3,J]:='0'+Cells[3,J];
                                                if StrToInt(Cells[3,K])<10 then Cells[3,K]:='0'+Cells[3,K];
                                                TestArray[Y+1]:='X'+Cells[0,J]+' '+Cells[3,J]+':'+Copy(Cells[4,J],12,3)+' '+S;
                                                if StrToInt(Cells[3,K])<10 then Cells[3,K]:='0'+Cells[3,K];
                                                if StrToInt(Cells[3,K])<100 then Cells[3,K]:='0'+Cells[3,K];
                                                if StrToInt(Cells[3,K])<1000 then Cells[3,K]:='0'+Cells[3,K];
                                                TestArray[Y+2]:='X'+Cells[0,J]+Cells[3,K]+':'+Copy(Cells[4,K],12,3);
                                                TestArray[Y+3]:='------';
                                                Y:=Y+3;
                                             end
                                          else TestArray[50]:='more';
                                       end
                                    else if (Cells[1,J]=Cells[1,K]) then
                                       begin  {same start time}
                                          if Y<=44 then
                                             begin
                                                S:=Cells[5,K];
                                                GetName(S);
                                                if StrToInt(Cells[3,J])<10 then Cells[3,J]:='0'+Cells[3,J];
                                                if StrToInt(Cells[3,J])<100 then Cells[3,J]:='0'+Cells[3,J];
                                                if StrToInt(Cells[3,J])<1000 then Cells[3,J]:='0'+Cells[3,J];
                                                TestArray[Y+2]:='X'+Cells[0,J]+Cells[3,J]+':'+Copy(Cells[4,J],12,3);
                                                if StrToInt(Cells[3,K])<10 then Cells[3,K]:='0'+Cells[3,K];
                                                if StrToInt(Cells[3,K])<100 then Cells[3,K]:='0'+Cells[3,K];
                                                if StrToInt(Cells[3,K])<1000 then Cells[3,K]:='0'+Cells[3,K];
                                                TestArray[Y+3]:=Cells[3,K]+':'+Copy(Cells[4,K],12,3);
                                                TestArray[Y+3]:='------';
                                                Y:=Y+3;
                                             end
                                          else TestArray[50]:='more';
                                       end;
                                  end;
                              end;
                           L:=L+1;
                        end;
                  end;
               Query1.Next;
            end;
         Query1.Close;
         Query2.Close;
         X:=Y;
      end;
end;

end.
