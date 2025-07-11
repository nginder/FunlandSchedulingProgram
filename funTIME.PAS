unit funTIME;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, Grids, Clipbrd, StdCtrls, FunSheet, ExtCtrls, DB, DateUtils,
   DBCtrls, Funloc, FunPay, Funexit,Menus,FunGrid, Funsched,FunClockIn,FunEntry,
  Gauges, System.UITypes;

type
  TForm6 = class(TForm)
    Day1: TLabel;
    Day2: TLabel;
    Day3: TLabel;
    Day4: TLabel;
    Day5: TLabel;
    Day6: TLabel;
    Day7: TLabel;
    Panel2: TPanel;
    ListBox1: TListBox;
    Button8: TButton;
    Button5: TButton;
    Button3: TButton;
    Button9: TButton;
    Memo2: TMemo;
    PM1: TPopupMenu;
    AddName1: TMenuItem;
    DeleteName2: TMenuItem;
    EditName1: TMenuItem;
    TotGrid: TStringGrid;
    EmpGrid: TStringGrid;
    Label1: TLabel;
    Button1: TButton;
    Button2: TButton;
    Memo3: TMemo;
    Memo1: TEdit;
    Button4: TButton;
    Button6: TButton;
    Button7: TButton;
    LB2: TListBox;
    SyncLabel: TLabel;
    procedure EmpGridTopLeftChanged(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure TotGridMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Day1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ListBox1DrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure Button4Click(Sender: TObject);
    procedure Memo1MouseActivate(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y, HitTest: Integer;
      var MouseActivate: TMouseActivate);
    procedure Memo1KeyPress(Sender: TObject; var Key: Char);
    procedure Memo3MouseActivate(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y, HitTest: Integer;
      var MouseActivate: TMouseActivate);
    procedure Button2Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure TotGridDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect;
      State: TGridDrawState);
    procedure EmpGridDblClick(Sender: TObject);
    procedure EmpGridDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure EmpGridMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure EmpGridDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure EmpGridDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect;
      State: TGridDrawState);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ListBox1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Button3Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure Button8Click(Sender: TObject);
    procedure Button9Click(Sender: TObject);
    procedure AddName1Click(Sender: TObject);
    procedure EditName1Click(Sender: TObject);
    procedure DeleteName2Click(Sender: TObject);
    procedure LB2MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Day1Click(Sender: TObject);

  private
    { Private declarations }
  protected

  public
    { Public declarations }
  end;

var
  Form6: TForm6;
  Formset: TFormatSettings;

implementation

uses Fungroups;

{$R *.DFM}

var
   ThisTemp:string;
      {ThisTemp=original caption of currently selected name or time label}
   Page,NamId,NamSGX,ThisSGX,ThisDay,ThisRec,PageH,PageD:longint;
      {Page=current page of time sheet}
      {NamId=employee Id of currently selected label}
      {NamSGX=index in Form13.SG1 of currently selected label}
      {ThisSGX=used by Fillname to fill IdNex array with indices from Form13.SG1}
      {ThisDay=gives column number of selected time label}
      {ThisRec=current record number of selected time label entry}
   MCol,MRow,MEntry,OffsetLeft,OffsetTop:integer;
   MRect:TRect;
   Memo1Plus:string;
   DS:String; {item string being dragged}
   TCount:integer;
       {current record number for new records to yyyymmdd.db}
   TCS:string;
      {3 byte string of TCount}
   DblFlag:boolean;
      {flag for double click}
   TestFlag:boolean; {true if testing has removed duplicate file records}
   Arr1:array [1..7,1..30] of string[8];   {these two arrays used with TotalUp}
   Arr2:array [1..7,1..30]  of integer;

procedure Fill_ListBox1;
{fill listbox with times based on which modes are active on time sheet}
var
   I,J:integer;
   S:string;
   Flag:boolean;
begin
   with Form6 do
      begin
         ListBox1.Clear;
         with Form13.TimeGridP do
           for I:=1 to RowCount do
            begin
               J:=1;
               Flag:=false;
               repeat
                   S:=IntToStr(ModArray[J]);
                   if Pos(S,Cells[8,I-1])>0 then
                      begin
                         {ListBox1.Items.Add(Cells[0,I-1]);}
                         ListBox1.Items.Add(IntToStr(I-1));
                         Flag:=true;
                      end;
                   Inc(J);
               until (J>7) or (Flag=true);
            end;
      end;
end;

procedure UndoTime(var U:string);
   {convert parsed "12:00-10:00" string to HHMMHHMM (24hr) format}
   {assume pm unless 'a' is found in string}
var
   T,V:string;
   I,J:integer;
   Flag:boolean;
begin
   Flag:=false;
   J:=Pos('-',U);
   T:=Copy(U,1,J-1); {T=start time}
   Delete(U,1,J);    {U=stop time}
   J:=Pos('a',U);
   if J>0 then Flag:=true;
   J:=Pos(':',U);
   V:=Copy(U,1,J-1);  {V=stop hours}
   Delete(U,1,J);     {U=stop minutes}
   if Flag=true then U:=Copy(U,1,Length(U)-1);
   if U+V='' then
      U:='9999'
   else
      begin
         I:=StrToInt(U);
         U:=IntToStr(I);
         if I<10 then U:='0'+U;
         I:=StrToInt(V);
         if (Flag=false) and (I<12) then I:=I+12
         else if (Flag=true) and (I=12) then I:=0;
         V:=IntToStr(I);
         if I<10 then V:='0'+V;
         U:=V+U;
      end;
   J:=Pos('a',T);
   if J>0 then Flag:=true
   else Flag:=false;
   J:=Pos(':',T);
   V:=Copy(T,1,J-1);  {V=start hours}
   Delete(T,1,J);     {T=start minutes}
   if Flag=true then T:=Copy(T,1,Length(T)-1);
   I:=StrToInt(T);
   T:=IntToStr(I);
   if I<10 then T:='0'+T;
   U:=T+U;
   I:=StrToInt(V);
   if (Flag=false) and (I<12) then I:=I+12
   else if (Flag=true) and (I=12) then I:=0;
   V:=IntToStr(I);
   if I<10 then V:='0'+V;
   U:=V+U;
end;

procedure DouTime(Flag:boolean;var U:String);
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

procedure CompTime(var S,S1:string);
 {parse time from SG1 to time label but conflate consecutive times}
 {return S w/cons. times as hh:mm strings; T as HHMMHHMM strings}
 var
    J,Ents:integer;
    T,U,V,W,Str,Str1:string;
    Flag:boolean;
begin
   with Form6 do
      begin
         Str:='';
         Str1:='';
         if S<>'' then
            repeat
               T:=Copy(S,1,30);
               Delete(S,1,30);
               if Copy(T,4,1)=Offmark then with Form13.TimeGridP do  {if off all day}
                   begin
                      V:='-'+Copy(T,5,2);
                      J:=0;
                      U:='';
                      Flag:=false;
                      repeat
                         if StrtoInt(V)=StrToInt(Cells[0,J]) then   {get proper off time label from TimeGridP}
                            begin
                               Flag:=true;
                               Str:=OffMark+Cells[1,J]+Chr(13)+Chr(10);
                            end;
                         J:=J+1;
                      until (J>=RowCount) or (Flag=true);
                   end
               else
                  begin
                     if Copy(T,5,2)='99' then {don't try to conflate an extra time}
                        begin
                           U:=Copy(T,7,8);
                           DoTime(true,U);
                           Str:=Str+U+Chr(13)+Chr(10);
                        end
                     else
                        begin
                           CountEnt(S,Ents);
                           J:=1;
                           if Ents>0 then
                              repeat
                                  if Copy(T,22,4)=Copy(S,(J-1)*30+18,4) then
                                     begin
                                        W:=Copy(S,(J-1)*30+11,4);
                                        Delete(T,11,4);
                                        Insert(W,T,11);
                                        W:=Copy(S,(J-1)*30+22,4);
                                        Delete(T,22,4);
                                        Insert(W,T,22);
                                        Delete(S,1,30);
                                     end
                                  else
                                     J:=J+1;
                               until (J>Ents) or (S='');
                           U:=Copy(T,7,8);
                           Str1:=Str1+T;
                           DoTime(true,U);
                           Str:=Str+U+Chr(13)+Chr(10);
                        end;
                  end;
            until S='';
         S:=Str;
         S1:=Str1;
      end;
end;

Procedure PassTime(var S:string);
   {parse time from SG1 to time label}
var
   I,J:integer;
   T,U,V,W:string;
begin
   with Form6 do
      begin
         T:='';      {T will be built into time label string for return}
         repeat
            J:=Pos(Chr(10),S);    {loop here for every time entry in this SG1 cell}
            if J>0 then    {continue here if there is another time entry to process}
               begin
                  if S[4]=Offmark then with Form13.TimeGridP do   {if this is an 'off' time continue here}
                     begin
                        V:='-'+Copy(S,5,2);
                        I:=0;
                        U:='';
                        repeat
                            if StrtoInt(V)=StrToInt(Cells[0,I]) then   {get proper off time label from TimeGridP}
                               U:=Cells[1,I];
                            I:=I+1;
                        until I>=RowCount;
                        W:=Offmark;  {set id char}
                     end
                  else           {here if this is an active time entry}
                     begin
                        U:=Copy(S,7,8);     {U=time start/time end string}
                        {if (Pos(UPMark,S)>0) and (Pos(UPMark,S)<J) then W:=UPMark
                        else if (Pos(PdMark,S)>0) and (Pos(PdMark,S)<J) then W:=PdMark
                        else W:='+'; }        {set id char - suppressed in 2021}
                        if (U[1]>='0') and (U[1]<='9') then  {if U is a proper time string then convert it to a '10:00-1:00' label}
                           DoTime(true,U);
                     end;
                  T:=T+W+U+Chr(13)+Chr(10);
                  Delete(S,1,J);
               end;
         until J=0;
         S:=T;
      end;
end;

procedure Parsehour(ACol,ARow:integer);
   {parse a record from SG1 for time}
   {ThisSGX is row pointer in SG1}
var
   Break:integer;
   S,U,Star,Stop,Plus:String;
   Hours:real;
   Posit,Sta,Sto,Minutes:longint;
   Flag:boolean;
begin
   if ThisSGX>-1 then
      begin
         Flag:=true;
         Minutes:=0;
         S:=Form13.SG1.Cells[ACol+2,ARow];
         if S<>'' then
            begin
               repeat
                   Posit:=Pos(#10,S);
                   if Posit>0 then
                      begin
                          U:=Copy(S,1,Posit);
                          Break:=Pos(UPMark,U);
                          Plus:=Copy(U,1,1);
                          Delete(S,1,Posit);
                          if Plus<>Offmark then
                              begin
                                 Star:=Copy(U,7,4);
                                 Stop:=Copy(U,11,4);
                                 InTime(Star,Sta);
                                 InTime(Stop,Sto);
                                 if (Sto=9999) or (Sta=9999) then
                                    Flag:=false
                                 else
                                    begin
                                       Minutes:=Minutes+Sto-Sta;
                                       if Sto<Sta then Minutes:=Minutes+1440;
                                       if Break<>0 then Minutes:=Minutes-BreakMinutes;
                                    end;
                              end;
                      end;
               until Posit<=0;
               if Minutes>0 then
                  begin
                     Hours:=Minutes/60;
                     S:=FormatFloat('#0.0',Hours);
                  end
               else S:='0.0';
               if Flag=false then S:=S+'*';
            end
         else S:='';
         with Form6.Empgrid.Canvas do
            begin
               Font.Color:=clRed;
               TextOut(MRect.Right-TextWidth(S)-2,MRect.Top+OffsetTop-3,S);
            end;
      end;
end;

procedure TotalHours(ARow:integer);
{do total hours for one employee for Show Hours Total}
var
   J,Posit,Break:integer;
   Minutes,Sta,Sto:longint;
   S,U,Plus,Star,Stop:string;
   Hours:real;
   NRect:TRect;
   Flag:boolean;
begin
   if ARow>-1 then
      begin
         Flag:=true;
         Minutes:=0;
         NRect:=Form6.EmpGrid.CellRect(0,ARow);
         for J:=1 to 7 do
            begin
               S:=Form13.SG1.Cells[J+2,ARow];
               Break:=Pos(UPMark,S);
               if S<>'' then
                  begin
                     repeat
                         Posit:=Pos(#10,S);
                         if Posit>0 then
                            begin
                               U:=Copy(S,1,Posit);
                               Plus:=Copy(U,4,1);
                               Delete(S,1,Posit);
                               if Plus<>Offmark then
                                  begin
                                     Star:=Copy(U,7,4);
                                     Stop:=Copy(U,11,4);
                                     InTime(Star,Sta);
                                     InTime(Stop,Sto);
                                     if (Sto=9999) or (Sta=9999) then
                                        Flag:=false
                                     else
                                        begin
                                           Minutes:=Minutes+Sto-Sta;
                                           if Sto<Sta then Minutes:=Minutes+1440;
                                           if Break<>0 then Minutes:=Minutes-BreakMinutes;
                                        end;
                                  end;
                            end;
                     until Posit<=0;
                  end;
            end;
         if Minutes>0 then
            begin
               Hours:=Minutes/60;
               S:=FormatFloat('#0.0',Hours);
            end
         else S:='0.0';
         if Flag=false then S:=S+'*';
         with Form6.Empgrid.Canvas do
            begin
               Font.Color:=clRed;
               TextOut(NRect.Right-TextWidth(S)-2,NRect.Top+OffsetTop-3,S);
            end;
      end;
end;

procedure TForm6.FormCreate(Sender: TObject);
begin
   Form6.Height:=Screen.Height;
   Form6.Top:=0;
   Form6.Width:=900;
   Form6.Left:=(Screen.Width-900) div 2;
end;

procedure ParseTime(var S:string);
   {parse a string for correct time}
var
   J:integer;
   T,U:string;
   Flag:boolean;
   X:TDateTime;
begin
   Flag:=true;
   J:=Pos('/',S);          {convert '/' to 'A' for am}
   if J>0 then S[J]:='A';
   J:=Pos('a',S);          {convert 'a' to 'A' for am}
   if J>0 then S[J]:='A';
   J:=Pos('*',S);           {convert '*' to ':'}
   if J>0 then S[J]:=':';
   J:=Pos(';',S);           {convert ';' to ':'}
   if J>0 then S[J]:=':';
   J:=Pos('/',S);           {if second occurence of any of the above characters, change them also}
   if J>0 then S[J]:='A';
   J:=Pos('a',S);
   if J>0 then S[J]:='A';
   J:=Pos('.',S);
   if J>0 then S[J]:=':';
   J:=Pos(';',S);
   if J>0 then S[J]:=':';
   J:=Pos('-',S);   {check for time separator, if no, set reject flag}
   if J<1 then
      begin
         S:='';
         Flag:=false;
      end
   else            {otherwise, continue here}
      begin
         T:=Copy(S,1,J-1); {T=start time}
         Delete(S,1,J);    {S=stop time}
         U:=S;
         J:=Pos('A',T);
         if J>0 then T:=T+'M'  {process start time}
         else T:=T+'PM';
         try
            X:=StrToTime(T);
         except
            on EconvertError do
               begin
                  Flag:=false;
                  S:='';
               end;
         end;
      end;
   if Flag=true then
      begin
         T:=TimeToStr(X);
         J:=Pos('A',T);
         S:=Copy(T,1,Length(T)-6);
         if J>0 then S:=S+'a';
         S:=S+'-';
      end;
   if (U<>'') and (FLag=true) then
      begin
         J:=Pos('A',U);
         if J>0 then U:=U+'M'
         else U:=U+'PM';
         try
            X:=StrToTime(U);
         except
            on EconvertError do
               begin
                  Flag:=false;
                  S:='';
               end;
         end;
         if Flag=true then
            begin
               U:=TimeToStr(X);
               J:=Pos('A',U);
               U:=Copy(U,1,Length(U)-6);
               S:=S+U;
               if J>0 then S:=S+'a';
            end;
      end;
   if Flag=false then S:='-';
end;

procedure TForm6.Button3Click(Sender: TObject);
{exit button}
begin
   close;
end;

procedure TotalOneUp(ThisDay:integer;DT:string);
{change one total; DS=time label, ThisDay = column index}
{DT=data string from Funtimes.db for this time label}
var
   I,J,Count,New:integer;
   Flag:boolean;
   T:string;
begin
   with Form6 do
      begin
         Count:=Length(DT) div 14;
         for I:=1 to Count do
            begin
               T:=Copy(DT,1,3);
               if T[1]<>OffMark then T[1]:='+'
               else T[1]:='-';
               Delete(DT,1,14);
               J:=0;
               Flag:=false;
               repeat
                  if TotGrid.Cells[TotGrid.ColCount,J]=T then
                     begin
                        Flag:=true;
                        New:=StrToInt(TotGrid.Cells[ThisDay,J]);
                        Inc(New);
                        TotGrid.Cells[ThisDay,J]:=IntToStr(New);
                     end;
                  Inc(J);
               until (J>TotGrid.RowCount) or (Flag=true);
            end;
      end;
end;

procedure TotalCount(TCol,TId:integer; var TCnt:integer);
{get TCnt=emps found for TCol=this day/TId=this time id}
var
   I,J,K,L,Ents:integer;
   S:string;
begin
   with Form13.SG1 do
      begin
         TCnt:=0;
         for I:=0 to RowCount-1 do
            begin
               S:=Cells[TCol+2,I];
               CountEnt(S,Ents);
               if Ents>0 then for J:=1 to Ents do
                  begin
                     L:=(J-1)*30+5;
                     K:=StrToInt(Copy(S,L,2));
                     if (K=TId) and (Copy(S,L-1,1)<>OffMark) then TCnt:=TCnt+1;
                  end;
            end;
      end;
end;

procedure NewTotalup;
{do complete totgrid fill with new format using Abbr field from Funtimes.db}
var
   I,J,K,L,M,Count,N:integer;
   S,U,Ind:string;
begin
   with Form6 do
      begin
        TotGrid.Visible:=false;
        TotGrid.RowCount:=1;
        FillTiparray;
        for J:=1 to 7 do          {do totals for each day of week}
           begin
              with Form13.SG1 do  {get total off employees for this day}
                 begin
                    M:=0;
                    for I:=0 to RowCount-1 do
                       if Copy(Cells[J+2,I],4,1)=OffMark then M:=M+1;
                    S:=IntToStr(M);
                    if M<10 then S:=' '+S;
                    TotGrid.Cells[J-1,0]:=' Off All Day: '+S;
                 end;
              M:=ModArray[J];      {M=mode for this day}
              L:=0;            {L = no. of time entries for this day}
              with Form13.TimeGridP do for I:=0 to RowCount-1 do
                 begin
                    if M=STrToInt(Cells[8,I]) then  {if this entry in TimeGridP is the right mode for this day then continue}
                       begin
                          Inc(L);
                          if L>TotGrid.RowCount-1 then TotGrid.RowCount:=TotGrid.RowCount+1;
                          K:=StrToInt(Cells[0,I]);  {K=time entry id}
                          TotalCount(J,K,Count);
                          S:=IntToStr(Count);
                          if Count<10 then S:=' '+S;
                          Ind:='';
                          U:=Cells[10,I];
                          for N:=1 to 5 do if U=Tiparray[J,N] then Ind:=IntToStr(N);
                          TotGrid.Cells[J-1,L]:=S+Ind+Cells[9,I];  {TotalCount+Color Ind+Abbr string};
                       end;
                 end;
           end;
        TotGrid.Visible:=true;
      end;
end;

procedure Preparrays;
{prepare array1 and array2 for combined totals}
var
   I,J,K,Ind:integer;
   S:string;
begin
   for I:=1 to 7 do for J:=1 to 30 do   {clear arrays}
      begin
         Arr1[I,J]:='';
         Arr2[I,J]:=0;
      end;
   with Form13 do            {set up Arr1 with possible time data strings HHMMHHMM}
      for I:=1 to 7 do with TimeGridP do  {fill all seven days}
         begin
            Ind:=0;
            S:='00000000';
            for J:=0 to RowCount-1 do if StrToInt(Cells[8,J])=ModArray[I] then  {if this time entry is proper mode for this day}
               begin
                  Ind:=Ind+1;
                  Arr1[I,Ind]:=Copy(Cells[2,J],4,8);
                  S:=Arr1[I,Ind];
                  if J<RowCount-1 then for K:=J+1 to RowCount-1 do 
                     begin
                        if Copy(Cells[2,K],4,4)=Copy(S,5,4) then  {if this is part of a combo}
                           begin
                              S:=Copy(S,1,4)+Copy(Cells[2,K],8,4);
                              Ind:=Ind+1;
                              Arr1[I,Ind]:=S;
                           end;
                     end;
               end;
         end;
end;

procedure TotalUp;
{do complete totgrid fill with combined times}
var
   I,J,K,L,M,Ents:longint;
   S,T,W:string;
begin
   with Form6 do
      begin
         Preparrays;  {prepare Arr1 and Arr2}
         with TotGrid do
            begin
               Visible:=false;
               for I:=1 to RowCount-1 do for J:=0 to ColCount-1 do  {initialize TotGrid - skipping Off All Day row}
                  Cells[J,I]:='';
               RowCount:=1;
            end;
        for J:=1 to 7 do with Form13.SG1 do         {do totals for each day of week}
           for I:=0 to RowCount-1 do if Cells[J+2,I]<>'' then
              begin
                 S:=Cells[J+2,I];
                 Comptime(S,W);
                 CountEnt(W,Ents);
                 if Ents>0 then for K:=1 to Ents do
                    begin
                       L:=((K-1)*30)+1;
                       if (Copy(W,L+3,1)<>Offmark) and (Copy(W,L+4,2)<>'99') then {no Off All Day or Extras}
                          begin
                             T:=Copy(W,L+17,8); {T=HHMMHHMM for this entry}
                             for M:=1 to 30 do
                                begin
                                   if Arr1[J,M]=T then
                                      Arr2[J,M]:=Arr2[J,M]+1;
                                end;
                          end;
                    end;
              end;
        for I:=1 to 7 do
           begin
              L:=0;
              for J:=1 to 30 do if Arr2[I,J]>0 then
                 begin
                    L:=L+1;
                    if L>TotGrid.RowCount then TotGrid.RowCount:=L+1;
                    S:=Arr1[I,J];
                    T:=IntToStr(Arr2[I,J]);
                    if Arr2[I,J]<9 then T:=' '+T;
                    TotGrid.Cells[I-1,L]:=S+T;
                 end;
           end;
        TotGrid.Visible:=true;
      end;
end;

procedure TForm6.Button5Click(Sender: TObject);
   {print button}
var
   I,J,K,L,M,PStart,PEnd,Count,SGX,Spc:longint;
   S,T,U,V:string;
begin
   PXPY;                   {set up printer offsets}
   SetLastPages;          {set last page of time sheets}
   LastPage:=LastPageH;
   Form3.Showmodal;      {show funexit form to set print parameters}
   if Flag<>0 then
      begin
         SGX:=0;
         if Flag=2 then     {here to set up for print all pages}
            begin
               S:='Ready to print all time sheets?';
               PStart:=1;
               PEnd:=LastPage;
            end
         else
            begin              {here to set up to print page range}
               S:='Ready to print ';
               T:=IntToStr(Pst);
               if Pst<>Pnd then
                  begin
                     U:=IntToStr(Pnd);
                     S:=S+'pages '+T+' to '+U+' of time sheets?';
                  end
               else
                  S:=S+'page '+T+' of time sheets';
               PStart:=Pst;
               PEnd:=Pnd;
               SGX:=(Pst-1)*13;
            end;
         if MessageDlg(S,mtConfirmation,[mbYes,mbNo],0)= mrYes then
            for Count:=PStart to PEnd do
               begin
                  Begindok;               {begin document}
                  for I:=0 to 7 do        {print vertical lines}
                     begin
                        J:=I*270+360;
                        if I=0 then Wide(4)
                        else Wide(2);
                        movetwo(J,0);
                        linetwo(J,3150);
                     end;
                  movetwo(360,0);
                  linetwo(2400,0);
                  for I:=1 to 14 do      {print horizontal lines}
                     begin
                        J:=I*225;
                        if I=1 then Wide(4)
                        else Wide(2);
                        movetwo(0,J);
                        linetwo(2400,J);
                     end;
                  Sise(10);             {print page number and dates/days}
                  Stile([fsBold]);
                  S:='Page '+IntToStr(Count)+' of '+IntToStr(LastPage);
                  TextOwt(60,90,S);
                  for I:=0 to 6 do
                     begin
                        J:=I*270+360;
                        S:=DateToStr(NewDate+I);
                        TextOwt(J+70,40,S);
                        S:=Formset.ShortDayNames[DayOfWeek(NewDate+I)];
                        TextOwt(J+100,120,S);
                     end;
                  Stile([]);
                  for I:=SGX to SGX+12 do  {print employee names for this page}
                     begin
                        Sise(10);
                        J:=(I-SGX)*225+275;
                        with Form13.SG1 do
                           if I<RowCount then
                              S:=Cells[1,I];
                        K:=Pos(#10,S);
                        if K>0 then
                           begin
                              T:=Copy(S,1,K-2);
                              TextOwt(0,J,T);
                              T:=Copy(S,K+1,Length(S)-K);
                              TextOwt(0,J+60,T);
                              Stile([]);
                           end;
                        for J:=0 to 6 do
                           begin
                              S:='';
                              with Form13.SG1 do
                                 if I<RowCount then
                                    S:=Cells[3+J,I];
                              if CompFlag=false then
                                 Passtime(S)
                              else Comptime(S,V);
                              if Copy(S,1,1)=OffMark then
                                 begin
                                    Delete(S,1,1);
                                    Insert(' ',S,1);
                                 end;
                              S:=Copy(S,1,Length(S)-2);
                              CountEnt(S,L);
                              with Memo2 do
                                 begin
                                    Text:='';
                                    case J of
                                      0:if Form3.CheckBox1.Checked=true then Text:=S;
                                      1:if Form3.CheckBox2.Checked=true then Text:=S;
                                      2:if Form3.CheckBox3.Checked=true then Text:=S;
                                      3:if Form3.CheckBox4.Checked=true then Text:=S;
                                      4:if Form3.CheckBox5.Checked=true then Text:=S;
                                      5:if Form3.CheckBox6.Checked=true then Text:=S;
                                      6:if Form3.CheckBox7.Checked=true then Text:=S;
                                    end;
                                    if Text<>'' then
                                       begin
                                          if L>6 then Text:=Text+'...';
                                          K:=(I mod 13)*225+255;
                                          L:=J*270+370;
                                          {Sise(8);
                                          if L<1 then Spc:=0
                                          else if L<4 then Spc:=60
                                          else
                                             begin}
                                                Sise(6);
                                                Spc:=30;
                                             {end;  }
                                          for M:=0 to 5 do
                                             TextOwt(L,K+(Spc*M),Lines[M]);
                                       end;
                                 end;
                           end;
                     end;
                  SGX:=SGX+13;
                  Enddok;
               end;
      end;
end;

procedure TForm6.FormActivate(Sender: TObject);
var
   I:integer;
   S:string;
begin
   SyncLabel.Visible:=false;
   LocFlag:=true;
   ListBoxFlag:=false;
   if Screen.PixelsPerInch>96 then
      EmpGrid.Canvas.Font.Size:=7
   else
      EmpGrid.Canvas.Font.Size:=8;
   if Screen.PixelsPerInch>96 then
      TotGrid.Canvas.Font.Size:=7
   else
      TotGrid.Canvas.Font.Size:=8;
   FillColorGrid(true);
   LB2.Visible:=false;
   TotGrid.Visible:=false;
   Button5.Enabled:=true;
   Button8.Enabled:=true;
   Button9.Enabled:=true;
   DblFlag:=false;
   SetLastPages;
   S:='Test';
   with EmpGrid do
      begin
         Left:=4;
         Width:=549;
         ColCount:=8;
         Width:=Col0+(ColCount-1)*(Col1+5);
         ColWidths[0]:=Col0;
         DefaultRowHeight:=Canvas.TextHeight(S)*3;
         for I:=1 to 7 do
            ColWidths[I]:=Col1;
         OffsetLeft:=(3*Col1) div 4;
         OffsetTop:=(3*DefaultRowHeight) div 4;
         Top:=Form6.Top+38;  {38}
         Height:=Form6.Height-385;
         RowCount:=Form13.SG1.RowCount;
         Day1.Left:=Left+Col0+3;
         Day1.Width:=Col1;
         Day2.Left:=Day1.Left+Col1+1;
         Day2.Width:=Col1;
         Day3.Left:=Day2.Left+Col1+1;
         Day3.Width:=Col1;
         Day4.Left:=Day3.Left+Col1+1;
         Day4.Width:=Col1;
         Day5.Left:=Day4.Left+Col1+1;
         Day5.Width:=Col1;
         Day6.Left:=Day5.Left+Col1+1;
         Day6.Width:=Col1;
         Day7.Left:=Day6.Left+Col1+1;
         Day7.Width:=Col1;
      end;
   Fill_ListBox1;
   with Form21 do   {set daily modes in radio group boxes}
      begin
         RG1.ItemIndex:=ModArray[1];
         RG2.ItemIndex:=ModArray[2];
         RG3.ItemIndex:=ModArray[3];
         RG4.ItemIndex:=ModArray[4];
         RG5.ItemIndex:=ModArray[5];
         RG6.ItemIndex:=ModArray[6];
         RG7.ItemIndex:=ModArray[7];
      end;
   with TotGrid do
      begin
         Left:=Col0+4;
         Width:=EmpGrid.Width-Col0-4;
         ColCount:=EmpGrid.ColCount-1;
         DefaultRowHeight:=20;
         for I:=0 to 6 do
            ColWidths[I]:=Col1;
         Top:=EmpGrid.Top+EmpGrid.Height+25;
         Height:=260;
         RowCount:=8;
         Label1.Height:=20;
         Label1.Width:=Width;
         Label1.Left:=Left+1;
         Label1.Top:=Top-20;
         NewTotalUp;
      end;
   with Panel2 do
      begin
         Width:=Form6.Width-EmpGrid.Width-30;
         Left:=EmpGrid.Width+15;
         Height:=800;
         Top:=EmpGrid.Top;
         LB2.Width:=Panel2.Width-4;
         LB2.Left:=2;
      end;
   PageD:=1;
   PageH:=1;
   Page:=1;
   LastPage:=LastPageH;
   Button9.Caption:='Hours On';
   Button4.Caption:='Totals Off';
   Button6.Caption:='Test File';
   Label1.Visible:=true;
   ListBox1.Visible:=false;   {!!!!}
   Button7.Caption:='Comb Off';  {auto time combining is on}
   CompFlag:=false;
end;

procedure GetMins(S:string;var Mins:integer;var AstFlag:boolean);
{get total minutes from string S which is data string from SG1}
{S is tested prior to call to be <>''}
var
   Posit:integer;
   U,Plus,Break,Star,Stop:string;
   Sta,Sto:longint;
begin
   Mins:=0;
   repeat
      Posit:=Pos(#10,S);
      if Posit>0 then
         begin
            U:=Copy(S,1,Posit);
            Plus:=Copy(U,4,1);
            Break:=Copy(U,15,1);
            Delete(S,1,Posit);
            if Plus<>Offmark then
               begin
                  Star:=Copy(U,7,4);
                  Stop:=Copy(U,11,4);
                  InTime(Star,Sta);
                  InTime(Stop,Sto);
                  if (Sto=9999) or (Sta=9999) then
                     AstFlag:=true
                  else
                     begin
                        Mins:=Mins+Sto-Sta;
                        if Sto<Sta then Mins:=Mins+1440;
                        if Break='*' then Mins:=Mins-BreakMinutes;
                     end;
               end;
         end;
      until Posit<=0;
end;

procedure TotalFifteenMinutes(ARow:integer;var AstFlag:boolean);
{fill Fmins array with daily minutes for one fifteenyearold}
{ARow is row of fifteenyearold in SG1}
var
   J,Mins:integer;
   S:string;
begin
   if ARow>-1 then
      begin
         AstFlag:=false;
         for J:=1 to 7 do
            begin
               FMins[J]:=0;
               S:=Form13.SG1.Cells[J+2,ARow];
               if S<>'' then
                  GetMins(S,Mins,AstFlag)
               else Mins:=0;
               FMins[J]:=Mins;
            end;
      end;
end;

procedure ProcessDrop(Sender:TStringGrid);
   {process a dropped or double-clicked time to EmpGrid cell}
   {DS=time string to be dropped}
   {ThisDay=column, ThisSGX=Row in SG1 and Empgrid destination}

var
   I,J,ThisId,NStar,OStar,NStop,OStop,Posit,EnterHere,Mins:integer;
   S,T,CellStr,NewStr,DT:string;
   Flag,FiFlag,AstFlag:boolean;
   Dayz,Minutes:integer;
   NDate:TDateTime;

begin
   with Sender as TStringGrid do
      begin
         Posit:=1;         {initialize var.s to determine where this drop will be entered in time data string}
         EnterHere:=1;
         CellStr:=Form13.SG1.Cells[ThisDay+2,ThisSGX]; {CellStr=current time data string for this day/this emp}
         ThisId:=StrToInt(Form13.SG1.Cells[0,ThisSGX]); {ThisId is emp id for this emp}
         NamShf:=Form13.SG1.Cells[2,ThisSGX];           {NamShf is shift character for this day/this emp}
         CountEnt(CellStr,I);
         if I<MaxEntries then              {used to be only 3 time entries per day or less; changed to arbitrary value of 6}
            begin                  {now allowing more to allow for overridden remote times added}
               Flag:=false;
               NewStr:='';
               with Form13.TimeGridP do
                  begin
                     J:=1;
                     repeat
                        if DS=Cells[0,J-1] then            {Here to build time data string in NewStr}
                           begin
                              I:=StrToInt(Cells[0,J-1]);         {I= Time Id [minus prefix] for matched entry in TimeGridP}
                              NewStr:=IntToStr(Abs(I));
                              if Abs(I)<10 then NewStr:='0'+NewStr;
                              if I<0 then NewStr:=Offmark+NewStr
                              else NewStr:='+'+NewStr;             {build proper time id with prefix in NewStr}
                              DT:=Cells[2,J-1];                   {this will be child string identifier in time data string}
                              if Cells[4,J-1]<>'' then      {if this time record has the UPBreak field not blank then set 1st char of string to UPMark}
                                  begin                    {   this indicates that this entry contains an unpaid/paid break}
                                     Delete(DT,1,1);
                                     Insert(UPMark,DT,1);
                                  end;
                              T:=Copy(DT,4,4);
                              InTime(T,NStar);        {NStar=drop start time in min.'s from 12 am}
                              T:=Copy(DT,Length(DT)-6,4);
                              InTime(T,NStop);        {NStop=drop stop time in min.s from 12 am}
                              NewStr:=NewStr+Copy(DT,4,4)+Copy(DT,Length(DT)-6,4)+
                                 DT+#13#10;    {NewStr=full parent/child string for this entry}
                              Flag:=true;
                           end;
                        Inc(J);
                     until (Flag=true) or (J>Rowcount);
                  end;
              Fiflag:=true;
              if (NamShf='F') and (NewStr<>'')then      {do fourteen/fifteen checking here}
                 begin
                    if ((Pos(SevenTHIRTYCode,NewStr)>0)        {No scheduling past 7:00 pm}
                        or (Pos(SevenThirtyCode,NewStr)>0) or (Pos(EightThirtyCode,NewStr)>0)) then
                       begin
                          S:='This employee cannot be scheduled past 7:00 pm!';
                          I:=MessageDlg(S,mtWarning,[mbOk],0);
                          FiFlag:=false;
                       end
                    else
                       begin
                          NDate:=NewDate;
                          NDate:=IncDay(NDate,ThisDay-1);
                          if (NDate<SchoolEnd) or (NDate>LaborDay) then
                             MaxFifteenMinutes:=60*MaxFifteenHoursSchool
                          else MaxFifteenMinutes:=60*MaxFifteenHoursSeason;
                          TotalFifteenMinutes(ThisSGX,AstFlag);
                          if AstFlag=true then
                             begin
                                S:='There is a missing time entry for this employee.'+#10
                                      +'Hour totals for this employee may not be completely accurate!';
                                I:=MessageDlg(S,mtWarning,[mbOk],0);
                             end;
                          Dayz:=0;             {check for no. of days working this week}
                          Minutes:=0;
                          for I:=1 to 7 do
                             begin
                                if FMins[I]>0 then Inc(Dayz);
                                Minutes:=Minutes+(FMins[I]);
                             end;
                          if FMins[ThisDay]=0 then Inc(Dayz);
                          if Dayz>MaxFifteenDaysPerWeek then
                             begin
                                S:='This employee may not be scheduled for more than '+IntToStr(MaxFifteenDaysPerWeek)+' days per week!';
                                I:=MessageDlg(S,mtWarning,[mbOk],0);
                                FiFlag:=false;
                             end
                          else  if (NStar<>9999) and (NStop<>9999) then
                             begin     {check for exceeding max hours/day}
                                S:='xxx'+NewStr;
                                GetMins(S,Mins,AstFlag);
                                I:=FMins[ThisDay]+Mins;
                                if I>MaxFifteenHoursPerDay*60 then
                                   begin
                                      S:='Adding this time exceeds the maximum allowable hours per day for this employee.';
                                      I:=MessageDlg(S,mtWarning,[mbOk],0);
                                      FiFlag:=false;
                                   end
                                else
                                   begin    {check for exceeding max hours per week}
                                      if Minutes+Mins>MaxFifteenMinutes then
                                         begin
                                            S:='Adding this time exceeds the maximum allowable hours per week for this employee.';
                                            I:=MessageDlg(S,mtWarning,[mbOk],0);
                                            FiFlag:=false;
                                         end;
                                   end;
                             end;
                       end;
                 end;
              Flag:=true;
              if (FiFlag=true) and (NewStr<>'') then
                     begin
                        S:=CellStr;
                        repeat
                           I:=Pos(Chr(10),S);
                           if I>0 then
                              begin
                                 T:=Copy(S,7,4);
                                 InTime(T,OStar);
                                 T:=Copy(S,11,4);
                                 InTime(T,OStop);
                                 Delete(S,1,I);
                                 if ((NStar>=OStar) and (NStar<=OStop)) or
                                    ((NStop>=OStar) and (NStop<=OStop)) then
                                    begin
                                       T:='Warning: this time shift may overlap another shift!';
                                       if MessageDlg(T,mtWarning,mbOKCancel,0)=mrOK then
                                          Flag:=true
                                       else
                                          begin
                                             Flag:=false;
                                             I:=0;
                                          end;
                                    end
                                 else Flag:=true;
                                 Posit:=Posit+I;
                                 if NStar>OStar then
                                   EnterHere:=Posit;
                              end;
                        until (I=0);
                     end;
              if (FiFlag=true) and (Flag=true) then
                 begin
                    DoCount(TCount,TCS);
                    S:=TCS+NewStr;
                    Insert(S,CellStr,EnterHere);
                    Form13.SG1.Cells[ThisDay+2,ThisSGX]:=CellStr;
                    S:=Form13.SG1.Cells[2,ThisSGX];
                    Add_Drop_To_File(NewStr,S,NStar,ThisId,ThisDay,TCount);
                    TotalOneUp(ThisDay,DT);
                    Form6.EmpGrid.Cells[ThisDay,ThisSGX]:='';
                 end;
              {TotalUp; }
            end
         else
            begin
               T:='Warning: too many entries for this employee for this day!';
               if MessageDlg(T,mtWarning,[mbOK],0)=mrOK then
                  begin

                  end;
            end;
      end;
end;

procedure SaveNam;
   {save edited name to file}
var
   S,F,L:string;
begin
   F:=Form6.Memo2.Lines[0];
   L:=Form6.Memo2.Lines[1];
   S:=IntToStr(NamId);
   Save_Name(S,F,L);
end;

procedure DeleteRec(ThisRec:integer);
{delete record RecN=ThisRec from YYYYMMDD.db and txt files}
begin
   DoDeleteRec(ThisRec);
   Do_it(false);
   {TotalUp;}
end;

procedure ParseMemo1;
   {parse one line of selected cell of Empgrid to find legit times}
   {setmemo1 has already been called and this procedure occurs at close of memo1}
   {Use MEntry to parse correct line, either in Sg1 cell or memo3}
   {ThisRec is record number in Newfile (YYYMMDD.db)}
var
   S,T,U,P,N,NewLast,ST:string;
   I,J,L,ThisCount:integer;
begin
   with Form6 do
      begin
         S:=Memo1.Text;
         NewLast:='';
         if S<>'' then
            begin
               Parsetime(S);  {check for legal time string; returns '-' if not}
               if S<>'-' then
                  begin     {legal nonblank entry here}
                     if Memo3.Visible=true then
                         Memo3.Lines[Mentry]:=S;
                     Undotime(S);       {put new time string ST into first field of ThisRec}
                     ST:=S;                            {modify yyyymmdd.db and .txt}
                     Modify_TFirst_Record(ThisRec,ST);  {ST returns as last field of ThisRec}
                     {rebuild data string in SG1}
                     T:=Form13.SG1.Cells[ThisDay+2,ThisSGX];  {T=data string for this entry}
                     CountEnt(T,ThisCount);  {ThisCount=no. of child strings in this entry}
                     N:='';
                     if Memo3.Visible=true then  {adjust Mentry index if Memo3 is visible}
                        L:=Mentry+2
                     else L:=Mentry;
                     for I:=1 to ThisCount do
                        begin
                           J:=Pos(Chr(10),T);     {J=position of end of next child string in this entry}
                           U:=Copy(T,1,J);         {U= next child string}
                           if I=L+1 then      {if this is the proper 'line' to be modified}
                              begin                {    replace it in the data string}
                                 Delete(U,7,8);
                                 Insert(S,U,7);
                              end;
                           Delete(T,1,J);
                           N:=N+U;                 {N is new data string}
                        end;
                     Form13.SG1.Cells[ThisDay+2,ThisSGX]:=N;
                  end
               else         {illegal nonblank entry - only action if memo3 is visible}
                  begin
                     if Memo3.Visible=true then
                        Memo3.Lines[Mentry]:=ThisTemp;
                  end;
            end
         else  {S='' - newly cleared line}
            begin    {check child entries for any assigned position}
               CountEnt(ST,ThisCount);   {ST is last field for thisrec}
               P:='999';
               for I:=1 to ThisCount do  {check all child strings for nonblank position assignments}
                  begin
                     U:=Copy(ST,12,3);
                     if U<>'999' then P:=U;
                     Delete(ST,1,14);
                  end;
               if ((P<>'999') and (MessageDlg('This entry has been assigned a position. Delete anyway?',mtWarning,[mbYes,mbNo],0)=mrNo))
                or ((P='999') and (MessageDlg('Confirm deletion of this entry?',mtConfirmation,[mbYes,mbNo],0)=mrNo)) then
                  begin     {do not delete entry}
                    {no action required?}
                  end
               else   {if ok to delete entry, continue here}
                  begin   {delete an entry }
                     DeleteRec(ThisRec);
                     if Memo3.Visible=true then
                        Memo3.Lines.Delete(Mentry);
                  end;
            end;
      end;
end;


procedure ParseMemo2;
   {parse Memo2 to remove blanks & anything beyond two lines}
var
   S,Space:string;
   T:Char;
   I,J:integer;
   Flag:boolean;
begin
   with Form6.Memo2 do
      begin
         S:=Text;
         Clear;
         J:=0;
         Space:='';
         Flag:=false;
         for I:=1 to Length(S) do
            begin
               T:=S[I];
               if (T=#10) then   {increment to second line}
                  begin
                     if J=0 then Text:=Text+#13#10;
                     Inc(J);
                     Space:='';
                     Flag:=false;
                  end;
               if (J<2) and (T<>#13) and (T<>#10) then
                  begin
                     if T=' ' then  {add to "inner spaces"}
                        begin
                           if  Flag=true then Space:=Space+' ';
                        end
                     else
                        begin       {add to text}
                           Flag:=true;
                           if Space<>'' then {add inner space + char}
                              begin
                                 Text:=Text+Space+T;
                                 Space:='';
                              end
                           else Text:=Text+T;
                        end;
                  end;
            end;
      end;
end;

procedure CloseMemo1;
   {close memo1 here and process time label}
var
   S:string;
begin
   with Form6.Memo1 do
      begin
         S:=Text;
         if (S<>ThisTemp) and (Memo1Plus<>Offmark) then
            ParseMemo1;
         Visible:=false;
      end;
   with Form6 do
      if Memo3.Visible=true then
       begin
         if Memo3.Lines.Count>0 then   {if there are any lines }
            Memo3.Lines[Mentry]:=Memo1.Text;
         if Memo3.Lines.Count<2 then    {but if only 1 line left in memo3, make it invisible}
            Memo3.Visible:=false;
       end;
   Form6.Memo1.Repaint;
   Application.ProcessMessages;
   Form6.EmpGrid.Cells[MCol,MRow]:='';
end;

procedure CloseMemo2;
   {close memo2 here and process name label}
var
   S:string;
begin
   with Form6.Memo2 do
      begin
         ParseMemo2;
         S:=Text;
         if S<>ThisTemp then
         if (S='') or (Lines[1]='')then
            begin
               S:=ThisTemp;
               Form6.EmpGrid.Cells[MCol,MRow]:=S;
            end
         else
            begin
               SaveNam;
               Form13.SG1.Cells[1,MRow]:=Lines[0]+#13#10+' '+Lines[1];
               Form6.EmpGrid.Cells[MCol,MRow]:=' '+Lines[0]+#13#10+' '+Lines[1];
            end;
         Visible:=false;
      end;
   Form6.Memo2.Repaint;
   Application.ProcessMessages;
end;

procedure TForm6.ListBox1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
{process test results from ListBox1}
var
   RecNo:integer;
   S,T,U:string;
begin
   with ListBox1 do if ItemIndex>-1 then
      begin
         TestFlag:=false;
         S:=Items[ItemIndex];
         T:=Copy(S,1,1);
         if (S<>'') and (T<>'-')and (T<>'N') then
            begin
               if T<>'M' then
                  begin
                     if T='D' then U:='Remove this duplicate time entry?';
                     if T='X' then U:='Remove this duplicate extra entry?';
                     if MessageDlg(U,mtConfirmation,[mbYes,mbNo],0)= mrYes then
                        begin
                           TestFlag:=true;
                           U:=Copy(S,3,4);
                           RecNo:=StrToInt(U);
                           DoDeleteRec(RecNo);
                           Selected[ItemIndex]:=true;
                           Selected[ItemIndex+1]:=true;
                           if ItemIndex mod 3 = 1 then
                              Selected[ItemIndex+1]:=true
                           else Selected[ItemIndex-2]:=true;
                           DeleteSelected;
                           if ItemIndex=0 then
                              Items.Add('No Duplicates found');
                        end
                     else
                        begin
                           Selected[ItemIndex]:=false;
                           Itemindex:=-1;
                        end;
                  end;
            end;
      end;
end;

procedure TForm6.Button8Click(Sender: TObject);
   {Payroll button}
begin
   if Memo1.Visible=true then CloseMemo1;
   if Memo2.Visible=true then CloseMemo2;
   if Memo3.Visible=true then memo3.Visible:=false;
   if LB2.Visible=true then LB2.Visible:=false;
   Form11.ShowModal;
end;

procedure SetMemo1;
   {set memo1 with time data}
   {MEntry is 0,1 or 2 = line in cell which is being modified}
   {   unless this is a 'More Entries' [memo3 visible] situation}
   {already verified that this MEntry is not blank}
   {each cell string from Form13.SG1 or SG2 consists of one
      or more entries each of which has a parent string [11 chars]
         + one or more child strings [each 14 chars long] terminated by <CR><LF>
      each parent string has a three-char id string followed by two four-char time strings
      in the format HHMM.  These two times are the displayed start and stop time
         which the user can modify.
      The first eleven chars of each child string are the same format as a parent string [IIIHHMMHHMM]
         the final three chars of the child string are the position id as found in FunJobs.db.
      If the position string = 999 then this particular child string has not be assigned a position.
      A typical id number begins with a plus sign for active work times or a - for off times;
         the two other chars are the id number for the time string found in Funtimes.
      The user does not directly modify the times of any child string. }
var
   I,J,K,L,Count:integer;
   S,T,TCS:string;
begin
   with Form6 do
      begin
         if Memo3.Visible=true then
            L:=Mentry+2
         else L:=Mentry;
         Memo1.Clear;
         Memo1.BringToFront;
         S:=Form13.SG1.Cells[ThisDay+2,MRow];
         CountEnt(S,Count);   {Count=number of parent/child entries in this cell string [1,2,or 3]}
         for I:=1 to Count do
            begin
               J:=Pos(Chr(10),S);  {process record number}
               if J>0 then
                  begin
                     if I=L+1 then
                        begin
                           if Copy(S,1,1)='A' then T:='10'+Copy(S,2,2)
                              else if Copy(S,1,1)='B' then T:='11'+Copy(S,2,2)
                              else if Copy(S,1,1)='C' then T:='12'+Copy(S,2,2)
                              else if Copy(S,1,1)='D' then T:='13'+Copy(S,2,2)
                              else if Copy(S,1,1)='E' then T:='14'+Copy(S,2,2)
                              else if Copy(S,1,1)='F' then T:='15'+Copy(S,2,2)
                              else if Copy(S,1,1)='G' then T:='16'+Copy(S,2,2)
                              else if Copy(S,1,1)='H' then T:='17'+Copy(S,2,2)
                              else if Copy(S,1,1)='I' then T:='18'+Copy(S,2,2)
                              else if Copy(S,1,1)='J' then T:='19'+Copy(S,2,2)
                              else if Copy(S,1,1)='K' then T:='20'+Copy(S,2,2)
                              else if Copy(S,1,1)='L' then T:='21'+Copy(S,2,2)
                              else if Copy(S,1,1)='M' then T:='22'+Copy(S,2,2)
                              else if Copy(S,1,1)='N' then T:='23'+Copy(S,2,2)
                              else if Copy(S,1,1)='O' then T:='24'+Copy(S,2,2)
                              else if Copy(S,1,1)='P' then T:='25'+Copy(S,2,2)
                              else if Copy(S,1,1)='Q' then T:='26'+Copy(S,2,2)
                              else if Copy(S,1,1)='R' then T:='27'+Copy(S,2,2)
                              else if Copy(S,1,1)='S' then T:='28'+Copy(S,2,2)
                              else if Copy(S,1,1)='T' then T:='29'+Copy(S,2,2)
                              else if Copy(S,1,1)='U' then T:='30'+Copy(S,2,2)
                              else if Copy(S,1,1)='V' then T:='31'+Copy(S,2,2)
                              else if Copy(S,1,1)='W' then T:='32'+Copy(S,2,2)
                              else T:=Copy(S,1,3);   {here if record # > 999}
                           TCS:=Copy(S,1,3);
                           UnAdjCount(TCS,K);
                           {ThisRec:=StrToInt(T);}     {ThisRec = record # as integer}
                           ThisRec:=K;
                           Memo1Plus:=Copy(S,4,1);
                           if Memo1Plus<>Offmark then    {if Memo1Plus <> Offmark then active work time}
                              begin
                                 T:=Copy(S,7,8);
                                 DoTime(True,T);
                              end
                           else
                              begin
                                 if CompFlag=false then
                                    Passtime(S)
                                 else Comptime(S,T);
                                 T:=Copy(S,2,Length(S)-3);
                              end;
                           Memo1.Text:=T;
                        end
                     else Delete(S,1,J);
                  end;
            end;
                         {set parameters for memo1}
         if Memo3.Visible=false then  {if memo3 is visible set memo1 in memo3}
            begin
               Memo1.Top:=EmpGrid.Top+MRect.Top+2+(EmpGrid.Canvas.TextHeight('Test')*MEntry);
               Memo1.Left:=EmpGrid.Left+MRect.Left+2;
            end
         else              {if memo3 is not visible, set memo1 in empgrid cell}
            begin
               Memo1.Top:=Memo3.Top+2+(EmpGrid.Canvas.TextHeight(S)*MEntry);
               Memo1.Left:=Memo3.Left;
            end;
         Memo1.Width:=Col1;
         Memo1.Height:=EmpGrid.Canvas.TextHeight('Test')+2;
         Memo1.Visible:=true;
         if Memo1Plus=Offmark then      {here if time entry is to be deleted}
            begin
               if MessageDlg('Delete this off time?',mtConfirmation,[mbYes,mbNo],0)=mrYes then
                     DeleteRec(ThisRec);
               Closememo1;
            end
         else
            begin
               ThisTemp:=Memo1.Text;    {set thistemp as original memo1 text to check for change}
               S:=ThisTemp;       {start here to find where to place the cursor in memo1}
               J:=Pos('-',S);    {look for '-' either between start/stop times or open shift e.g. '5:00-'}
               Delete(S,1,J);
               if S<>'' then
                  repeat
                      K:=Pos('-',S);
                      if K>0 then
                         begin
                            J:=J+K;
                            Delete(S,1,K);
                         end;
                  until K=0;
               if J>0 then       {J is the position of the last '-' in the entry, if any}
                  Memo1.SelStart:=Length(Memo1.Text)  {if there is a '-', set cursor pos to end of text}
               else Memo1.SelStart:=1;                  {otherwise set cursor to beginning of entry}
               Memo1.SetFocus;
            end;
      end;
end;

procedure SetMemo3;
{set up memo3 when 'More Entries' is selected with right mouse click}
var
   I,J,Count:integer;
   S,T:string;
begin
   with Form6 do
      begin
         Memo3.Clear;
         Memo3.Top:=EmpGrid.Top+MRect.Top+2+(EmpGrid.Canvas.TextHeight('test')*MEntry);
         Memo3.Left:=EmpGrid.Left+MRect.Left+2;
         Memo3.Width:=Col1;
         S:=Form13.SG1.Cells[ThisDay+2,MRow];
         if CompFlag=false then
            Passtime(S)
         else Comptime(S,T);
         Memo3.Font.Color:=clBlack;
         CountEnt(S,Count);   {Count=number of entries in this cell string [1,2,or 3]}
         for I:=1 to Count do     {add entries from SG1 - skip 1st two entries}
            begin
               J:=Pos(Chr(10),S);
               if J>0 then
                  if I>2 then
                     begin
                        T:=Copy(S,1,J-2);
                        {T:=Copy(S,7,8);
                        DoTime(True,T);
                        {if (Pos(UpMark,S)>0) and (Pos(UpMark,S)<J) then
                           begin
                              Delete(T,1,1);
                              Insert('U',T,1);
                           end
                        else if (Pos(PdMark,S)>0) and (Pos(PdMark,S)<J) then
                           begin
                              Delete(T,1,1);
                              Insert('P',T,1);
                           end;   }
                        Memo3.Lines.Add(T);
                     end;
               Delete(S,1,J);
            end;
         S:='Test';    {set the height of memo3 based on number of entries}
         Memo3.Height:=(EmpGrid.Canvas.TextHeight(S)+2)*(Memo3.Lines.Count);
         Memo3.Visible:=true;
      end;
end;

procedure TForm6.Button9Click(Sender: TObject);
   {Show Hours button}
begin
   if Button9.Caption='Hours On' then
      Button9.Caption:='Hours Off'
   else
      Button9.Caption:='Hours On';
   EmpGrid.Visible:=false;
   EmpGrid.Visible:=true;
end;

procedure TForm6.AddName1Click(Sender: TObject);
{add new name to time sheet}
var
   I,J:longint;
   Flag:boolean;
   S:string;
begin
   Form4.ShowModal;
   if LocFlag=true then
      begin
         Flag:=false;
         for I:=0 to Form13.SG1.RowCount-1 do if Flag=false then
            begin
               J:=StrToInt(Form13.SG1.Cells[0,I]);
               S:=Form13.SG1.Cells[2,I];
               if J=LocId then Flag:=true;
            end;
         if Flag=true then
            begin
               S:='This name is already entered on the hourly time sheet!';
               MessageDlg(S,mtError,[mbCancel],0);
            end
         else
            begin
               Flag:=false;
               Add_New_Name_To_Timesheet(Flag);
               Do_it(false);
               EmpGrid.RowCount:=EmpGrid.RowCount+1;
               SetLastPages;
               EmpGrid.Repaint;
               Application.ProcessMessages;
            end;
      end;
end;

procedure TForm6.EditName1Click(Sender: TObject);
{set up to edit a name cell in Memo1}
var
   U:TRect;
begin
   if NamId>0 then with Memo2 do
      begin
         if Visible=true then CloseMemo2;
         Clear;
         Text:=Form13.SG1.Cells[1,MRow];
         ParseMemo2;
         ThisTemp:=Memo2.Text;
         SelLength:=0;
         Font:=EmpGrid.Font;
         Height:=EmpGrid.DefaultRowHeight;
         U:=EmpGrid.CellRect(MCol,MRow);
         Top:=Form6.Top+EmpGrid.Left+U.Top-18;
         Left:=Form6.Top+EmpGrid.Left+U.Left;
         Width:=U.Right-U.Left;
         Visible:=true;
         SetFocus;
      end;
end;

procedure TForm6.DeleteName2Click(Sender: TObject);
   {remove name from this shift on time sheet}
var
   F,TS:string;
   J:integer;
begin
   TS:=Form13.SG1.Cells[2,MRow];
   Form13.SG1.Cells[2,MRow]:='S';
   EmpGrid.Cells[0,MRow]:='';
   if MessageDlg('Are you sure you want to delete this name?',mtConfirmation,[mbYes,mbNo],0)= mrYes then
      begin
         F:=IntToStr(NamId);
         Delete_Name_Plus(F);
         for J:=0 to EmpGrid.ColCount-1 do
            EmpGrid.Cells[J,MRow]:='';
         EmpGrid.RowCount:=EmpGrid.RowCount-1;
         {TotalUp;}
         SetLastPages;
      end
   else
      begin
         Form13.SG1.Cells[2,MRow]:=TS;
         EmpGrid.Cells[0,MRow]:='';
      end;
end;


procedure TForm6.LB2MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
   {if LB2.Visible=true then
      if Button=mbRight then
      LB2.Visible:=false
   else if Button=mbLeft then
      if LB2.ItemIndex>=0 then
         begin
            LB2.Visible:=false;
         end;}
   LB2.Visible:=false;
end;

procedure TForm6.FormClose(Sender: TObject; var Action: TCloseAction);
begin
   LB2.Visible:=false;
   if Memo1.Visible=true then
      CloseMemo1;
   if Memo2.Visible=true then
      CloseMemo2;
   if Memo3.Visible=true then
      Memo3.Visible:=false;
   Button9.Caption:='Hours On';
end;

procedure TForm6.Day1Click(Sender: TObject);
{Bring up schedule page}
var
   I:integer;
begin
    with Sender as TLabel do
      begin
         Offset:=((Left-Col0) div Col1)+1;
         Schedfile:=Newfile;
         I:=Pos(#10,Caption);
         if I>0 then
            SchedStr:=Copy(Caption,1,I-2)
         else SchedStr:='';
         Form8.Showmodal;
      end;
end;

procedure GetColorCode(S:string;var Code:string);
{get color Code for Timestring S}
var
   I,J:integer;
   T,U:string;
begin
   Code:='';
   T:=Copy(S,4,1);
   U:=Copy(S,5,2);
   if T=OffMark then U:='-'+U;
   with Form13.TimeGridP do for I:=1 to RowCount do
      begin
         J:=StrToInt(Cells[0,I-1]);
         if StrToInt(U)=J then
            Code:=Cells[5,I-1]
      end;
end;

procedure TForm6.EmpGridDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
var
   S,T,U,V:string;
   I,J,K,Count:integer;
begin
   with Empgrid do
      begin
         MRect:=Rect;
         if ACol=0 then    {fill empgrid names here}
            begin
               Canvas.FillRect(Rect);
               S:=Form13.SG1.Cells[1,ARow];
               T:=Form13.SG1.Cells[2,ARow];
               if T='H' then
                  Canvas.Font.Color:=HourlyColor
               else if T='M' then
                  Canvas.Font.Color:=MinorColor
               else if T='F' then
                  Canvas.Font.Color:=FifteenColor
               else if T='S' then
                  Canvas.Font.Color:=SpecialColor
               else if T='T' then
                  Canvas.Font.Color:=FamColor
               else
                  Canvas.Font.Color:=ExEmpColor;
               I:=Pos(#13,S);
               if I>0 then     {separate lines for first and last names}
                  begin
                     U:=' '+Copy(S,1,I-1);
                     S:=Copy(S,I+2,Length(S));
                     Canvas.TextOut(Rect.Left,Rect.Top+Canvas.TextHeight(S) div 2,U);
                     Canvas.TextOut(Rect.Left,Rect.Top+Canvas.TextHeight(S)+Canvas.TextHeight(S) div 2,S);
                  end
               else      {default if no <cr> char found}
                 Canvas.TextOut(Rect.Left,Rect.Top,S);
               if Form6.Button9.Caption='Hours Off' then
                  TotalHours(ARow);
            end
         else   {here to fill times}
            begin
               Canvas.FillRect(Rect);
               S:=Form13.SG1.Cells[ACol+2,ARow];
               T:='';
               if S<>'' then
                   GetColorCode(S,T);
               If T='1' then
                 Canvas.Font.Color:=clRed
               else if T='2' then
                  Canvas.Font.Color:=clBlack
               else if T='3' then
                  Canvas.Font.Color:=clPurple
               else Canvas.Font.Color:=clBlue;
               if S<>'' then
                  begin
                     if CompFlag=false then
                        Passtime(S)
                     else CompTime(S,V);
                     CountEnt(S,Count);
                     for I:=1 to Count do
                        begin
                           J:=Pos(Chr(10),S);
                           if J>0 then
                              begin
                                { V:=Copy(S,1,1);
                                 if V=UPMark then
                                    T:='U'+Copy(S,2,J-3)
                                 else if V=PdMark then
                                    T:='P'+Copy(S,2,J-3)
                                 else T:=' '+Copy(S,2,J-3);}
                                 if Copy(S,1,1)=OffMark then
                                    begin
                                       Delete(S,1,1);
                                       Insert(' ',S,1);
                                    end;
                                 T:=Copy(S,1,J-2);
                                 K:=Canvas.TextHeight(S)*(I-1);
                                 if (I>3) and (Count>3) then
                                    begin
                                       Canvas.Font.Color:=clBlack;
                                       T:=' More entries';
                                       K:=Canvas.TextHeight(S)*2;
                                    end;
                                 Canvas.TextOut(Rect.Left+2,Rect.Top+K,T);
                                 Delete(S,1,J);
                              end;
                        end;
                  end;
               if Form6.Button9.Caption='Hours Off' then   {here to parse and display total hours}
                  begin
                     Parsehour(ACol,ARow);
                     Empgrid.Cells[0,ARow]:='';
                  end;
            end;

      end;
end;

procedure Change_One_Break(Indx:integer;Dat:string;TFlag:boolean);
{toggle the upaid/paid break status of one T record in .db and .txt}
{Dat is SG1 entry for this day/ this employee}
{TFlag is true to change Paid to Unpaid and vice versa}
var
   I,J,K,Cnt,RecN:integer;
   S,T,Old,New:string;
begin
   if TFlag=false then
      begin
         Old:=UPMark;
         New:=PdMark;
      end
   else
      begin
         Old:=PdMark;
         New:=UPMark;
      end;
   CountEnt(Dat,Cnt);
   for I:=1 to Cnt do
      begin
         J:=Pos(Chr(10),Dat);
         S:=Copy(Dat,1,J);         {S=RecN+Parent+Child+$D$A portion of SG1 entry}
         Delete(Dat,1,J);          {delete this portion of SG1 entry}
         if (Indx=-1) or (Indx=I) then
            begin
               K:=Pos(Old,S);  {change all Old Marks to New Marks from individual records that make up SG1 entry}
               if K<>0 then     {- should be only one, but just in case change them all}
                  begin
                     Delete(S,K,1);               {modify and save each individual time record that has breaks in it}
                     Insert(New,S,K);
                     with Form6.Memo3 do if Visible=true then
                        begin
                           T:=Lines[Mentry];
                           Delete(T,1,1);
                           if TFlag=true then Insert('U',T,1)
                           else Insert('P',T,1);
                           Lines[Mentry]:=T;
                        end;
                     RecN:=StrToInt(Copy(S,1,3));  {get record number from entry}
                     S:=Copy(S,15,J-16);           {Get S=child string}
                     ModifyBreak(RecN,S);          {Send child string to modifybreak}
                 end;
            end;
      end;
end;

procedure Check_The_Breaks;
{do checking of unpaid/paid breaks for this cell or this entire column}
var
   I,J,K,Resp,Indx:integer;
   S,T:string;
begin
   with Form6 do
      begin
         T:=Form13.SG1.Cells[ThisDay+2,ThisSGX]; {this is current time data for this day and employee}
         J:=Pos(UPMark,T);     {Check for unpaid break marker}
         K:=Pos(PdMark,T);     {Check for paid break marker}
         if (J<>0) or (K<>0) then
            begin
               S:='Push Yes to make this break unpaid'+#13#10
                   +'Push No to make this break paid.'+#13#10
                    +'Push YesToAll to make all breaks today unpaid'+#13#10
                    +'Push NoToAll to make all breaks today paid';
               Resp:=MessageDlg(S,mtCustom,[mbYes,mbNo,mbYesToAll,mbNoToAll,mbCancel],0);
               if Resp<>mrCancel then
                  begin
                     if Memo3.Visible=false then
                        Indx:=Mentry+1
                     else Indx:=Mentry+3;
                     if (J<>0) and (Resp=mrNo) then  {here to toggle unpaid to paid}
                           Change_One_Break(Indx,T,false)
                     else  if(K<>0) and (Resp=mrYes) then  {here to toggle paid to unpaid}
                           Change_One_Break(Indx,T,true)
                     else if (Resp=mrYesToAll) or (Resp=mrNoToAll) then   {here to change all appropriate time entries to either unpaid or paid breaks}
                        begin
                           if Resp=mrYesToAll then
                              S:='Are you sure you want to change'+#13#10
                                   +'all appropriate breaks to "unpaid" for this day?'
                           else
                              S:='Are you sure you want to change'+#13#10
                                   +'all appropriate breaks "to paid" for this day?';
                           I:=MessageDlg(S,mtConfirmation,[mbYes,mbNo],0);
                           if I=mrYes then for I:=1 to Form13.SG1.RowCount do
                              begin
                                 Indx:=-1;
                                 S:=Form13.SG1.Cells[Thisday+2,I-1];
                                 J:=Pos(UPMark,S);
                                 K:=Pos(PdMark,S);
                                 if Resp=mrNoToAll then
                                    begin
                                       if J<>0 then Change_One_Break(Indx,S,false);
                                    end
                                 else if K<>0 then Change_One_Break(Indx,S,true);
                              end;
                        end;
                     Do_it(false);
                     Form6.EmpGrid.Repaint;
                     Application.ProcessMessages;
                  end;
            end;
      end;
end;

procedure TForm6.EmpGridDragOver(Sender, Source: TObject; X, Y: Integer;
  State: TDragState; var Accept: Boolean);
{Enable dragover employee grid}
begin
   if Source is TListBox then
      Accept:=true;
end;

procedure TForm6.EmpGridMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
{set Namlabel, NamId and Namshf by clicking on any name label}
var
   Count:integer;
   S:string;
begin
   if Memo1.Visible=true then
      CloseMemo1;
   if Memo2.Visible=true then
      CloseMemo2;
   if Memo3.Visible=true then Memo3.Visible:=false;
   EmpGrid.MouseToCell(X,Y,MCol,MRow);
   ThisDay:=MCol;
   ThisSGX:=MRow;
   MRect:=Empgrid.CellRect(MCol,MRow);
   S:=Form13.SG1.Cells[1,ThisSGX];
   MEntry:=(Y-MRect.Top) div EmpGrid.Canvas.TextHeight(S);
   if MCol=0 then   {name column only!}
      begin
         if Button=mbRight then
            if S<>'' then
               begin
                  NamId:=StrToInt(Form13.SG1.Cells[0,MRow]);
                  NamShf:=Form13.SG1.Cells[2,MRow];
                  NamSGX:=MRow;     {????}
                  X:=Form6.Left+EmpGrid.Left+X;
                  Y:=Form6.Top+EmpGrid.Top+Y;
                  PM1.Popup(X,Y);
               end
            else AddName1Click(EmpGrid);
         if Button=mbLeft then
            if Memo2.Visible then CloseMemo2;
      end
   else if Button=mbRight then      {time columns here}
      begin
         S:=Form13.SG1.Cells[ThisDay+2,MRow];
         CountEnt(S,Count);
         if (Count>3) and (MEntry=2) and (Memo3.Visible=false) then  {here if more than three entries}
            begin
               SetMemo3;
            end
         else if (S<>'')and (MEntry<Count) and (CompFlag=false) then SetMemo1;
      end
   else if Button=mbLeft {and (Shift=[ssLeft,ssShift])} then   {old- left mouse button and shift - do break changing}
        {Check_The_Breaks;}                                      {new - left m. button for name/dow then do time line entry}
      begin
         CurRow:=MRow;
         CurCol:=MCol;
         Form22.ShowModal;
         NewTotalUp;
      end;
end;

procedure TForm6.EmpGridDragDrop(Sender, Source: TObject; X, Y: Integer);
{process drag/drops for employee grid from ListBox1}
begin
   if (Source is TListBox) and (Sender is TStringGrid) then
      begin
         EmpGrid.MouseToCell(X,Y,ThisDay,ThisSGX);
         ProcessDrop(Sender As TStringGrid);
      end;
end;

procedure TForm6.EmpGridDblClick(Sender: TObject);
begin
   DblFlag:=true;
   with (Sender AS TStringGrid) do
      if DS<>'' then
         begin
            ThisSGX:=MRow;
            ThisDay:=MCol;
            ProcessDrop(Sender As TStringGrid);
         end;
end;

procedure TForm6.TotGridDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
var
   S,T:string;
   J,Ind:integer;
begin
   with TotGrid do
      begin
         Canvas.FillRect(Rect);
         T:=Cells[ACol,ARow];
         if ARow=0 then
            begin
              Canvas.Font.Color:=clBlack;
              Canvas.TextOut(Rect.Left{+TotGrid.DefaultColWidth-Canvas.TextWidth(T)},Rect.Top+Canvas.TextHeight(T) div 2,T);
            end
         else if CompFlag=false then
            begin
               if T<>'' then
                  begin
                    S:=Copy(T,4,Length(T)-3)+':   ';
                    Ind:=StrToInt(Copy(T,3,1));
                    case Ind of
                      1:Canvas.Font.Color:=TLBackColor1;
                      2:Canvas.Font.Color:=TLBackColor2;
                      3:Canvas.Font.Color:=TLBackColor3;
                      4:Canvas.Font.Color:=TLBackColor4;
                      5:Canvas.Font.Color:=TLBackColor5;
                    end;
                  end;
               Canvas.TextOut(Rect.Left,Rect.Top+Canvas.TextHeight(S) div 2,S);
               S:=Copy(T,1,2);
               Canvas.Font.Color:=clBlack;
               Canvas.TextOut(Rect.Left+TotGrid.DefaultColWidth-Canvas.TextWidth(S),Rect.Top+Canvas.TextHeight(S) div 2,S);
            end
         else
            begin
               Canvas.Font.Color:=TLBackColor1;
               S:=Copy(T,1,8);
               if S<>'' then
                  begin
                     DoTime(false,S);
                     Canvas.TextOut(Rect.Left,Rect.Top+Canvas.TextHeight(S) div 2,S);
                     J:=StrToInt(Copy(T,9,2));
                     S:=IntToStr(J)+' ';
                     Canvas.Font.Color:=clBlack;
                     Canvas.TextOut(Rect.Right-Canvas.TextWidth(S),Rect.Top+Canvas.TextHeight(S) div 2,S);
                  end;
            end;
      end;
end;

procedure TForm6.Button1Click(Sender: TObject);
{sync changes in yyyymmdd.txt with yyyymmdd.db}
var
  S:string;
  RFlag:boolean;
begin
   S:='Continue with Syncing Input Info with weekly file?';
   if MessageDlg(S,mtConfirmation,[mbYes,mbNo],0)= mrYes then
      begin
         RFlag:=false;
         LB2.Clear;
         Sync(RFlag);
         if RFlag=true then
            begin
               Do_it(false);
               EmpGrid.RowCount:=EmpGrid.RowCount+1;
               EmpGrid.Repaint;
               Application.ProcessMessages;
            end;
         if LB2.Items.Count>0 then LB2.Visible:=true;
      end;
   Form6.EmpGrid.SetFocus;
end;

procedure TForm6.Button2Click(Sender: TObject);
{regenerate yyyymmdd.txt from yyyymmdd.db}
var
   S:string;
begin
   S:='Continue with Regeneration of .txt file?';
   if MessageDlg(S,mtConfirmation,[mbYes,mbNo],0)= mrYes then Regen;
   Form6.EmpGrid.SetFocus;
end;

procedure TForm6.Memo3MouseActivate(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y, HitTest: Integer;
  var MouseActivate: TMouseActivate);
begin
   MouseActivate:=maNoActivateandEat;
   Mentry:=Y div EmpGrid.Canvas.TextHeight('Test');
   if (Button= mbRight) and (CompFlag=false) then
      begin
         SetMemo1;
      end
   else if (Button=mbLeft) and (Shift=[ssShift])then
      {Check_The_Breaks;}
end;

procedure TForm6.Memo1KeyPress(Sender: TObject; var Key: Char);
begin
     if Key in ['B'..'L']+['N'..'Z']+['b'..'l']+['n'..'z'] then Key:=#0
     else if Key in ['0'..'9']+['A','a'] then
        begin
        end
     else if Key=#08 then
        begin
        end
     else if Key=#13 then CloseMemo1
     else if Key='-' then Key:='-'
     else if Key='/' then Key:='A'
     else if Key='.' then Key:=':'
     else if Key=';' then Key:=':'
     else if Key='*' then Key:=':'
     else if Key=':' then Key:=':'
     else Key:=#0;          {everything else is eliminated}
end;

procedure TForm6.Memo1MouseActivate(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y, HitTest: Integer;
  var MouseActivate: TMouseActivate);
begin

   MouseActivate:=maNoActivateandEat;
end;

procedure TForm6.Button4Click(Sender: TObject);
{toggle totals on/off}
begin
   with Form6 do
      if Button4.Caption='Totals Off' then
         begin
            Button4.Caption:='Totals On';
            TotGrid.Visible:=false;
            Label1.Visible:=false;
            EmpGrid.Height:=Form6.Height-385+TotGrid.Height;
         end
      else
         begin
            Button4.Caption:='Totals Off';
            TotGrid.Visible:=true;
            Label1.Visible:=true;
            Empgrid.Height:=Form6.Height-385;
         end;
end;

procedure TForm6.ListBox1DrawItem(Control: TWinControl; Index: Integer;
  Rect: TRect; State: TOwnerDrawState);
var
   S:string;
   J:integer;
begin
   with ListBox1 do
      begin
         J:=StrToInt(Items[Index]);
         if ListBoxFlag=false then             {either display time or name labels in ListBox1}
            {S:=Form13.TimeGridP.Cells[1,Index]}
            S:=Form13.TimeGridP.Cells[1,J]
         else
            {S:=Form13.TimeGridP.Cells[7,Index]; }
            S:=Form13.TimeGridP.Cells[7,J];
         {if Form13.TimeGridP.Cells[5,Index]='1' then}
         if Form13.TimeGridP.Cells[5,J]='1' then
            Canvas.Font.Color:=clRed
         else if Form13.TimeGridP.Cells[5,J]='2' then Canvas.Font.Color:=clBlack
         else if Form13.TimeGridP.Cells[5,J]='3' then Canvas.Font.Color:=clPurple
         else Canvas.Font.Color:=clBlue;
         Canvas.FillRect(Rect);
         Canvas.TextOut(Rect.Left,Rect.Top,S);
      end;
end;

procedure TForm6.Day1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
   I:integer;
   S:string;
begin
    with Sender as TLabel do if ((Button=mbLeft) and (Shift=[ssLeft,ssShift])) then
      begin
         Offset:=((Left-Col0) div Col1)+1;
         Schedfile:=Newfile;
         I:=Pos(#10,Caption);
         if I>0 then
            SchedStr:=Copy(Caption,1,I-2)
         else SchedStr:='';
         EmpFlag:=false;
         Form13.ShowModal;
         FillQueue(Offset);
         S:='';
         case Offset of
           1:S:=Day1.Caption;
           2:S:=Day2.Caption;
           3:S:=Day3.Caption;
           4:S:=Day4.Caption;
           5:S:=Day5.Caption;
           6:S:=Day6.Caption;
           7:S:=Day7.Caption;
          end;
         Form20.Label10.Caption:=S;
         Form20.Showmodal;
      end;
end;
procedure TForm6.TotGridMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
{Process daily mode changes here}
begin
  with Sender as TStringgrid do if Button=mbRight then
     begin
        ModeChangeFlag:=false;
        Form21.showmodal;
        if ModeChangeFlag=true then
           begin
              Fill_ListBox1;
              NewTotalUp;
              Day1.Caption:=DateToStr(NewDate)+Chr(13)+Chr(10)+Formset.ShortDayNames[DayOfWeek(NewDate)]+'  Mode: '+IntToStr(ModArray[1]);
              Day2.Caption:=DateToStr(NewDate+1)+Chr(13)+Chr(10)+Formset.ShortDayNames[DayOfWeek(NewDate+1)]+'  Mode: '+IntToStr(ModArray[2]);
              Day3.Caption:=DateToStr(NewDate+2)+Chr(13)+Chr(10)+Formset.ShortDayNames[DayOfWeek(NewDate+2)]+'  Mode: '+IntToStr(ModArray[3]);
              Day4.Caption:=DateToStr(NewDate+3)+Chr(13)+Chr(10)+Formset.ShortDayNames[DayOfWeek(NewDate+3)]+'  Mode: '+IntToStr(ModArray[4]);
              Day5.Caption:=DateToStr(NewDate+4)+Chr(13)+Chr(10)+Formset.ShortDayNames[DayOfWeek(NewDate+4)]+'  Mode: '+IntToStr(ModArray[5]);
              Day6.Caption:=DateToStr(NewDate+5)+Chr(13)+Chr(10)+Formset.ShortDayNames[DayOfWeek(NewDate+5)]+'  Mode: '+IntToStr(ModArray[6]);
              Day7.Caption:=DateToStr(NewDate+6)+Chr(13)+Chr(10)+Formset.ShortDayNames[DayOfWeek(NewDate+6)]+'  Mode: '+IntToStr(ModArray[7]);
           end;
     end;
end;

procedure TForm6.Button6Click(Sender: TObject);
{'Test' button}
var
   I,X:integer;
   S:string;
begin
   if Button6.Caption<>'Test Done' then
      begin
         Button6.Caption:='testing';
         for I:=1 to 50 do TestArray[I]:='';
         TestEmp(X);
         ListBox1.Clear;
         if X<>0 then
            begin
               for I:=1 to 50 do if TestArray[I]<>'' then
                  ListBox1.Items.Add(TestArray[I]);
            end
         else
            begin
               S:='No duplicates found';
               ListBox1.Items.Add(S);
            end;
         ListBox1.Visible:=true;
         Button6.Caption:='Test Done';
      end
   else
      begin
         if TestFlag=true then
            begin
              Do_it(true);
            end;
         ListBox1.Visible:=false;
         Button6.Caption:='Test File';
      end;
end;

procedure TForm6.Button7Click(Sender: TObject);
{Automatic Time Compression Toggle}
begin
   Memo3.Visible:=false;
   if CompFlag=true then
      begin
         Button7.Caption:='Comb Off';
         CompFlag:=false;
         NewTotalUp;
      end
   else
      begin
         Button7.Caption:='Comb On';
         CompFlag:=true;
         TotalUp;
      end;
   EmpGrid.Repaint;
end;

procedure TForm6.EmpGridTopLeftChanged(Sender: TObject);
begin
   if Memo1.Visible=true then
      CloseMemo1;
   if Memo2.Visible=true then
      CloseMemo2;
   if Memo3.Visible=true then Memo3.Visible:=false;
end;

end.

