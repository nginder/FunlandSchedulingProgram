unit Funtrain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Grids, StdCtrls;

type
  TForm19 = class(TForm)
    JobG1: TStringGrid;
    Button4: TButton;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button5: TButton;
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form19: TForm19;

implementation

{$R *.dfm}

procedure TForm19.Button5Click(Sender: TObject); {Update button}
begin
  close;
end;

procedure TForm19.Button4Click(Sender: TObject);  {Cancel button}
begin
   close;
end;

procedure TForm19.Button3Click(Sender: TObject); {Save button}
begin
  close;
end;

end.
