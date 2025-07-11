unit Funsched;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, Grids , DB, DBGrids, Printers, Funsort,
  FunPrint , Mask, DBCtrls, FunGrid, FunPrintDef, Funlock, Funfill, ExtCtrls, System.UITypes,
  XPStyleActnCtrls, ActnList, ActnMan, FMTBcd , Gauges, Spin, Math, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error,
FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Comp.Client, FireDAC.Stan.Param,
FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.Comp.DataSet, FireDAC.Phys,
  FireDAC.VCLUI.Wait, FireDAC.DApt;


type
  TForm8 = class(TForm)
    SchG1: TStringGrid;
    Button1: TButton;
    JobG1: TStringGrid;
    RevG1: TStringGrid;
    Panel2: TPanel;
    Button10: TButton;
    Panel3: TPanel;
    Button4: TButton;
    Button3: TButton;
    Label1: TLabel;
    RevLabel: TLabel;
    Panel4: TPanel;
    Button2: TButton;
    Button6: TButton;
    Label2: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    SE1: TSpinEdit;
    Label8: TLabel;
    Button14: TButton;
    Button11: TButton;
    Panel1: TPanel;
    AvaBox: TListBox;
    EmpBox: TListBox;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Button5: TButton;
    BreakBox: TListBox;
    Label9: TLabel;
    Query1: TFDQuery;
    procedure BreakBoxDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure SchG1DragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure AvaBoxMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure SchG1DragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure EmpBoxMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure SchG1DblClick(Sender: TObject);
    procedure EmpBoxDrawItem(Control: TWinControl; Index: Integer; Rect: TRect;
      State: TOwnerDrawState);
    procedure SchG1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Button5Click(Sender: TObject);
    procedure Button14Click(Sender: TObject);
    procedure Button11Click(Sender: TObject);
    procedure SchG1SelectCell(Sender: TObject; ACol, ARow: Integer;
      var CanSelect: Boolean);
    procedure SE1Change(Sender: TObject);
    procedure Button10Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure JobG1DrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect;
      State: TGridDrawState);
    procedure Button4Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure AvaBoxDrawItem(Control: TWinControl; Index: Integer; Rect: TRect;
      State: TOwnerDrawState);
    procedure SchG1DrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect;
      State: TGridDrawState);
    procedure FormActivate(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure JobG1TopLeftChanged(Sender: TObject);
    procedure SchG1TopLeftChanged(Sender: TObject);

  private
    { Private declarations }
  public

    { Public declarations }
  end;

var
  Form8: TForm8;
  Formset: TFormatSettings;

implementation


{$R *.DFM}

const  {schedule printout defaults}
   Down = 60;  {number of rows per printed page}
   Across = 7; {number of columns per printed page}

var
   Namestr:string;
   SGCol:integer;
   DisplayCols:integer;
   SelectCol,SelectRow:integer;
   OldSelect:string;
   AvaFlag:boolean;
   PagesA,PagesD:integer;
   PW,PL:integer;
   Wid,Clr,Fit:boolean;
   RSp,CSp,CFt,TM,BM,LM,Cols1,Cols2,Roes1,Roes2,Fon1,Fon2,Fon3,Wd,Wg,DaysAgo:integer;
   Currec:integer;  {Currec = record no. for position changes}
   TogFlag:boolean;  {shows current state of time labels: true for tnames false for times}
   ACol,ARow,CurCol,NIndx,NRStrt,NREnd:integer;  {variables used with panel1 for name entries}
   DS:string; {name string being dragged}
   PRect,FRect:TRect;  {used for color printing cell backgrounds}

procedure ModifySG(Nmbr,SId:integer;Dest:string);
   {modify existing SG1 entry for employee Nmbr,Offset}
   {SId=time Id string; Dest is new position}
var
   I,J,K,TId,Ents:integer;
   S,W:string;
   Flag:boolean;
begin
   with Form8 do with Form13.SG1 do
      begin
         Flag:=false;
         I:=-1;
         repeat     {search each SG1 entry to find correct employee/timeid}
            Inc(I);
            if Nmbr=StrToInt(Cells[0,I]) then   {if this is correct emp continue}
                begin
                   S:=Cells[Offset+2,I];  {get entries for this emp/this DOW}
                   CountEnt(S,Ents);
                   if Ents>0 then
                      begin
                         J:=1;
                         repeat               {search each entry for Time id match}
                             K:=((J-1)*30)+1;
                             TId:=StrToInt(Copy(S,K+4,2));  {TId=time id for this entry}
                             if CurMode=0 then TId:=TId mod 10;
                             if TId=SId then
                                begin
                                   Flag:=true;
                                   W:=Copy(S,K,3);
                                   UnAdjCount(W,Currec);
                                   Delete(S,K+25,3);
                                   Insert(Dest,S,K+25);
                                   Cells[Offset+2,I]:=S;
                                end;
                             J:=J+1;
                         until (J>Ents) or (Flag=true);
                      end;
                end;
         until (I>=RowCount-1) or (Flag=true);
      end;
end;


procedure GetEmpTotals;
{get total available employees for each time label and display them}
var
   I,J,K,L,M,Ents,Count,TId,SId,Jb:integer;
   S,T:string;
begin
   with Form8 do
      begin
         for I:=1 to 5 do for J:=1 to 10 do
            begin
               CountArray[I,J]:=0;
               if LabArray[I,J]<>'' then
                  begin
                     Count:=0;
                     TId:=StrToInt(Copy(LabArray[I,J],1,2));
                     for K:=0 to Form13.SG1.RowCount-1 do
                         begin
                            S:=Form13.SG1.Cells[Offset+2,K];
                            CountEnt(S,Ents);
                            if Ents>0 then for L:=1 to Ents do
                               begin
                                  M:=((L-1)*30)+1;
                                  T:=Copy(S,M,30);
                                  SId:=StrToInt(Copy(T,5,2));
                                  Jb:=StrToInt(Copy(T,26,3));
                                  if (Jb=999) and (TId<>99) and (Copy(T,4,1)<>OffMark) then  {if assigned job is empty and there is a valid id #}
                                     if SId=Tid then             {if time id's match}
                                        Count:=Count+1;
                               end;
                         end;
                      Countarray[I,J]:=Count;
                   end;
            end;
      end;
end;

procedure ClearRevGrid(Flag:boolean);
{clear review grid}
{if Flag=true then clear entries from SchG1 grid as well}
var
   I,J:integer;
   S:string;
begin
   with Form8.RevG1 do
      begin
         for I:=0 to ColCount-1 do for J:=1 to RowCount do
            if Cells[I,J]<>'' then
               begin
                  Cells[I,J]:='';
                  if Flag=true then
                     begin
                        S:=Form8.SchG1.Cells[I,J];
                        Form8.SchG1.Cells[I,J]:='';
                        Form8.SchG1.Cells[I,J]:=S;
                     end;
               end;
      end;
end;


procedure GetJob(var Row,Jb:integer; var Status, Jsb:string);
{get job info from JobG1}
{Jsb is 3 digit job string, Jb is job as integer, Status is > ,trained, or <, untrained}
var
   S:string;
begin
   with Form8 do
     begin
        S:=JobG1.Cells[0,Row];
        Status:=S[Length(S)-3];
        Jsb:=Copy(S,Length(S)-2,3);
        Jb:=StrToInt(Jsb);
     end;
end;

procedure PracHis(F,L:string;Offs:integer);
   {process "Last" string from yyyymmdd.db as history}
   {Offs is days ago}
var
   J,Dest,X:integer;
   T:string;
begin
   with Form8 do
      begin
         T:=Copy(F,1,3);
         if T[1]='*' then T[1]:='+';
         Dest:=StrToInt(Copy(L,12,3));
         if Dest<>999 then for J:=0 to JobG1.RowCount-2 do
           if (Copy(JobG1.Cells[0,J],1,1)<>'#') and (JobG1.Cells[0,J]<>'') then
            begin
               X:=StrToInt(Copy(JobG1.Cells[0,J],Length(JobG1.Cells[0,J])-2,3));
               if X=Dest then with SchG1 do
                  begin
                     Dest:=999;
                     if Pos('.',SchG1.Cells[0,J])=0 then
                        SchG1.Cells[0,J]:=IntToStr(Offs)+','+SchG1.Cells[0,J]
                     else
                        begin
                           if Offs=0 then SchG1.Cells[0,J]:='Today'
                           else if Offs=1 then SchG1.Cells[0,J]:='1 Day Ago'
                           else SchG1.Cells[0,J]:=IntToStr(Offs)+' Days Ago';
                        end;
                  end;
            end;
      end;
end;


procedure GetAmpHis(Nmbr:integer);
   {get employee history from schedfile and oldfile; Nmbr is employee id number}
var
   S,F,L:string;
   I,Offs:integer;
begin
   with Form8 do
      begin
         {S:=AvaBox.Items[AvaBox.ItemIndex];
         S:=Copy(S,Length(S)-2,3);
         Nmbr:=StrToInt(S);}
         with Query1 do if (Olderfile<>'') and (OlderOffset>=1) and (OlderOffset<=HistDays) then
            begin        {Get OlderFile info first}
               Close;
               Sql.clear;
               Sql.Add('Select *');
               S:='from "'+OlderFile+'"';
               I:=OlderOffset+Offset-HistDays;
               if I<1 then I:=0;
               Sql.Add(S);
               S:='where Typ="T" and Id='+IntToStr(Nmbr)+' and Dat>'+IntToStr(I);
               Sql.Add(S);
               S:='order by Dat';
               Sql.Add(S);
               Open;
               First;
               for I:=1 to RecordCount do
                  begin
                     F:=FieldByName('First').AsString;
                     L:=FieldByName('Last').AsString;
                     Offs:=FieldByName('Dat').AsInteger;
                     {???}
                     Offs:=Offset+14-Offs;
                     PracHis(F,L,Offs);
                     Next;
                  end;
            end;
         with Query1 do if (Oldfile<>'') and (OldOffset>=1) and (OldOffset<=HistDays) then
            begin        {Get OldFile info second}
               Close;
               Sql.clear;
               Sql.Add('Select *');
               S:='from "'+OldFile+'"';
               I:=OldOffset+Offset-HistDays;
               if I<1 then I:=0;
               Sql.Add(S);
               S:='where Typ="T" and Id='+IntToStr(Nmbr)+' and Dat>'+IntToStr(I);
               Sql.Add(S);
               S:='order by Dat';
               Sql.Add(S);
               Open;
               First;
               for I:=1 to RecordCount do
                  begin
                     F:=FieldByName('First').AsString;
                     L:=FieldByName('Last').AsString;
                     Offs:=FieldByName('Dat').AsInteger;
                     {???}
                     Offs:=Offset+7-Offs;
                     PracHis(F,L,Offs);
                     Next;
                  end;
            end;
         with Query1 do    {get history data from Schedfile}
            begin
               Close;
               Sql.clear;
               Sql.Add('Select *');
               S:='from "'+Schedfile+'"';
               Sql.Add(S);
               S:='where Typ="T" and Id='+IntToStr(Nmbr)+' and Dat<='+IntToStr(Offset);
               Sql.Add(S);
               S:='order by Dat';
               Sql.Add(S);
               Open;
               First;
               for I:=1 to RecordCount do
                  begin
                     F:=FieldByName('First').AsString;
                     L:=FieldByName('Last').AsString;
                     Offs:=FieldByName('Dat').AsInteger;
                     Offs:=Offset-Offs;
                     PracHis(F,L,Offs);
                     Next;
                  end;
               Close;
            end;
      end;
end;


procedure PracJobHis(SName,S:string;Nmbr,Offs:integer);
   {process "Last" string from yyyymmdd.db as job history}
   {Offs is days ago; SName is schedule name for this entry}
   {Nmbr is position Id}
var
   I,J,K,Count,N,IDS:integer;
   TId,Dest:integer;
   T,U:string;
   IFlag:boolean;
begin
   with Form8 do
      begin
         Count:=Length(S) div 14;
         for I:=1 to Count do
            begin
               T:=Copy(S,1,3);
               if T[1]='*' then T[1]:='+';
               TId:=StrToInt(T);
               Dest:=StrToInt(Copy(S,12,3));
               Delete(S,1,14);
               if Dest=Nmbr then with SchG1 do
                  begin
                     for K:=0 to ColCount-1 do
                         begin
                            T:=Cells[K,RowCount+1];
                            IDS:=Length(T) div 3;
                            IFlag:=false;
                            N:=0;
                            repeat
                               Inc(N);
                               U:=Copy(T,(N-1)*3+1,3);
                               if StrToInt(U)=TId then
                                  IFlag:=true;
                            until (IFlag=true) or (N>=IDS);
                            if IFlag=true then
                               begin
                                  U:=IntToStr(Offs)+': '+SName;
                                  J:=Offs+2;
                                  Cells[K,J]:=U;
                               end;
                         end;
                   end;
            end;
      end;
end;

procedure GetJabHis(Nmbr:integer);
   {get job history from schedfile and oldfile}
   {PId=position Id number}
var
   S,SName:string;
   I,J,Offs:integer;
begin
   with Form8 do
      begin
         with SchG1 do for J:=0 to ColCount-1 do Cells[J,1]:=IntToStr(Toprow);
         with Query1 do    {get history data from Schedfile first}
            begin
               Close;
               Sql.clear;
               Sql.Add('Select *');
               S:='from "'+Schedfile+'"';
               Sql.Add(S);
               S:='where Typ="T" and Dat<='+IntToStr(Offset);
               Sql.Add(S);
               S:='order by Dat';
               Sql.Add(S);
               Open;
               Last;
               for I:=1 to RecordCount do
                  begin
                     S:=FieldByName('Last').AsString;
                     SName:=FieldByName('Id').AsString;
                     GetName(SName);
                     Offs:=FieldByName('Dat').AsInteger;
                     Offs:=Offset-Offs;
                     PracJobHis(SName,S,Nmbr,Offs);
                     Prior;
                  end;
            end;
         with Query1 do if (Oldfile<>'') and (OldOffset>=1) and (OldOffset<=HistDays) then
            begin        {Get OldFile info second}
               Close;
               Sql.clear;
               Sql.Add('Select *');
               S:='from "'+OldFile+'"';
               I:=OldOffset+Offset-HistDays;
               if I<0 then I:=0;
               Sql.Add(S);
               S:='where Typ="T" and Dat>'+IntToStr(I);
               Sql.Add(S);
               S:='order by Dat';
               Sql.Add(S);
               Open;
               Last;
               for I:=1 to RecordCount do
                  begin
                     S:=FieldByName('Last').AsString;
                     Offs:=FieldByName('Dat').AsInteger;
                     SName:=FieldByName('Id').AsString;
                     GetName(SName);
                     {???}
                     Offs:=Offset+7-Offs;
                     PracJobHis(SName,S,Nmbr,Offs);
                     Prior;
                  end;
            end;
         with Query1 do if (Olderfile<>'') and (OlderOffset>=1) and (OlderOffset<=HistDays) then
            begin        {Get OlderFile info last}
               Close;
               Sql.clear;
               Sql.Add('Select *');
               S:='from "'+OlderFile+'"';
               I:=OlderOffset+Offset-HistDays;
               if I<1 then I:=1;
               Sql.Add(S);
               S:='where Typ="T" and Dat>'+IntToStr(I);
               Sql.Add(S);
               S:='order by Dat';
               Sql.Add(S);
               Open;
               Last;
               for I:=1 to RecordCount do
                  begin
                     S:=FieldByName('Last').AsString;
                     Offs:=FieldByName('Dat').AsInteger;
                     SName:=FieldByName('Id').AsString;
                     GetName(SName);
                     {???}
                     Offs:=Offset+14-Offs;
                     PracJobHis(SName,S,Nmbr,Offs);
                     Prior;
                  end;
            end;
         Query1.Close;
         with SchG1 do for J:=0 to ColCount-1 do Cells[J,1]:='';
      end;
end;

procedure GetNum(var S:string);
   {S=Employee name; return w/S=Employee number as string from ColorGrid}
var
   K:integer;
   Flag:boolean;
begin
    with Form13.ColorGrid do
          begin
             Flag:=false;
             K:=1;
             repeat
                if S=Cells[1,K] then
                   begin
                      Flag:=true;
                      S:=Cells[0,K];
                   end;
                Inc(K);
             until (Flag=true) or (K>=RowCount+1);
          end;
   if Flag=false then S:='';
end;

procedure HeightAdjust;
{adjust height of SchG1 and JobG1 }
begin
   with Form8 do with SchG1 do
      begin
         RowCount:=JobG1.RowCount;
         Height:=RowCount*(DefaultRowHeight+1)+5;
         if Height+Top>Form8.Height then
            Height:=Form8.Height-35-Top;
         JobG1.Height:=Height;
      end;
end;

procedure GetParams (ARow:integer);
{set RowTimes array with time entry row no.s and set NRStrt and NREnd for ARow}
var
   I:integer;
   Flag:boolean;
begin
   with Form8 do
      begin
         if Copy(JobG1.Cells[0,ARow],1,1)<>'#' then  {if this row is not a time label row}
            begin
               I:=ARow;
               Flag:=false;
               repeat
                  if Copy(JobG1.Cells[0,I],1,1)='#' then
                     begin
                        ARow:=I;
                        Flag:=true;
                     end;
                  I:=I-1;
               until (Flag=true) or (I<0);
            end;
         NREnd:=ARow+1;
         NRStrt:=ARow+1;
         NIndx:=1;
         for I:=1 to 5 do if RowTimes[I,1]=ARow then
            begin
               NIndx:=I;
               NREnd:=RowTimes[I+1,1];
            end;
          if NREnd=-1 then NRend:=SchG1.RowCount-1;
      end;
end;

procedure RefillRowTimes;
{refill time label rows}
var
   I,Cnt:integer;
begin
   Cnt:=1;
   with Form8.JobG1 do for I:=0 to RowCount-1 do
      begin
         if Pos('#',Cells[0,I])=1 then   {this is a time label row}
            begin
               RowTimes[Cnt,1]:=I;
               Cnt:=Cnt+1;
            end;
      end;
end;

procedure CheckAdd(JobName:string;Cl:integer;var Rw:integer);
   {check to add row to schg1 & jobg1}
   {Rw = row which new row will be added if needed}
   {Cl = Column in which this emp is to be placed}
   {if ok then add row}
var
   I,J,K,L,Jsb,Jb:integer;
   Flag:boolean;
begin
   with Form8 do
      begin
         Jb:=StrToInt(JobName);
         J:=0;   {J=1st empty row in this Cl with this JobName}
         K:=0;   {K=last full row in this Cl with this JobName}
         with SchG1 do
            begin
               I:=0;
               Flag:=false;
               repeat
                  Inc(I);     {check to find if any rows with this Jobname have a blank entry in this col}
                  L:=Pos('<',JobG1.Cells[0,I]);
                  if L>0 then Jsb:=StrToInt(Copy(JobG1.Cells[0,I],L+1,3))
                  else Jsb:=0;
                  if (Jsb=Jb) then
                     begin
                        K:=I;
                        if Cells[Cl,I]='' then
                           begin
                              J:=I;
                              Flag:=true;
                           end;
                     end;
               until (Flag=true) or (I>=Rowcount-1);
            end;
         if Flag=false then   {if new row needed continue here}
            begin
               with SchG1 do
                  begin
                     Rw:=K+1;
                     RowCount:=RowCount+1;
                     JobG1.RowCount:=RowCount;
                     RevG1.RowCount:=RowCount;
                     for I:=RowCount-1 downto Rw+1 do  {move all data 'down' one row}
                        begin
                           Rows[I]:=Rows[I-1];
                           JobG1.Rows[I]:=JobG1.Rows[I-1];
                           RevG1.Rows[I]:=RevG1.Rows[I-1];
                        end;
                     JobG1.Cells[0,Rw]:=JobG1.Cells[0,Rw-1];   {add jobname to new row}
                     for I:=0 to ColCount-1 do  {initial cells for new row}
                        if Cells[I,Rw-1]='#0' then Cells[I,Rw]:='#0'
                        else Cells[I,Rw]:='';
                     ReFillRowTimes;
                     GetParams(Rw);
                  end;
            end
         else Rw:=J;  {here if blank spot found in Column Cl - no need to add row}
      end;
end;

procedure FindTId(TId:integer;var NCol:integer);
{use TId to find col in SchG1 to place this entry}
var
   I,J:integer;
   Flag:boolean;
   S:string;
begin
   with Form8 do
      begin
         Flag:=false;
         I:=1;
         repeat
            J:=1;
            repeat
               S:=LabArray[I,J];
               if S<>'' then
                  begin
                     if StrToInt(Copy(LabArray[I,J],1,2))=TId then
                        begin
                           NCol:=J-1;
                           Flag:=true;
                        end;
                  end;
               J:=J+1;
            until (Flag=true) or (J>=11);
            I:=I+1;
         until (Flag=true) or (I>=6);
         if Flag=false then NCol:=-1;
      end;
end;

procedure ProcEntry(S,Nm,Shf:string);
   {parse SG1.Cells[x,NRow] into SchG1 entry:  3 char. Id+Shift+Name}
   {use Cells[Offset+2,NRow to get column and row data}
var
   U,V:string;
   I,J,K,L,Ents,Jb,TId,NCol,Tb:integer;
   Flag:boolean;
begin
   with Form8 do with Form13.SG1 do
      begin
         CountEnt(S,Ents);
         if Ents>0 then
            begin
               J:=1;
               repeat
                  K:=((J-1)*30)+1;
                  TId:=StrToInt(Copy(S,K+4,2));  {TId=time id for this entry}
                  Jb:=StrToInt(Copy(S,K+25,3));
                  if Jb<>999 then
                     begin
                        FindTId(TId,NCol);      {get proper column for this entry}
                        if NCol<>-1 then
                           begin
                              I:=0;
                              Flag:=false;
                              repeat
                                 L:=Pos('<',JobG1.Cells[0,I]);
                                 if L>0 then
                                   Tb:=StrToInt(Copy(JobG1.Cells[0,I],L+1,3))
                                 else Tb:=-1;
                                 if Tb=Jb then
                                    begin
                                       if SchG1.Cells[NCol,I]<>'' then
                                          begin
                                             U:=IntToStr(Jb);
                                             CheckAdd(U,NCol,I);
                                          end;
                                       U:=Nm;
                                       L:=STrToInt(U);
                                       if L<10 then U:='00'+U
                                       else if L<100 then U:='0'+U;
                                       V:=U+Shf;
                                       GetName(U);
                                       V:=V+U;
                                       SchG1.Cells[NCol,I]:=V;
                                       Flag:=true;
                                    end;
                                 I:=I+1;
                              until (Flag=true) or (I>=JobG1.RowCount);
                           end;
                     end
                  else if (CurMode=0)and (TId=90) then   {add to BreakBox}
                     begin
                        U:=Nm;
                        L:=STrToInt(U);
                        if L<10 then U:='00'+U
                        else if L<100 then U:='0'+U;
                        V:=U+Shf;
                        GetName(U);
                        V:=V+U;
                        BreakBox.Items.Add(V);
                     end;
                  J:=J+1;
               until J>Ents;
            end;
      end;
end;

procedure FillGrid;
   {fill hourly, shift, and family names in grid}
var
   I,J,K,Cnt:integer;
   S,T,U:string;
   Flag:boolean;
begin
   with Form8 do
      begin
         with SchG1 do {clear schedule grid}
              for I:=0 to ColCount-1 do
                    for J:=0 to RowCount-1 do Cells[I,J]:='';
         for I:=1 to 5 do
            for J:=1 to 2 do RowTimes[I,J]:=-1;  {clear row no/max col array}
         RowTimes[1,3]:=TLBackColor1;            {set background display colors}
         RowTimes[2,3]:=TLBackColor2;
         RowTimes[3,3]:=TLBackColor3;
         RowTimes[4,3]:=TLBackColor4;
         RowTimes[5,3]:=TLBackColor5;
         RowTimes[1,4]:=PColor1;            {set background printout colors}
         RowTimes[2,4]:=PColor2;
         RowTimes[3,4]:=PColor3;
         RowTimes[4,4]:=PColor4;
         RowTimes[5,4]:=TLBackNormal;
         Cnt:=1;
         with Form8.JobG1 do   {load hourly previously filled positions and unassigned here}
            for I:=0 to RowCount-1 do
               begin
                  if Pos('#',Cells[0,I])=1 then   {this is a time label row}
                     begin
                        RowTimes[Cnt,1]:=I; {Enter this time row no. in RowTimes}
                        S:=Cells[0,I];
                        J:=StrToInt(Copy(S,2,1));    {J=index into Labarray data for this type}
                        Flag:=false;
                        for K:=1 to 10 do
                           begin
                              T:=Labarray[J,K];  {T=id+Tname for column K}
                              if T='' then
                                 begin
                                    T:='0';
                                    if Flag=false then
                                       begin
                                          Flag:=true;
                                          Rowtimes[Cnt,2]:=K;  {set Rowstime[..,2] to max columns+1 used/this type}
                                       end;
                                 end;
                              SchG1.Cells[K-1,I]:='#'+T;
                           end;
                        Cnt:=Cnt+1;
                     end;
               end;
         with SchG1 do   {fill extra cells with 'blacked out' code;}
            begin
               for I:=1 to 4 do if RowTimes[I,1]>-1 then
                  if RowTimes[I+1,1]>-1 then   {do 1-2,2-3,3-4,4-5 rows here}
                     begin
                        for J:=RowTimes[I,1]+1 to RowTimes[I+1,1]-1 do
                           for K:=RowTimes[I,2]-1 to DisplayCols-1 do
                              Cells[K,J]:='#0';
                     end
                  else         {if not 5 types, do this row to rowcount}
                     begin
                       for J:=RowTimes[I,1]+1 to RowCount-1 do
                           for K:=RowTimes[I,2]-1 to DisplayCols-1 do
                              Cells[K,J]:='#0';
                     end;
               if RowTimes[5,1]>-1 then   {if 5 types do this row to rowcount}
                     begin
                        for J:=RowTimes[5,1]+1 to RowCount-1 do
                           for K:=RowTimes[5,2]-1 to DisplayCols-1 do
                              Cells[K,J]:='#0';
                     end;
            end;
         with Form13.SG1 do  {process SG1 emp/job data to SchG1}
            for I:=0 to RowCount-1 do
               begin
                  S:=Cells[Offset+2,I];
                  T:=Cells[0,I];
                  U:=Cells[2,I];
                  ProcEntry(S,T,U);
               end;
         with Query1 do   {load family here}
            begin
               Close;
               Sql.clear;
               Sql.Add('Select *');
               S:='from "'+Schedfile+'"';
               Sql.Add(S);
               S:='where Typ="T" and Dat='+IntToStr(Offset)+' and Shf="T"';
               Sql.Add(S);
               Open;
               First;
               if RecordCount>0 then
                  for I:=1 to RecordCount do
                     begin
                        S:='xxx'+FieldByName('First').AsString
                           +FieldByName('Last').AsString
                           +#13#10;
                        T:=FieldByName('Id').AsString;
                        U:=FieldByName('Shf').AsString;
                        ProcEntry(S,T,U);
                        Next;
                     end;
               Close;
            end;
         HeightAdjust;
      end;
end;

procedure GridDefaults;
   {set up schedule and job grid defaults for both this form and history form16}
var
   I,J:integer;
begin
   with Form8 do
      begin
         Height:=Screen.Height;
         Width:=Screen.Width;
         with SchG1 do   {setup schedule grid defaults}
           begin
              DisplayCols:=1;
              for I:=1 to 5 do for J:=1 to 10 do
                 if (Labarray[I,J]<>'') and (J>DisplayCols) then DisplayCols:=J;
              ColCount:=DisplayCols;
              DefaultColWidth:=100;
              DefaultRowHeight:=16;
              FixedCols:=0;
              RevG1.FixedCols:=FixedCols;
              FixedRows:=0;
              RevG1.FixedRows:=FixedRows;
              Height:=665;
              Left:=121;
              Top:=48;
              Width:=(DefaultColWidth+1)*ColCount;
              Enabled:=true;
           end;
        with JobG1 do {setup job grid defaults}
           begin
              ColCount:=1;
              DefaultColWidth:=100;
              DefaultRowHeight:=16;
              Enabled:=true;
              FixedCols:=0;
              FixedRows:=0;
              Height:=665{344};
              Left:=4;
              ScrollBars:=ssVertical;
              Top:=48;
              Width:=117;
           end;
      end;
end;

procedure ColumnDefaults;
   {setup column time labels for grid}
begin
   with Form8 do
      begin
         with SchG1 do
            begin
               SchG1.Canvas.Font.Style:=[fsbold];
               if CurMode=0 then
                  begin
                     BreakBox.Left:=Left+Width+5;
                     BreakBox.Top:=Top+20;
                     Label9.Left:=BreakBox.Left+10;
                     Label9.Top:=Top;
                     Label9.Visible:=true;
                     Panel3.Left:=BreakBox.Left+BreakBox.Width+5;
                     BreakBox.Clear;
                     BreakBox.Visible:=true;
                  end
               else
                  begin
                     BreakBox.Visible:=false;
                     Label9.Visible:=false;
                     Panel3.Left:=Left+Width+5;
                  end;
               Button1.Left:=Panel3.Left+24;
               Panel4.Left:=Panel3.Left;
               Panel2.Top:=Panel3.Top;
               Panel2.Left:=Panel3.Left;
               RevG1.ColCount:=ColCount;
            end;
      end;
end;

procedure RowDefaults;
   {do grid row names & column Id's here for this form}
var
   I,Offs:integer;
   S,CurType:string;
begin
   with Form8 do
      begin
         CurType:='';
         FillJobGrid;
         Offs:=0;
         JobG1.RowCount:=1;
         for I:=0 to Form13.JobGrid.RowCount-1 do with JobG1 do
            begin
               if CurType<>Form13.JobGrid.Cells[1,I] then
                  begin
                     if CurMode<>0 then
                        begin
                           CurType:=Form13.JObGrid.Cells[1,I];
                           S:=IntToStr(Offs+1);
                           Cells[0,I+Offs]:='#'+S+CurType;
                           Offs:=Offs+1;
                           RowCount:=RowCount+1;
                        end
                     else if Offs=0 then {here if CurMode=0, set up first row }
                        begin
                           Cells[0,0]:='#1';
                           Offs:=1;
                           RowCount:=RowCount+1;
                        end;
                  end;
               Cells[0,I+Offs]:=Form13.JobGrid.Cells[0,I];
               RowCount:=RowCount+1;
            end;
        JobG1.RowCount:=JobG1.RowCount-1;
        SchG1.RowCount:=JobG1.RowCount;
        HeightAdjust;
        RevG1.RowCount:=SchG1.RowCount;
        SchG1.TopRow:=0;
        JobG1.TopRow:=0;
        if CurMode=0 then
           begin
              SchG1.FixedRows:=1;
              JobG1.FixedRows:=1;
           end
        else
           begin
              SchG1.FixedRows:=0;
              JobG1.FixedRows:=0;
           end;
     end;
end;

procedure EmptyGrid;
   {empty grid of names}
var
   I,J:integer;
begin
   with Form8.SchG1 do
      for I:=0 to RowCount-1 do for J:=0 to ColCount-1 do
         begin
            if Copy(Cells[J,I],1,1)<>'%' then
               Cells[J,I]:='                              .';
         end;
end;

procedure FillAvaBox;
   {fill avabox with all special/family employees}
var
   I,J:integer;
   S:string;
begin
   with Form8 do
      begin
         AvaBox.Clear;
         with Form13.ColorGrid do  {All family employees,Id no. and shift to AvaBox}
            begin
               AvaBox.Clear;
               for I:=1 to RowCount do    {ColorGrid starts at record 1}
                  begin
                     J:=StrToInt(Cells[2,I]);
                     if J=FamColor then
                        begin       {Add emp no + T code + schedule name to Avabox}
                           S:=Cells[0,I]+'T'+Cells[1,I];
                           AvaBox.Items.Add(S);
                        end;
                  end;
            end;
      end;
end;

procedure GetId(var TId:integer);
{get time id for ACol - working backward from ARow}
var
   I:integer;
   S:string;
   Flag:boolean;
begin
   with Form8.SchG1 do
      begin
         TId:=99;
         I:=ARow;
         Flag:=false;
         repeat
            S:=Cells[ACol,I];
            if Pos('#',S)=1 then
               begin
                  Flag:=true;
                  TId:=StrToInt(Copy(Cells[ACol,I],2,2));
               end;
            I:=I-1;
         until (I<0) or (Flag=true)
      end;
end;

procedure FillEmpBox;
{Fill EmpBox with names from SG1 for Offset=this DOW, column=this time id, row=this type}
{each entry to EmpBox will include emp id, shift, schedule name}
var
   S,T,U,V:string;
   I,J,K,L,Ents,Jb,TId,SId:integer;
begin
   with Form8 do
      begin
         EmpBox.Clear;
         for I:=0 to Form13.SG1.RowCount-1 do
            begin
               S:=Form13.SG1.Cells[Offset+2,I];
               GetId(TId);
               CountEnt(S,Ents);
               if Ents>0 then for J:=1 to Ents do
                  begin
                     K:=((J-1)*30)+1;
                     T:=Copy(S,K,30);
                     SId:=StrToInt(Copy(T,5,2));
                     if (SId>0) and (SId<>99) then
                        begin
                           if CurMode=0 then SId:=SId mod 10;
                           Jb:=StrToInt(Copy(T,26,3));
                           if (Jb=999) and (TId<>99) and (Copy(T,4,1)<>Offmark) then  {if assigned job is empty and there is a valid id #}
                           if SId=Tid then             {if time id's match}
                              begin
                                 U:=Form13.SG1.Cells[0,I];
                                 L:=STrToInt(U);
                                 if L<10 then U:='00'+U
                                 else if L<100 then U:='0'+U;
                                 V:=U+Form13.SG1.Cells[2,I];
                                 GetName(U);
                                 V:=V+U;
                                 EmpBox.Items.Add(V);
                              end;
                        end;
                  end;
            end;
      end;
end;

procedure CheckSub(ARow:integer);
   {check for removal of duplicate blank rows here}
var
   I,J,K:longint;
   JobName:string;
   AllBlank,Flag:boolean;
begin
   with Form8 do
      begin
         JobName:='';
         Flag:=false;
         with SchG1 do
            begin
               I:=1;
               repeat
                  JobName:=JobG1.Cells[0,I];
                  AllBlank:=true;
                  for J:=0 to ColCount-1 do if (Cells[J,I]<>'') and (Cells[J,I]<>'#0') then
                     AllBlank:=false;
                  if AllBlank=true then
                     if (JobG1.Cells[0,I-1]=JobName) or (JobG1.Cells[0,I+1]=JobName) then
                        begin
                           for J:=I to SchG1.RowCount-1 do
                              begin
                                 for K:=0 to ColCount-1 do
                                    begin
                                       Cells[K,J]:=Cells[K,J+1];
                                       RevG1.Cells[K,J]:=RevG1.Cells[K,J+1];
                                    end;
                                 JobG1.Cells[0,J]:=JobG1.Cells[0,J+1];
                              end;
                           RowCount:=RowCount-1;
                           JobG1.RowCount:=Rowcount;
                           RevG1.RowCount:=RowCount;
                           ReFillRowTimes;
                           GetParams(ARow);
                           Flag:=true;
                        end;
                  I:=I+1;
               until (Flag=true) or (I>=RowCount);
            end;
         HeightAdjust;
      end;
end;

procedure FillHistBox;
   {fill empbox with employees for history}
var
   I:integer;
   S,T:string;
begin
   with Form8 do
      begin
         FillColorGrid(false);
         with Form13.ColorGrid do for I:=1 to RowCount do
            begin
               T:='';
               if StrToInt(Cells[2,I])=HourlyColor then T:='H'
               else if StrToInt(Cells[2,I])=FifteenColor then T:='F'
               else if StrToInt(Cells[2,I])=MinorColor then T:='M';
               if T<>'' then
                  begin
                     S:=Cells[0,I];
                     if Length(S)=1 then S:='00'+S
                     else if Length(S)=2 then S:='0'+S;
                     EmpBox.Items.Add(S+T+Cells[1,I]);
                  end;
            end;
         FillColorGrid(true);
      end;
end;

procedure SetPanel1;
   {set attributes of Panel1 for scheduling}
begin
   with Form8 do
      begin
         Panel1.Visible:=false;
         Avabox.Visible:=true;
         Label3.Caption:='Drag and drop any name from either list.';
         Label4.Left:=56;
         Label4.Caption:='Available';
         Label5.Visible:=true;
         Button5.Visible:=true;
         Panel1.Width:=329;
         Panel1.Color:=clFuchsia;
         Button2.Enabled:=true;
         Button4.Enabled:=true;
         Button10.Enabled:=true;
      end;
end;

procedure UnSetPanel1;
   {set attributes of Panel1 for history}
begin
   with Form8 do
      begin
         Avabox.Visible:=false;
         Label3.Caption:='    History List';
         Label4.Left:=2;
         Label4.Caption:='(Sorted by Schedule Name)';
         Label5.Visible:=false;
         Button5.Visible:=false;
         Panel1.Width:=180;
         Panel1.Top:=SchG1.Top;
         Panel1.Color:=clSkyBlue;
         Panel1.Left:=Panel4.Left+Panel4.Width+50;
         Panel1.Visible:=true;
         Button2.Enabled:=false;
         Button4.Enabled:=false;
         Button10.Enabled:=false;
      end;
end;

procedure TForm8.FormActivate(Sender: TObject);
begin
   SchG1.TopRow:=0;
   JobG1.TopRow:=0;
   DaysAgo:=4;   {set default value for days between same job (+1) for autosort}
   Label8.Visible:=false;
   Panel1.Visible:=false;
   Button3.Caption:='Review Off';
   RevNum:=0;
   RevLabel.Visible:=false;
   Label1.Visible:=false;
   RevLabel.Caption:='';
   Query1.Connection:=Form13.funland;
   Button2.Enabled:=true;
   Button3.Font.Color:=clBlack;
   Button4.Font.Color:=clBlack;
   TrainFlag:=false;
   Button4.Caption:='Turn Check On';
   Button6.Caption:='History On';
   SetPanel1;
   CurMode:=ModArray[Offset];
   Form8.Caption:='Schedule for: '+Schedstr+'  '+Formset.LongDayNames[DayOfWeek(NewDate+Offset-1)]+'  Mode: '+IntToStr(CurMode);
   SchedDate:=SchedStr;
   BreakDate:=SchedStr;
   FillLabarray;
   GridDefaults;
   ColumnDefaults;
   RowDefaults;
   FillAvaBox;
   ClearRevGrid(false);
   SelectCol:=0;
   SelectRow:=0;
   OldSelect:=SchG1.Cells[0,0];
   if CurMode<>0 then
      begin
         TogFlag:=true;
         Button14.Caption:='Show Times';
         Button14.Enabled:=true;
      end
   else
      begin
         TogFlag:=false;
         Button14.Caption:='Show Labels';
         Button14.Enabled:=false;
      end;
   FillGrid;
   GetEmpTotals;
   AddTrainingData;
end;

Function TimeId(S:string;Id:integer):boolean;
   {check for time Id in string S}
   {return true if found}
var
   IDS,N:integer;
   T:string;
   Flag:boolean;
begin
   with Form8 do
      begin
         IDS:=Length(S) div 3;
         Flag:=false;
         N:=0;
         repeat
            Inc(N);
            T:=Copy(S,(N-1)*3+1,3);
            if StrToInt(T)=Id then
                  Flag:=true;
         until (Flag=true) or (N>=IDS);
         TimeId:=Flag;
      end;
end;

Function NameCheck:boolean;
   {check for name in schg1 or appropriate list}
var
   I,J,Id:longint;
   NCheck:boolean;
begin
   Id:=StrToInt(Copy(Namestr,Length(Namestr)-2,3));
   Delete(Namestr,Length(Namestr)-4,5);
   NCheck:=false;
   with Form8.schg1 do
      begin
         for I:=0 to RowCount-1 do
            if Pos(Namestr,Cells[SGCol,I])>0 then
               NCheck:=true;
         if NCheck=false then
            begin
               J:=StrToInt(Cells[SGCol,RowCount+2]);
               for I:=1 to J do
                  if StrToInt(Cells[SGCol,RowCount+2+I])=Id then
                     NCheck:=true;
            end;
      end;
   NameCheck:=NCheck;
end;

Procedure CalcPrintParams;
   {calculate printer parameters for current printer settings}
   {Default is 300 dpi, 2400 pixels wide, 3150 pixels long, portrait orientation}
var
   I:integer;
begin
   {PL:=Printer.PageHeight;
   PW:=Printer.PageWidth;}
   PL:=3150;
   PW:=2400;
   Wid:=Form18.CBx1.Checked;    {print double size?}
   Fit:=Form18.CBx2.Checked;    {print to fit page?}
   Clr:=Form18.CBx3.Checked;    {print in color?}
   TM:= 100;  {top margin}
   BM:= 100;  {bottom margin}
   if Wid=false then     {set up params to print regular size}
      begin
         CSp:= 209; {spacing between columns}
         CFt:= 350; {width of 1st column}
         Wd:=2;   {pen width}
         if Fit=false then
            RSp:=49 {spacing between rows}
         else
            begin     {fit to page here}
               I:=Form8.JobG1.RowCount+1;
               if I>0 then RSp:=(PL-TM) div I
                  else RSp:=49;
            end;
         if RSp>49 then RSp:=49
         else if RSp<39 then RSp:=39;
         Fon1:= 12; {title font size}
         Fon2:= 10; {fixed row/col font size}
         Fon3:= 8; {name font size}
      end
   else          {set up params to print double size}
      begin
         CSp:=400;
         CFt:=620;
         Wd:=4;
         Fon1:=22;
         Fon2:=18;
         Fon3:=16;
         RSp:=98;
      end;
   Wg:=Wd*3;  {set pen width}
   if Clr=false then LM:=5   {set left margin}
      else LM:=5+Wg;
   Cols1:=(PW-Cft) div CSp;
   Cols2:=PW div CSp;
   PagesA:=1+(DisplayCols-Cols1) div Cols2;    {set pages to print across value}
   if (DisplayCols-Cols1) mod Cols2 >0 then PagesA:=PagesA+1;
   Roes1:=((PL-TM) div RSp)-1;
   Roes2:=(PL div RSp)-1;
   PagesD:=1+(Form8.JobG1.RowCount-Roes1) div Roes2;  {set pages to print down value}
   if (Form8.JobG1.RowCount-Roes1) mod Roes2  >0 then PagesD:=PagesD+1;
end;

procedure SetRect(X,Y,Cnt:integer;Flag:boolean);
{print background color rectangle}
{X and Y are coordinates;Cnt sets color; Flag=true for job column false for other cols}
begin
   Printer.Canvas.Brush.Color:=RowTimes[Cnt,3];
   PRect.Left:=X-4;
   PRect.Top:=Y;
   if Flag=true then PRect.Right:=X+CFt
      else
         begin
            PRect.Left:=PRect.Left;
            PRect.Right:=X+CSp;
         end;
   PRect.Bottom:=Y+RSp;
   PRect.Bottom:=Round(PRect.Bottom*PY);
   PRect.Left:=Round(PRect.Left*PX);
   PRect.Right:=Round(PRect.Right*PX);
   PRect.Top:=Round(PRect.Top*PY);
   Printer.Canvas.FillRect(PRect);
end;

Procedure PrintPage(Dow,Acr:integer);
   {print next page}
   {Dow is pages down; Acr is pages across}

var
   I,J,K,L,M,P,X,Y,StartCol,EndCol,StartRow,EndRow,LineCount,ClCount,FW,FH,Offs,Cnt,Len:integer;
   S,T,Z,Prv:string;
   Flag:boolean;
begin
   with Form8 do
      begin
         if Acr=1 then                 {set up beginning and ending columns}
            begin
               StartCol:=0;
               EndCol:=Cols1-1;
            end
         else
            begin
               StartCol:=Cols1+(Cols2*(Acr-2));
               EndCol:=StartCol+Cols2 - 1;
             end;
         if EndCol>DisplayCols-1 then EndCol:=DisplayCols-1;
         if Dow=1 then                {set up beginning and ending rows}
            begin
               StartRow:=0;           {1st page down}
               EndRow:=Roes1;
            end
         else
            begin                     {succeeding pages down}
               StartRow:=Roes1+1+(Roes2*(Dow-2)){+1};
               EndRow:=StartRow+Roes2;
            end;
         if Endrow>SchG1.RowCount then
            Endrow:=SchG1.RowCount;
         Begindok;             {start actual printout}
         LineCount:=0;
         Wide(Wd);              {set pen width}
         if (Acr=1) and (Dow=1) then  {print title on first page across and down}
            begin
               Sise(Fon1);
               Stile([fsBold]);
               S:=Form8.Caption;
               TextOwt(0,0,S);
            end;
         Stile([]);
         Movetwo(0,TM);                          {print top line}
         FW:=(EndCol-StartCol+1)*Csp;
         if Acr=1 then FW:=FW+CFt;
         Linetwo(FW,TM);
         Prv:='';   {this will be previous job string: eg 'ChangeBag<001' or '#1'}
         I:=StartRow;
         Sise(Fon3);           {set font size}
         Cnt:=1;              {Cnt= line count for this page}
         with Schg1 do          {print each row for this page looping here}
            repeat             {print row labels from JObG1 and name data from SchG1 + horizontal lines}
               Printer.Canvas.Brush.Color:=TLBackNormal;
               if (I<EndRow) and (Copy(JobG1.Cells[0,I],1,1)='#') then
                  Cnt:=Cnt+1;
               K:=LineCount*RSp+TM;   {K=length of a full vertical line in pixels}
               if Clr=true then K:=K+(Cnt-1)*Wg;
               if Dow<>1 then K:=K-Rsp;
               Stile([]);         {clear font style to normal}
               if Prv<>JobG1.Cells[0,I] then
                  begin  {if diff.job than last row}
                     Prv:=JobG1.Cells[0,I];
                     if Copy(Prv,1,1)='#' then  {this is time label row}
                         begin
                            if Acr=1 then  {print time label and color rect on left most pages}
                               begin
                                  Stile([fsBold]);
                                  Z:=Copy(Prv,3,Length(Prv)-2); {Z=label for this time, if there is one.}
                                  if Clr=true then  {print color rect for label}
                                     begin
                                        Printer.Canvas.Brush.Color:=RowTimes[Cnt,4];
                                        SetRect(LM,K,Cnt,true);
                                     end;
                               end;
                         end
                     else  if Acr=1 then {this is regular job row}
                        begin
                           Z:=Copy(Prv,1,Length(Prv)-4);
                           if Clr=true then  {do row left vertical color line}
                              begin
                                 Wide(Wg);
                                 Printer.Canvas.Pen.Color:=RowTimes[Cnt,4];
                                 MoveTwo(LM-Wg,K);
                                 LineTwo(LM-Wg,K+RSp);
                                 Printer.Canvas.Pen.Color:=clBlack;
                                 Wide(Wd);
                              end;
                        end;
                     if (Clr=true) and (Cnt>1) then     {print bottom color line segment for previous time}
                        begin
                           {Wide(Wg);
                           Printer.Canvas.Pen.Color:=RowTimes[Cnt-1,4];
                           MoveTwo(Y,K-Wg);
                           LineTwo(Y+CFt,K-Wg);
                           Printer.Canvas.Pen.Color:=clBlack;
                           Wide(Wd); }
                        end;
                     TextOwt(LM,K,Z);   {print time or job label}
                     Movetwo(0,K);      {print line across page above this row }
                     Linetwo(FW,K);
                  end;
               ClCount:=0;
               for J:=StartCol to EndCol do  {do all column entries for this row}
                  begin
                      Printer.Canvas.Font.Color:=clBlack;
                      Printer.Canvas.Brush.Color:=TLBackNormal;
                      Stile([]);
                      T:=Cells[J,I];
                      if Copy(T,1,1)='#' then  {time label row or blank cell}
                         begin
                            if T='#0' then T:='xxxx' {no need to print blank cells in color}
                            else
                               begin            {here to set up for for time label cells}
                                  Stile([fsBold]);
                                  P:=Pos('&',T);
                                  T:=Copy(T,P+1,Length(T)-P);    {this is to show time data label}
                                  if Clr=true then
                                     begin
                                        Printer.Canvas.Brush.Color:=RowTimes[Cnt,4];
                                        Y:=(J*CSp)+5;
                                        if Acr=1 then Y:=Y+CFt;
                                        SetRect(Y,K,Cnt,false);
                                         if Cnt>1 then     {print bottom color line segment for previous time}
                                            begin
                                              { Wide(Wg);
                                               Printer.Canvas.Pen.Color:=RowTimes[Cnt-1,4];
                                               MoveTwo(Y,K-Wg);
                                               LineTwo(Y+CSp,K-Wg);
                                               Printer.Canvas.Pen.Color:=clBlack;
                                               Wide(Wd); }
                                           end;
                                     end;
                               end;
                         end
                      else if T<>''then  {here for name cells}
                          begin
                             T:=Copy(T,5,Length(T)-4);
                             if Clr=true then      {if color, set color here}
                                begin
                                   Flag:=false;
                                   L:=1;
                                   repeat
                                      if T=Form13.ColorGrid.Cells[1,L] then
                                         begin
                                            Flag:=true;
                                            Printer.Canvas.Font.Color:=StrToInt(Form13.ColorGrid.Cells[2,L]);
                                         end;
                                      L:=L+1;
                                    until (Flag=true) or (L>Form13.ColorGrid.RowCount);
                                    if Flag=false then Printer.Canvas.Font.Color:=clBlack;
                                end;
                             T:=' '+T;
                             if Clr=true then  {print right color line if true}
                               begin
                                  {????}
                               end;
                          end;
                      Y:=ClCount*CSp;
                      if Acr=1 then Y:=Y+CFt;
                      Sise(Fon3);
                      Offs:=(CSp-Printer.Canvas.TextWidth(T)) div 2;
                      if Offs<0 then Offs:=0;
                      TextOwt(Y+Offs,K+5,T);
                      Inc(ClCount);
                  end;
               Inc(LineCount);
               Inc(I);
            until I>EndRow;
         FH:=(LineCount)*RSp+TM;    {print vertical lines here}
         MoveTwo(0,TM);
         LineTwo(0,FH);
         J:=1;
         for I:=StartCol to EndCol do
            begin
               Y:=J*CSp;
               if Acr=1 then Y:=Y+CFt;
               MoveTwo(Y,TM);
               LineTwo(Y,FH);
               J:=J+1;
            end;
         MoveTwo(FW,TM);     {last vertical line}
         {LineTwo(FW,FH);}
         MoveTwo(0,FH);     {last horizontal line}
         LineTwo(FW,FH);
         if Clr=true then   {print last horizontal color line}
            begin
               {Wide(Wg);
               Printer.Canvas.Pen.Color:=RowTimes[Cnt,3];
               MoveTwo(LM,K);
               if EndCol<=RowTimes[2,Cnt]-1 then
                  X:=(EndCol-1-StartCol)*Csp
               else X:=(RowTimes[2,Cnt]-1-StartCol)*CSp;
               if Acr=1 then X:=X+Cft;
               LineTwo(X,K);
               Printer.Canvas.Pen.Color:=clBlack;
               Wide(Wd); }
            end;
         Enddok;
      end;
end;

procedure TForm8.Button2Click(Sender: TObject);
   {print button}
var
   I,J,K:longint;
   S:string;
begin
   Form18.ShowModal;
   CalcPrintParams;
   if (PagesA=1) and (PagesD=1) then
      S:='on a single page.'
   else if (PagesA=1) and (PagesD>1) then
      S:='one page across and '+IntToStr(PagesD)+' pages down.'
   else if (PagesA>1) and (PagesD=1) then
      S:=IntToStr(PagesA)+' pages across and one page down.'
   else S:=IntToStr(PagesA)+' pages across and '+IntToStr(PagesD)+ ' pages down.';
   S:='This schedule will be printed '+S;
   if MessageDlg(S,mtConfirmation,[mbYes,mbNo],0)=mrYes then
      begin
         PXPY;  {not using this anymore?}
         I:=0;
         repeat
            Inc(I);
            J:=0;
            repeat
               Inc(J);
               S:='Print page across= '+InttoStr(J)+'/page down= '+IntToStr(I)+' ?';
               K:=MessageDlg(S,mtConfirmation,mbYesNoCancel,0);
               if K=mrYes then
                  begin
                     PrintPage(I,J);
                  end
               else if K=mrCancel then
                  begin
                     J:=PagesA;
                     I:=PagesD;
                  end;
            until J>=PagesA;
         until I>=PagesD;
      end;
end;

procedure TForm8.JobG1TopLeftChanged(Sender: TObject);
begin
   SchG1.TopRow:=JobG1.TopRow;
end;

procedure TForm8.SchG1TopLeftChanged(Sender: TObject);
begin
   if SchG1.LeftCol<>0 then SchG1.LeftCol:=0;
   if SchG1.TopRow<>JobG1.Top then JobG1.TopRow:=SchG1.TopRow;
end;

procedure TForm8.SchG1DrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);

var
    S,T:string;
    Offs,I,J:integer;
begin
    with SchG1 do
       begin
          S:=Cells[ACol,ARow];
          if Pos('#',S)=1 then
             begin
                if S<>'#0' then   {here to draw Time SchG1 cells}
                   begin
                      Canvas.Font.Color:=clBlack;
                      I:=Pos('&',S);
                      if TogFlag=true then  {show label names}
                         T:=Copy(S,4,I-4)
                      else                  {show times+unassigned employee total}
                         begin
                            J:=StrToInt(Copy(Jobg1.Cells[0,ARow],2,1));  {J=Tipe no.}
                            T:=IntToStr(Countarray[J,ACol+1]);
                            T:=Copy(S,I+1,Length(S)-I)+'  ('+T+')';
                         end;
                      Canvas.Font.Style:=[fsBold];
                      try
                         J:=StrToInt(Copy(Form8.JobG1.Cells[0,ARow],2,1));
                      except
                        on EconvertError do
                          begin

                          end;
                      end;
                      Canvas.Brush.Color:=RowTimes[J,3];
                      Canvas.FillRect(Rect);
                   end
                else       {Here to draw 'blacked out' SchG1 cells}
                   begin
                      T:=' ';
                      Canvas.Brush.Color:=clMedGray;
                      Canvas.FillRect(Rect);
                   end;
                Offs:=(DefaultColWidth-Canvas.TextWidth(T)) div 2;
                Canvas.TextOut(Rect.Left+Offs-5,Rect.Top,T);
                Canvas.Font.Style:=[];
             end
          else if  Button6.Caption='History On' then   {here for Name entries in SchG1 cells}
             begin
                if Pos(':',S)=1 then       {???? was this used for sorting?}
                   S:=Copy(S,2,Length(S)-1);
                T:=Copy(S,4,1);
                if T='M' then Canvas.Font.Color:=MinorColor
                   else if T='H' then Canvas.Font.Color:=HourlyColor
                   else if T='S' then Canvas.Font.Color:=SpecialColor
                   else if T='F' then Canvas.Font.Color:=FifteenColor
                   else if T='T' then Canvas.Font.Color:=FamColor
                   else Canvas.Font.Color:=ExEmpColor;
                Canvas.Font.Style:=[fsBold];
                if (Panel1.Visible=false) or (ACol<>CurCol)
                   or (ARow>NREnd) or (ARow<NRStrt) then Canvas.Brush.Color:=clWindow
                else Canvas.Brush.Color:=clAqua;
                Canvas.FillRect(Rect);
                Offs:=(DefaultColWidth-Canvas.TextWidth(S)) div 2;
                if Offs<0 then Offs:=0;
                T:='';
                if Button3.Caption='Review On' then
                   begin
                      T:=RevG1.Cells[ACol,ARow];
                      if T<>'' then Offs:=5 ;
                   end;
                S:=Copy(S,5,Length(S)-4);
                Canvas.TextOut(Rect.Left+Offs,Rect.Top,S);
                if T<>'' then
                    begin
                       Offs:=DefaultColWidth-Canvas.TextWidth(T);
                       Canvas.Font.Color:=clRed;
                       Canvas.TextOut(Rect.Left+Offs-5,Rect.Top,T);
                    end;
                Canvas.Font.Style:=[];
             end
          else   {here for history entries}
             begin
                Offs:=0;
                Canvas.Brush.Color:=clWindow;
                Canvas.TextOut(Rect.Left+Offs,Rect.Top,S);
             end;
       end;
end;

procedure TForm8.AvaBoxDrawItem(Control: TWinControl; Index: Integer;
  Rect: TRect; State: TOwnerDrawState);
var
   S:string;
begin
   with AvaBox do
      begin
         S:='   '+Copy(Items[Index],5,Length(Items[Index])-4);
         Canvas.Font.Color:=FamColor;
         Canvas.FillRect(Rect);
         Canvas.TextOut(Rect.Left,Rect.Top,S);
      end;
end;

procedure TForm8.Button3Click(Sender: TObject);
{Toggle review on and off}
begin
   with Button3 do
      if Caption='Review Off' then
         begin
            Caption:='Review On';
            Label8.Visible:=true;
         end
      else
         begin
            Caption:='Review Off';
            ClearRevGrid(true);
            RevNum:=0;
            RevLabel.Visible:=false;
            Label1.Visible:=false;
            RevLabel.Caption:='';
            Label8.Visible:=false;
         end;
end;

procedure TForm8.Button4Click(Sender: TObject);
{Toggle train checking on and off}
begin
    with Button4 do
      if Caption='Turn Check On' then
         begin
            Caption:='Please Wait';
            TrainFlag:=true;
            FillTraine;
            AddTrainingData;
            FillGrid;
            Caption:='Turn Check Off';
         end
      else
         begin
            Caption:='Please Wait';
            TrainFlag:=false;
            FillGrid;
            Caption:='Turn Check On';
         end;
end;

procedure TForm8.JobG1DrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
var
   J:integer;
   S,T:string;
begin
   {if (TrainFlag=true) and (ACol=0)then} with JobG1 do
      begin
         S:=Cells[0,ARow];
         if S<>'' then
            begin
               T:=Copy(S,1,1);
               if T='#' then
                  begin
                     Canvas.Font.Style:=[fsBold];
                     Canvas.Font.Color:=clBlack;
                     S:=Copy(S,3,Length(S)-2);
                     for J:=1 to 5 do if S=TipArray[Offset,J] then
                        {case J of
                           1:Canvas.Brush.Color:=TLBackColor1;
                           2:Canvas.Brush.Color:=TLBackColor2;
                           3:Canvas.Brush.Color:=TLBackColor3;
                           4:Canvas.Brush.Color:=TLBackColor4;
                           5:Canvas.Brush.Color:=TLBackColor5;
                        end;}
                        Canvas.Brush.Color:=RowTimes[J,3];
                     Canvas.FillRect(Rect);
                  end
               else
                  begin
                     Canvas.Font.Color:=clBlack;
                     Canvas.Brush.Color:=clWhite;
                     S:=Copy(S,1,Length(S)-4)+'                      ';
                     Canvas.Font.Style:=[];
                  end;
               Canvas.TextOut(Rect.Left+2,Rect.Top+2,S);
            end;
      end;
end;

procedure TForm8.Button1Click(Sender: TObject);
{Exit schedule button}
begin
   Close;
end;

procedure TForm8.Button6Click(Sender: TObject);
{History button}
begin
   if Button6.Caption='History On' then
      begin
         Button6.Caption:='History Off';
         Button14.Enabled:=false;
         FillHistBox;
         EmptyGrid;
         UnSetPanel1;
      end
   else
      begin
         Button6.Caption:='History On';
         Button14.Enabled:=true;
         FillGrid;
         SetPanel1;
      end;
end;

procedure TForm8.Button10Click(Sender: TObject);
   {Lockout (training) button}
begin
   EmpTrainNum:=1;
   Form17.ShowModal;
end;

procedure TForm8.SE1Change(Sender: TObject);
begin
   if SE1.Value+1<>DaysAgo then
      DaysAgo:=SE1.Value+1;
end;

procedure TForm8.SchG1SelectCell(Sender: TObject; ACol, ARow: Integer;
  var CanSelect: Boolean);      {???? not sure what I'm doing this for!}
var                             {not currently called}
   S:string;
begin
   with SchG1 do
      begin
         if {(ACol<>SelectCol) or }(ARow<>SelectRow) then
            begin
               S:=Cells[SelectCol,SelectRow];
               Cells[SelectCol,SelectRow]:=S;
               SelectCol:=ACol;
               SelectRow:=ARow;
               OldSelect:=Cells[SelectCol,SelectRow];
               Cells[SelectCol,SelectRow]:=OldSelect;
            end;
      end;
end;

procedure FillBG1;
{fill BG1 with breakers/times}
var
   I:integer;
begin
   with Form7.BG1 do
      begin
         RowCount:=0;
         for I:=1 to Form8.SchG1.RowCount-1 do
            if Form8.SchG1.Cells[BrkCol,I]<>'' then
               begin
                  Cells[0,RowCount]:='>'+Form8.SchG1.Cells[BrkCol,I];
                  RowCount:=RowCount+1;
                  Cells[0,RowCount]:='7:30';
                  Cells[1,RowCount]:='';
                  Cells[2,RowCount]:='';
                  Cells[3,RowCount]:='';
                  RowCount:=RowCount+1;
                  Cells[0,RowCount]:='8:00';
                  Cells[1,RowCount]:='';
                  Cells[2,RowCount]:='';
                  Cells[3,RowCount]:='';
                  RowCount:=RowCount+1;
                  Cells[0,RowCount]:='8:30';
                  Cells[1,RowCount]:='';
                  Cells[2,RowCount]:='';
                  Cells[3,RowCount]:='';
                  RowCount:=RowCount+1;
                  Cells[0,RowCount]:='9:00';
                  Cells[1,RowCount]:='';
                  Cells[2,RowCount]:='';
                  Cells[3,RowCount]:='';
                  RowCount:=RowCount+1;
                  Cells[0,RowCount]:='9:30';
                  Cells[1,RowCount]:='';
                  Cells[2,RowCount]:='';
                  Cells[3,RowCount]:='';
                  RowCount:=RowCount+1;
                  Cells[0,RowCount]:='10:00';
                  Cells[1,RowCount]:='';
                  Cells[2,RowCount]:='';
                  Cells[3,RowCount]:='';
                  RowCount:=RowCount+1;
               end;
      end;
end;

function FiveCheck(S:string):boolean;
{check for presence of schedname S in 5:00-7:00}
var
   I:integer;
   Flag:boolean;

begin
   with Form8.SchG1 do
      begin
         Flag:=false;
         I:=1;
         while (Flag=false) and (I<RowCount) do
            begin
               if S=Cells[FivCol,I] then Flag:=true;
               Inc(I);
            end;
         FiveCheck:=Flag;
      end;
end;

procedure Transfers;
{copy JobG1 to Form7.JobG1 and SchG1 7:00 to Form7.SchG1 for breaks}
var
   I:integer;
   S,T:string;
begin
   with Form8 do
      begin
         Form7.SchG1.RowCount:=0;
         Form7.JobG1.RowCount:=0;
         For I:=1 to JobG1.RowCount-1 do
            begin
               Form7.BreakGrid.Cells[0,I]:='';
               Form7.BreakGrid.Cells[1,I]:='';
               Form7.BreakGrid.Cells[2,I]:='';
               S:=SchG1.Cells[SevCol,I];
               if S<>'' then
                  begin
                     Form7.JobG1.Cells[0,Form7.SchG1.RowCount]:=JobG1.Cells[0,I];
                     Form7.JobG1.RowCount:=Form7.JobG1.RowCount+1;
                     Form7.SchG1.Cells[0,Form7.SchG1.RowCount]:=SchG1.Cells[SevCol,I];
                     GetColor(S,T);
                     if FiveCheck(S)=true then
                        begin
                          if T='M' then Form7.SchG1.Cells[1,Form7.SchG1.RowCount]:='1'
                             else if T='H' then Form7.SchG1.Cells[1,Form7.SchG1.RowCount]:='2';
                        end
                     else  if T='M' then Form7.SchG1.Cells[1,Form7.SchG1.RowCount]:='3'
                        else Form7.SchG1.Cells[1,Form7.SchG1.RowCount]:='4';
                     Form7.SchG1.RowCount:=Form7.SchG1.RowCount+1;
                  end;
            end;
      end;
end;

procedure ColCheck(var Err:string);
{check for 5,7,7:30 displayed in SchG1}
var
   I:integer;
   S:string;
begin
   with Form8.SchG1 do
      begin
         FivCol:=0;
         SevCol:=0;
         BrkCol:=0;
         for I:=0 to ColCount-1 do
            begin
               S:=Cells[I,0];
               if Pos('5:00- 7:00',S)<>0then
                  FivCol:=I
               else if Pos('7:00-',S)<>0 then
                  SevCol:=I
               else if Pos('7:30-',S)<>0 then
                  BrkCol:=I;
            end;
         if FivCol=0 then Err:='5:00- 7:00'
         else if SevCol=0 then Err:='7:00-'
         else if BrkCol=0 then Err:='7:30-';
      end;
end;

procedure TForm8.Button11Click(Sender: TObject);
{do break scheduling here}
var
   S,Err:string;
begin
   Err:='';
   ColCheck(Err);
   if Err<>'' then
      begin
         S:=Err+' Column is not displayed. Please display before continuing.';
         MessageDlg(S,mtWarning,[mbOk],0);
      end
   else
      begin
         Transfers;
         FillBG1;
         Form7.ShowModal;
      end;
end;

procedure TForm8.Button14Click(Sender: TObject);
{toggle time labels in time row betwen tnames and lab field}
begin
   if TogFlag=true then
      begin
         TogFlag:=false;
         Button14.Caption:='Show Labels';
      end
   else
      begin
         TogFlag:=true;
         Button14.Caption:='Show Times';
      end;
   FillGrid;
end;

procedure TForm8.Button5Click(Sender: TObject);
{close panel1 name entry}
var
  I:integer;
  S:string;
begin
   Panel1.Visible:=false;
   for I:=NRStrt to NREnd do
      begin
         S:=SchG1.Cells[ACol,I];
         SchG1.Cells[ACol,I]:=S;
      end;
end;

procedure TForm8.SchG1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
   Nmbr,SId:integer;
   S,T:string;
begin
   SchG1.MouseToCell(X,Y,ACol,ARow);
   S:=SchG1.Cells[ACol,ARow];
   GetParams(ARow);
   if Button=mbRight then    {here for possible name deletion from SchG1}
      begin
         if (Pos('#',S)<>1) and (S<>'') then   {ignore time and blacked out and empty cells}
            begin
               T:=Copy(S,5,Length(S)-4);
               T:='Delete '+T+' from this position?';
               if MessageDlg(T,mtConfirmation,mbYesNo,0)=mrYes then
                begin
                 Nmbr:=StrToInt(Copy(S,1,3));  {employee no.}
                 SId:=StrToInt(Copy(SchG1.Cells[ACol,NRStrt-1],2,2));   {time id}
                 if CurMode=0 then SId:=SId mod 10;
                 Currec:=0;
                 if Copy(S,4,1)='T' then  {if family then delete record from files}
                  begin
                     FindRecord(Nmbr,SId,Currec);
                     if Currec>0 then DoDeleteRec(Currec);
                  end
                 else
                  begin               {here for non family employees}
                     GetParams(ARow);
                     T:='999'; {make no job}
                     ModifySG(Nmbr,SId,T);    {modifysg sets correct current record}
                     if Currec>0 then ChangePosition(Currec,T);  {if modifysg succeeds change this emp's position in files}
                     GetEmpTotals;
                     T:=SchG1.Cells[ACol,NRStrt-1];
                     SchG1.Cells[ACol,NRStrt-1]:=T;
                     if (Panel1.Visible=true) and (ACol=CurCol) then FillEmpBox;
                  end;
                 SchG1.Cells[ACol,ARow]:='';
                 CheckSub(ARow);
                end;
            end;
      end
   else if (Button=mbLeft) and (Copy(S,1,1)<>'#') then  {here for drag drop in same column}
      begin
         if (Panel1.Visible=false) or ((Panel1.Visible=true) and (CurCol=ACol)) then
            begin
               CurCol:=ACol;
               CurRow:=ARow;
               GetParams(ARow);
               DS:=S;
               DragFlag:=true;
               SchG1.begindrag(false);
            end;
      end;
end;

procedure TForm8.EmpBoxDrawItem(Control: TWinControl; Index: Integer;
  Rect: TRect; State: TOwnerDrawState);
var
   S,T:string;
begin
   with EmpBox do
      begin
         S:='  '+Copy(Items[Index],5,Length(Items[Index])-4);
         T:=Copy(Items[Index],4,1);
         if T='H' then Canvas.Font.Color:=HourlyColor
         else if T='M' then Canvas.Font.Color:=MinorColor
         else if T='F' then Canvas.Font.Color:=FifteenColor
         else if T='S' then Canvas.Font.Color:=SpecialColor
         else if T='T' then Canvas.Font.Color:=FamColor;
         Canvas.FillRect(Rect);
         Canvas.TextOut(Rect.Left,Rect.Top,S);
      end;
end;

procedure TForm8.SchG1DblClick(Sender: TObject);
{double click a time label to open panel1}
var
   I:integer;
   S:string;
begin
   S:=SchG1.Cells[ACol,ARow];
   if Panel1.Visible=true then   {here if panel1 already visible}
      begin
         Panel1.Visible:=false;     {change rect color of old selection back to clWhite}
         for I:=NRStrt to NREnd do
            begin
               S:=SchG1.Cells[CurCol,I];
               SchG1.Cells[CurCol,I]:=S;
            end;
      end;
   CurCol:=ACol;
   if (Pos('#',S)=1) and (S<>'#0') then     {is this a time label?}
      begin
         FillEmpBox;
         GetParams(ARow);
         for I:=NRStrt to NREnd do
            begin
               S:=SchG1.Cells[ACol,I];
               SchG1.Cells[ACol,I]:=S;
            end;
         Panel1.Left:=SchG1.Left+((ACol+1)*(SchG1.DefaultColWidth+1));
         Panel1.Visible:=true;
      end;
end;

procedure TForm8.EmpBoxMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
   J:integer;
begin
   with EmpBox do if ItemIndex>-1 then
      begin
         DS:=Items[ItemIndex];
         if Button6.Caption='History On' then
            begin
               AvaFlag:=false;
               DragFlag:=false;
               begindrag(false);
            end
         else
            begin
               EmptyGrid;
               J:=StrToInt(Copy(Items[ItemIndex],1,3));
               GetAmpHis(J);
            end;
      end;
end;

procedure TForm8.SchG1DragOver(Sender, Source: TObject; X, Y: Integer;
  State: TDragState; var Accept: Boolean);
var
   BCol,BRow:integer;
begin
  if (Source is TListBox) or (Source is TStringGrid) then
     begin
        SchG1.MouseToCell(X,Y,BCol,BRow);
        if ((BCol=CurCol) and (BRow>=NRStrt) and (BRow<=NREnd) and (CurMode<>0))
           or ((BCol=CurCol) and (CurMode=0)) then
                 Accept:=true
        else Accept:=false;
     end;
end;

procedure TForm8.AvaBoxMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
   with AvaBox do if ItemIndex>-1 then
      begin
         DS:=Items[ItemIndex];
         AvaFlag:=true;
         DragFlag:=false;
         begindrag(false);
      end;
end;

procedure TForm8.SchG1DragDrop(Sender, Source: TObject; X, Y: Integer);
{process drag drops here}
var
   I,BCol,BRow,Nmbr,SId,RecN,NRow,TCount:integer;
   S,T,Jsb:string;
begin
   with Sender as TStringGrid do
      begin
         MouseToCell(X,Y,BCol,BRow);
         S:=Cells[BCol,BRow];
         Jsb:=JobG1.Cells[0,BRow];   {Get Jsb=Job id string}
         I:=Pos('<',Jsb);
         Jsb:=Copy(Jsb,I+1,3);
         if DragFlag=true then
            begin
               Cells[CurCol,CurRow]:='';
               CheckSub(CurRow);
            end;
         if S<>'' then {here if cell not empty- check to add new row}
            begin
               CheckAdd(Jsb,BCol,BRow);
            end;
         Cells[BCol,BRow]:=DS;
         Nmbr:=StrToInt(Copy(DS,1,3));  {employee no.}
         SId:=StrToInt(Copy(SchG1.Cells[BCol,NRStrt-1],2,2));   {time id}

         T:=Copy(DS,4,1); {Shift <> family??}
         if T<>'T' then
            begin
               if CurMode=0 then SId:=SId mod 10;
               S:=Cells[BCol,BRow];
               if AvaFlag=false then EmpBox.DeleteSelected;
               Currec:=0;
               ModifySG(Nmbr,SId,Jsb);
               if Currec>0 then ChangePosition(Currec,Jsb);
               GetEmpTotals;
               T:=Cells[BCol,NRStrt-1];
               Cells[BCol,NRStrt-1]:=T;
            end
         else
            begin    {here for family drag drops}
               FindRecord(Nmbr,SId,RecN);
               If RecN>0 then  {if record already exists - change position}
                  begin
                     ChangePosition(RecN,Jsb);
                  end
               else           {if no record - make one}
                  begin
                     S:=Cells[BCol,NRStrt-1];
                     SId:=StrToInt(Copy(S,2,2));
                     NRow:=-1;
                     with Form13.TimeGridP do for I:=0 to RowCount-1 do
                        if StrToInt(Cells[0,I])=SId then  NRow:=I;
                     if NRow<>-1 then
                        begin
                           MakeNewStr(NRow);
                           T:=Copy(NewStr,4,4);
                           InTime(T,NStar);
                           Delete(NewStr,23,3);
                           Insert(Jsb,NewStr,23);
                           S:='T';
                           DoCount(TCount,T);
                           Add_Drop_To_File(NewStr,S,NStar,Nmbr,Offset,TCount);
                        end;
                  end;
            end;
      end;
end;


procedure TForm8.BreakBoxDrawItem(Control: TWinControl; Index: Integer;
  Rect: TRect; State: TOwnerDrawState);
var
   S,T:string;
begin
   with BreakBox do
      begin
         S:='  '+Copy(Items[Index],5,Length(Items[Index])-4);
         T:=Copy(Items[Index],4,1);
         if T='H' then Canvas.Font.Color:=HourlyColor
         else if T='M' then Canvas.Font.Color:=MinorColor
         else if T='F' then Canvas.Font.Color:=FifteenColor
         else if T='S' then Canvas.Font.Color:=SpecialColor
         else if T='T' then Canvas.Font.Color:=FamColor;
         Canvas.FillRect(Rect);
         Canvas.TextOut(Rect.Left,Rect.Top,S);
      end;
end;

end.
