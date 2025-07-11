unit FunNew;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, FunGrid;

type
  TForm15 = class(TForm)
    First: TEdit;
    Last: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Button1: TButton;
    Button2: TButton;
    Label3: TLabel;
    IDEd: TEdit;
    Label4: TLabel;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormActivate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form15: TForm15;
  ConFlag:boolean;
  NewNum:integer;

implementation

{$R *.DFM}



procedure TForm15.Button1Click(Sender: TObject);
begin
   if (First.Text<>'') and (Last.Text<>'') then
      begin
         ConFlag:=true;
         Close;
      end
   else
      begin
         ConFlag:=false;
         Close;
      end;
end;

procedure TForm15.Button2Click(Sender: TObject);
begin
   ConFlag:=false;
   Close;
end;

procedure TForm15.FormActivate(Sender: TObject);
begin
   Last.Text:='';
   First.Text:='';
   ConFlag:=false;
   Get_New_Emp_No(NewNum);
   IdEd.Text:=IntToStr(NewNum);
end;


end.
