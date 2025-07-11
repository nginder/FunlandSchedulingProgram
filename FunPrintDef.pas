unit FunPrintDef;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, DB ,FunGrid,Printers;

type
  TForm18 = class(TForm)
    Button2: TButton;
    PSD1: TPrinterSetupDialog;
    Button3: TButton;
    CBx1: TCheckBox;
    Cbx3: TCheckBox;
    Label1: TLabel;
    Label2: TLabel;
    CBx2: TCheckBox;
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure FormActivate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form18: TForm18;

implementation

{$R *.dfm}

procedure TForm18.FormActivate(Sender: TObject);
var
   I:integer;
begin
   CBx1.Checked:=false;
   CBx2.Checked:=false;
   CBx3.Checked:=false;
   I:=Printer.PrinterIndex;
   Label2.Caption:=Printer.Printers[I];
end;

procedure TForm18.Button3Click(Sender: TObject);
var
   I:integer;
begin
   PSD1.Execute;
   I:=Printer.PrinterIndex;
   Label2.Caption:=Printer.Printers[I];
end;

procedure TForm18.Button2Click(Sender: TObject);
begin
   Close;
end;

end.
