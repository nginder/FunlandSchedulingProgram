unit Funsort;
 {change this unit to do break schedule - I hope!}
interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Grids, StdCtrls, Fungrid, Db , ExtCtrls, FunCombo, Printers, System.UITypes,
  FunPrintDef, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Comp.Client, FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.Comp.DataSet,
  FireDAC.Phys, FireDAC.VCLUI.Wait, FireDAC.DApt;

type
  TForm7 = class(TForm)
    SchG1: TStringGrid;
    Button1: TButton;
    Label5: TLabel;
    JobG1: TStringGrid;
    BreakGrid: TStringGrid;
    BG1: TStringGrid;
    Button2: TButton;
    Button3: TButton;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Button4: TButton;
    RowGrid: TStringGrid;
    Query1: TFDQuery;
    Query2: TFDQuery;
    Query3: TFDQuery;
    procedure Button2Click(Sender: TObject);
    procedure BreakGridDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure Button3Click(Sender: TObject);
    procedure BreakGridDblClick(Sender: TObject);
    procedure BG1DblClick(Sender: TObject);
    procedure BG1TopLeftChanged(Sender: TObject);
    procedure BreakGridTopLeftChanged(Sender: TObject);
    procedure BreakGridDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure BreakGridDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure SchG1DrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect;
      State: TGridDrawState);
    procedure JobG1DrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect;
      State: TGridDrawState);
    procedure Button4Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure JobG1TopLeftChanged(Sender: TObject);
    procedure SchG1TopLeftChanged(Sender: TObject);
    procedure MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure SchG1SelectCell(Sender: TObject; Col, Row: Integer;
      var CanSelect: Boolean);
    procedure JobG1SelectCell(Sender: TObject; Col, Row: Integer;
      var CanSelect: Boolean);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form7: TForm7;
  Acceptance:string[1];
  BreakDate:string;
  FivCol,SevCol,BrkCol:integer;  {these hold column no.'s for break info}
  BreakName,BreakTime:string;    {drag and drop data}
  BreakerRow,BreakRow:integer;
  Avs:integer; {Available break slots}
  Nbs:integer; {Needed break slots}
  RSp,CSp,CFt,TM,Cols1,Cols2,Roes1,Roes2,Fon1,Fon2,Fon3,Wd,DaysAgo:integer;
  PL,PW,PagesD:integer;   {Printer page length, wide, no.of pages down}
  LFlag,RFlag:boolean;     {Breaker printer flags for left and right grids}

procedure GetColor(SchNam:string; var Shf:string);
 
implementation

{$R *.DFM}

var
   DisplayCols,ACol,ARow,PosCount,Step,SortIndex:integer;
   ShowForm16,MemoNotList:boolean;

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

procedure GetJob(var Row,Jb:integer);
{get job info from JobG1}
{Jb is job as integer}
var
   S,Jsb:string;
begin
   with Form7 do
     begin
        S:=JobG1.Cells[0,Row];
        Jsb:=Copy(S,Length(S)-2,3);
        Jb:=StrToInt(Jsb);
     end;
end;

function TrainCheck(Nam,Job:integer):boolean;
{check training status of breaker for job}
begin

end;

procedure HeightAdjust;
{adjust height of SchG1 and JobG1 }
begin
   with Form7 do with SchG1 do
      begin
         RowCount:=JobG1.RowCount;
         Height:=RowCount*(DefaultRowHeight+1)+5;
         if Height+Top>Form7.Height then
            Height:=Form7.Height-35-Top;
         JobG1.Height:=Height;
         BreakGrid.Height:=Height;
         BG1.Top:=Top;
         BG1.Height:=Height;
      end;
end;

procedure TForm7.JobG1TopLeftChanged(Sender: TObject);
begin
   JobG1.LeftCol:=0;
   SchG1.TopRow:=JobG1.TopRow;
end;

procedure TForm7.SchG1TopLeftChanged(Sender: TObject);
begin
   BreakGrid.LeftCol:=0;
   if SchG1.TopRow<>JobG1.Top then
      if SchG1.TopRow<=JobG1.RowCount-19 then
         begin
            JobG1.TopRow:=SchG1.TopRow;
            BreakGrid.TopRow:=JobG1.TopRow;
         end
      else
         begin
            SchG1.TopRow:=JobG1.RowCount-19;
            JobG1.TopRow:=JobG1.RowCount-19;
            BreakGrid.TopRow:=JobG1.TopRow-19;
         end;
end;

procedure TForm7.FormActivate(Sender: TObject);
var
   S:string;
begin
   with Form13 do
      begin
         Query1.Connection:=funland;
         Query2.Connection:=funland;
         Query3.Connection:=funland;
      end;
   Label1.Visible:=false;
   Label2.Visible:=false;
   Label3.Visible:=false;
   Form7.Caption:='Break Schedule for: '+BreakDate;
   with Form7 do
      begin
         with SchG1 do   {setup breaks grid defaults}
           begin
              ColCount:=1;
              DefaultColWidth:=80;
              DefaultRowHeight:=16;
              FixedCols:=0;
              FixedRows:=1;
              Height:=362;
              ScrollBars:=ssNone;
              Left:=101;
              Top:=24;
              Width:=80;
              Enabled:=true;
           end;
        with JobG1 do {setup job grid defaults}
           begin
              ColCount:=1;
              DefaultColWidth:=80;
              DefaultRowHeight:=16;
              Enabled:=true;
              FixedCols:=0;
              FixedRows:=1;
              Height:=344;
              Left:=4;
              ScrollBars:=ssVertical;
              Top:=24;
              Width:=97;
           end;
        with BreakGrid do {setup break grid defaults}
           begin
              ColCount:=3;
              DefaultColWidth:=80;
              DefaultRowHeight:=16;
              Enabled:=true;
              FixedCols:=0;
              FixedRows:=1;
              Height:=344;
              Left:=185;
              ScrollBars:=ssNone;
              Top:=24;
              Width:=160;
              RowCount:=JobG1.RowCount;
              Cells[0,0]:='Breaker';
              Cells[1,0]:='Time';
           end;
        with BG1 do {setup breaker grid defaults}
           begin
              ColCount:=4;
              DefaultColWidth:=80;
              DefaultRowHeight:=16;
              Enabled:=true;
              FixedCols:=0;
              FixedRows:=1;
              Height:=344;
              Left:=400;
              ScrollBars:=ssVertical;
              Top:=24;
              Width:=250;
              Cells[0,0]:='Time';
              Cells[1,0]:='To Break';
              Cells[2,0]:='Location';
           end;
        end;
   SchG1.Cells[0,0]:='7:00-';
   HeightAdjust;
   Repaint;
   Application.ProcessMessages;
   with Query2 do
      begin
         Close;
         Sql.Clear;
         Sql.Add('select Name from "FUNJOBS.DB"');
         Sql.Add('where Type="R" and Num2="1"');
         Open;
         First;
         RowGrid.RowCount:=0;
         if RecordCount>0 then
            repeat
               S:=FieldByName('Name').AsString;
               Query3.Close;
               Query3.Sql.Clear;
               Query3.SQL.Add('select Name from "FunJOBs.DB"');
               S:='where Type="I" and Num1='+S;
               Query3.SQL.Add(S);
               Query3.Open;
               if Query3.RecordCount>0 then
                  begin
                     RowGrid.RowCount:=RowGrid.RowCount+1;
                     RowGrid.Cells[0,RowGrid.RowCount]:=Query3.FieldByName('Name').AsString;
                  end;
               Next;
            until eof=true;
         Query2.Close;
         Query3.Close;
      end;
end;

procedure TForm7.MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
   ACol,ARow,I,J:integer;
   S:string;
begin
  BG1.MouseToCell(X,Y,ACol,ARow);
  if (Sender=BG1) and (Button = mbLeft) then with Sender As TStringGrid do
     begin    {begin drag from BG1 to BreakGrid}
        if (BG1.Cells[0,ARow]<>'') and (Pos('>',BG1.Cells[0,ARow])=0)
           and (BG1.Cells[1,ARow]='') and (BG1.Cells[2,ARow]='')
          then
             begin
                begindrag(false);
                BreakerRow:=ARow;
                BreakTime:=BG1.Cells[0,ARow];
                I:=ARow-(ARow mod 7)+1;
                S:=BG1.Cells[0,I];
                BreakName:=Copy(S,2,Length(S)-1);
             end;
     end;
   if (Sender=BG1) and (Button = mbRight) then with Sender As TStringGrid do
     begin    {delete initiated from BG1 }
        if BG1.Cells[1,ARow]<>'' then
           begin
              J:=StrToInt(BG1.Cells[3,ARow]);
              BreakGrid.Cells[0,J]:='';
              BreakGrid.Cells[1,J]:='';
              BreakGrid.Cells[2,J]:='';
              BG1.Cells[1,ARow]:='';
              BG1.Cells[2,ARow]:='';
              BG1.Cells[3,ARow]:='';
           end;
     end;
    if (Sender=BreakGrid) and (Button = mbRight) then with Sender As TStringGrid do
     begin    {delete initiated from BreakGrid }
        if BreakGrid.Cells[0,ARow]<>'' then
           begin
              S:=BreakGrid.Cells[2,ARow];
              BreakGrid.Cells[0,ARow]:='';
              BreakGrid.Cells[1,ARow]:='';
              if S<>'J' then
                 begin
                    J:=StrToInt(BreakGrid.Cells[2,ARow]);
                    BG1.Cells[1,J]:='';
                    BG1.Cells[2,J]:='';
                    BG1.Cells[3,J]:='';
                 end;
              BreakGrid.Cells[2,ARow]:='';
           end;
     end;
    if (Sender=SchG1) and (Button= mbLeft) then with Sender As TStringGrid do
       begin  {begin drag from SchG1 to BreakGrid here}
          SchG1.MouseToCell(X,Y,ACol,ARow);
          BreakName:=SchG1.Cells[ACol,ARow];
          begindrag(false);
       end;
end;

procedure TForm7.SchG1SelectCell(Sender: TObject; Col, Row: Integer;
  var CanSelect: Boolean);
begin
   ACol:=Col;
   ARow:=Row;
end;

procedure TForm7.JobG1SelectCell(Sender: TObject; Col, Row: Integer;
  var CanSelect: Boolean);
begin
   ARow:=Row;
   ACol:=Col;
end;

procedure TForm7.JobG1DrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
var
   S:string;
begin
   with JobG1 do
      begin
         S:=Cells[0,ARow];
         if S<>'' then
            begin
               Canvas.Font.Color:=clBlack;
               S:=Copy(S,1,Length(S)-4)+'                      ';
               Canvas.TextOut(Rect.Left+2,Rect.Top+2,S);
            end;
      end;
end;

procedure GetColor(SchNam:string; var Shf:string);
   {get shift as string for schedname S from employ.db}
var
   S:string;
begin
   Shf:='';
   with Form7 do
      begin
         with Query1 do      {Get shift}
            begin
               Close;
               Sql.clear;
               Sql.Add('Select Shift');
               S:='from "employ.db" ';
               Sql.Add(S);
               S:='where SchedName="'+SchNam+'"';
               Sql.Add(S);
               Open;
               First;
               if RecordCount>0 then
                     Shf:=Copy(FieldByName('Shift').AsString,1,1);
               Close;
            end;
      end;
end;

procedure TForm7.SchG1DrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
var
   S,T:string;
begin
   with SchG1 do if ARow>0 then
      begin
         Canvas.FillRect(Rect);
         S:=Cells[0,ARow];
         if S<>'' then
            begin
               GetColor(S,T);
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
              if Cells[1,ARow]='1' then
                  begin
                     Canvas.Brush.Color:=clMoneyGreen;
                  end
             else if Cells[1,ARow]='2' then
                  begin
                     Canvas.Brush.Color:=clFuchsia;
                  end;
              Canvas.FillRect(Rect);
              Canvas.TextOut(Rect.Left,Rect.Top,S);
            end;
      end;
end;

procedure TForm7.BreakGridDragOver(Sender, Source: TObject; X, Y: Integer;
  State: TDragState; var Accept: Boolean);
begin
   Accept:=false;
   if ((Source=BG1) or (Source=SchG1)) and (X>0) then with BreakGrid do
      begin
         MouseToCell(X,Y,ACol,ARow);
         if (Cells[0,ARow]='') and (Cells[1,ARow]='') then
            Accept:=true;
      end;
end;

procedure FillTimeBox;
{fill comboboxx CBox1 in Form19 with available times for this BreakName from SchG1}
var
   I:integer;
   TArray:array[1..6] of integer;
begin
   with Form7 do
      begin
         Form19.CBox1.Items.Clear;
         for I:=1 to 6 do TArray[I]:=1;
         For I:=1 to BreakGrid.RowCount-1 do
           if BreakGrid.Cells[0,I]=BreakName then
            begin
               if BreakGrid.Cells[1,I]='7:30' then TArray[1]:=0
                  else if BreakGrid.Cells[1,I]='8:00' then TArray[2]:=0
                  else if BreakGrid.Cells[1,I]='8:30' then TArray[3]:=0
                  else if BreakGrid.Cells[1,I]='9:00' then TArray[4]:=0
                  else if BreakGrid.Cells[1,I]='9:30' then TArray[5]:=0
                  else if BreakGrid.Cells[1,I]='10:00' then TArray[6]:=0;
            end;
         for I:=1 to 6 do if TArray[I]=1 then
            case I of
               1:Form19.CBox1.Items.Add('7:30');
               2:Form19.CBox1.Items.Add('8:00');
               3:Form19.CBox1.Items.Add('8:30');
               4:Form19.CBox1.Items.Add('9:00');
               5:Form19.CBox1.Items.Add('9:30');
               6:Form19.CBox1.Items.Add('10:00');
              end;
      end;
end;

procedure TForm7.BreakGridDragDrop(Sender, Source: TObject; X, Y: Integer);
var
   ChkJob,ChkNam:integer;
   S:string;
   Flag:boolean;
   NRect:TRect;
begin
   if Sender is TStringGrid then with BreakGrid do
      begin
         Flag:=true;
         MouseToCell(X,Y,ACol,ARow);
         S:=JobG1.Cells[ACol,ARow];
         ChkJob:=StrToInt(Copy(S,Length(S)-2,3));
         S:=BreakName;
         GetNum(S);
         ChkNam:=StrToInt(S);
         If Traine[ChkNam,ChkJob]<1 then
            begin
               S:='Breaker not trained for this job!'+#10+'Continue anyway?';
               if MessageDlg(S,mtWarning,[mbYes,mbNo],0)=mrNo then Flag:=false;
            end;
         if Flag=true then
            begin
               BreakGrid.Cells[0,ARow]:=BreakName;
               if Source=BG1 then
                  begin
                     BreakGrid.Cells[1,ARow]:=BreakTime;
                     BreakGrid.Cells[2,ARow]:=IntToStr(BreakerRow);
                     BG1.Cells[1,BreakerRow]:=SchG1.Cells[0,ARow];
                     BG1.Cells[2,BreakerRow]:=Copy(JobG1.Cells[0,ARow],1,Length(JobG1.Cells[0,ARow])-4);
                     BG1.Cells[3,BreakerRow]:=IntToStr(ARow);
                  end
               else if Source=SchG1 then
                  begin
                     FillTimeBox;
                     if Form19.CBox1.Items.Count>0 then
                         begin
                            NRect:=BreakGrid.CellRect(1,ARow);
                            NewTop:=BreakGrid.Top+NRect.Top;
                            NewLeft:=BreakGrid.Left+NRect.Left;
                            BreakGrid.Cells[2,ARow]:='J';
                            BreakRow:=ARow;
                            Form19.ShowModal;
                            BreakGrid.Cells[1,ARow]:=TimeSel;
                         end
                     else
                        Cells[0,ARow]:='';
                  end;
            end;
      end;
end;

procedure TForm7.BreakGridTopLeftChanged(Sender: TObject);
begin
   with BreakGrid do if  Col<>0 then Col:=0;
end;

procedure TForm7.BG1TopLeftChanged(Sender: TObject);
begin
   with BG1 do if  Col<>0 then Col:=0;
end;

procedure TForm7.BG1DblClick(Sender: TObject);
begin
   with BG1 do
      if (Col=1) and (Row mod 7 <>1) then
      if Cells[1,Row]='XXXXXX' then
            Cells[1,Row]:=''
      else if Cells[1,Row]='' then
            Cells[1,Row]:='XXXXXX'
end;

procedure TForm7.BreakGridDblClick(Sender: TObject);
begin
    with BreakGrid do
      if Col=0 then
      if Cells[0,Row]='XXXXXX' then
         begin
            Cells[0,Row]:='';
            Cells[1,Row]:='';
            Cells[2,Row]:='';
         end
      else if Cells[0,Row]='' then
         begin
            Cells[0,Row]:='XXXXXX';
            Cells[2,Row]:='J';
         end;
end;

procedure TForm7.Button3Click(Sender: TObject);
{do autofill here}
var
   I,J,BrkPtr,NBrkrs,Level,BTim,SPtr,CNam,CJob,Ans:integer;
   S,T,BNam:string;
   Flag,TFlag,BFlag,SkipFlag:boolean;
   M:integer;
begin

   Avs:=0;
   Nbs:=0;
   SkipFlag:=false;
   with BG1 do
      for I:=1 to RowCount-1 do
         if (Cells[1,I]='') and ((I mod 7)<>1) and (Cells[0,I]<>'') then
            Avs:=Avs+1;
   with BreakGrid do
      for I:=1 to RowCount-1 do
         if Cells[1,I]='' then Nbs:=Nbs+1;
    NBrkrs:= (BG1.RowCount-1) div 7;
    Label1.Caption:='Available breakers= '+IntToStr(NBrkrs);
    Label2.Caption:='Available breaker slots= '+IntToStr(Avs);
    Label3.Caption:='Empty break slots to be filled= '+IntToStr(Nbs);
    Label1.Visible:=true;
    Label2.Visible:=true;
    Label3.Visible:=true;
    S:='Do autofill with training check on?';
    Ans:=MessageDlg(S,mtWarning,[mbYes,mbNo,mbYestoAll],0);
    if Ans=mrYes then TFlag:=true
       else if Ans=mrNo then TFlag:=false
       else if Ans=mrYesToAll then
           begin
              SkipFlag:=true;
              TFlag:=true;
           end;
    if (Nbs>0) and (Avs>0) then {while (Nbs>0) and (Avs>0) do}
       begin
          for I:=2 to 7 do for J:=1 to NBrkrs do    {check all six break spots for each breaker}
             begin
                BTim:=((J-1)*7)+I;        {BTim is current pointer to breaktime row in BG1}
                S:=BG1.Cells[0,((J-1)*7+1)];   {BNam is current breaker name}
                BNam:=Copy(S,2,Length(S)-1);
                if BG1.Cells[1,BTim]='' then        {if this breaker's time slot is available, cont.}
                   begin
                      Level:=1;         {Fill empty break slots by level 1-4}
                      BFlag:=false;    {BFlag will be true if match found}
                      Sptr:=1;          {SPtr is pointer in SchG1, BreakGrid}
                      repeat    {use Repeat loop to find first available BreakGrid spot for this BNam,BTim}
                         M:=StrToInt(SchG1.Cells[1,SPtr]);   {this 3-line kludge makes all level 4 breaks into level 3 breaks}
                         if M=4 then M:=3;
                         if (BreakGrid.Cells[0,SPtr]='') and (M=Level)then
                         {if (BreakGrid.Cells[0,SPtr]='') and (SchG1.Cells[1,SPtr]=IntToStr(Level)) then}   {if this slot in BreakGrid needs a breaker, cont.}
                            begin
                               Flag:=true;   {Flag is continue flag}
                               if TFlag=true then    {do this section if training check is active}
                                  begin
                                     S:=JobG1.Cells[0,SPtr];
                                     CJob:=StrToInt(Copy(S,Length(S)-2,3));
                                     T:=Copy(S,1,Length(S)-4);
                                     S:=BNam;
                                     GetNum(S);
                                     CNam:=StrToInt(S);
                                     if Traine[CNam,CJob]<1 then
                                        if SkipFlag=false then
                                           begin
                                              S:=BNam+' is not trained on'+T+'!'+#10+'Continue anyway?';
                                              Ans:=MessageDlg(S,mtWarning,[mbYes,mbNo,mbNoToAll],0);
                                              if Ans=mrNo then Flag:=false
                                                 else if Ans=mrYes then Flag:=true
                                                 else if Ans=mrNotoAll then
                                                    begin
                                                       Flag:=false;
                                                       SkipFlag:=true;
                                                    end;
                                           end
                                        else Flag:=false;
                                  end;
                               if Flag=true then    {continue here to fill info}
                                  begin
                                     BreakGrid.Cells[0,SPtr]:=BNam;
                                     BreakGrid.Cells[1,SPtr]:=BG1.Cells[0,BTim];
                                     BG1.Cells[1,BTim]:=SchG1.Cells[0,SPtr];
                                     BG1.Cells[2,BTim]:=Copy(JobG1.Cells[0,SPtr],1,Length(JobG1.Cells[0,SPtr])-4);
                                     BG1.Cells[3,BTim]:=IntToStr(SPtr);
                                     Nbs:=Nbs-1;
                                     Avs:=Avs-1;
                                     BFlag:=true;
                                  end;
                            end;
                          SPtr:=SPtr+1;
                          if SPtr>BreakGrid.RowCount-1 then
                             begin
                                Level:=Level+1;
                                Sptr:=1;
                             end;
                      until  (Level>4) or (BFlag=true);
                   end;
             end;
       end;
   Label2.Caption:='Available breaker slots= '+IntToStr(Avs);
   Label3.Caption:='Empty break slots to be filled= '+IntToStr(Nbs);
end;

procedure TForm7.BreakGridDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
var
    S:string;
begin
   with BreakGrid do if Cells[2,ARow]='J' then
      begin
         S:=Cells[ACol,ARow];
         Canvas.Brush.Color:=clBtnFace;
         Canvas.FillRect(Rect);
         Canvas.TextOut(Rect.Left,Rect.Top,S);
      end;
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
   TM:= 100;  {top margin}
   DisplayCols:=1;
   CSp:= 209; {spacing between columns}
   CFt:= 340; {width of 1st column}
   Wd:=2;   {pen width}
   RSp:=49; {spacing between rows}
   Fon1:= 12; {title font size}
   Fon2:= 10; {fixed row/col font size}
   Fon3:= 8; {name font size}
   Cols1:=(PW-Cft) div CSp;
   Cols2:=PW div CSp;
   Roes1:=(PL-TM) div RSp;   {# of rows available for printing on Page 1}
   Roes2:=PL div RSp;        {# of rows available for printing on Pages>1}
   I:=Form7.SchG1.RowCount-1;  {max no.of rows among all stringgrids}
   if I<Form7.BG1.RowCount-1 then I:=Form7.BG1.RowCount-1;
   PagesD:=1+(I-Roes1) div Roes2;       {calculate no. of pages down}
   if I mod Roes2  >0 then PagesD:=PagesD+1;
end;

Procedure PrintPage(Dow:integer);
   {print next page}
   {Dow is pages down;}

var
   I,K,L,M,Y,StartRow,EndRow,LineCount,FW,LH,RH,Offs:integer;
   S,T,Z:string;
   Flag:boolean;

begin
   with Form7 do
      begin
         if Dow=1 then                {set up beginning and ending rows}
            begin
               StartRow:=1;
               EndRow:=Roes1;
            end
         else
            begin
               StartRow:=Roes1+(Dow-2)*Roes2+1;
               EndRow:=StartRow+Roes2;
            end;
         Begindok;
         LineCount:=1;
         Wide(Wd);
         if Dow=1 then  {print title on first page across and down}
            begin
               Sise(Fon1);
               Stile([fsBold]);
               I:=DayOfWeek(StrToDate(SchedStr));
               case I of
                  1:S:='Sunday';
                  2:S:='Monday';
                  3:S:='Tuesday';
                  4:S:='Wednesday';
                  5:S:='Thursday';
                  6:S:='Friday';
                  7:S:='Saturday';
               end;
               S:=Form7.Caption+'  '+S;
               TextOwt(0,0,S);
            end;
         if Dow=1 then   {print column labels if first page down}
            begin
               Sise(Fon2);
               Stile([]);
               Y:=CFt;
               S:='7:00-';
               Offs:=(CSp-Printer.Canvas.TextWidth(S)) div 2;
               if Offs<0 then Offs:=0;
               TextOwt(Y+Offs,TM,S);        {print SchG label}
               S:='Breaker';                {print BreakGrid labels}
               Offs:=(CSp-Printer.Canvas.TextWidth(S)) div 2;
               if Offs<0 then Offs:=0;
               Y:=CSp+CFt;
               TextOwt(Y+Offs,TM,S);
               S:='Time';
               Offs:=(CSp-Printer.Canvas.TextWidth(S)) div 2;
               if Offs<0 then Offs:=0;
               Y:=CSp*2+CFt;
               TextOwt(Y+Offs,TM,S);
               S:='Time';
               Offs:=(CSp-Printer.Canvas.TextWidth(S)) div 2;
               if Offs<0 then Offs:=0;
               Y:=CSp*4+CFt;
               TextOwt(Y+Offs,TM,S);
               S:='To Break';
               Offs:=(CSp-Printer.Canvas.TextWidth(S)) div 2;
               if Offs<0 then Offs:=0;
               Y:=CSp*5+CFt;
               TextOwt(Y+Offs,TM,S);
               S:='Location';
               Offs:=(CSp-Printer.Canvas.TextWidth(S)) div 2;
               if Offs<0 then Offs:=0;
               Y:=CSp*6+CFt;
               TextOwt(Y+Offs,TM,S);
            end;
         Stile([]);
         Movetwo(0,TM);                          {print top lines}
         FW:=3*Csp+CFt;
         Linetwo(FW,TM);
         FW:=4*Csp+CFt;
         Movetwo(FW,TM);
         FW:=7*Csp+CFt;
         Linetwo(FW,TM);
         S:='';
         I:=StartRow;
         repeat     {print row labels from JObG1 and name data from SchG1 + horizontal lines}
            K:=LineCount*RSp+TM;   {K is calculated X coordinate for this line}
            {if Dow<>1 then K:=K-Rsp; }
            if (LFlag=true) then  {if LFlag=true then left grid is still active}
               begin
                  if S<>JobG1.Cells[0,I] then with JobG1 do   {print job labels on left-most pages}
                     begin                                   {if diff.job than last row, print job label}
                        Sise(Fon2);
                        Stile([]);
                        Z:=Cells[0,I];
                        M:=Pos('<',Z);
                        if M>0 then Z:=Copy(Z,1,M-1);
                        TextOwt(5,K,Z);
                        Movetwo(0,K);
                        Y:=CSp*3+CFt;
                        Linetwo(Y,K);
                        S:=Cells[0,I];
                    end;
                  if SchG1.Cells[0,I]<>'' then with SchG1 do          {print SChG1 entry}
                     begin
                        T:=Cells[0,I];
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
                        Y:=CFt;
                        Sise(Fon3);
                        Stile([]);
                        T:=Cells[0,I];
                        Offs:=(CSp-Printer.Canvas.TextWidth(T)) div 2;
                        if Offs<0 then Offs:=0;
                        TextOwt(Y+Offs,K+5,T);
                        Printer.Canvas.Font.Color:=clBlack;
                     end;
                 if BreakGrid.Cells[0,I]<>''then with BreakGrid do          {print BreakGrid entries}
                     begin
                        if (SchG1.Cells[1,I]='1')or (SchG1.Cells[1,I]='2') then
                          begin
                             if SchG1.Cells[1,I]='1' then Printer.Canvas.Font.Color:=clGreen
                                else Printer.Canvas.Font.Color:=clFuchsia;
                          end;
                        Y:=CSp+CFt;
                        Sise(Fon3);
                        Stile([]);
                        T:=BreakGrid.Cells[0,I];
                        Offs:=(CSp-Printer.Canvas.TextWidth(T)) div 2;
                        if Offs<0 then Offs:=0;
                        TextOwt(Y+Offs,K+5,T);
                        Printer.Canvas.Font.Color:=clBlack;
                        T:=Cells[1,I];
                        if T<>'' then
                           begin
                              Y:=CSp*2+CFt;
                              Offs:=(CSp-Printer.Canvas.TextWidth(T)) div 2;
                              if Offs<0 then Offs:=0;
                              TextOwt(Y+Offs,K+5,T);
                           end;
                      end;
               end;
            if RFlag=true then
               if BG1.Cells[0,I]<>''then with BG1 do         {print BG1 entries}
                  begin
                     T:=Cells[0,I];
                     Y:=4*CSp+CFt;
                     Sise(Fon3);
                     Stile([]);
                     T:=Cells[0,I];
                     Offs:=(CSp-Printer.Canvas.TextWidth(T)) div 2;
                     if Offs<0 then Offs:=0;
                     TextOwt(Y+Offs,K+5,T);
                     T:=Cells[1,I];
                     if T<>'' then
                        begin
                           Y:=CSp*5+CFt;
                           Offs:=(CSp-Printer.Canvas.TextWidth(T)) div 2;
                           if Offs<0 then Offs:=0;
                           TextOwt(Y+Offs,K+5,T);
                        end;
                      T:=Cells[2,I];
                      if T<>'' then
                        begin
                           Y:=CSp*6+CFt;
                           Offs:=(CSp-Printer.Canvas.TextWidth(T)) div 2;
                           if Offs<0 then Offs:=0;
                           TextOwt(Y+Offs,K+5,T);
                        end;
                     Y:=CSp*4+CFt;
                     Movetwo(Y,K);
                     Linetwo(FW,K);
                     Printer.Canvas.Font.Color:=clBlack;
                  end;
            Inc(I);
            if (I>BG1.RowCount) and (RFlag=true) then
               begin
                  RFlag:=false;
                  RH:=(LineCount)*RSp+TM;
               end;
            if (I>SchG1.RowCount) and (LFlag=true) then
               begin
                  LFlag:=false;
                  LH:=(LineCount)*RSp+TM;
               end;
            Inc(LineCount);
         until (I>EndRow) or ((LFlag=false) and (RFlag=false));
         if LFlag=true then LH:=(LineCount)*RSp+TM;
         if RFlag=true then RH:=(LineCount)*RSp+TM;
         {FH:=(LineCount)*RSp+TM;}
         MoveTwo(0,TM);             {print vertical lines here for left grid}
         LineTwo(0,LH);
         Y:=CSp+Cft;
         MoveTwo(Y,TM);
         LineTwo(Y,LH);
         Y:=CSp*3+Cft;
         MoveTwo(Y,TM);
         LineTwo(Y,LH);
         Y:=CSp*4+Cft;           {print vertical lines here for right grid}
         MoveTwo(Y,TM);
         LineTwo(Y,RH);
         MoveTwo(FW,TM);     {last vertical line}
         LineTwo(FW,RH);
         MoveTwo(0,LH);     {print last left horizontal line}
         Y:=CSp*3+CFt;
         LineTwo(Y,LH);
         Y:=CSp*4+CFt;      {print last right horizontal line}
         MoveTwo(Y,RH);
         LineTwo(FW,RH);
         Enddok;
      end;
end;

procedure TForm7.Button1Click(Sender: TObject);
   {print break schedule button}
var
   I,K:longint;
   S:string;
begin
   LFlag:=true;       {true while BreakGrid still printing}
   RFlag:=true;       {true while BG1 still printing}
   CalcPrintParams;
   Form18.ShowModal;
   if PagesD=1 then S:='on a single page.'
   else S:='one page across and '+IntToStr(PagesD)+' pages down.';
   S:='This schedule will be printed '+S;
   if MessageDlg(S,mtConfirmation,[mbYes,mbNo],0)=mrYes then
      begin
         PXPY;
         I:=0;
         repeat
            Inc(I);
            S:='Print page down= '+IntToStr(I)+' ?';
            K:=MessageDlg(S,mtConfirmation,mbYesNoCancel,0);
            if K=mrYes then
               begin
                  PrintPage(I);
               end
            else if K=mrCancel then I:=PagesD;
         until I>=PagesD;
      end;
end;


procedure TForm7.Button2Click(Sender: TObject);
   {close button}
begin
   Close;
end;

procedure TForm7.Button4Click(Sender: TObject);
  {print break sheets here}
const
   LM =  94;  {left margin}
   TM =  56;  {top margin}
   XSp = 225; {spacing between grids - horizontal}
   YSp = 150; {spacing between grids - vertical}
   RH1 = 75;  {Row height for name row}
   RH2 = 60;  {Row height for label row}
   RH3 = 80;  {Row height for data rows}
   Rh4 = 160; {Row height for notes row}
   CW1 = 262; {Column width for time column}
   CW2 = 394; {Column width for to break and location columns}
   GW = 1050; {Grid width}
   GH = 844;  {Grid height}

var
   I,J,L,Brkrs,Pags,Ans,RPtr,PPtr,VOffs,HOffs,Offset:integer;
   S,T:string;
   PFlag,SFlag,AFlag:boolean;   {PFlag is print this page flag; SFlag is stop pringting flag; AFlag is ask flag}
begin
   Query2.Open;
   with Form7 do with BG1 do
      begin
         Brkrs:=RowCount div 7;
         if Brkrs>0 then
            begin
               Pags:=Brkrs div 6;
               if Brkrs mod 6 >0 then Pags:=Pags+1;
               I:=1;
               PFlag:=true;
               AFlag:=true;
               SFlag:=false;
               PXPY;
               Fon1:= 12; {name font size}
               Fon2:= 10; {break info font size}
               Fon3:= 8; {notes font size}
               repeat
                  if AFlag=true then
                     begin
                        S:='Print Page '+IntToStr(I)+' of '+IntToStr(Pags)+' Pages?';
                        Ans:=MessageDlg(S,mtWarning,[mbYes,mbNo,mbYestoAll,mbCancel],0);
                           if Ans=mrCancel then SFlag:=true
                            else if Ans=mrNo then PFlag:=false
                             else if Ans=mrYesToAll then
                                begin
                                   AFlag:=false;
                                   PFlag:=true;
                                end;
                     end;
                  if (SFlag=false) and (PFlag=true) then  {print next page here}
                     begin
                        begindok;
                        PPtr:=1;  {PPtr is current grid being printed}
                        RPtr:=(I-1)*42+1;    {RPtr is pointer to current entry in BG1}
                        repeat
                           if RPtr<=RowCount-7 then  {if at least one full set of breaker entries left}
                              begin            {then print a grid}
                                 if PPtr in [2,4,6] then HOffs:=LM+1050+XSp
                                    else HOffs:=LM;
                                 case PPtr of
                                    1..2:VOffs:=TM;
                                    3..4:VOffs:=TM+Ysp+GH;
                                    5..6:VOffs:=TM+2*(YSp+GH);
                                   end;
                                 Printer.Canvas.Pen.Width:=10;
                                 MoveTwo(HOffs,VOffs);          {draw grid rectangle here}
                                 LineTwo(HOffs+GW,VOffs);
                                 LineTwo(HOffs+GW,VOffs+GH);
                                 LineTwo(HOffs,VOffs+GH);
                                 LineTwo(HOffs,VOffs);
                                 MoveTwo(HOffs,VOffs+RH1);       {draw grid horizontal lines here}
                                 LineTwo(HOffs+GW,VOffs+RH1);
                                 MoveTwo(HOffs,VOffs+RH1+RH2);
                                 LineTwo(HOffs+GW,VOffs+RH1+RH2);
                                 MoveTwo(HOffs,VOffs+RH1+RH2+RH3);
                                 LineTwo(HOffs+GW,VOffs+RH1+RH2+RH3);
                                 MoveTwo(HOffs,VOffs+RH1+RH2+(2*RH3));
                                 LineTwo(HOffs+GW,VOffs+RH1+RH2+(2*RH3));
                                 MoveTwo(HOffs,VOffs+RH1+RH2+(3*RH3));
                                 LineTwo(HOffs+GW,VOffs+RH1+RH2+(3*RH3));
                                 MoveTwo(HOffs,VOffs+RH1+RH2+(4*RH3));
                                 LineTwo(HOffs+GW,VOffs+RH1+RH2+(4*RH3));
                                 MoveTwo(HOffs,VOffs+RH1+RH2+(5*RH3));
                                 LineTwo(HOffs+GW,VOffs+RH1+RH2+(5*RH3));
                                 MoveTwo(HOffs,VOffs+RH1+RH2+(6*RH3));
                                 LineTwo(HOffs+GW,VOffs+RH1+RH2+(6*RH3));
                                 MoveTwo(HOffs+CW1,VOffs+RH1);    {draw grid vertical lines}
                                 LineTwo(HOffs+CW1,VOffs+RH1+RH2+(6*RH3));
                                 MoveTwo(HOffs+CW1+CW2,VOffs+RH1);
                                 LineTwo(HOffs+CW1+CW2,VOffs+RH1+RH2+(6*RH3));
                                 Printer.Canvas.Pen.Width:=1;
                                 Sise(Fon1);
                                 Stile([fsBold]);
                                 S:=Cells[0,RPtr];
                                 T:=Copy(S,2,Length(S)-1);
                                 Offset:=(GW-(Printer.Canvas.TextWidth(T) div 2)) div 2;
                                 if Offset<0 then Offset:=0;
                                 TextOwt(HOffs+Offset,VOffs+2,T);       {print name row here}
                                 Stile([]);
                                 RPtr:=RPtr+1;
                                 Sise(Fon2);
                                 S:='TIME';
                                 Offset:=(CW1-(Printer.Canvas.TextWidth(S) div 2)) div 2;
                                 if Offset<0 then Offset:=0;
                                 TextOwt(HOffs+Offset,VOffs+RH1+5,S);
                                 S:='TO BREAK';
                                 Offset:=(CW2-(Printer.Canvas.TextWidth(S) div 2)) div 2;
                                 if Offset<0 then Offset:=0;
                                 TextOwt(HOffs+CW1+Offset,VOffs+RH1+5,S);
                                 S:='LOCATION';
                                 Offset:=(CW2-(Printer.Canvas.TextWidth(S) div 2)) div 2;
                                 if Offset<0 then Offset:=0;
                                 TextOwt(HOffs+CW1+CW2+Offset,VOffs+RH1+5,S);  {print label line here}
                                 Sise(Fon2);
                                 for J:=1 to 6 do
                                    begin   {print data rows here + Notes row}
                                       case J of
                                          1:S:='7:30-8';
                                          2:S:='8-8:30';
                                          3:S:='8:30-9';
                                          4:S:='9-9:30';
                                          5:S:='9:30-10';
                                          6:S:='10-10:30';
                                         end;
                                       Offset:=(CW1-(Printer.Canvas.TextWidth(S) div 2)) div 2;
                                       if Offset<0 then Offset:=0;
                                       TextOwt(HOffs+Offset,VOffs+RH1+RH2+((J-1)*RH3)+7,S);
                                       S:=Cells[1,RPtr];
                                       if (S<>'') and (S<>'XXXXXX') then  {Print 'To Break' here}
                                           begin
                                              Offset:=(CW2-(Printer.Canvas.TextWidth(S) div 2)) div 2;
                                              if Offset<0 then Offset:=0;
                                              TextOwt(HOffs+Offset+CW1,VOffs+RH1+RH2+((J-1)*RH3)+7,S);
                                           end;
                                       S:=Cells[2,RPtr];                   {Print 'Location' here}
                                       if (S<>'') and (S<>'XXXXXX') then
                                           begin
                                               with RowGrid do if RowCount>0 then
                                                  begin
                                                     L:=1;
                                                     repeat
                                                        if S=Cells[0,L] then
                                                           S:='Kiddie Row';
                                                        Inc(L);
                                                     until (L>RowCount) or (S='Kiddie Row');
                                                  end;
                                              Offset:=(CW2-(Printer.Canvas.TextWidth(S) div 2)) div 2;
                                              if Offset<0 then Offset:=0;
                                              TextOwt(HOffs+Offset+CW1+CW2,VOffs+RH1+RH2+((J-1)*RH3)+7,S);
                                           end;
                                       RPtr:=RPtr+1;
                                       if J=6 then
                                          begin
                                             S:='Notes:';
                                             TextOwt(HOffs+10,VOffs+RH1+RH2+(J*RH3)+5,S);
                                          end;
                                     end;
                              end;
                           PPtr:=PPtr+1;
                        until (RPtr>=RowCount) or (PPtr>6);
                        enddok;
                     end;
                  PFlag:=true;
                  I:=I+1;
               until (PFlag=false) or (I>Pags);
           end;
      end;
   Query2.Close;
end;

end.
