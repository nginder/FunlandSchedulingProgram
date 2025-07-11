unit funconfig;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, System.UITypes,
  StdCtrls, Db , FunGrid, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.Comp.DataSet, FireDAC.Comp.Client,
  FireDAC.UI.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Phys,
  FireDAC.VCLUI.Wait, FireDAC.DApt;

type
  TForm10 = class(TForm)
    LB1: TListBox;
    LB2: TListBox;
    Button1: TButton;
    Label1: TLabel;
    LB3: TListBox;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Label2: TLabel;
    Label3: TLabel;
    Memo1: TMemo;
    Edit1: TEdit;
    Label4: TLabel;
    LB4: TListBox;
    LB5: TListBox;
    Label5: TLabel;
    Label6: TLabel;
    Query1: TFDQuery;
    Query2: TFDQuery;
    Query3: TFDQuery;
    Query4: TFDQuery;
    Query5: TFDQuery;
    procedure LB3MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure LB3Click(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure LB1DblClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure LB2DblClick(Sender: TObject);
    procedure LB2MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Button3Click(Sender: TObject);
    procedure LB2Click(Sender: TObject);
    procedure LB5DblClick(Sender: TObject);
    procedure LB3DblClick(Sender: TObject);
    procedure LB4DblClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form10: TForm10;

implementation

{$R *.DFM}

var
   Mode,LB2X,LB2Y,CurPos,CurNum,NewNum,MoveMode,CurTimeId:integer;
   CurName,CurTime:string;
   SaveSort:boolean;  {true if Job sort order has been altered}

procedure FillLB2;
   {fill LB2 w/names from job file}
var
   I:integer;
begin
   with Form10 do with Query1 do
      begin
         Query1.First;
         LB2.Clear;
         for I:=1 to RecordCount do if FieldByName('Type').AsString='I' then
            begin
               LB2.Items.Add(FieldByName('Name').AsString);
               Next;
            end;
      end;
end;

procedure GetName(var S:string);
   {get S=job name for S=job number}
var
   T:string;
   Flag:boolean;
begin
   with Form10.Query1 do
      begin
         T:='';
         Flag:=false;
         First;
         repeat
            if (FieldByName('Type').AsString='I') and (FieldByName('Num1').AsInteger=StrToInt(S)) then
               begin
                  Flag:=true;
                  T:=FieldByName('Name').AsString;
               end;
            Next;
         until (Eof=true) or (Flag=true);
         if Flag=true then
            S:=T;
      end;
end;

procedure GetJobNum(var S:string);
   {get S=job number for S=job name}
var
   J:integer;
   Flag:boolean;
begin
   with Form10.Query1 do
      begin
         Flag:=false;
         First;
         repeat
            if (FieldByName('Type').AsString='I') and (FieldByName('Name').AsString=S) then
               begin
                  Flag:=true;
                  J:=FieldByName('Num1').AsInteger;
               end;
            Next;
         until (Eof=true) or (Flag=true);
         if Flag=true then
            S:=IntToStr(J);
      end;
end;

procedure FillLB3;
   {fill LB3 w/names from job rotation}
var
   I:integer;
   S:string;
begin
   with Form10 do with Query1 do
      begin
         Query1.First;
         LB3.Clear;
         for I:=1 to RecordCount do
            begin
               if (FieldByName('Type').AsString='R') and (FieldByName('Num2').AsInteger=StrToInt(CurName)) then
                  begin
                     LB3.Items.Add(FieldByName('Name').AsString);
                     CurTimeId:=FieldByName('Num1').AsInteger;
                  end;
               Next;
            end;
      end;
   with Form10 do with LB3 do
      for I:=0 to Items.Count-1 do
         begin
            S:=Items[I];
            GetName(S);
            Items[I]:=S;
         end;
end;

procedure GetNum(S:string);
   {get position number for job name S using Query1}
var
   Flag:boolean;
begin
   with Form10 do
      begin
         with Query1 do
            begin
               CurNum:=0;
               First;
               Flag:=false;
               repeat
                   if (FieldByName('Type').AsString='I') and (FieldByName('Name').AsString=S) then
                      begin
                         CurNum:=FieldByName('Num1').AsInteger;
                         Flag:=true;
                      end;
                   Next;
               until (Eof=true) or (Flag=true);
            end;
      end;
end;

procedure GettimeId(S:string);
   {get CurtimeId for S from Query2}
var
   Flag:boolean;
begin
   with Form10 do
      begin
         with Query2 do
            begin
               CurTimeId:=0;
               First;
               Flag:=false;
               repeat
                   if (FieldByName('PorC').AsString='C') and (FieldByName('Lab').AsString=S) then
                      begin
                         CurTimeId:=FieldByName('Id').AsInteger;
                         Flag:=true;
                      end;
                   Next;
               until (Eof=true) or (Flag=true);
            end;
      end;
end;

procedure Gettime(I:integer;var S:string);
   {return time label in S for timeId I Query2}
var
   Flag:boolean;
begin
   with Form10 do
      begin
         with Query2 do
            begin
               First;
               Flag:=false;
               S:='';
               repeat
                   if (FieldByName('PorC').AsString='C') and (FieldByName('Id').AsInteger=I) then
                      begin
                         S:=FieldByName('Lab').AsString;
                         Flag:=true;
                      end;
                   Next;
               until (Eof=true) or (Flag=true);
            end;
      end;
end;

procedure GetTail(T:string;var V:string);
   {return "(x/y)' string to indicate xth occurrence/y total occurrences of this job in job sort order}
   {T=job/time, string e.g. 'Arcade@1:00-5:00'}
   var
   I,J,K:integer;
   S:string;
begin
   with Form10 do with LB3 do
      begin
         J:=0;
         for I:=0 to Items.Count-1 do
            begin
               S:=Copy(Items[I],5,Length(Items[I])-9);
               if S=T then
                  begin
                     K:=StrToInt(Copy(Items[I],Length(Items[I])-1,1))+1;
                     if K>9 then K:=9;
                     J:=StrToInt(Copy(Items[I],Length(Items[I])-3,1));
                     {if K>2 then Inc(J);}
                     Items[I]:=Copy(Items[I],1,Length(Items[I])-5)+'{'+IntToStr(J)+'/'+IntToStr(K)+'}';
                  end;
            end;
         Inc(J);
         if J>9 then J:=9;
         V:='{'+IntToStr(J)+'/'+IntToStr(J)+'}';
      end;
end;

procedure FillJobSort(Curtime:string);
   {fill LB3 w/names from job sort order}
var
   I,J:integer;
   S,T,U,V:string;
begin
   with Form10 do with Query5 do
      begin
         V:=IntToStr(CurTimeId);
         Close;
         Sql.Clear;
         SQL.Add('select * from "FUNJOBS.DB"');
         SQL.Add('where Type="O" and Num1='+V);
         {SQL.Add('order by Num2');}
         Open;
         First;
         LB3.Clear;
         if RecordCount>0 then
            begin
               for I:=1 to RecordCount do
                  begin
                     S:=FieldByName('Name').AsString;
                     U:=IntToStr(I)+':';
                     J:=FieldByName('Num2').AsInteger;
                     GetTime(CurTimeId,T);
                     if J<10 then
                        U:='00'+U
                     else if J<100 then
                        U:='0'+U;
                     T:=S+'@'+T;
                     LB3.Items.Add(U+T);
                     Next;
                  end;
               for I:=0 to LB3.Items.Count-1 do
                  begin
                     J:=Pos('@',LB3.Items[I]);
                     S:=Copy(LB3.Items[I],5,J-5);
                     T:=Copy(LB3.Items[I],J,Length(LB3.Items[I])-J+1);
                     GetName(S);
                     T:=S+T;
                     if I=0 then
                        V:='{1/1}'
                     else GetTail(T,V);
                     LB3.Items[I]:=Copy(LB3.Items[I],1,4)+T+V;
                  end;
            end
         else   {add a dummy entry to LB3}
            begin
               S:='empty list';
               Lb3.Items.Add(S);
            end;
      end;
end;

procedure FindNewNum;
   {find a new position # for added job}
var
   I:integer;
begin
   with Form10 do with Query1 do
      begin
         First;
         I:=0;
         repeat
             if FieldByName('Type').AsString='I' then
                if FieldByName('Num1').AsInteger>I then
                   I:=FieldByName('Num1').AsInteger;
             Next;
         until Eof=true;
         NewNum:=I+1;
      end;
end;

procedure TForm10.FormActivate(Sender: TObject);
   {setup LB1-choices and LB2 -jobs}
begin
   Mode:=-1;
   SaveSort:=false;
   with Form13 do
      begin
         Query1.Connection:=funland;
         Query2.Connection:=funland;
         Query3.Connection:=funland;
         Query4.Connection:=funland;
         Query5.Connection:=funland;
      end;
   with LB1 do
      begin
         Clear;
         Items.Add('Add job name');
         Items.Add('Delete job name');
         Items.Add('Change job order');
         Items.Add('Edit job name');
         Items.Add('Create job rotation');
         Items.Add('Delete job rotation');
         Items.Add('Edit job rotation');
         Items.Add('Edit job sort order');
         {lockout groups}
      end;
   with Query1 do
      begin
         Close;
         UpdateOptions.RequestLive:=true;
         Sql.Clear;
         SQL.Add('select * from "FUNJOBS.DB"');
         Open;
         FillLB2;
      end;
   LB3.Sorted:=false;  
end;

procedure Hidecontrols;
   {hide controls other than LB1}
begin
   with Form10 do
      begin
         LB2.Enabled:=true;
         Memo1.Text:='';
         Label3.Visible:=false;
         Edit1.Visible:=false;
         LB3.Visible:=false;
         Button3.Visible:=false;
         Button4.Visible:=false;
         LB4.Visible:=false;
         LB5.Visible:=false;
         Label5.Visible:=false;
         Label6.Visible:=false;
      end;
end;

procedure FillRotQueries;
   {fill LB4 with Rotation names/LB5 with Child times}
var
   I:integer;
begin
   with Form10 do
      begin
         with Query2 do
            begin
               Close;
               Sql.Clear;
               SQL.Add('select * from "FUNTIMES.DB"');
               SQL.Add('where PORC="C"');
               Open;
               First;
               LB5.Clear;
               for I:=1 to RecordCount do
                  begin
                     LB5.Items.Add(FieldByName('Lab').AsString);
                     Next;
                  end;
            end;
         with Query3 do
            begin
               Close;
               Sql.Clear;
               SQL.Add('select distinct Num2 from "FUNJOBS.DB"');
               SQL.Add('where Type="R"');
               Open;
               First;
               LB4.Clear;
               for I:=1 to RecordCount do
                  begin
                     LB4.Items.Add(FieldByName('Num2').AsString);
                     Next;
                  end;
            end;
      end;
end;
procedure FillMemo(I:Integer);
   {fill memo1 with instructions}
begin
   with Form10.Memo1 do
      begin
         Clear;
         case I of
            0:begin
               Lines[0]:='1. Double-click where new job is to be inserted.';
               Lines.Insert(1,'2. Enter new job name (must be a unique name!).');
               Lines.Insert(2,'3. Push "OK" to complete process.');
               Lines.Insert(3,'   ');
               Lines.Insert(4,'   Push "Cancel" to cancel job entry process.');
              end;
            1:begin
               Lines[0]:='1. Highlight job to be deleted.';
               Lines.Insert(1,'2. Push "OK" to complete process.');
               Lines.Insert(2,'   ');
               Lines.Insert(3,'   Push "Cancel" to cancel job entry process.');
              end;
            2:begin
               Lines[0]:='1. Double-click on job to be moved.';
               Lines.Insert(1,'2. Double-click on position where job is to be inserted.');
               Lines.Insert(2,'3. Push "OK" to complete process.');
               Lines.Insert(3,'   ');
               Lines.Insert(4,'   Push "Cancel" to cancel job move process.');
              end;
            3:begin
               Lines[0]:='1. Double-click on job name to be edited.';
               Lines.Insert(1,'2. Complete name editing.');
               Lines.Insert(2,'3. Push "OK" to complete process.');
               Lines.Insert(3,'   ');
               Lines.Insert(4,'   Push "Cancel" to cancel job name edit process.');
              end;
            4:begin
               Lines[0]:='1. Double-click on time for this new rotation.';
               Lines.Insert(1,'2. Double-click on any and all jobs in "JOBS" to add to this rotation.');
               Lines.Insert(2,'3. Double-click on any and all jobs in "JOB ROTATION" ');
               Lines.Insert(3, '        to delete from this rotation.');
               Lines.Insert(4,'4. Push "OK" to complete process.');
               Lines.Insert(5,'   ');
               Lines.Insert(6,'   Push "Cancel" to cancel process.');
              end;
            5:begin
               Lines[0]:='1. Double-click on rotation to be deleted.';
               Lines.Insert(1,'2. Confirm that this rotation is to be deleted.');
               Lines.Insert(2,'3. Push "OK" to complete process.');
               Lines.Insert(5,'   ');
               Lines.Insert(6,'   Push "Cancel" to cancel process.')
              end;
             6:begin
               Lines[0]:='1. Double-click on rotation to be edited.';
               Lines.Insert(1,'2. Double-click on any and all jobs in "JOBS"');
               Lines.Insert(2,'         to add to this rotation.');
               Lines.Insert(3,'3. Double-click on any and all jobs in "JOB ROTATION" ');
               Lines.Insert(4, '        to delete from this rotation.');
               Lines.Insert(5,'4. Push "OK" to complete process.');
               Lines.Insert(6,'   ');
               Lines.Insert(7,'   Push "Cancel" to cancel process.');
              end;
             7:begin
               Lines[0]:='This is the order in which automatic sort fills jobs.';
               Lines.Insert(1,'   Note that "{x/y}" indicates xth time of y times');
               Lines.Insert(2,'     this job occurs at this time.');
               Lines.Insert(3,'To add a job to sort order: Double-click on a time in "Times"');
               Lines.Insert(4,'   then double-click on job in "JOBS" to be added,');
               Lines.Insert(5,'   then double-click on position in "JOB SORT".');
               Lines.Insert(6,'   Push "OK" to add to sort order ');
               Lines.Insert(7,'      [multiple instances of each job allowed].');
               Lines.Insert(8,'To delete from the sort order: Shift/Left-click on ');
               Lines.Insert(9,'        any job in "SORT ORDER" ');
               Lines.Insert(10,'   ');
               Lines.Insert(11,'   Push "Cancel" to cancel process.');
              end;
         end;
      end;
end;

procedure TForm10.Button2Click(Sender: TObject);
begin
   Close;
end;

procedure Chooseit;
   {choose an activity}
begin
   with Form10 do if LB1.Itemindex>-1 then
      begin
         Mode:=LB1.ItemIndex;
         FillMemo(Mode);
         if LB1.ItemIndex<2 then
            if MessageDlg('Warning: changes made here can be disastrous. Continue?',mtWarning,[MbYes,mbNo],0)=mrNo then
               begin
                  LB1.ItemIndex:=-1;
                  Mode:=-1;
               end;
         case Mode of
            0:begin   {set up to add a job to funjobs.db; Mode=0}
                 Form10.Caption:='Configure - Add new job to job list';
                 Button1.Enabled:=false;
                 Button2.Enabled:=false;
                 LB1.Enabled:=false;
                 Button3.Caption:='OK';
                 Button4.Caption:='Cancel';
                 Button3.Visible:=true;
                 Button4.Visible:=true;
              end;
            1:begin {set up to delete  a job in funjobs.db; Mode=1}
                 Form10.Caption:='Configure - Delete a job from job list';
                 Button1.Enabled:=false;
                 Button2.Enabled:=false;
                 LB1.Enabled:=false;
                 Button3.Caption:='OK';
                 Button4.Caption:='Cancel';
                 Button3.Visible:=true;
                 Button4.Visible:=true;
              end;
            2:begin {set up to move  a job in funjobs.db; Mode=1}
                 Form10.Caption:='Configure - Move a job in job list';
                 Button1.Enabled:=false;
                 Button2.Enabled:=false;
                 LB1.Enabled:=false;
                 Button3.Caption:='OK';
                 Button4.Caption:='Cancel';
                 Button3.Visible:=true;
                 Button4.Visible:=true;
                 MoveMode:=0;
              end;
            3:begin  {set up to edit a job name}
                 Form10.Caption:='Configure - Edit a job name in job list';
                 Button1.Enabled:=false;
                 Button2.Enabled:=false;
                 LB1.Enabled:=false;
                 Button3.Caption:='OK';
                 Button4.Caption:='Cancel';
                 Button3.Visible:=true;
                 Button4.Visible:=true;
              end;
            4:begin {create new job rotation}
                 FillRotQueries;
                 Form10.Caption:='Configure - Create a new job rotation';
                 Button1.Enabled:=false;
                 Button2.Enabled:=false;
                 LB1.Enabled:=false;
                 LB2.Enabled:=false;
                 LB3.Enabled:=false;
                 LB3.Clear;
                 LB3.Visible:=true;
                 Button3.Caption:='OK';
                 Button4.Caption:='Cancel';
                 Button3.Visible:=true;
                 Button4.Visible:=true;
                 LB5.Visible:=true;
                 Label6.Caption:='Times';
                 Label6.Left:=LB5.Left;
                 Label3.Caption:='Job Rotation for:';
                 Label3.Left:=LB3.Left-25;
                 Label3.Visible:=true;
                 Label6.Visible:=true;
                 MoveMode:=0;
              end;
            5:begin {delete job rotation}
                 FillRotQueries;
                 Form10.Caption:='Configure - Delete a job rotation';
                 Button1.Enabled:=false;
                 Button2.Enabled:=false;
                 LB1.Enabled:=false;
                 LB2.Enabled:=false;
                 LB3.Enabled:=false;
                 LB3.Clear;
                 LB3.Visible:=true;
                 Button3.Caption:='OK';
                 Button4.Caption:='Cancel';
                 Button3.Visible:=true;
                 Button4.Visible:=true;
                 LB4.Visible:=true;
                 Label5.Caption:='Rotations';
                 Label5.Left:=LB4.Left;
                 Label3.Caption:='Job Rotation for:';
                 Label3.Left:=LB3.Left-25;
                 Label3.Visible:=true;
                 Label5.Visible:=true;
              end;
            6:begin {edit job rotation}
                 FillRotQueries;
                 Form10.Caption:='Configure - Edit a job rotation';
                 Button1.Enabled:=false;
                 Button2.Enabled:=false;
                 LB1.Enabled:=false;
                 LB2.Enabled:=false;
                 LB3.Enabled:=false;
                 LB3.Clear;
                 LB3.Visible:=true;
                 Button3.Caption:='OK';
                 Button4.Caption:='Cancel';
                 Button3.Visible:=true;
                 Button4.Visible:=true;
                 LB4.Enabled:=true;
                 LB4.Visible:=true;
                 Label5.Caption:='Rotations';
                 Label5.Left:=LB4.Left;
                 Label3.Caption:='Job Rotation for:';
                 Label3.Left:=LB3.Left-25;
                 Label3.Visible:=true;
                 Label5.Visible:=true;
              end;
            7:begin {edit automatic job sort order}
                 Form10.Caption:='Configure - Edit job sort order';
                 FillRotQueries;
                 Button1.Enabled:=false;
                 Button2.Enabled:=false;
                 LB1.Enabled:=false;
                 LB2.Enabled:=true;
                 LB3.Enabled:=true;
                 LB5.Enabled:=true;
                 LB5.Visible:=true;
                 LB3.Clear;
                 LB3.Sorted:=true;
                 LB3.Visible:=true;
                 Button3.Caption:='OK';
                 Button4.Caption:='Cancel';
                 Button3.Visible:=true;
                 Button4.Visible:=true;
                 Label3.Caption:='Job Sort Order';
                 Label3.Left:=LB3.Left;
                 Label3.Visible:=true;
                 Label6.Caption:='Times';
                 Label6.Left:=LB5.Left+25;
                 Label6.Visible:=true;
            end;
         end;
      end;
end;

procedure TForm10.LB1DblClick(Sender: TObject);
begin
   Chooseit;
end;

procedure TForm10.Button1Click(Sender: TObject);
begin
   Chooseit;
end;

procedure TForm10.FormCreate(Sender: TObject);
begin
   HideControls;
end;

procedure EndMode;
   {restore things after "cancel" or completed operation}
begin
   with Form10 do
      begin
         HideControls;
         LB3.Sorted:=false;
         LB1.Enabled:=true;
         LB2.ItemIndex:=-1;
         Button1.Enabled:=true;
         Button2.Enabled:=true;
         Mode:=-1;
         form10.Caption:='Configure';
      end;
end;

procedure AddToSort;
   {add Job with CurNum to job sort order}
begin

end;

procedure AddToRotate;
   {if not already there,add Job with CurNum to current rotation}
var
   I:integer;
   Flag:boolean;
begin
   with Form10 do with LB3 do
      begin
         I:=0;
         Flag:=false;
         while (I<LB3.Items.Count) and (Flag=false) do
            begin
               if LB3.Items[I]=LB2.Items[LB2.ItemIndex] then
                   begin
                      MessageDlg('This job is already in this rotation for this time!',MtError,[mbOk],0);
                      Flag:=true;
                   end;
               Inc(I);
            end;
         if Flag=false then
            begin
               LB3.Items.Add(LB2.Items[LB2.ItemIndex]);
               with Query1 do
                  begin
                     Append;
                     FieldByName('Num1').AsInteger:=CurTimeId;
                     FieldByName('Name').AsString:=IntToStr(CurNum);
                     FieldByName('Type').AsString:='R';
                     FieldByName('Num2').AsInteger:=StrToInt(LB4.Items[LB4.ItemIndex]);
                     Post;
                  end;
            end;
      end;
end;

procedure TForm10.Button4Click(Sender: TObject);
   {Cancel?? button}
begin
   case Mode of
      0:begin
           LB2.Items.Delete(CurPos);
           EndMode;
        end;
      1:EndMode;
      2:begin
           FillLB2;
           EndMode;
        end;
      3:EndMode;
      4:EndMode;
      5:EndMode;
      6:EndMode;
      7:EndMode;
     end;
   SaveSort:=false;
end;

procedure TForm10.LB2DblClick(Sender: TObject);
   {double click right 'jobs' list box}
begin
   case Mode of
     -1:LB2.ItemIndex:=-1;
      0:with LB2 do if ItemIndex>-1 then
        begin
           GetNum(LB2.Items[ItemIndex]);
           FindNewNum;
           Items.Insert(Itemindex,' ');
           CurPos:=ItemIndex-1;
           ItemIndex:=-1;
           Enabled:=false;
           Edit1.Left:=Left-2;
           Edit1.Width:=Width;
           Edit1.Top:=LB2Y-8+Top;
           Edit1.Text:='';
           Edit1.ReadOnly:=false;
           Edit1.Visible:=true;
           Edit1.SetFocus;
        end;
      1:with LB2 do if ItemIndex>-1 then
        begin
           GetNum(LB2.Items[ItemIndex]);
        end;
      2:with LB2 do if MoveMode=0 then
           begin
              GetNum(LB2.Items[ItemIndex]);
              NewNum:=CurNum;
              CurName:=LB2.Items[ItemIndex];
              LB2.Items.Delete(LB2.ItemIndex);
              MoveMode:=1;
           end
        else if MoveMode=1 then
           begin
              GetNum(LB2.Items[ItemIndex]);
              Items.Insert(Itemindex,CurName);
              MoveMode:=2;
           end;
      3:with LB2 do if ItemIndex>-1 then
        begin
           GetNum(LB2.Items[ItemIndex]);
           Enabled:=false;
           Edit1.Left:=Left-2;
           Edit1.Width:=Width;
           Edit1.Top:=LB2Y-8+Top;
           Edit1.Text:=LB2.Items[ItemIndex];
           Edit1.ReadOnly:=false;
           Edit1.Visible:=true;
           Edit1.SetFocus;
        end;
      4:with LB2 do if MoveMode=1 then
        begin
           GetNum(LB2.Items[ItemIndex]);
           AddToRotate;
        end;
      6:with LB2 do if LB4.ItemIndex>-1 then
        begin
           GetNum(LB2.Items[ItemIndex]);
           AddToRotate;
        end;
      7:if LB5.ItemIndex<0 then
           MessageDlg('No time was highlighted.',mtError,[mbOk],0)
        else with LB2 do
           begin
              Curname:=LB2.Items[ItemIndex];
              GetNum(LB2.Items[ItemIndex]);
           end;
   end;
end;

procedure TForm10.LB2MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
 {mouse down in right 'Jobs' list box}
begin
   case Mode of
     0,3:begin
          LB2X:=X;
          LB2Y:=Y;
       end;
   end;
end;

Procedure Uneek(var S:string;var Flag:boolean);
   {check Query1 jobnames (type=T) to see if S is already there}
   {return Flag=true if found or S=''}
   {remove leading spaces from S}
begin
   with Form10 do
      begin
         if S='' then
            Flag:=true
         else
            begin
               if Copy(S,1,1)=' 'then
               Flag:=false;
               repeat
                  if Copy(S,1,1)=' ' then
                     S:=Copy(S,2,Length(S)-1)
                  else Flag:=true;
               until (Flag=true) or (S='');
            end;
         if S<>'' then
            begin
               Flag:=false;
               with Query1 do
                  begin
                     First;
                     repeat
                        if FieldByname('Type').AsString='I' then
                           begin
                              if UpperCase(FieldByName('Name').AsString)=UpperCase(S) then
                                 Flag:=true;
                           end;
                        Next;
                     until (Eof=true) or (Flag=true);
                  end;
            end;
      end;
end;

procedure DoSave;
{save amended Job Sort Order from LB3 to FunJobs.db}
var
   I,J,K,Diff,N2:integer;
   S,T,Nm,Nm2:string;
begin

   with Form10 do IF Lb3.Count>0 then   {change all job no.s in query5 to those in Lb3}
      begin
         with Query5 do
             begin
                Diff:=Lb3.Count-RecordCount;
                Close;
                UpdateOptions.RequestLive:=true;
                Open;
                First;
                K:=0;
                while (Eof=false) and (K<Lb3.Count) do
                   begin
                      S:=LB3.Items[K];
                      J:=Pos('@',S);
                      Nm:=Copy(S,5,J-5);
                      GetJobNum(Nm);
                      Nm2:=FieldByName('Name').AsString;
                      if Nm<>Nm2 then
                         begin
                            Edit;
                            FieldByName('Name').AsString:=Nm;
                            Post;
                         end;
                      Next;
                      Inc(K);
                   end;
                if Diff>0 then   {here if more records in LB3 than Query5}
                   for I:=1 to Diff do
                      begin
                         S:=Lb3.Items[K];
                         T:=Copy(S,1,3);
                         N2:=StrToInt(T);
                         J:=Pos('@',S);
                         Nm:=Copy(S,5,J-5);
                         GetJobNum(Nm);
                         Append;
                         FieldByName('Name').AsString:=Nm;
                         FieldByName('Num1').AsInteger:=CurTimeId;
                         FieldByName('Num2').AsInteger:=N2;
                         FieldByName('Type').AsString:='O';
                         Post;
                         Inc(K);
                      end;
                   if Diff<0 then   {here if more records in Query5 than Lb3}
                      begin
                         Diff:=RecordCount-Lb3.Count;
                         for I:=1 to Diff do
                            begin
                               Delete;
                               Next;
                            end;
                      end;
                Close;
             end;
       end;

end;

procedure TForm10.Button3Click(Sender: TObject);
   {OK button}
var
   S,T:string;
   Flag:boolean;
   I:integer;
begin
   case Mode of
     0:begin    {add a job}
          T:=Edit1.Text;
          Uneek(T,Flag);
          if Flag=true then
             begin
                if T='' then
                   S:='No job name was entered!'
                else S:='Duplicate job name found!';
                MessageDlg(S,mtError,[mbOk],0);
                LB2.Items.Delete(CurPos);
                EndMode;
             end
          else
             begin
                with Query1 do
                   begin
                      First;
                      Flag:=false;
                      repeat
                         if (FieldByName('Type').AsString='I') and
                            (FieldByName('Num1').AsInteger=CurNum) then
                            begin
                               Insert;
                               FieldByName('Num1').AsInteger:=NewNum;
                               FieldByName('Name').AsString:=T;
                               FieldByName('Type').AsString:='I';
                               Post;
                               Flag:=true;
                            end;
                         Next;
                      until (Eof=true) or (Flag=true);
                      LB2.Items[CurPos]:=T;
                   end;
             end;
          EndMode;
       end;
     1:begin   {delete a job from funjobs.db}
          S:='Are you sure you want to delete '+LB2.Items[LB2.Itemindex]+' from joblist and all related Lockout, Rotation, and Sorting data?';
          if MessageDlg(S,mtConfirmation,[MbYes,mbNo],0)=mrNo then EndMode
          else
             begin
                with Query1 do
                   begin
                      First;
                      Flag:=false;
                      repeat
                         if (FieldByName('Type').AsString='I') and
                            (FieldByName('Num1').AsInteger=CurNum) then
                            Delete
                         else if (FieldByName('Type').AsString='R') and
                            (FieldByName('Name').AsInteger=CurNum) then
                            Delete
                         else if (FieldByName('Type').AsString='L') and
                            (FieldByName('Num1').AsInteger=CurNum) then
                            Delete
                         else Next;
                      until (Eof=true) or (Flag=true);
                   end;
                LB2.Items.Delete(LB2.ItemIndex);
                EndMode;
             end;
       end;
     2:begin   {move a job from one location to another}
          if MoveMode=0 then
             begin
                MessageDlg('No job has been selected for move',mtError,[mbOk],0)
             end
          else if MoveMode=1 then
             begin
                MessageDlg('No destination has been selected for move',mtError,[mbOk],0)
             end
          else with Query1 do
             begin
                First;
                Flag:=false;
                I:=0;
                repeat
                    if (FieldByName('Type').AsString='I') and
                       (FieldByName('Num1').AsInteger=NewNum) then
                       begin
                          I:=FieldByName('Num1').AsInteger;
                          S:=FieldByName('Name').AsString;
                          Delete;
                          Flag:=true;
                       end;
                    Next;
                until (Eof=true) or (Flag=true);
                First;
                Flag:=false;
                repeat
                    if (FieldByName('Type').AsString='I') and
                       (FieldByName('Num1').AsInteger=CurNum) then
                       begin
                          Insert;
                          FieldByName('Num1').AsInteger:=I;
                          FieldByName('Name').AsString:=S;
                          FieldByName('Type').AsString:='I';
                          Post;
                          Flag:=true;
                       end;
                    Next;
                until (Eof=true) or (Flag=true);
                EndMode;
             end;
       end;
     3:begin     {edit job name}
          T:=Edit1.Text;
          Uneek(T,Flag);
          if Flag=true then
             begin
                if T='' then
                   S:='No job name was entered!'
                else S:='Duplicate job name found!';
                MessageDlg(S,mtError,[mbOk],0);
                EndMode;
             end
          else
             begin
                with Query1 do
                   begin
                      First;
                      Flag:=false;
                      repeat
                         if (FieldByName('Type').AsString='I') and
                            (FieldByName('Num1').AsInteger=CurNum) then
                            begin
                               Edit;
                               FieldByName('Name').AsString:=T;
                               Post;
                               Flag:=true;
                            end;
                         Next;
                      until (Eof=true) or (Flag=true);
                   end;
                LB2.Items[LB2.ItemIndex]:=T;
                LB2.ItemIndex:=-1;
                EndMode;
             end;
       end;
     4:begin     {create job rotation}
          if MoveMode=0 then
             begin
                MessageDlg('No time has been selected for this rotation!',mtError,[mbOk],0)
             end
          else if (MoveMode=1) and (LB3.Items.Count<1) then
             begin
                MessageDlg('No jobs have been selected for this rotation!',mtError,[mbOk],0)
             end
          else with Query1 do
             begin
                for I:=0 to LB3.Items.Count-1 do
                   begin
                      GetNum(LB3.Items[I]);
                      Append;
                      FieldByName('Num1').AsInteger:=CurTimeId;
                      FieldByName('Name').AsString:=IntToStr(CurNum);
                      FieldByName('Type').AsString:='R';
                      FieldByName('Num2').AsInteger:=StrToInt(CurName);
                      Post;
                   end;
                EndMode;
             end;
       end;
     5:begin    {delete a job rotation}
          if LB3.Items.Count<1 then
             begin
                MessageDlg('No rotation has been selected for deletion!',mtError,[mbOk],0)
             end
          else if MessageDlg('Are you sure you want to delete this rotation?',mtConfirmation,[mbYes,MbNo],0)=mrYes then with Query1 do
             begin
                First;
                repeat
                   if (FieldByName('Type').AsString='R') and (FieldByName('Num2').AsInteger=StrToInt(LB4.Items[LB4.ItemIndex])) then
                      Delete
                   else
                      Next;
                until (Eof=true) or (Flag=true);
                EndMode;
             end;
       end;
     6:begin  {finish edit job rotation}
          {if LB4.ItemIndex<0 then
             begin
                MessageDlg('No rotation has been selected for editing!',mtError,[mbOk],0);
             end
          else if LB3.Items.Count<1 then
             begin
                MessageDlg('No jobs left in rotation!',mtError,[mbOk],0);
             end
          else
             begin}
                EndMode;
             {end;  }
       end;
     7:begin
          if SaveSort=true then
             begin {save additions/deletions to job sort order to FunJobs.db}
                DoSave;
                SaveSort:=false;
             end;
          EndMode;
       end;
     end;
end;


procedure TForm10.LB2Click(Sender: TObject);
begin
   case Mode of
     -1:LB2.Itemindex:=-1;
      1:with LB2 do if Itemindex>-1 then
        begin
           Curname:=LB2.Items[ItemIndex];
        end;
      7:if LB5.ItemIndex<0 then
           MessageDlg('No time was highlighted.',mtError,[mbOk],0)
        else with LB2 do
           begin
              Curname:=LB2.Items[ItemIndex];
              GetNum(LB2.Items[ItemIndex]);
           end;
   end;
end;

procedure GetRotNum;
   {get new rotation number as string}
var
   I:integer;
begin
   with Form10 do with Query3 do
      begin
         I:=0;
         First;
         repeat
            if FieldByName('Num2').AsInteger>I then
               I:=FieldByName('Num2').AsInteger;
            Next;
         until Eof=true;
      end;
   Inc(I);
   CurName:=IntToStr(I);
end;

procedure TForm10.LB5DblClick(Sender: TObject);
{double click 'times' list box}
begin
   if (Mode=4) or (Mode=7)then
      begin
         CurTime:=LB5.Items[LB5.Itemindex];
         GetTimeId(CurTime);
         if Mode=4 then
            begin
               GetRotNum;
               Label3.Caption:='Job Rotation for: '+CurTime;
               MoveMode:=1;
            end
         else
            begin
               Label3.Caption:='Job Sort Order for: '+CurTime;
               FillJobSort(Curtime);
            end;
         {LB5.Itemindex:=-1;}
         LB5.Enabled:=false;
         LB2.Enabled:=true;
         LB3.Enabled:=true;
      end;
end;

procedure TForm10.LB3DblClick(Sender: TObject);
{double click 'results' list box}
var
   I,J,K:integer;
   S,T,U,V:string;
begin
   if (Mode=4) or ((Mode=6) and (LB3.ItemIndex>-1)) then with LB3 do
      begin
         GetNum(LB3.Items[LB3.ItemIndex]);
         LB3.Items.Delete(LB3.ItemIndex);
         if Mode=6 then
            with Query4 do
               begin
                  UpdateOptions.RequestLive:=true;
                  Sql.clear;
                  S:='Delete from "Funjobs.db"';
                  Sql.Add(S);
                  S:='where Type="R" and Name="'+IntToStr(CurNum)+'" and Num1='+IntToStr(CurTimeId)+' and Num2='+LB4.Items[LB4.ItemIndex];
                  Sql.Add(S);
                  ExecSQL;
                  {Close; }
               end;
      end
   else if Mode=7 then      {here to add an entry to job sort order}
      begin
         if Lb2.ItemIndex<0 then
            MessageDlg('No job highlighted',mtError,[mbOk],0)
         else if LB5.Itemindex<0 then
            MessageDlg('No time highlighted',mtError,[mbOk],0)
         else with LB3 do
            begin
               if ItemIndex>-1 then
                   begin
                      J:=ItemIndex+1;
                      S:=Items[Count-1];
                      if S='empty list' then
                         begin
                            U:='@'+Curtime;
                            T:='001:';
                         end
                      else
                         begin
                            Items.Add(S);
                            for I:=Count-2 downto J do Items[I]:=Items[I-1];
                            S:=Items[ItemIndex];
                            T:=Copy(S,1,4);
                            J:=Pos('@',S);
                            K:=Pos('{',S);
                            U:=Copy(S,J,K-J);
                         end;
                      S:=Curname+U;
                      GetTail(S,V);
                      S:=T+S+V;
                      Items[ItemIndex]:=S;
                      SaveSort:=true;
                      S:=Curname+U;
                      Gettail(S,V);
                      if Count>1 then
                         begin
                            for I:=ItemIndex to Count-2 do
                               begin
                                  S:=Items[I+1];
                                  T:=Copy(S,1,4);
                                  U:=Items[I];
                                  Delete(U,1,4);
                                  Items[I]:=T+U;
                               end;
                            S:=Items[Count-2];
                            T:=Copy(S,1,3);
                            J:=StrToInt(T);
                            Inc(J);
                            T:=IntToStr(J);
                            if J<10 then T:='00'+T
                            else if J<100 then T:='0'+T;
                            U:=Items[Count-1];
                            Delete(U,1,3);
                            Items[Count-1]:=T+U;
                         end;
                   end;
            end;
      end;
end;

procedure TForm10.LB4DblClick(Sender: TObject);
{double click left 'Jobs' list box}
var
   S:string;
begin
   if Mode=5 then
      begin
         CurName:=LB4.Items[LB4.Itemindex];
         FillLB3;
         Gettime(CurTimeId,S);
         Label3.Caption:='Job Rotation for: '+S;
      end
   else if Mode=6 then
      begin
         CurName:=LB4.Items[LB4.Itemindex];
         FillLB3;
         Gettime(CurTimeId,S);
         Label3.Caption:='Job Rotation for: '+S;
         LB2.Enabled:=true;
         LB3.Enabled:=true;
      end;
end;

procedure TForm10.LB3Click(Sender: TObject);
{single click 'results' box}
begin
   if Mode=7 then     {highlight a position in job sort order}
      begin
        if Lb2.ItemIndex<0 then
            MessageDlg('No job highlighted',mtError,[mbOk],0)
         else if LB5.Itemindex<0 then
            MessageDlg('No time highlighted',mtError,[mbOk],0)
         else
            begin

            end;
      end;
end;

procedure TForm10.LB3MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
  {here for job sort order deletes}
var
   I:integer;
   S,T,U:string;
begin
   if (Mode=7) and (Button=mbLeft) and (Shift=[ssShift,ssLeft]) then
      begin
         if MessageDlg('Are you sure you want to delete this job',mtConfirmation,[mbYes,mbNo],0)=mrYes
           then  with Lb3 do
            begin
               for I:=ItemIndex to Count-2 do
                  begin
                     S:=Items[I];
                     T:=Copy(S,1,4);
                     S:=Items[I+1];
                     U:=Copy(S,5,Length(S)-4);
                     Items[I]:=T+U;
                  end;
               I:=Count-1;
               Items.Delete(I);
               SaveSort:=true;
            end;
      end; 
end;

end.
