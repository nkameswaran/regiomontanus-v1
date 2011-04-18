{
  K�plet adatok sz�m�t�sa �s alapinf� szolg�ltat�s
}

unit uAstro4AllCalculator;

interface

uses SysUtils, uAstro4AllFileHandling, uAstro4AllTypes;

type
  //# A bet�lt�tt adatokb�l k�rdezhet�nk le vele inform�ci�kat
  TDataSetInfoProvider = class(TObject)
  private
    FDataSetLoader: TDataSetLoader;
  public
    constructor Create;
    destructor Destroy; override;
    function GetCountryFromCountryID(ACountryID: string): string;
    function GetCountryIDFromCityName(ACityName: string): string;
    function GetTimeZoneIDFromCityName(ACityName: string): string;
    function GetTimeZoneIDFromCountry(ACountryID: string): string;
    function GetTimeZoneInfo(ATimeZoneID: string): TTimeZoneInfo;
    function IsDaylightSavingTimeOnDate(ADatum: TDateTime; ACountryID: string): Boolean;
    property DataSetLoader: TDataSetLoader read FDataSetLoader;
  end;

  TBaseCalculator = class(TObject)
  private
    FDataSetInfoProvider: TDataSetInfoProvider;
    FSettingsProvider: TSettingsProvider;
    procedure CalcAspects;
    procedure CalcHouseLords;
    procedure CalcPlanetsInHouses;
    procedure CalcSelfMarkers;
    procedure CalcWalkedUnWalkedPath;
    //function GetARMCTime: Double;
    function GetJulianDateET: Double;
    function GetJulianDateUT: Double;
    function GetSideralTime: Double;
  public
    FSzulKepletInfo: TSzuletesiKepletInfo;
    FCalcResult: TCalcResult;
    constructor Create(ADataSetInfoProvider: TDataSetInfoProvider; ASettingsProvider: TSettingsProvider);
    procedure CalcHouseCusps; virtual; abstract;
    procedure CalcPlanetsPosition; virtual; abstract;
    procedure CalculateOtherInformations;
    procedure DoCalculate(ASzulKepletInfo: TSzuletesiKepletInfo);
    function GetEclipticObliquity: Double;
    function GetGMTFromBirthDateTime: TDateTime;
  end;

  //# Swiss Ephemerides Calculator
  TSWECalculator = class(TBaseCalculator)
  public
    procedure CalcHouseCusps; override;
    procedure CalcPlanetsPosition; override;
  end;

  //# Napkelte, napnyugta
  TSunRiseSunSet = class(TObject)
  end;

  TDrakonikusCalculator = class(TSWECalculator)
  public
    procedure DoCalculateDraconicTimeAndDate(ASzulKepletInfo: TSzuletesiKepletInfo);
  end;

implementation

uses Math, Variants, DateUtils, DB, swe_de32, uAstro4AllConsts, uSegedUtils,
  Classes, Contnrs;

constructor TDataSetInfoProvider.Create;
begin
  inherited Create;
  FDataSetLoader := TDataSetLoader.Create();
end;

destructor TDataSetInfoProvider.Destroy;
begin
  FreeAndNil(FDataSetLoader);
  inherited Destroy;
end;

function TDataSetInfoProvider.GetCountryFromCountryID(ACountryID: string): string;
begin
  Result := '';

  if FDataSetLoader.CountryLoader.DataSet.Locate(cDS_COUNTRY_CountryCode, ACountryID, []) then
    Result := VarToStr(FDataSetLoader.CountryLoader.DataSet[cDS_COUNTRY_DisplayName]);
end;

function TDataSetInfoProvider.GetCountryIDFromCityName(ACityName: string): string;
var iCityID : integer;
begin
  Result := '';

  iCityID := FDataSetLoader.CityLoader.GetCityRecID(ACityName);
  if iCityID <> -1 then
    if FDataSetLoader.CityLoader.DataSetForSearch.Locate('RecID', iCityID, []) then
      Result := VarToStr(FDataSetLoader.CityLoader.DataSetForSearch[cDS_CITY_CountryCode]);
end;

function TDataSetInfoProvider.GetTimeZoneIDFromCityName(ACityName: string): string;
var iCityID : integer;
begin
  Result := '';

  if Trim(ACityName) <> '' then
    begin
      iCityID := FDataSetLoader.CityLoader.GetCityRecID(ACityName);
      if iCityID <> -1 then
        if FDataSetLoader.CityLoader.DataSetForSearch.Locate('RecID', iCityID, []) then
          Result := VarToStr(FDataSetLoader.CityLoader.DataSetForSearch[cDS_CITY_TimeZoneCode]);
    end;
end;

function TDataSetInfoProvider.GetTimeZoneIDFromCountry(ACountryID: string): string;
begin
  Result := '';

  if Trim(ACountryID) <> '' then
    if FDataSetLoader.CountryLoader.DataSet.Locate(cDS_COUNTRY_CountryCode, ACountryID, []) then
      Result := VarToStr(FDataSetLoader.CountryLoader.DataSet[cDS_COUNTRY_TimeZoneCode]);
end;

function TDataSetInfoProvider.GetTimeZoneInfo(ATimeZoneID: string): TTimeZoneInfo;
begin
  Result := nil;

  if Trim(ATimeZoneID) = '' then
    ATimeZoneID := 'GMT'; // GreenwichMeanTime 

  if DataSetLoader.TimeZoneLoader.DataSet.Locate(cDS_TZONE_TimeZoneCode, ATimeZoneID, [loCaseInsensitive]) then
    begin
      Result := TTimeZoneInfo.Create;

      Result.TimeZoneCode := DataSetLoader.TimeZoneLoader.DataSet[cDS_TZONE_TimeZoneCode];
      Result.DisplayName  := DataSetLoader.TimeZoneLoader.DataSet[cDS_TZONE_DisplayName];
      Result.Delta        := DataSetLoader.TimeZoneLoader.DataSet[cDS_TZONE_Delta];
      Result.Group        := DataSetLoader.TimeZoneLoader.DataSet[cDS_TZONE_Group];
      Result.TZType       := DataSetLoader.TimeZoneLoader.DataSet[cDS_TZONE_Type];
    end;
end;

function TDataSetInfoProvider.IsDaylightSavingTimeOnDate(ADatum: TDateTime; ACountryID: string): Boolean;
var dDatumTol, dDatumIg : TDateTime;
begin
  Result := false;

  // DoubleSummerTime... http://www.timeanddate.com/worldclock/timezone.html?n=136&syear=1925

  FDataSetLoader.CestLoader.DataSet.First;
  if FDataSetLoader.CestLoader.DataSet.Locate(cDS_CEST_CountryCode, ACountryID, [loCaseInsensitive]) then
    begin
      while (not FDataSetLoader.CestLoader.DataSet.Eof) and
            (FDataSetLoader.CestLoader.DataSet[cDS_CEST_CountryCode] = ACountryID) and
            (not Result) do
        begin
          // form�tum pl.: ;H;1941;04;6;01:59:59;1942;11;2;02:59:59
          TryOwnEncodeDateTime
            (
              StrToInt(VarToStr(FDataSetLoader.CestLoader.DataSet[cDS_CEST_EVTOL])),
              StrToInt(VarToStr(FDataSetLoader.CestLoader.DataSet[cDS_CEST_HOTOL])),
              StrToInt(VarToStr(FDataSetLoader.CestLoader.DataSet[cDS_CEST_NAPTOL])),
              GetReszletFromCESTIdopont(tcOra, VarToStr(FDataSetLoader.CestLoader.DataSet[cDS_CEST_ORATOL])),
              GetReszletFromCESTIdopont(tcPerc, VarToStr(FDataSetLoader.CestLoader.DataSet[cDS_CEST_ORATOL])),
              GetReszletFromCESTIdopont(tcMP, VarToStr(FDataSetLoader.CestLoader.DataSet[cDS_CEST_ORATOL])),
              0,
              dDatumTol
            );

          TryOwnEncodeDateTime
            (
              StrToInt(VarToStr(FDataSetLoader.CestLoader.DataSet[cDS_CEST_EVIG])),
              StrToInt(VarToStr(FDataSetLoader.CestLoader.DataSet[cDS_CEST_HOIG])),
              StrToInt(VarToStr(FDataSetLoader.CestLoader.DataSet[cDS_CEST_NAPIG])),
              GetReszletFromCESTIdopont(tcOra, VarToStr(FDataSetLoader.CestLoader.DataSet[cDS_CEST_ORAIG])),
              GetReszletFromCESTIdopont(tcPerc, VarToStr(FDataSetLoader.CestLoader.DataSet[cDS_CEST_ORAIG])),
              GetReszletFromCESTIdopont(tcMP, VarToStr(FDataSetLoader.CestLoader.DataSet[cDS_CEST_ORAIG])),
              0,
              dDatumIg
            );

          if (ADatum >= dDatumTol) and (ADatum < dDatumIg) then
            Result := true;

          FDataSetLoader.CestLoader.DataSet.Next;
        end;
    end;
end;

constructor TBaseCalculator.Create(ADataSetInfoProvider: TDataSetInfoProvider; ASettingsProvider: TSettingsProvider);
begin
  inherited Create;
  FDataSetInfoProvider := ADataSetInfoProvider;
  FCalcResult := nil;
  FSzulKepletInfo := nil;
  FSettingsProvider := ASettingsProvider;
end;

procedure TBaseCalculator.CalcAspects;

  function GetPlanetOrAxisAspectQualityType(AObj01RA, AObj02RA: Double; ADeg, AOrb: double) : TAspectQualityType;
  var iSourceDeg, iDestDeg : double;
      iAspPlusDeg, iAspNegDeg: double;
      iDiffDeg : double;
  begin
    Result := taqu_None;

    iSourceDeg := AObj01RA;
    iDestDeg := AObj02RA;

    if iDestDeg < iSourceDeg then
      iDestDeg := iDestDeg + 360;

    // Plusz / Minusz ir�ny az orbisszal
    iAspPlusDeg := ADeg + AOrb;
    iAspNegDeg := ADeg - AOrb;

    // K�t pont k�zti k�l�nbs�g
    iDiffDeg := iDestDeg - iSourceDeg;

    if iDiffDeg = ADeg then
      begin
        Result := taqu_Exact;
      end
    else
      begin
        if (iDiffDeg >= iAspNegDeg) and (iDiffDeg <= iAspPlusDeg) then
          Result := taqu_Other;
      end;
  end;

var i, j, k : integer;
    oPlanet01, oPlanet02 : TPlanet;
    oAxis01 : TAxis;
    oHouseCusp : THouseCusp;
    aqType : TAspectQualityType;
    dOrb : Double;
begin
  // F�nysz�gek
  FCalcResult.AspectList.Clear;

  for i := SE_SUN to SE_VESTA{SE_TRUE_NODE{} do
    begin
      if i in [SE_SUN..SE_VESTA{SE_PLUTO{}{, SE_MEAN_NODE{}] then
        begin
          oPlanet01 := FCalcResult.PlanetList.GetPlanetInfo(i);
          if Assigned(oPlanet01) then
            begin
              for j := SE_SUN to SE_VESTA{SE_PLUTO{} {SE_TRUE_NODE{} do
                if (i <> j) and (j in [SE_SUN..SE_VESTA{SE_PLUTO{}{, SE_MEAN_NODE{}]) then // saj�t mag�t az�' csak m�� ne
                  begin
                    for k := cFSZ_EGYUTTALLAS to cFSZ_2OTODFENY do
                      begin
                        oPlanet02 := FCalcResult.PlanetList.GetPlanetInfo(j);
                        if Assigned(oPlanet02) then
                          begin
                            dOrb := cFENYSZOGSETTINGS[k].iOrb;
                            
                            if k = cFSZ_EGYUTTALLAS then
                              if (oPlanet01.HouseNumber <> oPlanet02.HouseNumber) or (oPlanet01.InZodiacSign <> oPlanet02.InZodiacSign) then
                                dOrb := Round(dOrb) / 2;

                            aqType := GetPlanetOrAxisAspectQualityType(oPlanet01.RA, oPlanet02.RA, cFENYSZOGSETTINGS[k].iDeg, dOrb);
                            if aqType <> taqu_None then
                              FCalcResult.AspectList.AddNewAspectInfo(oPlanet01.PlanetID, tasc_Planet, oPlanet02.PlanetID, tasc_Planet, k, aqType);
                          end;
                      end;
                  end;

              // �s itt a tengelyeken is mehetn�nk... amikhez a f�nysz�geket megn�zhetn�nk...
              for j := 0 to FCalcResult.AxisList.Count - 1 do
                begin
                  if FCalcResult.AxisList.GetAxisInfo(j).AxisID in [SE_ASC..SE_NASCMC] then
                    for k := cFSZ_EGYUTTALLAS to cFSZ_2OTODFENY do
                      begin
                        oAxis01 := FCalcResult.AxisList.GetAxisInfo(j);
                        if Assigned(oAxis01) then
                          begin
                            aqType := GetPlanetOrAxisAspectQualityType(oPlanet01.RA, oAxis01.RA, cFENYSZOGSETTINGS[k].iDeg, cFENYSZOGSETTINGS[k].iOrb);
                            if aqType <> taqu_None then
                              FCalcResult.AspectList.AddNewAspectInfo(oPlanet01.PlanetID, tasc_Planet, oAxis01.AxisID, tasc_Axis, k, aqType);
                          end;
                      end;
                end;

              // �s itt pedig a h�zak... 
              for j := 0 to FCalcResult.HouseCuspList.Count - 1 do
                begin
                  if FCalcResult.HouseCuspList.GetHouseCuspInfo(j).HouseNumber in ([cHSN_House01..cHSN_House12] - [cHSN_House01, cHSN_House10]) then
                    for k := cFSZ_EGYUTTALLAS to cFSZ_2OTODFENY do
                      begin
                        oHouseCusp := FCalcResult.HouseCuspList.GetHouseCuspInfo(j);
                        if Assigned(oHouseCusp) then
                          begin
                            aqType := GetPlanetOrAxisAspectQualityType(oPlanet01.RA, oHouseCusp.RA, cFENYSZOGSETTINGS[k].iDeg, cFENYSZOGSETTINGS[k].iOrb);
                            if aqType <> taqu_None then
                              FCalcResult.AspectList.AddNewAspectInfo(oPlanet01.PlanetID, tasc_Planet, oHouseCusp.HouseNumber, tasc_HouseCusp, k, aqType);
                          end;
                      end;
                end;
              (**)
            end;
        end;
    end;
end;

procedure TBaseCalculator.CalcHouseLords;
var i, j, k, l, iLastHouseNum, iCnt : integer;
    objPlanet : TPlanet;
    iInZodiacSet, iSetResult : set of byte;
begin
  // H�zurak kisz�m�t�sa...

  for i := SE_SUN to SE_PLUTO do
    begin
      objPlanet := FCalcResult.PlanetList.GetPlanetInfo(i);
      objPlanet.FHouseLordsContainer.FClosedHouseNumbers := [];
      objPlanet.FHouseLordsContainer.FNormalHouseNumbers := [];

      for j := low(cZODIACANDPLANETLETTERS) to high(cZODIACANDPLANETLETTERS) do
        if cZODIACANDPLANETLETTERS[j].iPlanetID = objPlanet.PlanetID then
          begin
            iSetResult := [];
            iInZodiacSet := [];
            iInZodiacSet := iInZodiacSet + [cZODIACANDPLANETLETTERS[j].iZodiacID];

            for k := 0 to FCalcResult.HouseCuspList.Count - 1 do
              if THouseCusp(FCalcResult.HouseCuspList.Items[k]).HouseNumber in [cHSN_House01..cHSN_House12] then
                if THouseCusp(FCalcResult.HouseCuspList.Items[k]).InZodiacSign in iInZodiacSet then
                  begin
                    iSetResult := iSetResult + [THouseCusp(FCalcResult.HouseCuspList.Items[k]).HouseNumber];
                  end;

            if iSetResult <> [] then
              begin // Nem bez�rt
                objPlanet.FHouseLordsContainer.FNormalHouseNumbers :=
                  objPlanet.FHouseLordsContainer.FNormalHouseNumbers + iSetResult;
              end
            else
              begin // Bez�rt jegy... Melyik h�z kezd�dik az "iInZodiacSet" elemben
                iLastHouseNum := -1;
                iCnt := 1;
                
                repeat
                  for l := 0 to FCalcResult.HouseCuspList.Count - 1 do
                    if THouseCusp(FCalcResult.HouseCuspList.Items[l]).HouseNumber in [cHSN_House01..cHSN_House12] then
                      if THouseCusp(FCalcResult.HouseCuspList.Items[l]).InZodiacSign = Round(IncPeriodValue(cZODIACANDPLANETLETTERS[j].iZodiacID, -iCnt, cZDS_Kos, cZDS_Halak)) then
                        if (THouseCusp(FCalcResult.HouseCuspList.Items[l]).HouseNumber > iLastHouseNum) and (iLastHouseNum <> 1) then
                          iLastHouseNum := THouseCusp(FCalcResult.HouseCuspList.Items[l]).HouseNumber;
                  inc(iCnt);
                until iLastHouseNum <> -1;

                if iLastHouseNum <> -1 then
                  objPlanet.FHouseLordsContainer.FClosedHouseNumbers :=
                    objPlanet.FHouseLordsContainer.FClosedHouseNumbers + [iLastHouseNum];
              end;
          end;
    end;

end;

procedure TBaseCalculator.CalcPlanetsInHouses;
var i, j, k : integer;
    iStartDeg, iEndDeg : Double;
    oPlanetInfo : TPlanet;
    oHouseInfo : THouseCusp;
    bOK : boolean;
begin
  for i := 0 to FCalcResult.PlanetList.Count - 1 do
    begin
      oPlanetInfo := TPlanet(FCalcResult.PlanetList.GetPlanet(i));

      bOK := false;
      j := 1;
      while (j <= FCalcResult.HouseCuspList.Count - 1) and (not bOK) do
        begin
          oHouseInfo := THouseCusp(FCalcResult.HouseCuspList.GetHouseCuspInfo(j));

          iStartDeg := THouseCusp(FCalcResult.HouseCuspList.GetHouseCuspInfo(j)).RA;
          if j = FCalcResult.HouseCuspList.Count - 1 then k := 1 else k := j + 1;
          iEndDeg := THouseCusp(FCalcResult.HouseCuspList.GetHouseCuspInfo(k)).RA;

          if IsBetweenDeg(oPlanetInfo.RA, iStartDeg, iEndDeg) then
            begin
              oPlanetInfo.HouseNumber := oHouseInfo.HouseNumber;
              bOK := true;
            end;

          inc(j);
        end;
    end;
end;

procedure TBaseCalculator.CalcSelfMarkers;
var i, iCnt, iEnd : integer;
    iStartHouse01, iStartHouse02 : integer;
    objZodSignSelfMarker : TZodiacSignForSelfMarkers;
begin
  // �njel�l�k
  {
    ASC, ASC anal�g plan�t�ja = Sz�l.uralkod�, ASC �s a vele 1,5�-on bel�l �ll� plan�ta
    1. h�zban tal�lhat� plan�t�k
    az 1. h�zba bez�rt zodi�kus jegy(ek) �s anal�g plan�ta(i)
    Nap, Nap �s a vele egy�tt �ll� 7,5�-on bel�li plan�ta
    Hold
  }

  FCalcResult.SelfMarkerList.Clear;

  // Nap, �s a vele egy�tt 7,5�-on bel�l �ll� plan�ta...
  FCalcResult.SelfMarkerList.AddNewSelfMarker(FCalcResult.PlanetList.GetPlanetInfo(SE_SUN));
  // Hold
  FCalcResult.SelfMarkerList.AddNewSelfMarker(FCalcResult.PlanetList.GetPlanetInfo(SE_MOON));

  // ASC
  FCalcResult.SelfMarkerList.AddNewSelfMarker(FCalcResult.HouseCuspList.GetHouseCuspInfo(1));
  // ASC anal�g plan�ta, sz�l. uralkod�
  FCalcResult.SelfMarkerList.AddNewSelfMarker(FCalcResult.PlanetList.GetPlanetInfo(cZODIACANDPLANETLETTERS[FCalcResult.HouseCuspList.GetHouseCuspInfo(1).InZodiacSign].iPlanetID));

  // ASC �s a vele 1,5�-on bel�l �ll� plan�ta
  // 1. h�zban tal�lhat� plan�t�k ---- ebbe benne lesz az el�z� is, ill a 12. h�z nem!!! :(
  for i := 0 to FCalcResult.PlanetList.Count - 1 do
    begin
      if (FCalcResult.PlanetList.GetPlanet(i).HouseNumber = 1) and (FCalcResult.PlanetList.GetPlanet(i).PlanetID in [SE_SUN..SE_PLUTO]) then
        FCalcResult.SelfMarkerList.AddNewSelfMarker(FCalcResult.PlanetList.GetPlanet(i));
    end;

  // 1. h�zba bez�rt zodi�kus jegy(ek) �s anal�g plan�ta(i)
  iStartHouse01 := FCalcResult.HouseCuspList.GetHouseCuspInfo(1).InZodiacSign;
  iStartHouse02 := FCalcResult.HouseCuspList.GetHouseCuspInfo(2).InZodiacSign;

  iEnd := iStartHouse02 - iStartHouse01;

  if iStartHouse02 < iStartHouse01 then iEnd := (iStartHouse01 + (11 - iStartHouse01) + 1) - iStartHouse01;

  // a bez�rt zodi�kus jegyeket is �n�llapotk�nt meg kellene jelen�teni!!! a zodi�kus jegy k�zep�n
  i := iStartHouse01;
  iCnt := 0;
  while iCnt < iEnd do
    begin
      i := Round(IncPeriodValue(i, 1, 0, 11));

      if (i <> iStartHouse01) and (i <> iStartHouse02) and (i in [0..11]) then
        begin
          objZodSignSelfMarker := TZodiacSignForSelfMarkers.Create;
          objZodSignSelfMarker.RA := i * 30 + 15; //bak = 9 - v�z�nt� = 10 (!)
          objZodSignSelfMarker.SignID := i + 1;
          FCalcResult.SelfMarkerList.AddNewSelfMarker(objZodSignSelfMarker);
        end;

      inc(iCnt);
    end;

  // 9->0
  i := iStartHouse01;
  iCnt := 0;
  while iCnt < iEnd do
    begin
      //FCalcResult.
      i := Round(IncPeriodValue(i, 1, 0, 11));

      if (i in [0..11]) and (i <> iStartHouse02){} then
        FCalcResult.SelfMarkerList.AddNewSelfMarker(FCalcResult.PlanetList.GetPlanetInfo(cZODIACANDPLANETLETTERS[i].iPlanetID));
      inc(iCnt);
    end;
end;

procedure TBaseCalculator.CalculateOtherInformations;
begin
  CalcPlanetsInHouses;
  CalcAspects;
  CalcSelfMarkers;
  CalcWalkedUnWalkedPath;
  CalcHouseLords;
end;

procedure TBaseCalculator.CalcWalkedUnWalkedPath;

  function GetPointValue(AASCSign, AHelyzet: integer) : word;
  var k : integer;
      objPlanet : TPlanet;
  begin
    Result := 0;

    for k := 0 to FCalcResult.PlanetList.Count - 1 do
      begin
        objPlanet := TPlanet(FCalcResult.PlanetList.Items[k]);

        if objPlanet.PlanetID in [SE_SUN..SE_PLUTO] then
          begin
            if objPlanet.HouseNumber = AHelyzet then Result := Result + 1;
            if objPlanet.InZodiacSign = (AHelyzet - 1) then Result := Result + 1;

            if (objPlanet.HouseNumber = AHelyzet) or (objPlanet.InZodiacSign = (AHelyzet - 1)) then
              if objPlanet.PlanetID in [SE_SUN, SE_MOON, SE_MERCURY] then Result := Result + 1;
          end;
      end;
    if (AHelyzet - 1) = AASCSign then Result := Result + 2;
  end;

var iASCSign, i, j, iSumVizsz, iSumFugg : integer;
    lisMaxSor, lisMaxOszlop, lisMinSor, lisMinOszlop, lisJartUt, lisJaratlanUt : TSorOszlopList;
begin
  {
    -= J�rt - j�ratlan �t =-
    -= �letstart�gia �s "j�ratlan �t" =-

    Nap, Hold, Merkur, ASCjegye 2x pont, t�bbi 1-1
    Ha az egyes haz teljes egeszeben bennfoglal egy jegyet, akkor az ASC �s a bez�rt jegy is CSAK 1-1 pont

    Ell �sszeg: sor �s oszlop SUM megegyezik

    J�rt �t    : a max sorok k�z�l a legnagyobb �rt�k�(ek)
    J�ratlan �t: a min sorok k�z�l a legkisebb �rt�k�(ek)

         | Kard.  |   Fix    | Labil. |
    -----------------------------------
    T�z  | Kos/1  | Orosz/5  | Nyil/9 |
    -----------------------------------
    F�ld | Bak/10 | Bika/2   | Sz�z/6 |
    -----------------------------------
    Lev. | M�rl/7 | V�z�/11  | Ikr/3  |
    -----------------------------------
    Vizes| R�k/4  | Skorp/8  | Hal/12 |
    -----------------------------------
  }

  FillChar(FCalcResult.matrJartJaratlanPontszam, sizeof(FCalcResult.matrJartJaratlanPontszam), #0);
  FCalcResult.matrJartJaratlanPontszam[1,1] :=  1; FCalcResult.matrJartJaratlanPontszam[2,1] :=  5; FCalcResult.matrJartJaratlanPontszam[3,1] :=  9;
  FCalcResult.matrJartJaratlanPontszam[1,2] := 10; FCalcResult.matrJartJaratlanPontszam[2,2] :=  2; FCalcResult.matrJartJaratlanPontszam[3,2] :=  6;
  FCalcResult.matrJartJaratlanPontszam[1,3] :=  7; FCalcResult.matrJartJaratlanPontszam[2,3] := 11; FCalcResult.matrJartJaratlanPontszam[3,3] :=  3;
  FCalcResult.matrJartJaratlanPontszam[1,4] :=  4; FCalcResult.matrJartJaratlanPontszam[2,4] :=  8; FCalcResult.matrJartJaratlanPontszam[3,4] := 12;

  iASCSign := FCalcResult.AxisList.GetAxisInfo(SE_ASC).InZodiacSign; // Kos = 0 .. Halak = 11
  iSumVizsz := 0;
  iSumFugg := 0;

  for i := 1 to 3 do
    for j := 1 to 4 do
      begin
        FCalcResult.matrJartJaratlanPontszam[i, j] := GetPointValue(iASCSign, FCalcResult.matrJartJaratlanPontszam[i, j]);

        FCalcResult.matrJartJaratlanPontszam[i, 5] := FCalcResult.matrJartJaratlanPontszam[i, 5] + FCalcResult.matrJartJaratlanPontszam[i, j];
        FCalcResult.matrJartJaratlanPontszam[4, j] := FCalcResult.matrJartJaratlanPontszam[4, j] + FCalcResult.matrJartJaratlanPontszam[i, j];
      end;

  lisMaxSor := TSorOszlopList.Create(true, true);
  lisMaxOszlop := TSorOszlopList.Create(true, true);
  lisMinSor := TSorOszlopList.Create(true, false);
  lisMinOszlop := TSorOszlopList.Create(true, false);

  for i := 1 to 3 do // oszlop
    begin
      iSumVizsz := iSumVizsz + FCalcResult.matrJartJaratlanPontszam[i, 5];
      lisMaxOszlop.AddNewItem(i, FCalcResult.matrJartJaratlanPontszam[i, 5]);
      lisMinOszlop.AddNewItem(i, FCalcResult.matrJartJaratlanPontszam[i, 5]);
    end;

  for i := 1 to 4 do // sor
    begin
      iSumFugg := iSumFugg + FCalcResult.matrJartJaratlanPontszam[4, i];
      lisMaxSor.AddNewItem(i, FCalcResult.matrJartJaratlanPontszam[4, i]);
      lisMinSor.AddNewItem(i, FCalcResult.matrJartJaratlanPontszam[4, i]);
    end;

  if iSumVizsz = iSumFugg then // Check! egyenl�nek kell lennie
    FCalcResult.matrJartJaratlanPontszam[4, 5] := iSumVizsz
  else
    FCalcResult.matrJartJaratlanPontszam[4, 5] := 999;

  lisJartUt := TSorOszlopList.Create(true, true);
  lisJaratlanUt := TSorOszlopList.Create(true, false);

  for i := 0 to lisMaxSor.Count - 1 do
    for j := 0 to lisMaxOszlop.Count - 1 do                           // oszlop, sor
      lisJartUt.AddNewItem
        (
          cJARTJARATLANZODIACs[lisMaxOszlop.GetItem(j).SO_ID, lisMaxSor.GetItem(i).SO_ID],
          FCalcResult.matrJartJaratlanPontszam[lisMaxOszlop.GetItem(j).SO_ID, lisMaxSor.GetItem(i).SO_ID]
        );

  for i := 0 to lisMinSor.Count - 1 do
    for j := 0 to lisMinOszlop.Count - 1 do                           // oszlop, sor
      lisJaratlanUt.AddNewItem
        (
          cJARTJARATLANZODIACs[lisMinOszlop.GetItem(j).SO_ID, lisMinSor.GetItem(i).SO_ID],
          FCalcResult.matrJartJaratlanPontszam[lisMinOszlop.GetItem(j).SO_ID, lisMinSor.GetItem(i).SO_ID]
        );

  SetLength(FCalcResult.utJartUt, 0);
  SetLength(FCalcResult.utJaratlanUt, 0);

  for i := 0 to lisJartUt.Count - 1 do
    begin
      SetLength(FCalcResult.utJartUt, Length(FCalcResult.utJartUt) + 1);
      FCalcResult.utJartUt[Length(FCalcResult.utJartUt) - 1] := lisJartUt.GetItem(i).SO_ID;
    end;

  for i := 0 to lisJaratlanUt.Count - 1 do
    begin
      SetLength(FCalcResult.utJaratlanUt, Length(FCalcResult.utJaratlanUt) + 1);
      FCalcResult.utJaratlanUt[Length(FCalcResult.utJaratlanUt) - 1] := lisJaratlanUt.GetItem(i).SO_ID;
    end;

  FreeAndNil(lisJartUt);
  FreeAndNil(lisJaratlanUt);
  FreeAndNil(lisMaxSor);
  FreeAndNil(lisMaxOszlop);
  FreeAndNil(lisMinSor);
  FreeAndNil(lisMinOszlop);
end;

procedure TBaseCalculator.DoCalculate(ASzulKepletInfo: TSzuletesiKepletInfo);
begin
  if Assigned(ASzulKepletInfo) then
    begin
      FSzulKepletInfo := ASzulKepletInfo;

      CalcHouseCusps;
      CalcPlanetsPosition;

      CalculateOtherInformations;
    end;
end;

function TBaseCalculator.GetEclipticObliquity: Double;
var dEclipticObliquity : TPlanetPositionInfo;
    sErr : TsErr;
begin
  Result := 23.4393; // 2000-es �vben ez volt a m�rt �rt�k!

  swe_calc(GetJulianDateET, SE_ECL_NUT, 0, dEclipticObliquity[0], sErr);

  if dEclipticObliquity[0] <> 0 then
    Result := dEclipticObliquity[0];
end;
{
function TBaseCalculator.GetARMCTime: Double;
begin
  Result := GetSideralTime * 15;
end;
{}
function TBaseCalculator.GetGMTFromBirthDateTime: TDateTime;
var iTimeZoneOraPerc : Double;
    objTimeZoneInfo : TTimeZoneInfo;
    iDayOfTheYear : integer;
    //iSzorzo : integer;
    //dDate, dTime : TDateTime;
begin
  {
    Visszaadja a Greenwich-i id�t = UT = GMT
     - Levonjuk a T�li/Ny�ri +1 �r�t
     - Levonjuk az id�z�na miatti id�t!
    Nyugati id�ponttal mi is is van?! na az kicsit bonyolultabb, de mostm�r alakul :D
  {}

  Result := FSzulKepletInfo.DateOfBirth; // DateTime of Birth - with TimeZone!!!
  iTimeZoneOraPerc := 0;

  if FSzulKepletInfo.TZoneCode <> 'LMT' then
    begin
      objTimeZoneInfo := FDataSetInfoProvider.GetTimeZoneInfo(FSzulKepletInfo.TZoneCode);
      if Assigned(objTimeZoneInfo) then // Be�l�ltott id�z�na
        iTimeZoneOraPerc := OraPercToDouble(Round(objTimeZoneInfo.DeltaHour), Round(objTimeZoneInfo.DeltaMinute))
      else
        if Trim(FSzulKepletInfo.TZoneCode) = '' then // k�zi be�ll�t�s
          iTimeZoneOraPerc := OraPercToDouble(Round(FSzulKepletInfo.TZoneHour), Round(FSzulKepletInfo.TZoneMinute));
    end
  else
    begin
      iTimeZoneOraPerc :=
        (
          (4 * Abs(FSzulKepletInfo.LocLongDegree))
          +
          ((4 / 60) * FSzulKepletInfo.LocLongMinute)
        ); // ennyi perc �sszesen
      iTimeZoneOraPerc :=
        OraPercToDouble(
          Round(iTimeZoneOraPerc) div 60,
          Round(iTimeZoneOraPerc) - ((Round(iTimeZoneOraPerc) div 60) * 60)
                       );
    end;

  // megvan, hogy h�ny �r�val kell v�ltoztatni a norm�l id�pontot!
  // hozz� vessz�k a ny�ri id�sz�mt�st

  if (FSzulKepletInfo.IsDayLightSavingTime and ((pos('/S', FSzulKepletInfo.TZoneCode) = 0) and (pos('DT', FSzulKepletInfo.TZoneCode) = 0))) or
     ((FSzulKepletInfo.TZoneCode = 'LMT') and FSzulKepletInfo.IsDayLightSavingTime) or
     ((FSzulKepletInfo.TZoneCode = 'LMT') and FDataSetInfoProvider.IsDaylightSavingTimeOnDate(Result, FSzulKepletInfo.LocCountryID)) then
    begin
      if FSzulKepletInfo.TZoneWest then
        iTimeZoneOraPerc := iTimeZoneOraPerc - 1
      else
        iTimeZoneOraPerc := iTimeZoneOraPerc + 1;
    end;

  // mehet a v�ltoztat�s
  if Result >= 0 then  // 1900.01.01-n�l nagyobb = a d�tum
    begin
      if FSzulKepletInfo.TZoneWest then // NY-i id� => TZone�ra az "-" �rt�k� => hozz� kell adni az �rasz�mot
        begin
          if FSzulKepletInfo.TZoneCode <> 'LMT' then // NEM HelyiK�z�pid�!
            begin 
              Result := IncHour(Result, - DoubleToOra(iTimeZoneOraPerc));
              Result := IncMinute(Result, - DoubleToPerc(iTimeZoneOraPerc));
            end
          else
            begin
              Result := IncHour(Result, DoubleToOra(iTimeZoneOraPerc));
              Result := IncMinute(Result, DoubleToPerc(iTimeZoneOraPerc));
            end;
        end
      else
        begin // K-i id� => TZone�ra az "+" �rt�k� => le kell vonni az �rasz�mot
          //if FSzulKepletInfo.TZoneCode <> 'LMT' then // NEM HelyiK�z�pid�!
            begin 
              Result := IncHour(Result, - DoubleToOra(iTimeZoneOraPerc));
              Result := IncMinute(Result, - DoubleToPerc(iTimeZoneOraPerc));
            end;
        end;
    end
  else
    begin
      if FSzulKepletInfo.TZoneWest then // NY-i id� => TZone�ra az "-" �rt�k� => hozz� kell adni az �rasz�mot
        begin
          if FSzulKepletInfo.TZoneCode <> 'LMT' then // NEM HelyiK�z�pid�!
            begin
              iDayOfTheYear := DayOfTheYear(Result);
              Result := IncHour(Result, DoubleToOra(iTimeZoneOraPerc));
              Result := IncMinute(Result, DoubleToPerc(iTimeZoneOraPerc));
              if iDayOfTheYear <> DayOfTheYear(Result) then
                Result := IncDay(Result, +2);
            end
          else
            begin
              iDayOfTheYear := DayOfTheYear(Result);
              Result := IncHour(Result, - DoubleToOra(iTimeZoneOraPerc));
              Result := IncMinute(Result, - DoubleToPerc(iTimeZoneOraPerc));
              if iDayOfTheYear <> DayOfTheYear(Result) then
                Result := IncDay(Result, +2);
            end;
        end
      else
        begin // K-i id� => TZone�ra az "+" �rt�k� => le kell vonni az �rasz�mot
          //if FSzulKepletInfo.TZoneCode <> 'LMT' then // NEM HelyiK�z�pid�!
            begin
              iDayOfTheYear := DayOfTheYear(Result);
              Result := IncHour(Result, DoubleToOra(iTimeZoneOraPerc));
              Result := IncMinute(Result, DoubleToPerc(iTimeZoneOraPerc));
              if iDayOfTheYear <> DayOfTheYear(Result) then
                Result := IncDay(Result, -2);
            end;
        end;
    end;
end;

function TBaseCalculator.GetJulianDateET: Double;
begin
  // Ephemeris Time!
  Result := GetJulianDateUT + swe_deltat(GetJulianDateUT);
end;

function TBaseCalculator.GetJulianDateUT: Double;
var dGMTSzulDatum : TDateTime;
begin
  dGMTSzulDatum := GetGMTFromBirthDateTime;

  Result := swe_julday
            (
              YearOf(dGMTSzulDatum),
              MonthOf(dGMTSzulDatum),
              DayOf(dGMTSzulDatum),
              OraPercToDouble(HourOf(dGMTSzulDatum), MinuteOf(dGMTSzulDatum)),
              SE_GREG_CAL
            );
end;

function TBaseCalculator.GetSideralTime: Double;
begin
  Result := swe_sidtime(GetJulianDateUT) + (FokFokPercToDouble(FSzulKepletInfo.LocLongDegree, FSzulKepletInfo.LocLongMinute) / 15);
end;

{ TSWECalculator }

procedure TSWECalculator.CalcHouseCusps;
var eps_true   : Double;
    HouseCusps : THouseCuspsType;
    AscMc      : TAscMcType;
    i, iFlagType : integer;
begin
  inherited;
  eps_true := GetEclipticObliquity;
{
  swe_houses_armc
    (
      GetARMCTime,
      FokFokPercToDouble(FSzulKepletInfo.LocLatDegree, FSzulKepletInfo.LocLatMinute),
      eps_true,
      SEHOUSE_SYSTEM[0],
      HouseCusps[0],
      AscMc[0]
    );
{}
{
  swe_houses
    (
      GetJulianDateUT,
      FokFokPercToDouble(FSzulKepletInfo.LocLatDegree, FSzulKepletInfo.LocLatMinute),
      FokFokPercToDouble(FSzulKepletInfo.LocLongDegree, FSzulKepletInfo.LocLongMinute),
      FSettingsProvider.GetHouseCuspSystem[1], //SEHOUSE_SYSTEM[0],
      HouseCusps[0],
      AscMc[0]
    );
{}
  iFlagType := 0;
  if FSettingsProvider.GetZodiacType = 'S' then
    iFlagType := iFlagType + SEFLG_SIDEREAL;

  swe_houses_ex
    (
      GetJulianDateUT,
      iFlagType,
      FokFokPercToDouble(FSzulKepletInfo.LocLatDegree, FSzulKepletInfo.LocLatMinute),
      FokFokPercToDouble(FSzulKepletInfo.LocLongDegree, FSzulKepletInfo.LocLongMinute),
      FSettingsProvider.GetHouseCuspSystem[1], //SEHOUSE_SYSTEM[0],
      HouseCusps[0],
      AscMc[0]
    );

  if Assigned(FCalcResult) then
    begin
      FCalcResult.EclipticObliquity := eps_true;
      
      for i := SE_ASC to SE_NASCMC do
        begin
          if i = SE_ASC then FCalcResult.ASC_PointValue := AscMc[i];
          
          FCalcResult.AxisList.AddNewAxisInfo(i, AscMc[i]);
        end;

      for i := Low(THouseCuspsType) to High(THouseCuspsType) do
        FCalcResult.HouseCuspList.AddNewHouseCuspInfo(i, HouseCusps[i]);
    end;
end;

procedure TSWECalculator.CalcPlanetsPosition;
var i, iFlagType : integer;
    dBolygoAdatok : TPlanetPositionInfo;
    sErr : TsErr;
    dSidTime : DOuble;
    wHour, wMin : word;
begin
  inherited;

  if Assigned(FCalcResult) then
    begin
      FCalcResult.UniversalTime := GetGMTFromBirthDateTime;

      dSidTime := GetSideralTime;

      // Nyugati id�
      if dSidTime < 0 then dSidTime := 24 + dSidTime;

      // M�r �tmegy m�sik napra...
      if dSidTime >= 24 then dSidTime := dSidTime - (24 * (Round(dSidTime) div 24));

      wHour := DoubleToOra(dSidTime);
      wMin := DoubleToPerc(dSidTime);

      if wMin >= 60 then
        begin
          wHour := wHour + (wMin div 60);
          wMin := wMin - (60 * (wMin div 60));
        end;

      FCalcResult.SideralTime := EncodeDateTime(1900,01,01, wHour, wMin, 0, 0);

      FCalcResult.Ayanamsa := swe_get_ayanamsa_ut(GetJulianDateUT);
    end;

  iFlagType := SEFLG_SPEED;
  if FSettingsProvider.GetZodiacType = 'S' then
    iFlagType := iFlagType + SEFLG_SIDEREAL;

  for i := SE_SUN to SE_VESTA {SE_PLUTO{} do
    begin
      swe_calc(GetJulianDateET, i, iFlagType, dBolygoAdatok[0], sErr);
      //swe_calc(GetJulianDateUT, i, SEFLG_SPEED, dBolygoAdatok[0], sErr);

      if Assigned(FCalcResult) then // ha a dBolygoAdatok[3] < 0 akkor Retrogr�d a mozg�s
        FCalcResult.PlanetList.AddNewPlanetInfo(i, dBolygoAdatok[0], 0, dBolygoAdatok[3]);
    end;
  // ERIS - SE_ERIS
  swe_calc(GetJulianDateET, SE_ERIS, iFlagType, dBolygoAdatok[0], sErr);
  if Assigned(FCalcResult) then // ha a dBolygoAdatok[3] < 0 akkor Retrogr�d a mozg�s
    FCalcResult.PlanetList.AddNewPlanetInfo(SE_ERIS, dBolygoAdatok[0], 0, dBolygoAdatok[3]);
end;

procedure TDrakonikusCalculator.DoCalculateDraconicTimeAndDate(ASzulKepletInfo: TSzuletesiKepletInfo);
var dDegKulonbseg, dNodeUp, dAsc : double;
    iDecValue : integer;
begin
  FSzulKepletInfo := ASzulKepletInfo; // Mata Hari eset�ben ... hmm nem az igazi...

  DoCalculate(FSzulKepletInfo);

  iDecValue := 1;
  dDegKulonbseg := Abs(FCalcResult.PlanetList.GetPlanetInfo(SE_MEAN_NODE).RA - FCalcResult.HouseCuspList.GetHouseCuspInfo(SE_ASC).RA);
  while dDegKulonbseg > 0.1 do
    begin
      if dDegKulonbseg > 30 then iDecValue := 30 else
      if dDegKulonbseg > 15 then iDecValue := 15 else
      if dDegKulonbseg > 5 then iDecValue := 5 else
      if dDegKulonbseg > 1 then iDecValue := 1;{ else
      if dDegKulonbseg > 0.5 then iDecValue := 30 else
      if dDegKulonbseg > 0.01 then iDecValue := 5 else iDecValue := 2;{}

//      if dDegKulonbseg > 0.5 then
        FSzulKepletInfo.SetDateOfBirth(IncMinute(FSzulKepletInfo.DateOfBirth, - iDecValue));
//      else
//        FSzulKepletInfo.SetDateOfBirth(IncSecond(FSzulKepletInfo.DateOfBirth, - iDecValue));

      DoCalculate(FSzulKepletInfo);

      dNodeUp := FCalcResult.PlanetList.GetPlanetInfo(SE_MEAN_NODE).RA;
      dAsc := FCalcResult.HouseCuspList.GetHouseCuspInfo(1).RA;

      dDegKulonbseg := Abs(dNodeUp - dAsc);
    end;
end;

end.
