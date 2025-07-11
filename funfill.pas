unit funfill;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, ExtCtrls, FileCtrl, DB ;

type
  Tform12 = class(TForm)
    Button2: TButton;
    Button1: TButton;
    Button4: TButton;
    Label1: TLabel;
    procedure FormActivate(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);

  private
    { Private declarations }
  public
    { Public declarations }

  end;

var
  form12: Tform12;
  BadFlag:integer;
  BadName,BadJob:string;



implementation

{$R *.DFM}

procedure Tform12.Button2Click(Sender: TObject);
   {Continue Anyway Button}
begin
   BadFlag:=0;
   Close;
end;

procedure Tform12.Button4Click(Sender: TObject);
   {Cancel button}
begin
   BadFlag:=2;
   Close;
end;

procedure Tform12.Button1Click(Sender: TObject);
   {Change Training Data Button}
begin
   BadFlag:=1;
   Close;
end;


procedure Tform12.FormActivate(Sender: TObject);
begin
   Label1.Caption:=BadName+' is not trained for '+BadJob;
end;

end.
