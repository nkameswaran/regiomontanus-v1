unit fKepletLepteto;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, StdCtrls, Buttons, ExtCtrls, uAstro4AllMain;

type
  TfrmKepletLepteto = class(TForm)
    pnlClient: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label7: TLabel;
    btnEvP: TSpeedButton;
    btnEvM: TSpeedButton;
    btnHoP: TSpeedButton;
    btnHoM: TSpeedButton;
    btnNaP: TSpeedButton;
    btnNaM: TSpeedButton;
    btnOrP: TSpeedButton;
    btnOrM: TSpeedButton;
    btnPeP: TSpeedButton;
    btnPeM: TSpeedButton;
    btnEvPP: TSpeedButton;
    btnEvMM: TSpeedButton;
    btnHoPP: TSpeedButton;
    btnHoMM: TSpeedButton;
    btnNaPP: TSpeedButton;
    btnNaMM: TSpeedButton;
    btnOrPP: TSpeedButton;
    btnOrMM: TSpeedButton;
    btnPePP: TSpeedButton;
    btnPeMM: TSpeedButton;
    edtMertek: TEdit;
    UpDown1: TUpDown;
    Label6: TLabel;
    btnMPP: TSpeedButton;
    btnMPM: TSpeedButton;
    btnMPPP: TSpeedButton;
    btnMPMM: TSpeedButton;
    procedure btnLeptetoClick(Sender: TObject);
  private
    FobjAstro4AllMain: TAstro4AllMain;
    { Private declarations }
  public
    property objAstro4AllMain: TAstro4AllMain  read FobjAstro4AllMain write FobjAstro4AllMain;
    { Public declarations }
  end;

var
  frmKepletLepteto: TfrmKepletLepteto;

implementation

uses DateUtils, uAstro4AllTypes;

{$R *.dfm}

procedure TfrmKepletLepteto.btnLeptetoClick(Sender: TObject);
var btnName : string;
    iLeptetValue : integer;
    objAktSzulKepletInfo: TSzuletesiKepletInfo;
begin
  // lek�rni az akt k�plet adatokat... �s m�dos�tani a cuccost majd visszarajzolni...

  if Sender is TSpeedButton then
    begin
      objAktSzulKepletInfo := FobjAstro4AllMain.GetAktSzulKepletInfo;

      btnName := TSpeedButton(Sender).Name;
      delete(btnName, 1, 3); // "btn" el�tag t�rl�se...

      // nagybet�s lesz minden
      btnName := UpperCase(btnName);

      // marad�k prefixek: EV - HO - NA - OR - PE - MP
      // marad�k szuffixek: P - PP - M - MM
      // => hossz: 3 vagy 4
      iLeptetValue := 1;
      if btnName[3] = 'M' then // cs�kkenteni = 'M'�nusz / 'P'lusz
        iLeptetValue := - iLeptetValue;

      // m�rt�kl�pt�k, ha nem 1x-es
      if length(btnName) = 4 then
        iLeptetValue := iLeptetValue * StrToIntDef(edtMertek.Text, 1);

      { nyugati id� ??? y0
      if objAktSzulKepletInfo.TZoneWest then
        iLeptetValue := - iLeptetValue;
      {}

      btnName := copy(btnName, 1, 2);

      if btnName = 'EV' then objAktSzulKepletInfo.SetDateOfBirth(IncYear(objAktSzulKepletInfo.DateOfBirth, iLeptetValue)) else
      if btnName = 'HO' then objAktSzulKepletInfo.SetDateOfBirth(IncMonth(objAktSzulKepletInfo.DateOfBirth, iLeptetValue)) else
      if btnName = 'NA' then objAktSzulKepletInfo.SetDateOfBirth(IncDay(objAktSzulKepletInfo.DateOfBirth, iLeptetValue)) else
      if btnName = 'OR' then objAktSzulKepletInfo.SetDateOfBirth(IncHour(objAktSzulKepletInfo.DateOfBirth, iLeptetValue)) else
      if btnName = 'PE' then objAktSzulKepletInfo.SetDateOfBirth(IncMinute(objAktSzulKepletInfo.DateOfBirth, iLeptetValue)) else
      if btnName = 'MP' then objAktSzulKepletInfo.SetDateOfBirth(IncSecond(objAktSzulKepletInfo.DateOfBirth, iLeptetValue));

      FobjAstro4AllMain.SetAktSzulKepletInfo(objAktSzulKepletInfo);
      FobjAstro4AllMain.UpdateActiveSheetHint;
    end;
end;

end.
