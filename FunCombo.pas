unit FunCombo;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TForm19 = class(TForm)
    CBox1: TComboBox;
    Label1: TLabel;
    procedure CBox1Select(Sender: TObject);
    procedure FormActivate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form19: TForm19;
  NewTop, Newleft:integer;
  TimeSel:string;

implementation

{$R *.dfm}


procedure TForm19.FormActivate(Sender: TObject); 
var
   S:string;
begin
   S:='Choose a time'+#10+'for this break:';
   Label1.Caption:=S;
   Top:=NewTop+30;
   Left:=NewLeft+70;
   CBox1.Text:='';
end;

procedure TForm19.CBox1Select(Sender: TObject);
begin
   with CBox1 do
      begin
         TimeSel:=CBox1.Text;
         Close;
      end;
end;

end.
