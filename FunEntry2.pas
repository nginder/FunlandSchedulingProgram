unit FunEntry2;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Grids, StdCtrls, ExtCtrls, DateUtils, FunGrid, ComCtrls;

type
  TForm22 = class(TForm)
    EmpName: TLabel;
    Button3: TButton;
    Panel1: TPanel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    Shape1: TShape;
    Shape2: TShape;
    Shape3: TShape;
    Shape4: TShape;
    Shape6: TShape;
    Shape7: TShape;
    Shape8: TShape;
    Shape9: TShape;
    Shape10: TShape;
    Shape11: TShape;
    Shape12: TShape;
    Shape13: TShape;
    Shape14: TShape;
    Shape15: TShape;
    Shape16: TShape;
    Shape17: TShape;
    Shape18: TShape;
    Shape19: TShape;
    Shape20: TShape;
    Shape21: TShape;
    Label16: TLabel;
    Label15: TLabel;
    Label17: TLabel;
    Shape22: TShape;
    Shape23: TShape;
    Label18: TLabel;
    Shape24: TShape;
    Shape25: TShape;
    Label19: TLabel;
    Shape26: TShape;
    Shape28: TShape;
    Label20: TLabel;
    Shape29: TShape;
    Shape30: TShape;
    Label21: TLabel;
    Shape31: TShape;
    Shape5: TShape;
    Shape32: TShape;
    Shape33: TShape;
    Shape34: TShape;
    Shape35: TShape;
    Shape36: TShape;
    Shape37: TShape;
    Shape38: TShape;
    Shape39: TShape;
    Shape40: TShape;
    Shape41: TShape;
    Shape42: TShape;
    Shape43: TShape;
    Shape44: TShape;
    Shape45: TShape;
    Shape46: TShape;
    Shape47: TShape;
    Shape48: TShape;
    Shape49: TShape;
    Shape50: TShape;
    Shape51: TShape;
    Shape52: TShape;
    Shape53: TShape;
    Shape54: TShape;
    Shape55: TShape;
    Shape56: TShape;
    Shape57: TShape;
    Shape58: TShape;
    TL1: TLabel;
    TL2: TLabel;
    TL3: TLabel;
    TL4: TLabel;
    TL5: TLabel;
    Name1: TLabel;
    Name2: TLabel;
    Name3: TLabel;
    Name4: TLabel;
    Name5: TLabel;
    Button1: TButton;
    A1: TLabel;
    A2: TLabel;
    A3: TLabel;
    A4: TLabel;
    A5: TLabel;
    A6: TLabel;
    A7: TLabel;
    A8: TLabel;
    A9: TLabel;
    A10: TLabel;
    B1: TLabel;
    B3: TLabel;
    B4: TLabel;
    B5: TLabel;
    B6: TLabel;
    B7: TLabel;
    B8: TLabel;
    B9: TLabel;
    B10: TLabel;
    C1: TLabel;
    C2: TLabel;
    C3: TLabel;
    C4: TLabel;
    C5: TLabel;
    C6: TLabel;
    C7: TLabel;
    C8: TLabel;
    C9: TLabel;
    C10: TLabel;
    D1: TLabel;
    D2: TLabel;
    D3: TLabel;
    D4: TLabel;
    D5: TLabel;
    D6: TLabel;
    D7: TLabel;
    D8: TLabel;
    D9: TLabel;
    D10: TLabel;
    E1: TLabel;
    E2: TLabel;
    E3: TLabel;
    E4: TLabel;
    E5: TLabel;
    E6: TLabel;
    E7: TLabel;
    E8: TLabel;
    E9: TLabel;
    E10: TLabel;
    DowName: TLabel;
    ModeName: TLabel;
    Shape27: TShape;
    Label1: TLabel;
    Shape59: TShape;
    Shape60: TShape;
    Shape61: TShape;
    RadG1: TRadioGroup;
    TotST: TLabel;
    TotSW: TLabel;
    TotAW: TLabel;
    TotAT: TLabel;
    TC1: TPanel;
    Button2: TButton;
    Button4: TButton;
    Label4: TLabel;
    Label5: TLabel;
    B2: TLabel;
    Label10: TLabel;
    CK1: TLabel;
    X1: TLabel;
    X2: TLabel;
    Edit1: TEdit;
    UD1: TUpDown;
    Edit2: TEdit;
    UD2: TUpDown;
    OffAll: TLabel;
    ExLabel: TLabel;
    procedure Panel1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Name5Click(Sender: TObject);
    procedure OffAllClick(Sender: TObject);
    procedure UD2Click(Sender: TObject; Button: TUDBtnType);
    procedure UD1Click(Sender: TObject; Button: TUDBtnType);
    procedure Button2Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure A1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure RadG1Click(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

const
   TLLeft = 120;  {left coordinate for all time lines}
   TLHeight = 32; {height for all time lines}
   TLTop1 = 120; {top coordinates for each time line}
   TLTop2 = 184;
   TLTop3 = 248;
   TLTop4 = 312;
   TLTop5 = 376;
   TL15Min = 16;  {15 minute increment for all time lines}

var
  Form22: TForm22;
  Mood:integer;
  LCnt: array[1..5] of integer;
  Tbls: array [1..5,1..10] of TLabel;
  TCount:integer; {current record number for new records to yyyymmdd.db}
  TCS:string;  {3 byte string of TCount}
  OldData:string;  {holds original data string for this emp/this day in case of cancel}
  AstFlag:boolean;  {used with total hours calculations}
  StartTime,StopTime:integer;  {used with time entry manual editing}
  Indx:integer; {used with time entry manual editing save}
  XFlag:boolean;   {used with Extra time label=false for start/true for end}
  XStart,XSt,XCnt:integer;  {start time for Extra shift; 0-start/1=stop/2=done}

  implementation

{$R *.dfm}

procedure TForm22.Button3Click(Sender: TObject);
{cancel button}
begin
   Form13.SG1.Cells[CurCol+2,CurRow]:=OldData;  {restore original time data for this employee - no change}
   Button1.Enabled:=true;
    Panel1.Color:=Pan1Off;
   Close;
end;

procedure ConvertTimeLine(Tim:integer;var STim:string);
{convert extra time coordinates to HHLL strings}
var
   Hrs,Mins:integer;
   S:string;
begin
   Hrs:=(Tim div (4*TL15Min))+9;
   S:=IntToStr(Hrs);
   if Hrs<10 then S:='0'+S;
   Mins:=Tim mod (4*TL15Min);
   STim:='00';
   case Mins of
      16:STim:='15';
      32:STim:='30';
      48:STim:='45';
    end;
   STim:=S+STim;
end;

procedure TForm22.Button1Click(Sender: TObject);
{save button}
var
   I,J,K,L,Ents,Ind,RecNo,NStar,NStop,Cnt,Strt,Stop:integer;
   S,T,U,V,W,TId,SId,NewSGEnt,DT,Inst,Oust,Test:string;
   Flag:boolean;

begin
   NewSGEnt:='';
   S:=Form13.SG1.Cells[CurCol+2,CurRow];
   NamShf:=Form13.SG1.Cells[2,CurRow]; {get shift from SG1}
   ThisId:=StrToInt(Form13.SG1.Cells[0,CurRow]);  {get emp id from SG1}
   CountEnt(S,Ents);   {get no. of entries in current SG1 entry}
   for I:=1 to 5 do for J:=1 to 10 do
      if Tbls[I,J].Tag>-1 then with Tbls[I,J] do
      begin
         Ind:=Tag;
         V:=Name;
         U:=Font.Name;
         if I=5 then
            begin
               if Tag=99 then
                  begin
                     ConvertTimeLine(Tbls[I,J].Left-TLLeft,Test); {Get HHMM for start ofthis Tbl[I,J]}
                  end;
            end
         else
            TId:=Form13.TimeGridP.Cells[0,Ind];  {this is time id for this time entry label}
         Flag:=false;
         K:=0;
         if Ents>0 then    {check each time entry in this SG11 cell-is this time entry already in SG1?}
            repeat
               Inc(K);
               L:=((K-1)*30+5);    {L=pointer to time id for this entry in SG1}
               T:=Copy(S,L+13,4);
               if Tag=99 then
                  begin
                     if Test<>Copy(S,L+13,4) then TId:=''    {If HHMM of Tbl[I,J]<>HHMM start of this SG1 entry then no match}
                     else TId:='99';
                  end;
               SId:=Copy(S,L,2);
               T:=Copy(S,L-4,3);    {T=record no. string for this entry}
               UnAdjCount(T,RecNo);    {change recno for no.s >1000}
               if SId=TId then Flag:=true;      {Yes, time id's match}
            until (Flag=true) or (K>=Ents);
         if (Flag=true) and (U=FontOff) then   {here if entry present in SG1 but shouldn't be}
            begin                                        {don't enter in NewSGEnt but delete in weekly and txt}
               DoDeleteRec(RecNo);
            end
         else if (Flag=true) and (U=FontOn) then   {here if entry present and should be- move to NewSGEnt}
            begin
               W:=Copy(S,L-4,30);
               DT:=Copy(S,L+10,1);
               if DT='*' then                   {check for any changed times}
                  begin
                     DoDeleteRec(RecNo);    {delete old record}
                     Delete(W,15,1);         {restore unchanged marker}
                     Insert('+',W,15);
                     NewStr:=Copy(W,4,27);  {NewStr=data string without record no.}
                     V:=Copy(W,18,4);  {V=schedule start time HHMM string}
                     InTime(V,NStar);     {NStar=Start time in minutes from midnight}
                     Add_Drop_To_File(NewStr,NamShf,NStar,ThisId,CurCol,RecNo+1);  {save revised entry with same record no.}
                  end;
               NewSGEnt:=NewSGEnt+W;
            end
         else if (Flag=false) and (U=FontOff) then
            begin
              {here if not present and shouldn't be - skip entering in NewSGEnt}
            end
         else if (Flag=false) and (U=FontOn) then  {here if not present and should be}
            begin      {make new entry and put in NewSGEnt and add to weekly and txt}
               if (I=5) and (Tbls[5,J].Tag=99) then
                  begin
                     Strt:=Tbls[5,J].Left-TLLeft;
                     ConvertTimeLine(Strt,Inst);
                     Stop:=Strt+Tbls[5,J].Width+2;
                     ConvertTimeLine(Stop,Oust);
                     InTime(Inst,NStar);
                     NewStr:='+99'+Inst+Oust+'+00'+Inst+Oust+'999'+Chr(13)+Chr(10);
                     T:=Copy(Newstr,4,4);
                     InTime(T,NStar);
                  end
               else MakeNewStr(Ind);
               DoCount(TCount,U);  {get U=next 3char. record no. and update TCount to next record no.}
               Add_Drop_To_File(NewStr,NamShf,NStar,ThisId,CurCol,TCount);
               T:=U+NewStr;
               NewSGEnt:=NewSGEnt+T;
            end;
      end;
   SortSG1(NewSGEnt);
   Form13.SG1.Cells[CurCol+2,CurRow]:=NewSGEnt;
   Close;
end;

procedure FillTbls; {fill label array}
var
  I:integer;
begin
   with Form22 do
      begin
         Tbls[1,1]:=A1;
         Tbls[1,2]:=A2;
         Tbls[1,3]:=A3;
         Tbls[1,4]:=A4;
         Tbls[1,5]:=A5;
         Tbls[1,6]:=A6;
         Tbls[1,7]:=A7;
         Tbls[1,8]:=A8;
         Tbls[1,9]:=A9;
         Tbls[1,10]:=A10;
         Tbls[2,1]:=B1;
         Tbls[2,2]:=B2;
         Tbls[2,3]:=B3;
         Tbls[2,4]:=B4;
         Tbls[2,5]:=B5;
         Tbls[2,6]:=B6;
         Tbls[2,7]:=B7;
         Tbls[2,8]:=B8;
         Tbls[2,9]:=B9;
         Tbls[2,10]:=B10;
         Tbls[3,1]:=C1;
         Tbls[3,2]:=C2;
         Tbls[3,3]:=C3;
         Tbls[3,4]:=C4;
         Tbls[3,5]:=C5;
         Tbls[3,6]:=C6;
         Tbls[3,7]:=C7;
         Tbls[3,8]:=C8;
         Tbls[3,9]:=C9;
         Tbls[3,10]:=C10;
         Tbls[4,1]:=D1;
         Tbls[4,2]:=D2;
         Tbls[4,3]:=D3;
         Tbls[4,4]:=D4;
         Tbls[4,5]:=D5;
         Tbls[4,6]:=D6;
         Tbls[4,7]:=D7;
         Tbls[4,8]:=D8;
         Tbls[4,9]:=D9;
         Tbls[4,10]:=D10;
         Tbls[5,1]:=E1;
         Tbls[5,2]:=E2;
         Tbls[5,3]:=E3;
         Tbls[5,4]:=E4;
         Tbls[5,5]:=E5;
         Tbls[5,6]:=E6;
         Tbls[5,7]:=E7;
         Tbls[5,8]:=E8;
         Tbls[5,9]:=E9;
         Tbls[5,10]:=E10;
      end;
end;

procedure LabelInit;  {intialize all time line labels}
var
   I,J:integer;
begin
 with Form22 do
  begin
     Name1.Caption:='';
     Name2.Caption:='';
     Name3.Caption:='';
     Name4.Caption:='';
     Name5.Caption:='';
     for I:=1 to 5 do for J:=1 to 10 do
        begin
           Tbls[I,J].Font.Style:=[];
           Tbls[I,J].Font.Size:=10;
           Tbls[I,J].Font.Name:=FontOff;
           Tbls[I,J].Tag:=-1;
           Tbls[I,J].Visible:=false;
        end;
     for I:=1 to 5 do LCnt[I]:=0; {clear label timeline pointers}
  end;
end;

procedure GetTimeString(TId,NStar:string;var S:string;var Index:integer);
{search SG1.Cells[CurCol+2,CurRow for Id=TId; return in S; Index=start position of string}
{for extra shifts, use NStar to get proper entry in SG1}
var
   K,L,Ents:integer;
   T,SId:string;
   Flag:boolean;
begin
   with Form22 do
      begin
         T:=Form13.SG1.Cells[CurCol+2,CurRow];
         CountEnt(T, Ents);
         K:=0;
         Flag:=false;
         S:='';
         Index:=-1;
         if Ents>0 then
            repeat
               Inc(K);
               L:=((K-1)*30+5);
               SId:=Copy(T,L,2);
               if (SId='99') and (Copy(T,L+13,4)<>NStar) then  SId:='';
               if SId=TId then
                  begin
                     Flag:=true;
                     S:=Copy(T,L-4,30);
                     Index:=L-4;
                  end;
            until (Flag=true) or (K>=Ents);
      end;
end;

procedure GetMins(S:string;var AMins,SMins:integer;var AstFlag:boolean);
{get total minutes from string S which is data string from SG1}
{S is tested prior to call to be <>''}
var
   Posit:integer;
   U,Plus,Break,Star,Stop:string;
   Sta,Sto:longint;
begin
   AMins:=0;
   SMins:=0;
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
                  Star:=Copy(U,7,4); {first calculate actual minutes}
                  Stop:=Copy(U,11,4);
                  InTime(Star,Sta);
                  InTime(Stop,Sto);
                  if (Sto=9999) or (Sta=9999) then
                     AstFlag:=true
                  else
                     begin
                        AMins:=AMins+Sto-Sta;
                        if Sto<Sta then AMins:=AMins+1440;
                        if Break='*' then AMins:=AMins-BreakMinutes;
                     end;
                  Star:=Copy(U,18,4); {now calculate scheduled minutes}
                  Stop:=Copy(U,22,4);
                  InTime(Star,Sta);
                  InTime(Stop,Sto);
                  if (Sto=9999) or (Sta=9999) then
                     AstFlag:=true
                  else
                     begin
                        SMins:=SMins+Sto-Sta;
                        if Sto<Sta then SMins:=SMins+1440;
                        if Break='*' then SMins:=SMins-BreakMinutes;
                     end;
               end;
         end;
      until Posit<=0;
end;

procedure TotalFifteenMinutes(ARow:integer;var AstFlag:boolean);
{fill Fmins array with daily scheduled minutes}
{fill Gmins array with daily real minutes}
{ARow is row of employee in SG1}
{AstFlag returns true if missing time}
var
   J,AMins,SMins:integer;
   S:string;
begin
   if ARow>-1 then
      begin
         AstFlag:=false;
         for J:=1 to 7 do
            begin
               FMins[J]:=0;
               GMins[J]:=0;
               S:=Form13.SG1.Cells[J+2,ARow];
               if S<>'' then
                  GetMins(S,AMins,SMins,AstFlag)
               else
                  begin
                     AMins:=0;
                     SMins:=0;
                  end;
               FMins[J]:=AMins;
               GMins[J]:=SMins;
            end;
      end;
end;

procedure FillHours;
{fill daily/weekly scheduled/actual hours for this employee}
var
  I,Hrs,Mins:integer;
  S,T:string;
begin
   with Form22 do
      begin
         Mins:=0;                               {Do scheduled hours daily/weekly}
         for I:=1 to 7 do Mins:=Mins+GMIns[I];
         Hrs:=Mins div 60;
         S:=IntToStr(Hrs);
         if Hrs<10 then S:=' '+S;
         Mins:=Mins mod 60;
         T:=IntToStr(Mins);
         if Mins<10 then T:='0'+T;
         TotSW.Caption:='Total scheduled hours for this week: '+S+':'+T;
         Mins:=GMins[CurCol];
         Hrs:=Mins div 60;
         S:=IntToStr(Hrs);
         if Hrs<10 then S:=' '+S;
         Mins:=Mins mod 60;
         T:=IntToStr(Mins);
         if Mins<10 then T:='0'+T;
         TotST.Caption:='Total scheduled hours for today: '+S+':'+T;
         Mins:=0;                               {Now do actual hours daily/weekly}
         for I:=1 to 7 do Mins:=Mins+FMIns[I];
         Hrs:=Mins div 60;
         S:=IntToStr(Hrs);
         if Hrs<10 then S:=' '+S;
         Mins:=Mins mod 60;
         T:=IntToStr(Mins);
         if Mins<10 then T:='0'+T;
         TotAW.Caption:='Total actual hours for this week: '+S+':'+T;
         Mins:=FMins[CurCol];
         Hrs:=Mins div 60;
         S:=IntToStr(Hrs);
         if Hrs<10 then S:=' '+S;
         Mins:=Mins mod 60;
         T:=IntToStr(Mins);
         if Mins<10 then T:='0'+T;
         TotAT.Caption:='Total actual hours for today: '+S+':'+T;
      end;
end;

procedure TForm22.FormActivate(Sender: TObject);
{set up entry form with time data and employee}
var
   I,J,K,CurLine,LCount,Strt,Stop,Tg,Mins,Hrs:integer;
   P,S,T,U,CurTipe,Test:string;
   Flag:boolean;
begin
   NamShf:=Form13.SG1.Cells[2,CurRow]; {get shift for this emp from SG1}
   ThisId:=StrToInt(Form13.SG1.Cells[0,CurRow]);  {get emp id from SG1}
   FillTbls;   {fill Tbls array with Time Line Entry Labels}
   LabelInit;  {initialize all time line labels}
   LCount:=0;  {keeps track of which label to use next}
   CurLine:=0;  {Current line on form being filled}
   CurTipe:=''; {Current 'type' being loaded into current line e.g. 'Rides'}
   Mood:=ModArray[CurCol]; {Set mode for form from column no. received from FunTime}
   ModeName.Caption:='Mode: '+IntToStr(Mood);
   DowName.Caption:=LongDayNames[DayOfWeek(NewDate+CurCol-1)];
   DowName.Left:=ModeName.Left+ModeName.Width+32;
   EmpName.Left:=DowName.Left+DowName.Width+32;
   S:=Form13.SG1.Cells[1,CurRow];
   I:=Pos(#13,S);
   if I>0 then
      T:=Copy(S,1,I-1)+' '+Copy(S,I+2,Length(S)-I)
    else T:='';
   S:=Form13.SG1.Cells[2,CurRow];
   if S='F' then EmpName.Font.Color:=FifteenColor
    else  if S='M' then EmpName.Font.Color:=MinorColor
     else EmpName.Font.Color:=HourlyColor;
   EmpName.Caption:=T;
   for I:=1 to 4 do if Tiparray[CurCol,I]<>'' then     {fill time line name labels first}
      begin                                             {four 'type' limit - 5 line is 'extra' line}
         S:=Tiparray[CurCol,I];
         case I of
          1:begin
              Name1.Color:=TLBackColor1;
              Name1.Caption:=S;
              Name1.Visible:=true;
            end;
          2:begin
              Name2.Color:=TLBackColor2;
              Name2.Caption:=S;
              Name2.Visible:=true;
            end;
          3:begin
              Name3.Color:=TLBackColor3;
              Name3.Caption:=S;
              Name3.Visible:=true;
            end;
          4:begin
              Name4.Color:=TLBackColor4;
              Name4.Caption:=S;
              Name4.Visible:=true;
            end;
           end;
      end;
   Name5.Color:=TLBackColor5;
   Name5.Caption:='Extra';
   Name5.Visible:=true;
   OffAll.Font.Name:=FontOff;
   with Form13.TimeGridP do
      for I:=0 to RowCount-1 do {fill time lines}
         begin
           try
             J:=StrToInt(Cells[8,I]);  {get mode from TimeGridP}
           except
             J:=-1;
           end;
           if J=Mood then
              begin
                 CurLine:=0;      {Current Line of Time Entry Form}
                 S:=Cells[10,I]; {S=Tipe}
                 T:=Cells[2,I];  {T=Time data}
                 U:=Cells[7,I];  {U=TName}
                 if S<>'' then
                    begin
                       if S=Name1.Caption then CurLine:=1
                       else if S=Name2.Caption then Curline:=2
                       else if S=Name3.Caption then Curline:=3
                       else if S=Name4.Caption then Curline:=4
                       else if S=Name5.Caption then Curline:=5;
                       LCnt[CurLine]:=LCnt[CurLine]+1;
                       if LCnt[CurLine]<11 then   {if there is still an available label for this timeline, continue}
                          begin
                             Mins:=StrToInt(Copy(T,6,2));  {calculate start of time entry}
                             Mins:=(Mins div 15)*TL15Min;
                             Hrs:=StrToInt(Copy(T,4,2));
                             Hrs:=(Hrs-9)*4*TL15Min;
                             Strt:=Hrs+Mins+TLLeft;
                             Mins:=StrToInt(Copy(T,10,2));   {calc width of time entry}
                             Mins:=(Mins div 15)*TL15Min;
                             Hrs:=StrToInt(Copy(T,8,2));
                             Hrs:=(Hrs-9)*4*TL15Min+TLLeft;
                             Stop:=Hrs+Mins-Strt-2;
                             LCount:=LCnt[CurLine];
                             Tbls[CurLine,LCount].Caption:=U;
                             Tbls[CurLine,LCount].Left:=Strt;
                             Tbls[CurLine,LCount].Width:=Stop;
                             if Stop<32 then
                                Tbls[CurLine,LCount].Font.Size:=6
                             else if Stop<64 then Tbls[CurLine,LCount].Font.Size:=8;
                             Tbls[CurLine,LCount].Visible:=true;
                             Tbls[CurLine,LCount].Tag:= I; {set time label tag to entry index in TimeGrid{}
                             Tbls[CurLine,LCount].Hint:=Tbls[CurLine,LCount].Caption;
                          end;
                    end;
              end;
         end;
   ExLabel.Caption:='Click here to add an extra shift';
   ExLabel.Visible:=true;
   Button1.Enabled:=true;
   OldData:=Form13.SG1.Cells[CurCol+2,CurRow];  {save original datastring for this emp/this day in case of cancel}
   if OldData<>'' then   {process employee time data for this emp/this day}
    begin
      if Copy(OldData,4,1)=OffMark then  {here to process Off All Day}
       begin
          OffAll.Font.Name:=FontOn;
          Button1.Enabled:=false;
       end
      else
       begin
         CountEnt(OldData,LCount);
         XCnt:=1;
         for Strt:=1 to LCount do
            begin
               P:=Copy(OldData,((Strt-1)*30)+5,2);   {P=Id in TimeGridP.Cells[0,x] for this entry}
               Tg:=0;
               with Form13.TimeGridP do for Stop:=0 to RowCount-1 do
                  if Cells[0,Stop]=P then Tg:=Stop;    {find this entry in TimeGridP and make Tg=expected Tag in Tbls array}
               if Tg<>0 then for I:=1 to 5 do for J:=1 to 10 do  {now find this label in Tbls array and highlight it}
                  if Tbls[I,J].Tag=Tg then  Tbls[I,J].Font.Name:=FontOn;
               if (P='99') and (XCnt<11)  then
                  begin
                     Tbls[5,XCnt].Font.Name:=FontOn;
                     T:=Copy(OldData,((Strt-1)*30)+1,30);
                     Mins:=StrToInt(Copy(T,9,2));  {calculate start of time entry}
                     Mins:=(Mins div 15)*TL15Min;
                     Hrs:=StrToInt(Copy(T,7,2));
                     Hrs:=(Hrs-9)*4*TL15Min;
                     J:=Hrs+Mins+TLLeft;
                     Mins:=StrToInt(Copy(T,13,2));   {calc width of time entry}
                     Mins:=(Mins div 15)*TL15Min;
                     Hrs:=StrToInt(Copy(T,11,2));
                     Hrs:=(Hrs-9)*4*TL15Min+TLLeft;
                     K:=Hrs+Mins-J-2;
                     Tbls[5,XCnt].Caption:='Extra'+IntToStr(XCnt);
                     Tbls[5,XCnt].Left:=J;
                     Tbls[5,XCnt].Width:=K;
                     if K<32 then
                        Tbls[5,XCnt].Font.Size:=6
                     else if K<64 then Tbls[5,XCnt].Font.Size:=8;
                     Tbls[5,XCnt].Visible:=true;
                     Tbls[5,XCnt].Tag:=99;
                     Tbls[5,XCnt].Hint:=Tbls[5,XCnt].Caption;
                     Tbls[5,XCnt].Visible:=true;
                     XCnt:=XCnt+1;
                  end;
            end;
         for I:=XCnt to 10 do Tbls[5,I].Tag:=-1;
       end;
    end;
   RadG1.ItemIndex:=0;
   TotalFifteenMinutes(CurRow,AstFlag);
   FillHours;
   TC1.Visible:=false;
end;

procedure ProcessClick(Sender:TLabel);
{process a clicked time entry to check if can be added to employee data}
{CurCol=column, CurRow=Row in Form13.SG1}
var
   I,J,K,L,TId,SId,Ents,OStar,OStop,NStop,Posit,EnterHere,SMins,AMins:integer;
   S,T,CellStr,TStar,TStop,DS,DT,Test:string;
   Flag,FiFlag,CFlag:boolean;
   Dayz,Minutes:integer;
   NDate:TDateTime;

begin
   with Sender as TLabel do
      begin
         CellStr:=Form13.SG1.Cells[CurCol+2,CurRow]; {CellStr=current time data string for this day/this emp}
         ThisId:=StrToInt(Form13.SG1.Cells[0,CurRow]); {ThisId is emp id for this emp}
         NamShf:=Form13.SG1.Cells[2,CurRow];           {NamShf is shift character for this day/this emp}
         DS:=Form13.TimeGridP.Cells[2,Tag];                   {DS = data string to add to SG1, EmpGrid}
         CountEnt(CellStr,Ents);
         if Tag=99 then
            begin
               TId:=99;
               ConvertTimeLine((Sender As TLabel).Left-TLLeft,Test); {Get HHMMk for start ofthis Tbl[I,J]}
            end
         else TId:=StrToInt(Form13.TimeGridP.Cells[0,Tag]);
         Flag:=false;
         FiFlag:=true;
         If Ents>0 then for J:=1 to Ents do    {check here to see if this time entry is already present in SG1[CurCol+2,CurRow]}
            begin
               I:=((J-1)*30)+5;
               S:=Copy(CellStr,I,2);
               if Test<>Copy(S,I+2,4) then TId:=98;
               SId:=StrToInt(S);
               if SId=TId then
                  begin
                     Flag:=true;
                  end;
            end;
         if (Flag=false) and (Ents>=MaxEntries) then       {if flag = false, a new entry is needed; is one available?}
            begin                                        {here if no}
               T:='Warning: too many entries for this employee for this day!';
               if MessageDlg(T,mtWarning,[mbOK],0)=mrOK then
                  begin

                  end;
            end
         else           {continue here if either new entry allowed or this is previous}
            begin
               Flag:=true;
               TStar:=Copy(DS,4,4);   {TStar=schedule start time for this time entry}
               TStop:=Copy(DS,8,4);    {Tstop=schedule stop time for this time entry}
               if NamShf='F' then      {do fourteen/fifteen checking here}
                  begin
                     InTime(TStar,I);        {No scheduling past 7:00 pm for 14/15}
                     InTime(TStop,J);
                     if (I>=SevenCode) or (J>SevenCode) then
                        begin
                           S:='This employee cannot be scheduled past 7:00 pm!'+Chr(10)+'Override?';
                           if MessageDlg(S,mtWarning,[mbYes,mbNo],0)=mrNo then FiFlag:=false;
                        end
                     else      {check 14/15 max minutes}
                        begin
                           NDate:=NewDate;
                           NDate:=IncDay(NDate,CurCol-1);
                           if (NDate<SchoolEnd) or (NDate>LaborDay) then
                              MaxFifteenMinutes:=60*MaxFifteenHoursSchool
                           else MaxFifteenMinutes:=60*MaxFifteenHoursSeason;
                           TotalFifteenMinutes(CurRow,AstFlag);
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
                           if FMins[CurCol]=0 then Inc(Dayz);
                           if Dayz>MaxFifteenDaysPerWeek then
                              begin
                                 S:='This employee may not be scheduled for more than '+IntToStr(MaxFifteenDaysPerWeek)+' days per week!'+Chr(10)+'Override?';
                                 if MessageDlg(S,mtWarning,[mbYes,mbNo],0)=mrNo then FiFlag:=false;
                              end
                           else  if (NStar<>9999) and (NStop<>9999) then
                              begin     {check for exceeding max hours/day}
                                 S:='xxx'+NewStr;
                                 GetMins(S,AMins,SMins,AstFlag);
                                 I:=GMins[CurCol]+SMins;
                                 if I>MaxFifteenHoursPerDay*60 then
                                    begin
                                       S:='Adding this time exceeds the maximum allowable hours per day for this employee.'+Chr(10)+'Override?';
                                       if MessageDlg(S,mtWarning,[mbYes,mbNo],0)=mrNo then FiFlag:=false;
                                    end
                                 else
                                    begin    {check for exceeding max hours per week}
                                       if Minutes+SMins>MaxFifteenMinutes then
                                          begin
                                             S:='Adding this time exceeds the maximum allowable hours per week for this employee.'+Chr(10)+'Override?';
                                             if MessageDlg(S,mtWarning,[mbYes,mbNo],0)=mrNo then FiFlag:=false;
                                          end;
                                    end;
                              end;
                        end;
                 end;
               CFlag:=true;
               if (FiFlag=true) and (Flag=true) then       {do time overlap checking here}
                  begin
                     for I:=1 to 5 do for J:=1 to 10 do
                        if Tbls[I,J].Font.Name=FontOn then
                         if Tbls[I,J].Name<>Name then
                           begin
                           S:=Tbls[I,J].Name;
                           T:=Name;
                              OStar:=Tbls[I,J].Left;
                              OStop:=Tbls[I,J].Width+OStar;
                              if (OStar>=Left+Width) or (OStop<=Left) then
                                 begin

                                 end
                              else CFlag:=false;  {if any overlaps found, set flag=false}
                           end;
                  end;
               if CFlag=false then
                  begin
                     T:='Warning: this time shift overlaps another shift!';
                     I:=MessageDlg(T,mtWarning,[mbCancel],0);
                     Flag:=false;
                  end;
               if (Flag=true) and (FiFlag=true) then Font.Name:=FontOn;
            end;
      end;
end;

procedure UpdateToday;
{total up projected scheduled hours for this day}
var
   I,J,Strt,Stop,TMins:integer;
   S,T:string;
begin
    TMins:=0;
    with Form22 do
       begin
          for I:=1 to 4 do for J:=1 to 10 do
            with Tbls[I,J] do if (Tag>-1) and (Tag<>99) then if Font.Name=FontOn then
             begin
                S:=Form13.TimeGridP.Cells[2,Tag];
                T:=Copy(S,4,4);
                InTime(T,Strt);
                T:=Copy(S,8,4);
                InTime(T,Stop);
                TMins:=TMins+Stop-Strt;
             end;
          for J:=1 to 10 do if Tbls[5,J].Tag=99 then  {if there is an extra shift}
             begin
                I:=(Tbls[5,J].Width div TL15Min)*15;
                TMins:=TMins+I;
             end;
          GMins[CurCol]:=TMins;
          FillHours;
       end;
end;

procedure ConvertTime(Inst:string;Flag:boolean;var Oust:string);
{convert Inst=HHMM to Oust=HH:MM; if flag is true add am or pm to string}
var
   H,M:string;
   I,J:integer;
begin
   H:=Copy(Inst,1,2);
   M:=Copy(Inst,3,2);
   Oust:='';
   I:=StrToInt(H);
   if I>11 then
    if Flag=true then Oust:=' pm'
      else if Flag=true then Oust:=' am';
   if I>12 then I:=I-12;
   H:=IntToStr(I);
   Oust:=H+':'+M+Oust;
end;

procedure TForm22.RadG1Click(Sender: TObject);
{change captions on time labels with radio group}
var
   I,J,Ind:integer;
   S,T,U,TId,Strt:string;

begin
   for I:=1 to 5 do for J:=1 to 10 do
      if Tbls[I,J].Tag>-1 then
         begin
            if RadG1.ItemIndex=0 then
               begin
                  if Tbls[I,J].Tag=99 then S:='Extra'+IntToStr(J)
                     else S:=Form13.TimeGridP.Cells[7,Tbls[I,J].Tag];
               end
            else if RadG1.ItemIndex=1 then
               begin
                  if Tbls[I,J].Tag=99 then
                     begin
                        TId:='99';
                        ConvertTimeLine(Tbls[I,J].Left-TLLeft,Strt);
                        GetTimeString(TId,Strt,S,Ind);
                        if S<>'' then
                           begin
                              T:=Copy(S,18,4);
                              ConvertTime(T,false,T);
                              U:=Copy(S,22,4);
                              ConvertTime(U,false,U);
                              S:=T+'-'+U;
                           end
                     end
                  else S:=Form13.TimeGridP.Cells[1,Tbls[I,J].Tag];
               end
            else if RadG1.ItemIndex=2 then
               begin
                  if Tbls[I,J].Tag=99 then TId:='99'
                  else TId:=Form13.TimeGridP.Cells[0,Tbls[I,J].Tag];
                  ConvertTimeLine(Tbls[I,J].Left-TLLeft,Strt);
                  GetTimeString(TId,Strt,S,Ind);
                  if S<>'' then
                     begin
                        T:=Copy(S,7,4);
                        ConvertTime(T,false,T);
                        U:=Copy(S,11,4);
                        ConvertTime(U,false,U);
                        S:=T+'-'+U;
                     end;
               end;
            Tbls[I,J].Caption:=S;
            Tbls[I,J].Hint:=S;
         end;
end;

procedure TForm22.A1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
{process time entry label clicks}
var
   I,J,Ents,RecNo,XCol,XRow:integer;
   S,T,U,V,W,Inst,Oust,TId:string;
   Flag:boolean;
begin
   with Sender as TLabel do if OffAll.Font.Name=FontOff then
   begin
    if Button=mbLeft then             {toggle time entry label if appropriate}
      begin
         TC1.Visible:=false;
         if Font.Name=FontOff then
            begin
                ProcessClick(Sender As TLabel);
               if Font.Name=FontOn then UpdateToday;
            end
         else
            begin
               Flag:=false;
               if (Sender AS TLabel).Tag=99 then
                  begin
                     T:='Delete this extra shift?!';
                     if MessageDlg(T,mtConfirmation,[mbYes,mbNo],0)=mrYes then
                        begin
                           (Sender AS TLabel).Font.Name:=FontOff;  {????}
                           {(Sender As TLabel).Width:=0;}
                           (Sender AS TLabel).Tag:=0;
                           UpdateToday;
                        end;
                     Flag:=true;
                  end;
               if Flag=false then
                  begin
                     Font.Name:=FontOff;
                     UpdateToday;
                  end;
            end;
      end
   else if (Button=mbRight) and (Font.Name=FontOn) then    {change actual times}
       begin
         Button1.Enabled:=false;
         Label10.Caption:=Form13.TimeGridP.Cells[7,Tag];
         Flag:=false;
         if (Sender As TLabel).Tag=99 then
            TId:='99'
         else
            TId:=Form13.TimeGridP.Cells[0,Tag];
         GetTimeString(TId,'',S,Indx);   {Indx will be used if ok button pressed}
         T:='Clocked In';
         U:='Not Clocked In!';
         V:='Clocked Out';
         W:='Not Clocked Out!';
         if S<>'' then
            begin
               Inst:=Copy(S,4,1);
               if Inst=SANI then
                  begin
                     X1.Caption:=U;
                     X1.Font.Color:=clRed;
                     X1.Visible:=true;
                     X2.Caption:=W;
                     X2.Font.Color:=clRed;
                  end
               else if Inst=SANO then
                  begin
                     X1.Caption:=T;
                     X1.Font.Color:=clLime;
                     X1.Visible:=true;
                     X2.Caption:=W;
                     X2.Font.Color:=clRed;
                  end
               else if Inst=SAD then
                  begin
                     X1.Caption:=T;
                     X1.Font.Color:=clLime;
                     X1.Visible:=true;
                     X2.Caption:=V;
                     X2.Font.Color:=clLime;
                  end;
               Inst:=Copy(S,7,4);
               InTime(Inst,StartTime);
               ConvertTime(Inst,true,Oust);
               Edit1.Text:=Oust;
               Inst:=Copy(S,11,4);
               InTime(Inst,StopTime);
               ConvertTime(Inst,true,Oust);
               Edit2.Text:=Oust;
               TC1.Visible:=true;
            end;
      end;
    end
    else
       begin
          S:='Remove "Off All Day" before making time entries!';
          I:=MessageDlg(S,mtWarning,[mbOk],0);
       end;

end;

procedure TForm22.Button4Click(Sender: TObject);
{cancel time changes made in TC1 panel}
begin
   TC1.Visible:=false;
   Button1.Enabled:=true;
end;

procedure TForm22.Button2Click(Sender: TObject);
{save time changes made on TC1 panel - but only temporarily until 'save'button is clicked}
{Indx is set by GetTimeString to start of this string in the SG1 string for this emp/this day}
var
   S,T,U,V,TId:string;
   I,J:integer;
begin
   S:=Form13.SG1.Cells[CurCol+2,CurRow];
   Delete(S,Indx+6,8);
   OutTime(StartTime,T);
   Outtime(StopTime,U);         {insert changed time into this entry in SG1}
   T:=T+U;
   Insert(T,S,Indx+6);
   Delete(S,Indx+14,1);         {mark this entry as changed}
   Insert('*',S,Indx+14);
   Form13.SG1.Cells[CurCol+2,CurRow]:=S;
   TC1.Visible:=false;
   if RadG1.ItemIndex=2 then     {force display updated time(s)}
      begin
         RadG1.ItemIndex:=-1;
         RadG1.ItemIndex:=2;
      end;
   TotalFifteenMinutes(CurRow,AstFlag); {update hour display labels}
   FillHours;
   Button1.Enabled:=true;
end;

procedure TForm22.UD1Click(Sender: TObject; Button: TUDBtnType);
{change text}
var
   S,T:string;
   H,M:integer;
begin
   with Sender as TUpDown do
     if Button=btNext then
        begin
           if StartTime<StopTime then Inc(StartTime);
        end
     else if Button=btPrev then
        begin
           if StartTime>2 then Dec(StartTime); {no starting earlier than midnight }
        end;
   H:=StartTime div 60;
   M:=StartTime mod 60;
   if H<12 then S:=' am'
     else S:=' pm';
   if H>12 then H:=H-12;
   T:=IntToStr(M);
   if M<10 then T:='0'+T;
   Edit1.Text:=IntToStr(H)+':'+T+S;
end;

procedure TForm22.UD2Click(Sender: TObject; Button: TUDBtnType);
{change  stop time}
var
   S,T:string;
   H,M:integer;
begin
   with Sender as TUpDown do
     if Button=btNext then
        begin
           if StopTime<1438 then Inc(StopTime); {no going past midnight}
        end
     else if Button=btPrev then if StopTime>StartTime then Dec(StopTime);
   H:=StopTime div 60;
   M:=StopTime mod 60;
   if H<12 then S:=' am'
     else S:=' pm';
   if H>12 then H:=H-12;
   T:=IntToStr(M);
   if M<10 then T:='0'+T;
   Edit2.Text:=IntToStr(H)+':'+T+S;
end;

procedure ChangeOffDayStatus(Flag:boolean);
{change SG1 and files to reflect Off All Day status}
{Flag=true is Off All Day true; false is Off All Day false}
{enter knowing there are no other time entries for this day}
var
   I,TId,RecN,NStar:integer;
   S:string;
begin
   with Form13 do
      begin
         if Flag=true then {add to SG1 and files}
            begin
               TId:=-2;   {time id for off all day in funtimes.db}
               for I:=0 to Form13.TimeGridP.RowCount-1 do
                  if StrToInt(TimeGridP.Cells[0,I])=TId then
                     begin
                        MakeNewStr(I);
                        S:=Copy(NewStr,4,4);
                        InTime(S,NStar);
                        DoCount(RecN,S);
                        Add_Drop_To_File(NewStr,NamShf,NStar,ThisId,CurCol,RecN);
                        SG1.Cells[CurCol+2,CurRow]:=S+NewStr;
                     end;
            end
         else    {subtract from SG1 and files}
            begin
               S:=Copy(SG1.Cells[CurCol+2,CurRow],1,3);
               UnAdjCount(S,Recn);
               SG1.Cells[CurCol+2,CurRow]:='';
               DoDeleteRec(RecN);
            end;
         OldData:=SG1.Cells[CurCol+2,CurRow];
      end;
end;

procedure TForm22.OffAllClick(Sender: TObject);
{process off all day label}
var
   I,J:integer;
   S:string;
   Flag:boolean;
begin
   if OffAll.Font.Name=FontOff then
      begin
         Flag:=true;
         for I:=1 to 5 do for J:=1 to 10 do if Tbls[I,J].Font.Name=FontOn then
            Flag:=false;
         if Flag=true then
            begin
               OffAll.Font.Name:=FontOn;
               ChangeOffDayStatus(true);
               Button1.Enabled:=false;
            end
         else
            begin
               S:='Remove all scheduled times first!';
               I:=MessageDlg(S,mtWarning,[mbOk],0);
            end;
      end
   else
      begin
         OffAll.Font.Name:=FontOff;
         ChangeOffDayStatus(false);
         Button1.Enabled:=true;
      end;
end;

procedure TForm22.Name5Click(Sender: TObject);
{enable TL5 to add 'extra' shifts}
var
   S,T,Inst,Oust,TCS:string;
   I,Strt,Stop,NStar,NId,TCount:integer;
begin
   with TL5 do
      begin
         if Name5.Color=ExOff then
            begin
               XCnt:=0;
               I:=1;
               repeat
                  if Tbls[5,I].Tag=-1 then XCnt:=I;
                  I:=I+1;
               until (I=11) or (XCnt<>0);
               if XCnt<>0 then
                  begin
                     Name5.Color:=ExOn;
                     Panel1.Color:=Pan1On;
                     Tbls[5,XCnt].Font.Name:=FontOn;
                     XSt:=0;
                     Button1.Enabled:=false;
                     ExLabel.Caption:='Click timeline above to set start time';
                  end;
            end
         else if Name5.Color=ExOn  then
            begin
               Name5.Color:=ExOff;
               Panel1.Color:=Pan1Off;
               Button1.Enabled:=true;
               ExLabel.Caption:='Click here for extra shift';
               if XSt=2 then
                  begin
                     Tbls[5,XCnt].Caption:='Extra'+IntToStr(XCnt);
                     Tbls[5,XCnt].Font.Size:=8;
                     Tbls[5,XCnt].Tag:= 99; {no time label in TimeGridP}
                     Tbls[5,XCnt].Visible:=true;
                     UpDateToday;
                  end
               else
                  begin
                     Tbls[5,XCnt].Tag:=-1;
                     Tbls[5,XCnt].Visible:=false;
                     ExLabel.Caption:='Click timeline above to set start time';
                  end;
            end;
      end;
end;

procedure TimeCheck(var X:integer);
{check all active extra shifts to see if X is within Left, Left+Width}
var
   I,J,K:integer;
   Flag:boolean;
begin
   K:=X+Form22.Panel1.Left;   {add offset from left edge}
   for I:=1 to 4 do for J:=1 to 10 do
      if (Tbls[I,J].Font.Name=FontOn) and (K>Tbls[I,J].Left) and (K<Tbls[I,J].Left+Tbls[I,J].Width) then X:=-1;
   if X<>-1 then for J:=1 to 10 do
      if (Tbls[5,J].Tag=99) and (K>Tbls[5,J].Left) and (K<Tbls[5,J].Left+Tbls[5,J].Width) then X:=-1;
end;

procedure TForm22.Panel1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
{use timeline to set start/stop of Extra shift}
var
   Inst,Oust,Ist,Ost:string;
begin
   if Name5.Color=ExOn then with Tbls[5,XCnt] do
      begin
         if Button=mbLeft then
            begin
               if XSt=0 then
                  begin
                     TimeCheck(X); {check for overlaps}
                     if X<>-1 then
                        begin
                           XSt:=1;
                           X:=X-24;  {X=relative distance in pixels from 9 sm}
                           if X<0 then X:=0;
                           X:=(X div 16)*16; {round off X to nearest lower 15 minute mark}
                           XStart:=X;
                           Left:=TL5.Left+X;
                           Width:=2;
                           Visible:=true;
                           ExLabel.Caption:='Click timeline above to set stop time';
                        end
                     else  ShowMessage('Overlap found!');
                  end
               else if XSt=1 then
                  begin
                     if X>XStart then
                        begin
                           TimeCheck(X);
                           if X<>-1 then
                              begin
                                 X:=X-24;  {X=relative distance in pixels from 9 sm}
                                 X:=(X div 16)*16;  {round off X to nearest lower 15 minute mark}
                                 if X=XStart then {minimum of 15 minute shift}
                                    X:=X+16;
                                 Width:=X-XStart;
                                 XSt:=2;
                                 ConvertTimeLine(XStart,Inst);
                                 ConvertTime(Inst,false,Ist);
                                 ConvertTimeLine(X,Oust);
                                 ConvertTime(Oust,false,Ost);
                                 Width:=Width-2;
                                 if Width<=4*TL15Min then Font.Size:=6;
                                 Caption:=Ist+'-'+Ost;
                                 ExLabel.Caption:='Click above to set shift';
                              end
                           else ShowMessage('Overlap found!');
                        end;
                  end
            end
         else if Button=mbRight then
            begin
               if XSt=2 then
                  begin
                     XSt:=1;
                     Width:=2;
                     ExLabel.Caption:='Click timeline above to set stop time';
                  end
               else if XSt=1 then
                  begin
                     XSt:=0;
                     Width:=0;
                     Visible:=false;
                     ExLabel.Caption:='Click timeline above to set start time';
                  end;
            end;
      end;
end;

end.
