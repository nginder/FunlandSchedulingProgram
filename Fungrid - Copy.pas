unit Fungrid;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Grids, Db , Gauges, StdCtrls, ExtCtrls, Printers, DateUtils, FireDAC.Comp.Client, FireDAC.Stan.Intf, FireDAC.Stan.Option,
FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.Comp.DataSet;

type
  TForm13 = class(TForm)
    Ga1: TGauge;
    Query1: TFDQuery;
    SG1: TStringGrid;   {holds time/pos data for each emp as calc from YYYYMMDD.db}
                        {col=0 is emp Id string; col=1 is emp name as <first>$d$a<last>;}
                          {col=2 is shift 'H' or 'F' or 'M' etc.; cols=3-9 represent days of week 1-7}
    Label1: TLabel;
    Timer1: TTimer;
    LB2: TListBox;
    HG1: TStringGrid;
    ColorGrid: TStringGrid;
    Query2: TFDQuery;
    Table1: TFDTable;
    List1: TListBox;
    TimeGridP: TStringGrid;
    TimeGridC: TStringGrid;
    Queue: TStringGrid; {holds time data from Funtimes.db}
                            {col=0 is time string id; col=1 is time string; col=2 is time data}
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
   {OrangeColor = clMaroon;}
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
   SchoolEndDay = 15;
   MaxFifteenHoursPerDay = 8;  {Max. total hours allowed per day 14-15 year olds}
   Sevencode = '+04';  {Time code for 7:00- time entry}
   SevenThirtyCode = '+30'; {Time code for 7:30- time entry}
   EightThirtyCode = '+13'; {Time code for 8:30- time entry}
   B14 = '              ';  {fill for .txt fields}
   B4 = '    ';
   MaxEntries = 10;  {maximum no. of time entries allowed for eacvh employee per day}
   UPMark = 'U';    {unpaid break marker in timedata}
   PdMark = 'u';    {paid break marker in timedata}
   OffMark = '/';    {this is 1st character in a time string - indicates an off time entry}
   LocalDriveAlias = 'C:/funland';
   RemoteDriveAlias = 'T:/TextFiles';
   LocalAlias ='Funland';
   RemoteAlias ='Funland1';
   Max_Sched_Display_Cols = 10; {max. no. of columns to be displayed in FunSched}

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
  NamShf:string;
  {NamShf=shift of currently selected name label}
  {...possible values: M=minor,H=hourly,P=parttime}
  SixteenYearsOld, EighteenYearsOld,
    FourteenYearsOld,LaborDay,SchoolEnd:TDateTime;  {Age level time variables}
  MaxFifteenMInutes:real;  {max. hrs. weekly work for 14-15 year olds set in funsheet.pas}
  FMins: array[1..7] of integer;  {holds daily minutes for a week of 14-15 employee}
  TCount:integer; {Count of records in YYMMDD.DB file}
  Y,M,D:word;
  Filemask,Newfile:string;
  Rarray:array[1..MaxEmp,0..1] of integer;
  LastEntry,Daze,NewDaze:integer;
  Chckflag:boolean;
  CFile,BFile:file of FunFileRec;  {typed file variables}
  RecIn,RecOut: FunFileRec;   {variables for passing YYYYMMDD.db record values}
  OverFlag: boolean;   {set to true when override input requires adding new I records - append new records nonalphabetically}

procedure FillColorGrid;
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
procedure Add_Drop_To_File(NewStr,NamShf:string;NStar,ThisId,ThisDay,TCount:integer);
procedure DoDeleteRec(ThisRec:integer);
procedure Modify_TFirst_Record(ThisRec:integer;var S:string);
procedure FindRecord(Nmbr:integer;Typ:string;var Shf,CurRec:string);
procedure ModifyRecord(CurRec,ColId:string;Dest:string);
procedure GetInfo(Nmbr:integer;var FName,LName,Shf:string);
procedure AddTrainingData;
procedure Regen;
procedure Sync(var RFlag:boolean);
procedure ModifyBreak(WrecN:integer;T:string);

implementation

{$R *.DFM}

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
   T:string;
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
   {convert 4 byte string HHMM to minutes since midnight}
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

procedure FillHistGrid;
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

procedure FillColorGrid;
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
               Sql.Add('select Empnmbr, SchedName,Last,First, Shift from "Employ.db"');
               Sql.Add('order by Empnmbr');
               Open;
               First;
               ColorGrid.RowCount:=RecordCount;
               for I:=1 to RecordCount do
                  begin
                     S:=FieldByName('SchedName').AsString;
                     if S='' then
                        S:=FieldByName('First').AsString+' '+Copy(FieldByName('Last').AsString,1,1);
                     ColorGrid.Cells[1,I]:=S;
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
   I,J,K,NewId,CurId,Resp,GridX,TotRec,ProRec:integer;
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
               RequestLive:=true;
               Sql.Clear;
               Sql.Add('select Id,Shf,Last,First');
               Sql.Add('from "'+Nufile+'"');
               Sql.Add('where Typ="I"');
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
                              RequestLive:=true;
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
                               Post;
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
               Sql.Clear;
               Sql.Add('select Id,Dat,Star,Shf,First,Last,RecN');
               Sql.Add('from "'+Nufile+'"');
               Sql.Add('where Typ="T"');
               Sql.Add('order by Id,Dat,Star');
               Open;
               First;
            end;
         with SG1 do   {process time data from YYYYMMDD.db to SG1 grid}
            begin
               CurId:=0;   {CurId = employee id of current row of SG1}
               for I:=1 to Query1.RecordCount do   {Process thru every T record found}
                  begin
                     NewId:=Query1.FieldByName('Id').AsInteger; {NewId = employee id field of current record in Query1}
                     if NewId<>CurId then  {here if this is not the right row of SG1 for the T record being processed}
                        begin
                           GridX:=0;       {GridX=row pointer in SG1}
                           Flag:=false;    {Flag=true when proper row in SG! is found}
                           repeat          {set GridX to proper row in SG1}
                               CurId:=StrToInt(Cells[0,GridX]);
                               if CurId=NewId then
                                  Flag:=true
                               else Inc(GridX);
                           until (Flag=true) or (GridX=RowCount);
                        end;
                     if NewId=CurId then     {if somehow no proper row is found, ignore this T record}
                        begin                {otherwise, process T record to proper column}
                           J:=Query1.FieldByName('Dat').AsInteger;   {J=day of week for this T record}
                           S:=Query1.FieldByName('First').AsString  {parent string, length of 11 chars.}
                              +Query1.FieldByName('Last').AsString  {child strings, each length of 14 chars.}
                              +#13#10;
                           K:=Query1.FieldByName('RecN').AsInteger;
                           AdjCount(K,T);                           {adjust record no. for RecN's above 999}
                           Cells[J+2,GridX]:=Cells[J+2,GridX]+T+S;   {days of week columns are 3-9}
                        end;                                          {add adjusted RecN+First+Last fields+#d#a to data already present (multiple entries for this day if any)}
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
         Query1.Close;
         Query2.Close;
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
         Sql.Add('Select * from "Funtimes.Db"');
         Sql.Add('where PorC="P"');
         Sql.Add('order by Star');
         Open;
         First;
         TimeGridP.RowCount:=RecordCount;
         for I:=1 to RecordCount do
            begin
               S:=FieldByName('Id').AsString;
               J:=STrToInt(S);
               if (J<10) and (J>0) then
                  S:='0'+S;
               TimeGridP.Cells[0,I-1]:=S;
               TimeGridP.Cells[1,I-1]:=FieldByName('Lab').AsString;
               TimeGridP.Cells[2,I-1]:=FieldByName('TData').AsString;
               TimeGridP.Cells[3,I-1]:=FieldByName('NoShow').AsString;
               TimeGridP.Cells[4,I-1]:=FieldByName('UPBreak').AsString; {use this field for potential unpaid evening break}
               TimeGridP.Cells[5,I-1]:=FieldByName('AltId').AsString;
               TimeGridP.Cells[6,I-1]:=FieldByName('Star').AsString;
               TimeGridP.Cells[7,I-1]:=FieldByName('TName').AsString;
               Next;
            end;
         Close;
         Sql.Clear;
         Sql.Add('Select * from "Funtimes.Db"');
         Sql.Add('where PorC="C"');
         Sql.Add('order by Star');
         Open;
         First;
         TimeGridC.RowCount:=RecordCount;
         for I:=1 to RecordCount do
            begin
               S:=FieldByName('Id').AsString;
               J:=STrToInt(S);
               if (J<10) and (J>0) then S:='0'+S;
               TimeGridC.Cells[0,I-1]:=S;
               TimeGridC.Cells[1,I-1]:=FieldByName('Lab').AsString;
               TimeGridC.Cells[2,I-1]:=FieldByName('TData').AsString;
               TimeGridC.Cells[3,I-1]:=FieldByName('NoShow').AsString;
               TimeGridC.Cells[4,I-1]:=FieldByName('UPBreak').AsString;
               TimeGridC.Cells[5,I-1]:=FieldByName('AltId').AsString;
               TimeGridC.Cells[6,I-1]:=FieldByName('Star').AsString;
               TimeGridC.Cells[7,I-1]:=FieldByName('TName').AsString;
               Next;
            end;
         Close;
      end;

end;

procedure TForm13.FormActivate(Sender: TObject);
var
   S:string;
begin
   {Query1.Databasename:=Aliass;
   Query2.DatabaseName:=Aliass;}
   if EmpFlag=true then
      begin
         Label1.Caption:='Building employee worksheet database';
         Do_it(true);
      end
   else
      FillHistGrid;
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
   I,J,X,Y:integer;
   S:string;
   T:string[100];
begin
   with Form13 do
     begin
        for X:=1 to MaxEmp do for Y:=1 to 2 do Rarray[X,Y]:=0;
        LastEntry:=0;
        with Query2 do
           begin
              close;
              RequestLive:=true;
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
  Flag:boolean;
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
              RequestLive:=true;
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
   PrepRotationData;
   I:=Form13.List1.Items.Count-1; {LB2 has yyyymmdd strings; Count:=total # of .db files}
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
         FileMask:=IntToStr(Y)+'*.db';
         FDManager.GetTableNames(Aliass1,FileMask,false,false,List1.Items);
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


procedure FindRecord(Nmbr:integer;Typ:string;var Shf,CurRec:string);
   {use Query1 to check for records in yyyymmdd.db for employee Id=Nmbr}
   {if Typ='I', search for I record;}
   {if Typ='T', search for T records w/ Offset [schedule day of week]}
var
   S:string;
   I:integer;
begin
   with Form13.Query1 do
      begin
         Close;
         UpdateOptions.RequestLive:=true;
         Sql.clear;
         Sql.Add('Select *');
         S:='from "'+Newfile+'"';
         Sql.Add(S);
         if Typ='T' then
            S:='where Typ="T" and Dat='+IntToStr(Offset)+'and Id='+IntToStr(Nmbr)
         else
            S:='where Typ="I" and Id='+IntToStr(Nmbr);
         Sql.Add(S);
         Open;
         First;
         if RecordCount>0 then
            begin
               Shf:=FieldByName('Shf').AsString;
               I:=FieldByName('RecN').AsInteger;
               CurRec:=IntToStr(I);
               if I<1000 then CurRec:='0'+CurRec;
               if I<100 then CurRec:='0'+CurRec;
               if I<10 then CurRec:='0'+CurRec;
            end
         else
            begin
               Shf:='';
               CurRec:='';
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

procedure ModifyBreak(WrecN:integer;T:string);
{modify LAST field of record number=WreN in .db and.txt to change unpaid/paid status}
{T=child srring of entry with break in it}
var
   S,U,V:string;
   I:integer;
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
   S:string;
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
         Rec.First:=B14;
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


    WNetCancelConnection2('P:',dwFlags,false);
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
   FDManager.PrivateDir:='C:\Funland';
   List1.Clear;       {try to find network drive pointed to by alias "Funland1"}
   Test:=0;
   LocalFlag:=false;
   {continue here to check for local alias}
   try
      FDManager.GetAliasParams(LocalAlias,List1.Items);
   except
      MessStr:='Warning: Local alias [Funland] not Found!'+#13+#10+
                    'Click ''Cancel'' to terminate program';
      I:=MessageDlg(MessStr,mtWarning,[mbCancel],0);
      Close;
   end;
   {Continue here if local alias found}
   S:=List1.Items[0];  {Path info for this alias in Items[0]}
   I:=Pos(':',S)-1;     {check for local drive}
   J:=Ord(S[I])-64;
   Test:=DiskSize(J);
   if Test=-1 then   {no local drive}
      begin
         MessStr:='Warning: Local Drive Not Found!'+#13+#10+
                         'Click ''Cancel'' to terminate program';
         I:=MessageDlg(MessStr,mtWarning,[mbOk,mbCancel],0);
         Close;
      end;
   {continue here for remote alias}
   try
      FDManager.GetAliasParams(RemoteAlias,List1.Items);
   except
      MessStr:='Warning: Network drive alias [Funland1] not Found!'+#13+#10+
                'Continue initialization with local drive?';
      I:=MessageDlg(MessStr,mtWarning,[mbOk,mbCancel],0);
      if I=mrCancel then Close
      else LocalFlag:=true;
   end;
   if LocalFlag=false then
      {Continue here to map server drive - if RemoteAlias not found}
      try
         MakeDriveMapping('T:', '\\CHRISTOPHERFE4F\Users\Public\Documents', 'admin', 'Funland-969727', True);
      except
         MessStr:='Cannot connect to server.'+#13+#10+
                   'Continue initialization with local drive?';
         I:=MessageDlg(MessStr,mtWarning,[mbOk,mbCancel],0);
         if I=mrCancel then Close
         else LocalFlag:=true;
   end;
   if LocalFlag=true  then   {here if local drive only}
      begin
         Aliass:=LocalAlias;
         Aliass1:=LocalAlias;
         Query1.Connection:=Aliass;
         Query2.Connection:=Aliass;
         Table1.Connection:=Aliass;
         TempAlias:=LocalDriveAlias;
         TextFileAlias:=LocalDriveAlias;
      end
   else                     {here if both local and remote drives}
      begin
         Aliass:=LocalAlias;;
         Aliass1:=RemoteAlias;
         FDManager.GetAliasParams(Aliass1,List1.Items);
         List1.Items[0]:='Path='+RemoteDriveAlias;
         FDManager.ModifyConnectionDef(Aliass1,List1.Items);
         Query1.Connection:=Aliass1;
         Query2.Connection:=Aliass1;
         Table1.Connection:=Aliass1;
         TempAlias:=RemoteDriveAlias;
         TextFileAlias:=RemoteDriveAlias;
      end;
   MessStr:='Force Local Drive? ';  {This is added temporarily}
   I:=MessageDlg(MessStr,mtWarning,[mbYes,mbNo],0);
   if I=mrYes then
      begin
         Aliass:=LocalAlias;;
         Aliass1:=LocalAlias;
         Query1.Connection:=Aliass1;
         Query2.Connection:=Aliass1;
         Table1.Connection:=Aliass1;
         TempAlias:=LocalDriveAlias;
         TextFileAlias:=LocalDriveAlias;
      end;
   TempAlias:=TempAlias+'/';
   {continue file checking}
   FDManager.GetAliasParams(Aliass1,List1.Items);
   FDManager.GetTableNames(Aliass1,'employ.db',false,false,List1.Items);
   if List1.Items.Count<1 then
      begin
         MessStr:='Warning: Employee Data File [Employ.db] Not Found!'+#13+#10+
            'Click ''Cancel'' to terminate program';
         I:=MessageDlg(MessStr,mtWarning,[mbCancel],0);
         Close;
      end;
   RPath:='';   {get remote drive path and check for remote lock files}
   if Aliass1=RemoteAlias then
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
      end;
   FDManager.GetTableNames(Aliass1,'funtimes.db',false,false,List1.Items);
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
               RequestLive:=true;
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
               RequestLive:=false;
            except
               on EFDDBEngineException do
                  begin
                  end;
            end;
      end;
   List1.Clear;       {make new training data file if one does not exist}
   FDManager.GetTableNames(Aliass1,'Training.db',false,false,List1.Items);
   if List1.Items.Count<1 then
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
  I,J,K,Len:integer;
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
   read(BFile,Rec); {write 'C' record to new file - no update!}
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
   S:string;
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
  I,J,K,Len:integer;
  S,CurFile:string;
  CFlag:boolean;
  Rec,TRec:FunFileRec;
begin
   Len:=Length(Newfile)-2;
   CurFile:=TempAlias+Copy(Newfile,1,Len)+'txt';
   Assignfile(CFile,Curfile);
   Reset(CFile);
   CFlag:=false;
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
  CFlag:boolean;
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
   Assign(CFile,Bacfile);
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
  CFlag:boolean;
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
   I,J,K,Len,OStar:integer;
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
   H:string;
begin
   with Form13.Query2 do
      begin
         Close;
         SQL.Clear;
         H:='Delete from "'+Newfile+'" ';
         SQL.Add(H);
         H:='where RecN='+IntToStr(ThisRec);
         SQL.Add(H);
         ExecSQL;
         Close;
      end;
   Delete_RecN_in_Txtfile(ThisRec);
end;

procedure Modify_TFirst_Record(ThisRec:integer;var S:string);
{modify First field of ThisRec in YYYYMMDD.db ad .txt; return Last field in S}
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

procedure Regen;
{regenerate yyyymmdd.txt from Newfile (current yyyymmdd.db file)}
var
  I,J,K,Len:integer;
  CurFile,BacFile:string;
  CFlag:boolean;
  S:string;
  Rec:FunFileRec;

begin
   CFlag:=true;
   Len:=Length(Newfile)-2;
   CurFile:=TempAlias+Copy(Newfile,1,Len)+'txt';
   BacFile:=TempAlias+Copy(Newfile,1,Len)+'bac';
   Assignfile(CFile,BacFile);        {CFile is possible current YYYYMMDD.bac file}
   {$I-}
   Reset(CFile);
   if Ioresult=0 then    {if already a backup file found for this yyyymmdd}
      begin
         Close(CFile);
         if MessageDlg('Backup file already exists! Continue anyway?',mtWarning,[mbYes,mbNo],0)=mrYes then
            begin
               erase(CFile);
            end
         else CFlag:=false;
      end;
   Closefile(CFile);
   assignfile(CFile,Curfile);
   K:=IOResult;
   if CFlag=true then
      begin
         Reset(CFile);
         if IOresult=0 then    {if already a current file found for this yyyymmdd}
            begin
               if MessageDlg('Current text file already exists! Continue anyway?',mtWarning,[mbYes,mbNo],0)=mrYes then
                  begin
                     CloseFile(CFile);
                     Rename(CFile,BacFile);
                     Assignfile(CFile,Curfile);
                  end
               else CFlag:=false;
            end;
      end;
   Close(CFile);
   K:=IOResult;
   {$I+}
   if CFlag=true then
      begin
         Assignfile(CFile,CurFile);         {CFile will be new YYYYMMDD.txt file}
         Rewrite(CFile);
         with Form13.Query2 do   {get info from YYYYMMDD.db}
            begin
               Close;
               UpdateOptions.RequestLive:=true;
               Sql.Clear;
               Sql.Add('select * ');
               Sql.Add('from "'+Nufile+'"');
               Open;
               First;
               if RecordCount>0 then for I:=1 to RecordCount do
                  begin
                     Rec.Typ:=FieldByName('Typ').AsString;
                     S:=FieldByName('RecN').AsString;
                     if S='' then
                        S:='    '
                     else
                        begin
                           J:=StrToInt(S);
                           if J<1000 then S:='0'+S;
                           if J<100 then S:='0'+S;
                           if J<10 then S:='0'+S;
                        end;
                     Rec.RecN:=S;
                     S:=FieldByName('Id').AsString;
                     if S='' then
                         S:='    '
                     else
                        begin
                           J:=StrToInt(S);
                           if J<1000 then S:=' '+S;
                           if J<100 then S:=' '+S;
                           if J<10 then S:=' '+S;
                        end;
                     Rec.Id:=S;
                     S:=Copy(FieldByName('Shf').AsString,1,1);
                     if S='' then S:=' ';
                     Rec.Shif:=S;
                     S:=Copy(FieldByName('Dat').AsString,1,1);
                     if S='' then S:=' ';
                     Rec.Daye:=S;
                     S:=Copy(FieldByName('Star').AsString,1,4);
                     if S='' then S:='    ';
                     Rec.Star:=S;
                     S:=FieldByName('First').AsString+'~';
                     Len:=Length(S);
                     if Len<14 then for J:=Len to 14 do S:=S+'~';
                     Rec.First:=S;
                     S:=FieldByName('Last').AsString+'~';
                     Len:=Length(S);
                     if Len<42 then for J:=Len to 42 do S:=S+'~';
                     Rec.Last:=S;
                     write(CFile,Rec);
                     Next;
                  end;
               Close;
            end;
         Closefile(CFile);
      end;
end;

procedure Remote_TRec(var NRec:FunFileRec);
{process building a new T record from data supplied remotely for override entry}
{enter with valid data in Rec.Id, REc.Shif, Rec.Day and sign-in time in proper place in Rec.First}
var
   I,J,K,Str,Sto,Sig,Len,X:integer;
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
         Sto:=StrToInt(T);  {Sto=Stop time for this entry}
         T:=Cells[6,I];
         X:=StrToInt(T);    {X=Star field for this entry}
         if (Sig>=Str) and (Sig<Sto) and (Len=14)    {find last start time >= to sign in time and less than stop ime}
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
   I,J,Len,TRecN:integer;
   S,Fn,Ln,Curfile:string;
   Rec:FunFileRec;
   BFile:file of FunFileRec;
   CFlag:boolean;
begin
   Form13.Queue.RowCount:=1;
   Len:=Length(Newfile)-2;
   CurFile:=TempAlias+Copy(Newfile,1,Len)+'txt';
   Assignfile(BFile,CurFile);        {BFile is current YYYYMMDD.txt file}
   Reset(BFile);
   with Form13.Query2 do   {get all T records from Newfile}
      begin
         Close;
         {RequestLive:=true;}
         Sql.clear;
         Sql.Add('Select * from "'+Newfile+'" where Typ="T"');
         Sql.Add(S);
         Open;
         First;
      end;
   if Form13.Query2.RecordCount>0 then
      while Eof(BFile)=false do
         begin
            Read(Bfile,Rec);   {check only 't' (updated) records from BFile}
            if Rec.Typ='t'then
               if Rec.RecN='9999' then
                  begin {'9999' RecN field means new T record}
                     Remote_TRec(Rec);   {fill Rec with appropriate data}
                     seek(BFile,FilePos(BFile)-1);
                     write(BFile,Rec);
                     RFlag:=true;
                     with Form13.Query2 do   {append a new T record to YYYYMMDD.db}
                        begin
                           Last;
                           Append;
                           FieldByName('RecN').AsInteger:=StrToInt(Rec.RecN);
                           FieldByName('Id').AsInteger:=StrToInt(Rec.Id);
                           FieldByName('Typ').AsString:='T';
                           FieldByName('Shf').AsString:=Rec.Shif;
                           FieldByName('Dat').AsInteger:=StrToInt(Rec.Daye);
                           FieldByName('Star').AsInteger:=StrToInt(Rec.Star);
                           FieldByName('First').AsString:=Rec.First;
                           FieldByName('Last').AsString:=Rec.Last;
                           Post;
                        end;
                     with Form13.Query1 do   {check for Id already present in YYYYMMDD.db for SG1}
                        begin
                           Close;
                           UpdateOptions.RequestLive:=true;
                           Sql.Clear;
                           Sql.Add('select Id,Shf,Last,First');
                           Sql.Add('from "'+Nufile+'"');
                           S:=Rec.Id;
                           Sql.Add('where Typ="I" and Id='+S);
                           Open;
                           if RecordCount=0 then     {if no I record exists for this employee for this timesheet}
                              begin
                                 I:=StrToInt(Rec.Id);
                                 GetInfo(I,Fn,Ln,S);
                                 with Form13.Queue do   {add id, first name, last name, and shift to queue for later processing}
                                    begin
                                       Cells[0,RowCount-1]:=Rec.Id;
                                       Cells[1,RowCount-1]:=Fn;
                                       Cells[2,RowCount-1]:=Ln;
                                       Cells[3,RowCount-1]:=S;
                                       RowCount:=RowCount+1;
                                    end;
                              end;
                           Close;
                        end;
                  end
               else  {otherwise process updated T record here}
                  begin
                     TRecN:=StrToInt(Rec.RecN);
                     S:=Rec.First;
                     Rec.Typ:='T';        {reset 'updated record' marker}
                     seek(BFile,FilePos(BFile)-1);
                     write(BFile,Rec);
                     CFlag:=false;
                     I:=1;
                     with Form13.Query2 do   {find correct RecN in .db and update First field}
                        begin
                           First;
                           repeat
                           J:=FieldByName('RecN').AsInteger;
                           if J=TRecN then
                                 begin
                                    Edit;
                                    FieldByName('First').AsString:=S;
                                    Post;
                                    CFlag:=true;
                                    RFlag:=true;
                                 end;
                              Next;
                              Inc(I)
                           until (CFlag=true) or (I>RecordCount)
                        end;
                  end;
         end;
   Form13.Query2.Close;
   closefile(BFile);
   with Form13.Queue do       {this section currently not needed - no new employees can be added remotely 5/28/2020}
      if RowCount>1 then     {here if new I records need to be added to files}
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
        end;
end;

end.
