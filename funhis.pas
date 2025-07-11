unit funhis;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Grids, StdCtrls, ExtCtrls, Db , FunGrid, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf,
FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Comp.Client, FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf,
FireDAC.Comp.DataSet;

type
  TForm16 = class(TForm)
Funland : TFDConnection;
    SchG1: TStringGrid;
    JobG1: TStringGrid;
    AvaBox: TListBox;
    Label3: TLabel;
    Button1: TButton;
    Panel1: TPanel;
    Query1: TFDQuery;
    Label4: TLabel;
    Label5: TLabel;
    procedure Button1Click(Sender: TObject);
    procedure SchG1TopLeftChanged(Sender: TObject);
    procedure JobG1TopLeftChanged(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form16: TForm16;
  Intro,Intrx:string;
  Emp_NotJob:boolean;
  NewCol,InNum:integer;

implementation

{$R *.DFM}

var
   CurCol,LeftCol:integer;

procedure FillAvaBox(Flag:boolean);
   {fill avabox with all employees}
   {Flag=true to sort by Last, First}
   {Flag=false to sort by Schedname}
var
   I,J:integer;
   S,T:string;
begin
   with Form16 do
      begin
         AvaBox.Clear;
         with Query1 do  {All available employees and their Id no.s to AvaBox}
            begin        {if SchedName is '', use First name, Last initial}
               Close;
               Sql.clear;
               Sql.Add('Select EmpNmbr,SchedName,Last,First');
               Sql.Add('from "employ.db"');
               Sql.Add('where Shift<>''TheFamily''');
               if Flag=true then
                  Sql.Add('order by Last, First')
               else Sql.Add('order by Schedname');
               Open;
               for I:=1 to RecordCount do
                  begin
                     S:=FieldByName('SchedName').AsString;
                     if S='' then
                        S:=FieldByName('First').AsString+' '+Copy(FieldByName('Last').AsString,1,1);
                     J:=FieldByName('EmpNmbr').AsInteger;
                     T:=IntToStr(J);
                     if J<10 then T:='00'+T
                     else if J<100 then T:='0'+T;
                     S:=S+', '+T;
                     AvaBox.Items.Add(S);
                     Next;
                  end;
               Close;
            end;
      end;
end;

procedure GetNum(var S:string);
   {S=Employee name; return w/S=Employee number as string from AvaBox}
var
   J,K:integer;
   Flag:boolean;
   T,U:string;
begin
   with Form16.AvaBox do
      begin
         Flag:=false;
         K:=0;
         repeat
            T:=Items[K];
            J:=Pos(',',T);
            if J>0 then
               U:=Copy(T,1,J-1)
            else U:='';
            if U=S then
               begin
                  Flag:=true;
                  S:=Copy(T,Length(T)-2,3);
               end;
            Inc(K);
         until (Flag=true) or (K>Items.Count);
      end;
   if Flag=false then S:='';
end;

procedure GetName(var S:string);
   {S=Employee Id; return w/S=Employee name from AvaBox}
var
   I,J,K:integer;
   Flag:boolean;
   T:string;
begin
   with Form16.AvaBox do
      begin
         Flag:=false;
         J:=StrToInt(S);
         K:=0;
         repeat
            T:=Items[K];
            I:=StrToInt(Copy(T,Length(T)-2,3));
            if I=J then
               begin
                  Flag:=true;
                  S:=Copy(T,1,Length(T)-5);
               end;
            Inc(K);
         until (Flag=true) or (K>=Items.Count);
      end;
   if Flag=false then S:='';
end;


procedure TForm16.Button1Click(Sender: TObject);
begin
   Close;
end;              

procedure ProcHis(S:string;Offs:integer);
   {process "Last" string from yyyymmdd.db as history}
   {Offs is days ago}
var
   I,J,K,Count,N,IDS:integer;
   TId,Dest,X:integer;
   T,U:string;
   IFlag:boolean;
begin
   with Form16 do
      begin
         Count:=Length(S) div 14;
         for I:=1 to Count do
            begin
               T:=Copy(S,1,3);
               if T[1]='*' then T[1]:='+';
               TId:=StrToInt(T);
               Dest:=StrToInt(Copy(S,12,3));
               Delete(S,1,14);
               if Dest<>999 then for J:=1 to JobG1.RowCount-1 do
                   begin
                      X:=StrToInt(JobG1.Cells[1,J]);
                      if X=Dest then with SchG1 do
                         for K:=0 to ColCount-1 do
                         begin
                            T:=Cells[K,RowCount+1];
                            IDS:=Length(T) div 3;
                            IFlag:=false;
                            N:=0;
                            repeat
                               Inc(N);
                               U:=Copy(T,(N-1)*3+1,3);
                               if U[1]='*' then U[1]:='+';
                               if StrToInt(U)=TId then
                                  IFlag:=true;
                            until (IFlag=true) or (N>=IDS);
                            if IFlag=true then
                               begin
                                  if Cells[K,J]<>'' then
                                     Cells[K,J]:=IntToStr(Offs)+','+Cells[K,J]
                                  else
                                     if Offs=0 then Cells[K,J]:='Today'
                                     else if Offs=1 then Cells[K,J]:='1 Day Ago'
                                     else Cells[K,J]:=IntToStr(Offs)+' Days Ago';
                               end;
                         end;
                   end;
            end;
      end;
end;


procedure GetEmpHis(Nmbr:integer);
   {get employee history from schedfile and oldfile; Nmbr is employee id number}
var
   S:string;
   I,Offs:integer;
begin
   with Form16 do
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
                     S:=FieldByName('Last').AsString;
                     Offs:=FieldByName('Dat').AsInteger;
                     {???}
                     Offs:=Offset+14-Offs;
                     ProcHis(S,Offs);
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
                     S:=FieldByName('Last').AsString;
                     Offs:=FieldByName('Dat').AsInteger;
                     {???}
                     Offs:=Offset+7-Offs;
                     ProcHis(S,Offs);
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
                     S:=FieldByName('Last').AsString;
                     Offs:=FieldByName('Dat').AsInteger;
                     Offs:=Offset-Offs;
                     ProcHis(S,Offs);
                     Next;
                  end;
               Close;
            end;
      end;
end;


procedure ProcJobHis(SName,S:string;Nmbr,Offs:integer);
   {process "Last" string from yyyymmdd.db as job history}
   {Offs is days ago; SName is schedule name for this entry}
   {Nmbr is position Id}
var
   I,J,K,Count,N,IDS:integer;
   TId,Dest:integer;
   T,U:string;
   IFlag:boolean;
begin
   with Form16 do
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

procedure GetJobHis(Nmbr:integer);
   {get job history from schedfile and oldfile}
   {PId=position Id number}
var
   S,SName:string;
   I,J,Offs:integer;
begin
   with Form16 do
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
                     ProcJobHis(SName,S,Nmbr,Offs);
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
                     ProcJobHis(SName,S,Nmbr,Offs);
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
                     ProcJobHis(SName,S,Nmbr,Offs);
                     Prior;
                  end;
            end;
         Query1.Close;
         with SchG1 do for J:=0 to ColCount-1 do Cells[J,1]:='';
      end;
end;

procedure TForm16.SchG1TopLeftChanged(Sender: TObject);
begin
   if SchG1.LeftCol<>CurCol then
      begin
         CurCol:=SchG1.LeftCol;
         with SchG1 do
            begin
               if Col<LeftCol then Col:=LeftCol;
               if Col>LeftCol+4 then Col:=LeftCol+4;
            end;
      end;
   if SchG1.TopRow<>JobG1.Top then
      if SchG1.TopRow<=JobG1.RowCount-19 then
         JobG1.TopRow:=SchG1.TopRow
      else
         begin
            SchG1.TopRow:=JobG1.RowCount-19;
            JobG1.TopRow:=JobG1.RowCount-19;
         end;
end;

procedure TForm16.JobG1TopLeftChanged(Sender: TObject);
begin
   JobG1.LeftCol:=0;
   SchG1.TopRow:=JobG1.TopRow;
end;

procedure TForm16.FormActivate(Sender: TObject);
var
   I:integer;
begin
   Query1.Connection:=Aliass;
   with SchG1 do for I:=1 to RowCount-1 do
      Rows[I].Clear;
   CurCol:=NewCol;
   FillAvaBox(true);
   if SchG1.ColCount>5 then Panel1.Visible:=false
   else Panel1.Visible:=true;
   Label5.Caption:='   '+Intro;
   Application.ProcessMessages;
   {if Emp_NotJob=true then GetEmpHis(InNum)
   else GetJobHis(InNum)}
end;

procedure TForm16.MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
   I,ACol,Arow:integer;
   T:string;
begin
   if Shift=[ssLeft] then
      begin
         Emp_NotJob:=true;
         if Sender=JobG1 then with JobG1 do
            begin
               Emp_NotJob:=false;
               MouseToCell(X,Y,ACol,ARow);
               Intro:=Cells[0,ARow];
               InNum:=StrToInt(Cells[1,ARow]);
            end
         else if Sender=AvaBox then
            begin
               Intro:=Copy(AvaBox.Items[AvaBox.ItemIndex],1,Length(AvaBox.Items[AvaBox.ItemIndex])-5);
            end
         else if Sender is TListBox then with Sender as TListBox do
            begin
               if ItemAtPos(Point(X,Y), True) >=0 then
                  begin
                     Intro:=Items[ItemIndex];
                  end;
            end;
         if Intro<>'' then
            begin
               with SchG1 do for I:=1 to RowCount-1 do
               Rows[I].Clear;
               Label5.Caption:=Intro;
               Application.ProcessMessages;
               if Emp_NotJob=true then
                  begin
                     T:=Intro;
                     Getnum(T);
                     InNum:=StrToInt(T);
                     GetEmpHis(InNum);
                  end
               else GetJobHis(InNum);
            end;
      end;
end;

end.
