unit Funclockin;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Grids,FunGrid, Spin;

const
    NoYt = 'Not Yet clocked In';
    ClkI = 'Clocked In           ';
    ClkO = 'Clocked Out          ';
type
  TForm20 = class(TForm)
    Button5: TButton;
    Label10: TLabel;
    ClockGrid: TStringGrid;
    Label1: TLabel;
    CB1: TComboBox;
    SB1: TSpinButton;
    procedure SB1UpClick(Sender: TObject);
    procedure SB1DownClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ClockGridMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ClockGridDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure ClockGridTopLeftChanged(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure Button5Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form20: TForm20;
  ThisCol,ThisRow:integer;
  ThisOldTime:string;
  MRect:TRect;
  SavFlag:boolean;
  
implementation

{$R *.dfm}

procedure TForm20.Button5Click(Sender: TObject);
begin
   Close;
end;

procedure GetFullName(var S:string);
   {S=Employee Id; return w/S=Employee full name from ColorGrid}
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
              try
                 I:=StrToInt(Cells[0,K]);
              except
              end;
              if I=J then
                 begin
                    Flag:=true;
                    S:=Cells[3,K]+' '+Cells[4,K];
                 end;
              Inc(K);
           until (Flag=true) or (K>=RowCount+1);
        end;
   if Flag=false then S:='';
end;

procedure FillClockGrid;
{fill ClockGrid from Form13.Queue}
var
   I,J,Ind:integer;
   S,T:string;
   Flag:boolean;
begin
   Form20.ClockGrid.RowCount:=Form13.Queue.RowCount;
   with Form20.ClockGrid do if Form13.Queue.RowCount>1 then
      begin
         I:=1;
         repeat
             S:=Form13.Queue.Cells[1,I-1];  {copy id no.}
             GetFullName(S);
             Cells[0,I]:=S;
             Cells[1,I]:=Form13.Queue.Cells[2,I-1];  {copy start time}
             S:=Form13.Queue.Cells[3,I-1];           {get old first field}
             T:=Copy(S,4,4);
             Cells[2,I]:=T;
             T:=Copy(S,8,4);
             Cells[3,I]:=T;
             Cells[4,I]:=Copy(S,1,1);{get status char. from first field}
             Cells[5,I]:=Form13.Queue.Cells[0,I-1]; {copy rec no.}
             Cells[6,I]:=Form13.Queue.Cells[3,I-1];  {get rec.First to use for Undo}
             if I>1 then {sort by start time}
                begin
                   J:=StrToInt(Cells[1,I]);
                   Flag:=true;
                   Ind:=I-1;;
                   repeat
                      if J<StrToInt(Cells[1,Ind]) then
                         begin
                            Rows[RowCount+1]:=Rows[Ind];
                            Rows[Ind]:=Rows[Ind+1];
                            Rows[Ind+1]:=Rows[RowCount+1];
                         end
                      else Flag:=false;
                      Dec(Ind);
                   until (Ind<1) or (Flag=false);
                end;
             Inc(I);
         until (I>=Form13.Queue.RowCount)
      end;
end;

procedure TForm20.FormActivate(Sender: TObject);
var
   I:integer;
begin
   Left:=200;
   Width:=820;
   Height:=700;
   Top:=50;
   with ClockGrid do
      begin
         Left:=130;
         Top:=10;
         ColCount:=7;
         FixedRows:=1;
         Width:=(Col0+Col0)*2+3*(Col1+5);
         ColWidths[0]:=Col0+Col0;
         DefaultRowHeight:=Canvas.TextHeight('Test')+5;
         Height:=650;
         for I:=1 to 3 do
            ColWidths[I]:=Col1;
         ColWidths[4]:=Col0+Col0;
         FillClockGrid;
      end;
   with CB1 do
      begin
         Clear;
         AddItem(NoYt,nil);
         AddItem(ClkI,nil);
         AddItem(ClkO,nil);
      end;
   with SB1 do
       begin
          Visible:=false;
          Height:=ClockGrid.DefaultRowHeight;
          Width:=10;
       end;
   SavFlag:=false;
   ThisRow:=0;
end;

procedure DoATime(var S:string);
{process 4 char HHMM to hh:mm string}
var
   I:integer;
   PM:boolean;
   T,U:string;
begin
   I:=StrToInt(S);
   if (I<>9999) and (I<>0000) then
      begin
         I:=StrToInt(Copy(S,1,2));
         if I>=12 then
            begin
               PM:=true;
               I:=I-12;
            end
         else PM:=false;
         if I=0 then I:=12;
         T:=IntToStr(I);
         if I<10 then T:=' '+T;
         I:=StrToInt(Copy(S,3,2));
         U:=IntToStr(I);
         if I<10 then U:='0'+U;
         S:=T+':'+U;
         if PM=false then
            S:=S+'a';
      end
   else S:='';
end;

procedure TForm20.ClockGridTopLeftChanged(Sender: TObject);
begin
   if ClockGrid.LeftCol<>0 then ClockGrid.LeftCol:=0;
end;

procedure TForm20.ClockGridDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
 var
  S:string;
begin
   with ClockGrid do
      begin
         if ARow=0 then
            begin
              Canvas.Font.Style:=[fsBold];
               case ACol of
                0:S:='      Employee Name';
                1:S:='      Shift Time';
                2:S:='      Clock In';
                3:S:='      Clock Out';
                4:S:='      Status';
               end;

            end
         else
            begin
               Canvas.Font.Style:=[];
               S:=Cells[ACol,ARow]; {if ACol=0 then Employee Name}
               if (ACol>0) and (ACol<4) then {if ACol=1,2,3 do times}
                  DoATime(S)
               else    {if ACol=4 then do status}
                  begin
                     if Cells[ACol,ARow]='/' then S:='Off All Day'
                     else if Cells[ACol,ARow]='+' then
                        begin
                           S:=NoYt;
                           Canvas.Font.Color:=clRed;
                        end
                     else if Cells[ACol,ARow]='-' then
                        begin
                           S:=ClkI;
                           Canvas.Font.Color:=clBlue;
                        end
                     else if Cells[ACol,ARow]='*' then S:=ClkO;
                  end;
            end;
         S:=' '+S;
         Canvas.TextOut(Rect.Left,Rect.Top,S);
         Canvas.Font.Color:=clBlack;
      end;
end;

procedure SaveRecord;
{save modified record to yyyymmdd.txt}
var
   S,RecNo:string;
begin
   with Form20 do
      begin
         RecNo:=ClockGrid.Cells[5,ThisRow]; {get record number from clockgrid}
         S:=ClockGrid.Cells[4,ThisRow]+Copy(ClockGrid.Cells[6,ThisRow],2,2)
            +ClockGrid.Cells[2,ThisRow]+ClockGrid.Cells[3,ThisRow];
         Modify_Clock_Record(RecNo,S);
         SavFlag:=false;
      end;
end;

procedure SetSB1;
{set up spin button to change clock in or out times}
var
   S:string;
begin
   with Form20 do
      begin
         S:=ClockGrid.Cells[ThisCol,ThisRow];
         ThisOldTime:=S;
         SB1.Top:=ClockGrid.Top+MRect.Top+2;
         SB1.Left:=ClockGrid.Left+MRect.Left+Col1-10;
         SB1.Visible:=true;
         if CB1.Visible=true then CB1.Visible:=false;
      end;
end;

procedure SetCB1;
{set up combo box with status choices}
var
   S:string;
begin
   with Form20 do
      begin
         S:=ClockGrid.Cells[ThisCol,ThisRow];
         if S='+' then
             begin
                CB1.Text:=NoYt;
             end
         else if S='-' then
             begin
                CB1.Text:=ClkI;
             end
         else if S='*' then
             begin
                CB1.Text:=ClkO;
             end;
         CB1.Top:=ClockGrid.Top+MRect.Top+2;
         CB1.Left:=ClockGrid.Left+MRect.Left+2;
         CB1.Visible:=true;
         if SB1.Visible=true then SB1.Visible:=false;
      end;
end;

procedure CloseSB1;
{close out spin button w/ changed time}
begin
   with Form20 do
      begin
         SB1.Visible:=false;
         if ClockGrid.Cells[ThisCol,ThisRow]<>ThisOldTime then
            begin
               if Copy(ClockGrid.Cells[0,ThisRow],1,1)<>'*' then
                   ClockGrid.Cells[0,ThisRow]:='*'+ClockGrid.Cells[0,ThisRow];
               SavFlag:=true;  {save this change when row is changed or close occurs}
            end;
      end;
end;

procedure CloseCB1;
{close out combo box w/ changed status}
var
   S:string;
begin
   S:='';
   with Form20 do if CB1.Visible=true then
      begin
         if CB1.Text=NoYt then S:='+'
         else if CB1.Text=ClkI then S:='-'
         else if CB1.Text=ClkO then S:='*';
         if ClockGrid.Cells[ThisCol,ThisRow]<>S then
            begin
               ClockGrid.Cells[ThisCol,ThisRow]:=S;
               if Copy(ClockGrid.Cells[0,ThisRow],1,1)<>'*' then
                   ClockGrid.Cells[0,ThisRow]:='*'+ClockGrid.Cells[0,ThisRow];
               SavFlag:=true;  {save this change when row is changed or close occurs}
            end;
         CB1.Visible:=false;
      end;
end;

procedure TForm20.ClockGridMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
   MCol,MRow:integer;
   S,T,RecNo:string;
begin
   if SB1.Visible=true then
      CloseSB1;
   if CB1.Visible=true then
      CloseCB1;
   ClockGrid.MouseToCell(X,Y,MCol,MRow);
   if (ThisRow<>MRow) and (SavFlag=true) then  {do a save if new row and changed data}
      begin
         SaveRecord;
      end;
   ThisCol:=MCol;
   ThisRow:=MRow;
   MRect:=ClockGrid.CellRect(MCol,MRow);
   S:=Copy(ClockGrid.Cells[0,ThisRow],1,1);
   if MRow>0 then
      if (Mcol=0) and (S='*') then
         begin
            if MessageDlg('Do you want to undo changes to this record?',mtConfirmation,[mbYes,mbNo],0)=mrYes then
               begin
                  S:=ClockGrid.Cells[0,ThisRow];
                  ClockGrid.Cells[0,ThisRow]:='';
                  ClockGrid.Cells[0,ThisRow]:=Copy(S,2,Length(S)-1)+'          ';
                  S:=ClockGrid.Cells[6,ThisRow];           {get old first field}
                  T:=Copy(S,4,4);
                  ClockGrid.Cells[2,ThisRow]:=T;
                  T:=Copy(S,8,4);
                  ClockGrid.Cells[3,ThisRow]:=T;
                  ClockGrid.Cells[4,ThisRow]:=Copy(S,1,1);
                  SaveRecord;
               end;
         end
      else if (MCol=2) or (MCol=3) then
         SetSB1
      else if MCol=4 then
         SetCB1;
      ClockGrid.LeftCol:=0;
end;

procedure TForm20.FormClose(Sender: TObject; var Action: TCloseAction);
begin
   if SB1.Visible=true then CloseSB1;
   if CB1.Visible=true then CloseCB1;
   if SavFlag=true then SaveRecord;
end;

procedure TForm20.SB1DownClick(Sender: TObject);
{decrement time by one minute}
var
  Hr,Mn:integer;
  S,T:string;
begin
   S:=ClockGrid.Cells[ThisCol,ThisRow];
   Hr:=StrToInt(Copy(S,1,2));
   Mn:=StrToInt(Copy(S,3,2));
   Dec(Mn);
   if Mn<0 then
      begin
         Mn:=59;
         Dec(Hr);
      end;
   if (Hr<0) or ((Hr=0) and (Mn=0)) then
      begin
         Hr:=0;
         Mn:=1;
      end;
   S:=InttoStr(Hr);
   if Hr<10 then S:='0'+S;
   T:=IntToStr(Mn);
   if Mn<10 then T:='0'+T;
   ClockGrid.Cells[ThisCol,ThisRow]:=S+T;
end;

procedure TForm20.SB1UpClick(Sender: TObject);
{increment time by one minute}
var
  Hr,Mn:integer;
  S,T:string;
begin
   S:=ClockGrid.Cells[ThisCol,ThisRow];
   Hr:=StrToInt(Copy(S,1,2));
   Mn:=StrToInt(Copy(S,3,2));
   Inc(Mn);
   if Mn>59 then
      begin
         Mn:=0;
         Inc(Hr);
      end;
   if Hr>24 then Hr:=1;
   S:=InttoStr(Hr);
   if Hr<10 then S:='0'+S;
   T:=IntToStr(Mn);
   if Mn<10 then T:='0'+T;
   ClockGrid.Cells[ThisCol,ThisRow]:=S+T;
end;

end.
