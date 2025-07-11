unit Funprint;

interface

uses WinTypes, WinProcs, Classes, Graphics, Forms, Controls, Buttons,
  StdCtrls, ExtCtrls;

type
  TBtnBottomDlg = class(TForm)
    OKBtn: TBitBtn;
    CancelBtn: TBitBtn;
    Bevel1: TBevel;
    Label1: TLabel;
    PB1: TListBox;
    Label2: TLabel;
    procedure OKBtnClick(Sender: TObject);
    procedure CancelBtnClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure PB1DblClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  BtnBottomDlg: TBtnBottomDlg;
  OkShow:boolean;
implementation

{$R *.DFM}

procedure TBtnBottomDlg.OKBtnClick(Sender: TObject);
begin
   OKShow:=true;
   close;
end;

procedure TBtnBottomDlg.CancelBtnClick(Sender: TObject);
begin
   OKShow:=false;
   close;
end;

procedure TBtnBottomDlg.FormActivate(Sender: TObject);
begin
   OKShow:=false;
end;

procedure TBtnBottomDlg.PB1DblClick(Sender: TObject);
var
   S,T:string;
begin
   with PB1 do
      if (ItemIndex>-1) and (Items[ItemIndex]<>'') then
         begin
            S:=Items[ItemIndex];
            T:=Copy(S,2,1);
            Delete(S,2,1);
            if T='x' then T:=' '
            else T:='x';
            Insert(T,S,2);
            Items[ItemIndex]:=S;
         end;
end;

end.
