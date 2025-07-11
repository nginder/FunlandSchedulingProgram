unit funlock;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, Grids, Db , FunGrid, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf,
FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Comp.Client, FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf,
FireDAC.Comp.DataSet, FireDAC.Phys, FireDAC.VCLUI.Wait, FireDAC.DApt;

type
  TForm17 = class(TForm)
    JobG1: TStringGrid;
    Label3: TLabel;
    AvaBox: TListBox;
    Button1: TButton;
    Label1: TLabel;
    Avnbox: TListBox;
    Label4: TLabel;
    Label2: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    RotBox: TListBox;
    Button5: TButton;
    Button6: TButton;
    Label13: TLabel;
    Label14: TLabel;
    funland: TFDConnection;
    Query1: TFDQuery;
    Query2: TFDQuery;
    procedure Button6Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure JobG1SelectCell(Sender: TObject; ACol, ARow: Integer;
      var CanSelect: Boolean);
    procedure JobG1DblClick(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure JobG1DrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect;
      State: TGridDrawState);
    procedure AvaBoxClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormActivate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form17: TForm17;
  CurCol,ACol,ARow:integer;
  Flag:boolean;
  BCol,BRow:integer;

implementation

{$R *.DFM}
procedure FillAvaBox;
   {fill avabox with all hourly and special employees}
   {also fill avnbox with employee numbers }
var
   I,J:integer;
   S,T:string;
begin
   with Form17 do
      begin
         AvaBox.Clear;
         AvnBox.Clear;
         with Query1 do  {All hourly and special employees and their Id no.s to AvaBox}
            begin
               Close;
               Sql.clear;
               Sql.Add('Select EmpNmbr,Last,First,Shift');
               Sql.Add('from "employ.db"');
               {Sql.Add('where Status=''Active'' and');
               Sql.Add('Shift = ''Hourly'' or Shift = ''Special''');}
               Sql.Add('order by Shift, Last, First');
               Open;
               First;
               for I:=1 to RecordCount do
                  begin
                     S:=FieldByName('First').AsString+' '+FieldByName('Last').AsString;
                     AvaBox.Items.Add(S);
                     J:=FieldByName('EmpNmbr').AsInteger;
                     T:=IntToStr(J);
                     if J<10 then T:='00'+T
                     else if J<100 then T:='0'+T;
                     AvnBox.Items.Add(T);
                     Next;
                  end;
               Close;
            end;
      end;
end;

procedure GetTrainingData1;
{get and display training data for EmpTrainNum}
{if does not exist make new record in Training.db}
var
   EName:string;
   I,J:integer;
   S:string;
begin
   with Form17 do
     begin
        EName:=IntToStr(EmpTrainNum);
        with Query2 do
           begin
              close;
             { RequestLive:=true; }
              Sql.clear;
              Sql.Add('Select *');
               Sql.Add('from "Training.Db"');
               Sql.Add('where EID='+EName);
               Open;
               First;
               if RecordCount<1 then
                  begin
                     Append;
                     S:='';
                     J:=ETranMax;
                     for I:=1 to J do S:=S+'0';
                     FieldByName('EId').AsInteger:=EmpTrainNum;
                     FieldByName('ETran').AsString:=S;
                     Post;
                  end
               else
                  S:=FieldByName('ETran').AsString;
               CurrentData:=S;
               OldData:=S;
               close;
           end;
     end;
end;

procedure FillJobG1;
{fill jobs grid with job names}
{2nd column of grid holds status of job training: "1" = trained; "0" = untrained}
var
   I:integer;
begin
   with Form17 do
      begin
         with Query1 do
            begin
               close;
               Sql.clear;
               Sql.Add('Select Name, Num1');
               Sql.Add('from "FUNJOBS.Db"');
               Sql.Add('where Type="I"');
               Open;
               JobG1.RowCount:=RecordCount+1;
               First;
               for I:=1 to RecordCount do with JobG1 do
                  begin
                     Cells[0,I]:=FieldByName('Name').AsString;
                     Cells[1,I]:=FieldByName('Num1').AsString;
                     Next;
                  end;
               close;
            end;
      end;
end;

procedure FillRotBox;
{fill training rotation box}
var
   I:integer;
   S,T:string;
begin
   with Form17 do
      begin
         RotBox.Clear;
         with Query1 do
            begin
               close;
               Sql.clear;
               Sql.Add('Select Name, Num1');
               Sql.Add('from "FUNJOBS.Db"');
               Sql.Add('where Type="T"');
               Open;
               First;
               S:='';
               for I:=1 to RecordCount do with RotBox do
                  begin
                     T:=FieldByName('Name').AsString;
                     if S<>T then
                        begin
                           RotBox.Items.Add(T);
                           S:=T;
                        end;
                     Next;
                  end;
               close;
            end;
      end;
end;

procedure GetIndex;
   {Highlight name in Avabox indexed by EmpTrainNum}
var
   I,J:integer;
begin
   I:=-1;
   with Form17 do with Avnbox do
      repeat
         Inc(I);
         J:=StrToInt(Items[I]);
      until (I>=Items.Count-1) or (J=EmpTrainNum);
   if J=EmpTrainNum then
      begin
         Form17.AvaBox.ItemIndex:=I;
         GetTrainingData1;
      end
   else
      Form17.AvaBox.ItemIndex:=-1;
end;

procedure SaveData;
{save changed ETran data}
begin
   with Form17.Query2 do
      begin
         close;
         UpdateOptions.RequestLive:=true;
         Open;
         Edit;
         FieldByName('ETran').AsString:=CurrentData;
         Post;
      end;
end;

procedure TForm17.Button1Click(Sender: TObject); {Close with Save button}
begin
   SaveData;
   Close;
end;

procedure TForm17.FormActivate(Sender: TObject);
begin
   Query1.Connection:=funland;
   Query2.Connection:=funland;
   OldData:='';
   CurrentData:='';
   AvaBox.Height:=JobG1.Height;
   AvaBox.Top:=JobG1.Top;
   FillAvaBox;
   FillRotBox;
   if EmpTrainNum>0 then GetIndex;
   FillJobG1;
   JobG1.Visible:=true;
   JobG1.Enabled:=true;
   Avabox.Enabled:=true;
end;

procedure TForm17.AvaBoxClick(Sender: TObject);
begin
   if CurrentData<>OldData then SaveData;
   EmpTrainNum:=StrToInt(AvnBox.Items[AvaBox.ItemIndex]);
   GetIndex;
   FillJobG1;
end;

procedure TForm17.JobG1DrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
var
    S:string;
begin
    with JobG1 do if ACol=0 then
      begin
        S:=Cells[0,ARow];
        if CurrentData[ARow]='0' then
           Canvas.Font.Color:=clBlack
        else
          Canvas.Font.Color:=clRed;
        Canvas.TextOut(Rect.Left+2,Rect.Top+2,S);
      end;
end;

procedure TForm17.Button4Click(Sender: TObject);   {Cancel without Saving}
begin
   close;
end;

procedure TForm17.Button2Click(Sender: TObject); {Mark All button}
var
   I:integer;
   S:string;
begin
   S:='1';
   with Form17.JobG1 do for I:=RowCount-1 downto 1 do
      begin
        Cells[1,I]:='1';
        S:=S+'1';
      end;
   CurrentData:=S;
end;

procedure TForm17.Button3Click(Sender: TObject); {Clear All}
var
   I:integer;
   S:string;
begin
   S:='0';
   with Form17.JobG1 do for I:=RowCount-1 downto 1 do
      begin
        Cells[1,I]:='0';
        S:=S+'0';
      end;
   CurrentData:=S;
end;

procedure TForm17.JobG1DblClick(Sender: TObject);
begin
   with JobG1 do
     if CurrentData[BRow]='0' then
            CurrentData[BRow]:='1'
         else CurrentData[BRow]:='0';
   JobG1.Cells[0,BRow]:=JobG1.Cells[0,BRow];
end;

procedure TForm17.JobG1SelectCell(Sender: TObject; ACol, ARow: Integer;
  var CanSelect: Boolean);
begin
  BRow:=ARow;
end;

procedure TForm17.Button5Click(Sender: TObject);
{mark rotation here}
var
   I,J,K:integer;
   S,T:string;
begin
   if RotBox.Itemindex>-1 then
      begin
         S:=RotBox.Items[RotBox.ItemIndex];
         with Query1 do
            begin
               close;
               Sql.clear;
               Sql.Add('Select Name, Num1');
               Sql.Add('from "FUNJOBS.Db"');
               Sql.Add('where Type="T"');
               Open;
               First;
               for I:=1 to RecordCount do
                  begin
                     T:=FieldByName('Name').AsString;
                     if S=T then
                        begin
                           K:=FieldByName('Num1').AsInteger;
                           for J:=1 to JobG1.RowCount do
                              if JobG1.Cells[1,J]<>'' then
                                 if K=StrToInt(JobG1.Cells[1,J]) then
                                    begin
                                       CurrentData[J]:='1';
                                       JobG1.Cells[0,J]:=JobG1.Cells[0,J];
                                       Repaint;
                                       Application.ProcessMessages;
                                    end;
                        end;
                     Next;
                  end;
               close;
            end;
      end;
end;

procedure TForm17.Button6Click(Sender: TObject);
{clear rotation here}
var
   I,J,K:integer;
   S,T:string;
begin
   if RotBox.Itemindex>-1 then
      begin
         S:=RotBox.Items[RotBox.ItemIndex];
         with Query1 do
            begin
               close;
               Sql.clear;
               Sql.Add('Select Name, Num1');
               Sql.Add('from "FUNJOBS.Db"');
               Sql.Add('where Type="T"');
               Open;
               First;
               for I:=1 to RecordCount do
                  begin
                     T:=FieldByName('Name').AsString;
                     if S=T then
                        begin
                           K:=FieldByName('Num1').AsInteger;
                           for J:=1 to JobG1.RowCount do
                              if JobG1.Cells[1,J]<>'' then
                                 if K=StrToInt(JobG1.Cells[1,J]) then
                                    begin
                                       CurrentData[J]:='0';
                                       JobG1.Cells[0,J]:=JobG1.Cells[0,J];
                                       Repaint;
                                       Application.ProcessMessages;
                                    end;
                        end;
                     Next;
                  end;
               close;
            end;
      end;

end;

end.
