unit Funexit;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, Mask, FunGrid;

type
  TForm3 = class(TForm)
    Label1: TLabel;
    Button1: TButton;
    Button2: TButton;
    GroupBox1: TGroupBox;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    CheckBox3: TCheckBox;
    CheckBox4: TCheckBox;
    CheckBox5: TCheckBox;
    CheckBox6: TCheckBox;
    CheckBox7: TCheckBox;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Button3: TButton;
    ME1: TMaskEdit;
    ME2: TMaskEdit;
    Label5: TLabel;
    Label6: TLabel;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure FormActivate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form3: TForm3;
  Flag:integer;
  PSt,Pnd:integer;

implementation

{$R *.DFM}


procedure TForm3.Button1Click(Sender: TObject);
   {print all button}
begin
   Flag:=2;
   close;
end;

procedure TForm3.Button2Click(Sender: TObject);
   {print page button}
begin
   Flag:=1;
   close;
end;

procedure TForm3.Button3Click(Sender: TObject);
   {cancel print button}
begin
   Flag:=0;
   Close;
end;

procedure TForm3.FormActivate(Sender: TObject);
begin
   CheckBox1.Checked:=true;
   CheckBox2.Checked:=true;
   CheckBox3.Checked:=true;
   CheckBox4.Checked:=true;
   CheckBox5.Checked:=true;
   CheckBox6.Checked:=true;
   CheckBox7.Checked:=true;
   Label1.Caption:='Print all time sheets for hourly employees:';
   Label6.Caption:='for hourly employees';
end;

procedure TForm3.FormClose(Sender: TObject; var Action: TCloseAction);
begin
   if Flag=1 then
      begin
         if ME1.Text=''then Pst:=1
            else Pst:=StrToInt(ME1.Text);
         if Pst>LastPage then Pst:=LastPage;
         if ME2.Text='' then Pnd:=Pst
            else Pnd:=StrToInt(ME2.Text);
         if Pnd>LastPage then Pnd:=LastPage;
         if Pnd<Pst then Pnd:=Pst;
      end;
end;

end.
