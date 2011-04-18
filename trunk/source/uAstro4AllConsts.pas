{
  Konstansok a program m�k�d�s�hez
}
unit uAstro4AllConsts;

interface

uses DateUtils, swe_de32, Graphics;

type TZodiacSignAndPlanet = record
       iZodiacID,
       iPlanetID : integer;
       cZodiacLetter,
       cZodiacsPlanetLetter : char;
       sZodiacName,
       sZodiacPlanetName,
       sBulvarZodiacName,
       sBulvarZodiacItemName : string;
     end;

     TAspectValues = record
       cAspectLetter : char;
       sAspectName,
       sOtherAspectName : string;
       iDeg : integer;
       iOrb : Double;
     end;

     TPlanetNames = record
       cPlanetLetter : string;
       sPlanetName : string;
     end;

     THouseNames = record
       sHouseNumberArabic : string[5];
       sHouseNumberOther  : string[5];
       sHouseDesc : string;
     end;

     TAxisNames = record
       sLongAxisName,
       sShortAxisName  :string;
     end;

     TAssignSettingsINI = record
       sItemName : string[20];
       iAssignedItem : integer;
     end;

    TBulvarType = (tbulv_AjandekAJegySzulotteinek, tbulv_JegyEsEgeszseg, tbulv_JegyEsKoveik, tbulv_JegyArnyoldalai,
                   tbulv_JegyAmitSzeretnek, tbulv_JegyAmitNemSzeretnek, tbulv_JegyErossegei, tbulv_JegyBunok,
                   tbulv_JegyDivat);

    TAspectType = (tasc_None, tasc_Planet, tasc_Axis, tasc_HouseCusp);
    TAspectQualityType = (taqu_None, taqu_Exact, taqu_Grow, taqu_Decrease, taqu_Other);
    TColorType = (tcol_Water, tcol_Ground, tcol_Air, tcol_Fire);

    TPrintType = (ptSzulKeplet, ptDrakonikus, prOsszevetes, ptPrimerDirekcio, ptSzekunderDirekcio, ptSolarRevolution);

    TRegState = (regAll, regBase, regNone);

    TByteSet = set of byte;

    TAspectStyleRec = record
      sItemName : string;
      psPenStyle : TPenStyle;
    end;

    TTerNegyed = (negyNONE, negyJobb, negyAlso, negyBal, negyFelso);

const cFILENAME_CEST     = 'table.cest.dat';      // T�li/Ny�r id�sz�m�t�s id�pontok
      cFILENAME_CITY     = 'table.city.dat';      // F�bb telep�l�sek vil�gszerte 
      cFILENAME_COUNTRY  = 'table.country.dat';   // Orsz�gok
      cFILENAME_TIMEZONE = 'table.timezone.dat';  // Id�z�na adatok

      cFILENAME_BULVARJELLEMZESEK = 'bulvar\jellemzesek.ini';
      cFILENAME_IMAGEDLL = 'regmonimages.dll';
      cFILENAME_SETTINGS = 'settings.ini';

      cFILE_SEP = ';'; // A mez� szepar�tor a f�jlokban

      cSZULKEPLETFILEFILETER = 'Sz�let�si k�pletek (*.szk)|*.szk|Minden f�jl (*.*)|*.*'; 

      cPATH_EPHE_DATA = 'data\sweph\';
      cPATH_DATA = 'data\';
      cPATH_SZULKEPLET = 'hors\';

      cREG_KEYLASTOPENEDFILES = '\Software\Regiomontanus\LastOpenedFiles\';
      cREG_PREFIX_LASTOPENED = 'LastOpened';

      // Horoszk�p INI f�jl szerkezete
      cBIRTHINI_SECBIRTHINFO  = 'BirthInfo';
      cBIRTHINI_SECNOTES      = 'Notes';

      cBIRTHINI_Name          = 'Name';
      cBIRTHINI_Gender        = 'Gender';
      cBIRTHINI_Year          = 'Year';
      cBIRTHINI_Month         = 'Month';
      cBIRTHINI_Day           = 'Day';
      cBIRTHINI_Hour          = 'Hour';
      cBIRTHINI_Minute        = 'Minute';
      cBIRTHINI_Second        = 'Second';
      cBIRTHINI_TZoneCode     = 'TZoneCode';
      cBIRTHINI_TZoneWest     = 'TZoneWest';
      cBIRTHINI_TZoneHour     = 'TZoneHour';
      cBIRTHINI_TZoneMinute   = 'TZoneMinute';
      cBIRTHINI_LocCity       ='LocCity';
      cBIRTHINI_LocCountry    ='LocCountry';
      cBIRTHINI_LocCountryID  ='LocCountryID';
      cBIRTHINI_LocAltitude   = 'LocAltitude';
      cBIRTHINI_LocLongDegree = 'LocLongDegree';
      cBIRTHINI_LocLongMinute = 'LocLongMinute';
      cBIRTHINI_LocLongSecond = 'LocLongSecond';
      cBIRTHINI_LocLatDegree  = 'LocLatDegree';
      cBIRTHINI_LocLatMinute  = 'LocLatMinute';
      cBIRTHINI_LocLatSecond  = 'LocLatSecond';
      cBIRTHINI_IsDayLightSavingTime = 'IsDayLightSavingTime';

      cBIRTHINI_NoteBASE = 'Note'; // NoteXX=

      //CountryCode;EVTOL;HOTOL;NAPTOL;ORATOL;EVIG;HOIG;NAPIG;ORAIG
      cDS_CEST_CountryCode = 'CountryCode';
      cDS_CEST_EVTOL       = 'EVTOL';
      cDS_CEST_HOTOL       = 'HOTOL';
      cDS_CEST_NAPTOL      = 'NAPTOL';
      cDS_CEST_ORATOL      = 'ORATOL';
      cDS_CEST_EVIG        = 'EVIG';
      cDS_CEST_HOIG        = 'HOIG';
      cDS_CEST_NAPIG       = 'NAPIG';
      cDS_CEST_ORAIG       = 'ORAIG';

      cDS_DISP_CEST_CountryCode = 'K�d';
      cDS_DISP_CEST_EVTOL       = '�v';
      cDS_DISP_CEST_HOTOL       = 'H�';
      cDS_DISP_CEST_NAPTOL      = 'Nap';
      cDS_DISP_CEST_ORATOL      = '�r�t�l';
      cDS_DISP_CEST_EVIG        = '�v';
      cDS_DISP_CEST_HOIG        = 'H�';
      cDS_DISP_CEST_NAPIG       = 'Nap';
      cDS_DISP_CEST_ORAIG       = '�r�ig';

      //CountryCode;CityName;Longitude;Latitude;TimeZoneCode;
      cDS_CITY_CountryCode  = 'CountryCode';
      cDS_CITY_CityName     = 'CityName';
      cDS_CITY_Longitude    = 'Longitude';
      cDS_CITY_Latitude     = 'Latitude';
      cDS_CITY_TimeZoneCode = 'TimeZoneCode';

      //CountryCode;DisplayName;TimeZoneCode
      cDS_COUNTRY_CountryCode  = 'CountryCode';
      cDS_COUNTRY_DisplayName  = 'DisplayName';
      cDS_COUNTRY_TimeZoneCode = 'TimeZoneCode';

      cDS_DISP_COUNTRY_CountryCode  = 'Orsz�g k�d';
      cDS_DISP_COUNTRY_DisplayName  = 'Orsz�g neve';
      cDS_DISP_COUNTRY_TimeZoneCode = 'Id�z�na';

      //TimeZoneCode;DisplayName;Delta;Group;Type
      cDS_TZONE_TimeZoneCode = 'TimeZoneCode';
      cDS_TZONE_DisplayName  = 'DisplayName';
      cDS_TZONE_Delta        = 'Delta';
      cDS_TZONE_Group        = 'Group';
      cDS_TZONE_Type         = 'Type';
      cDS_TZONE_Order        = 'Order';

      cY2000 = 730530.0;
      cINITNUMBER = 999;

      // Megnevez�sek
      cAXISNAMES : array[SE_ASC..SE_NASCMC] of TAxisNames =
        (
          (sLongAxisName: 'Ascendens'; sShortAxisName : 'AC'),
          (sLongAxisName: 'Medium Coeli'; sShortAxisName : 'MC'),
          (sLongAxisName: 'ARMS'; sShortAxisName : ''),
          (sLongAxisName: 'Vertex'; sShortAxisName : ''),
          (sLongAxisName: 'Keletpont'; sShortAxisName : ''),
          (sLongAxisName: 'Koascendens (W.Koch)'; sShortAxisName : ''),
          (sLongAxisName: 'Koascendens (M. Munkasey)'; sShortAxisName : ''),
          (sLongAxisName: 'Sarki Ascendens'; sShortAxisName : ''),
          (sLongAxisName: 'NASCMC'; sShortAxisName : '')
        );

      cDAYNAMES : array[DayMonday..DaySunday] of string =
        (
          'H�tf�', 'Kedd', 'Szerda', 'Cs�t�rt�k', 'P�ntek', 'Szombat', 'Vas�rnap'
        );

      cZDS_Kos      =  0;
      cZDS_Bika     =  1;
      cZDS_Ikrek    =  2;
      cZDS_Rak      =  3;
      cZDS_Oroszlan =  4;
      cZDS_Szuz     =  5;
      cZDS_Merleg   =  6;
      cZDS_Skorpio  =  7;
      cZDS_Nyilas   =  8;
      cZDS_Bak      =  9;
      cZDS_Vizonto  = 10;
      cZDS_Halak    = 11;

      cHSN_House01 =  1;
      cHSN_House02 =  2;
      cHSN_House03 =  3;
      cHSN_House04 =  4;
      cHSN_House05 =  5;
      cHSN_House06 =  6;
      cHSN_House07 =  7;
      cHSN_House08 =  8;
      cHSN_House09 =  9;
      cHSN_House10 = 10;
      cHSN_House11 = 11;
      cHSN_House12 = 12;

      cHOUSENAMEENDINGS : array[cHSN_House01..cHSN_House12] of string =
        (
          'Els� H�z', 'M�sodik H�z', 'Harmadik H�z', 'Negyedik H�z', '�t�dik H�z', 'Hatodik H�z',
          'Hetedik H�z', 'Nyolcadik H�z', 'Kilencedik H�z', 'Tizedik H�z', 'Tizenegyedik H�z', 'Tizenkettedik H�z'
        );

      // ******************** Bulv�r adatok ******************** //

      cBULVARTYPESECTIONS : array[Low(TBulvarType)..High(TBulvarType)] of string =
        (
          'AjandekAJegySzulotteinek', 'JegyEsEgeszseg', 'JegyEsKoveik', 'JegyArnyoldalai',
          'JegyAmitSzeretnek', 'JegyAmitNemSzeretnek', 'JegyErossegei', 'JegyBunok',
          'JegyDivat'
        );

      cBULVAR_Forras = 'Forras';
      cBULVAR_Leiras = 'Leiras';
      cBULVAR_RovidLeiras = 'RovidLeiras';
      cBULVAR_Caption = 'Caption';

      // ******************** H�z adatok ******************** //

      cHOUSECAPTIONS : array[cHSN_House01..cHSN_House12] of THouseNames =
        (
          (sHouseNumberArabic: '1';   sHouseNumberOther: 'I';   sHouseDesc: 'Az "�N" vil�gban val� megjelen�s�nek ter�lete'),
          (sHouseNumberArabic: '2';   sHouseNumberOther: '2';   sHouseDesc: 'Az "�N" l�tez�s�nek alapja, h�ttere'),
          (sHouseNumberArabic: '3';   sHouseNumberOther: '3';   sHouseDesc: 'Az "�N" k�rnyezete, k�zege, az ebben val� mozg�s, k�zleked�s, kommunik�ci�'),
          (sHouseNumberArabic: '4';   sHouseNumberOther: 'IV';  sHouseDesc: 'Az otthon �s a csal�d, amelybe az "�N" belesz�letik. Korai imprinting hat�sok'),
          (sHouseNumberArabic: '5';   sHouseNumberOther: '5';   sHouseDesc: 'A kreativit�s, az "�N" teremt� erej�nek meg�l�si ter�lete'),
          (sHouseNumberArabic: '6';   sHouseNumberOther: '6';   sHouseDesc: 'A mindennapos k�nyszer� vagy k�telez� rutin, a periodikusan ism�tl�d� tev�kenys�gek h�za'),
          (sHouseNumberArabic: '7';   sHouseNumberOther: 'VII'; sHouseDesc: 'A "TE", a t�rs, a m�sik ember ter�lete'),
          (sHouseNumberArabic: '8';   sHouseNumberOther: '7';   sHouseDesc: 'A transzform�ci� ter�lete'),
          (sHouseNumberArabic: '9';   sHouseNumberOther: '9';   sHouseDesc: 'Az id�ben, t�rben t�voli �gyek'),
          (sHouseNumberArabic: '10';  sHouseNumberOther: 'X';   sHouseDesc: 'Az egy�n szerepe a t�rsadalmi munkamegoszt�sban'),
          (sHouseNumberArabic: '11';  sHouseNumberOther: '11';  sHouseDesc: 'A f�gg�s �s f�ggetlened�s h�za'),
          (sHouseNumberArabic: '12';  sHouseNumberOther: '12';  sHouseDesc: 'Az �lethosszig tart� neh�zs�gek, terhek, korl�toz�sok')
        );

      // ******************** Bet�t�pusok ******************** //

      cBASEFONTNAME    = 'MS Sans Serif';
      cBASEFONTNAME2   = 'Times New Roman';
      cBASEFONTNAME3   = 'Arial';
      cSYMBOLSFONTNAME = 'Regimontanus Astrological Symbols';

      cRETROGRADELETTER     = 'R';
      cSELFMARKERSIGNLETTER = '�';//'*';
      cASC_KEPLERLETTER = 'S';
      cMC_KEPLERLETTER  = 'D';

      // ******************** Bolyg� �s Zodi�kus adatok ******************** //

      cPLANETLIST : array[SE_SUN..SE_TRUE_MEAN_NODE_DOWN] of TPlanetNames =
        (
          (cPlanetLetter: 'a';   sPlanetName: 'Nap'),
          (cPlanetLetter: 's';   sPlanetName: 'Hold'),
          (cPlanetLetter: 'd';   sPlanetName: 'Merk�r'),
          (cPlanetLetter: 'f';   sPlanetName: 'V�nusz'),
          (cPlanetLetter: 'g';   sPlanetName: 'Mars'),
          (cPlanetLetter: 'h';   sPlanetName: 'Jupiter'),
          (cPlanetLetter: 'j';   sPlanetName: 'Szaturnusz'),
          (cPlanetLetter: 'k';   sPlanetName: 'Ur�nusz'),
          (cPlanetLetter: 'l';   sPlanetName: 'Neptunusz'),
          (cPlanetLetter: ';';   sPlanetName: 'Pl�t�'),
          (cPlanetLetter: 'A';   sPlanetName: 'Felsz.holdcs.(k�zepes)'),
          (cPlanetLetter: 'A';   sPlanetName: 'Felsz.holdcs.(val�di)'),
          (cPlanetLetter: 'Lil'; sPlanetName: 'Lilith'),
          (cPlanetLetter: 'Pri'; sPlanetName: 'Priapus'),
          (cPlanetLetter: 'L';   sPlanetName: 'F�ld'),
          (cPlanetLetter: 'K';   sPlanetName: 'Chiron'),
          (cPlanetLetter: 'Pho'; sPlanetName: 'Pholus'),
          (cPlanetLetter: 'F';   sPlanetName: 'Ceres'),
          (cPlanetLetter: 'G';   sPlanetName: 'Pallas Athene'),
          (cPlanetLetter: 'H';   sPlanetName: 'Juno'),
          (cPlanetLetter: 'J';   sPlanetName: 'Vesta'),
          (cPlanetLetter: ':';   sPlanetName: ''),
          (cPlanetLetter: ':';   sPlanetName: ''),
          (cPlanetLetter: ':';   sPlanetName: ''),
          (cPlanetLetter: 'Q';   sPlanetName: 'Lesz�ll� holdcsom�')
        );

      cZODIACANDPLANETLETTERS : array[cZDS_Kos..cZDS_Halak] of TZodiacSignAndPlanet =
        (
          (iZodiacID: cZDS_Kos;      iPlanetID: SE_MARS;    cZodiacLetter: 'q'; cZodiacsPlanetLetter: 'g'; sZodiacName: 'Kos';      sZodiacPlanetName: 'Mars';       sBulvarZodiacName: 'Kos';      sBulvarZodiacItemName: 'Kos [III.21 - IV.20]'),
          (iZodiacID: cZDS_Bika;     iPlanetID: SE_VENUS;   cZodiacLetter: 'w'; cZodiacsPlanetLetter: 'f'; sZodiacName: 'Bika';     sZodiacPlanetName: 'V�nusz';     sBulvarZodiacName: 'Bika';     sBulvarZodiacItemName: 'Bika [IV.21 - V.20]'),
          (iZodiacID: cZDS_Ikrek;    iPlanetID: SE_MERCURY; cZodiacLetter: 'e'; cZodiacsPlanetLetter: 'd'; sZodiacName: 'Ikrek';    sZodiacPlanetName: 'Merk�r';     sBulvarZodiacName: 'Ikrek';    sBulvarZodiacItemName: 'Ikrek [V.21 - VI.21]'),
          (iZodiacID: cZDS_Rak;      iPlanetID: SE_MOON;    cZodiacLetter: 'r'; cZodiacsPlanetLetter: 's'; sZodiacName: 'R�k';      sZodiacPlanetName: 'Hold';       sBulvarZodiacName: 'Rak';      sBulvarZodiacItemName: 'R�k [VI.22 - VII.22]'),
          (iZodiacID: cZDS_Oroszlan; iPlanetID: SE_SUN;     cZodiacLetter: 't'; cZodiacsPlanetLetter: 'a'; sZodiacName: 'Oroszl�n'; sZodiacPlanetName: 'Nap';        sBulvarZodiacName: 'Oroszlan'; sBulvarZodiacItemName: 'Oroszl�n [VII.23 - VIII.23]'),
          (iZodiacID: cZDS_Szuz;     iPlanetID: SE_MERCURY; cZodiacLetter: 'y'; cZodiacsPlanetLetter: 'd'; sZodiacName: 'Sz�z';     sZodiacPlanetName: 'Merk�r';     sBulvarZodiacName: 'Szuz';     sBulvarZodiacItemName: 'Sz�z [VIII.24 - IX.23]'),
          (iZodiacID: cZDS_Merleg;   iPlanetID: SE_VENUS;   cZodiacLetter: 'u'; cZodiacsPlanetLetter: 'f'; sZodiacName: 'M�rleg';   sZodiacPlanetName: 'V�nusz';     sBulvarZodiacName: 'Merleg';   sBulvarZodiacItemName: 'M�rleg [IX.24 - X.23'),
          (iZodiacID: cZDS_Skorpio;  iPlanetID: SE_PLUTO;   cZodiacLetter: 'i'; cZodiacsPlanetLetter: ';'; sZodiacName: 'Skorpi�';  sZodiacPlanetName: 'Pl�t�';      sBulvarZodiacName: 'Skorpio';  sBulvarZodiacItemName: 'Skorpi� [X.24 - XI.22'),
          (iZodiacID: cZDS_Nyilas;   iPlanetID: SE_JUPITER; cZodiacLetter: 'o'; cZodiacsPlanetLetter: 'h'; sZodiacName: 'Nyilas';   sZodiacPlanetName: 'Jupiter';    sBulvarZodiacName: 'Nyilas';   sBulvarZodiacItemName: 'Nyilas [XI.23 - XII.21]'),
          (iZodiacID: cZDS_Bak;      iPlanetID: SE_SATURN;  cZodiacLetter: 'p'; cZodiacsPlanetLetter: 'j'; sZodiacName: 'Bak';      sZodiacPlanetName: 'Szaturnusz'; sBulvarZodiacName: 'Bak';      sBulvarZodiacItemName: 'Bak [XII.22 - I.20]'),
          (iZodiacID: cZDS_Vizonto;  iPlanetID: SE_URANUS;  cZodiacLetter: '['; cZodiacsPlanetLetter: 'k'; sZodiacName: 'V�z�nt�';  sZodiacPlanetName: 'Ur�nusz';    sBulvarZodiacName: 'Vizonto';  sBulvarZodiacItemName: 'V�z�nt� [I.21 - II.19]'),
          (iZodiacID: cZDS_Halak;    iPlanetID: SE_NEPTUNE; cZodiacLetter: ']'; cZodiacsPlanetLetter: 'l'; sZodiacName: 'Halak';    sZodiacPlanetName: 'Neptunusz';  sBulvarZodiacName: 'Halak';    sBulvarZodiacItemName: 'Halak [II.20 - III.20]')
        );

      // ******************** F�nysz�g adatok ******************** //

      cFSZ_EGYUTTALLAS      = 1;
      cFSZ_SZEMBENALLAS     = 2;
      cFSZ_NEGYEDFENY       = 3;
      cFSZ_NYOLCADFENY      = 4;
      cFSZ_3NYOLCADFENY     = 5;
      cFSZ_HARMADFENY       = 6;
      cFSZ_HATODFENY        = 7;
      cFSZ_TIZENKETTEDFENY  = 8;
      cFSZ_5TIZENKETTEDFENY = 9;
      cFSZ_OTODFENY         = 10;
      cFSZ_TIZEDFENY        = 11;
      cFSZ_2OTODFENY        = 12; 

      cFENYSZOGSETTINGS : array[cFSZ_EGYUTTALLAS..cFSZ_2OTODFENY] of TAspectValues =
        (
           // V�z eneregia
           (cAspectLetter: 'z'; sAspectName: 'Egy�tt�ll�s';       sOtherAspectName : 'Konjunkci�';      iDeg:   0; iOrb: 15),

           // F�ld energia
           (cAspectLetter: 'x'; sAspectName: 'Szemben�ll�s';      sOtherAspectName : 'Oppoz�ci�';       iDeg: 180; iOrb: 7.5),
           (cAspectLetter: 'c'; sAspectName: 'Negyedf�ny';        sOtherAspectName : 'Kvadr�t';         iDeg:  90; iOrb: 4),
           (cAspectLetter: 'm'; sAspectName: 'Nyolcadf�ny';       sOtherAspectName : 'Semiquadrat';     iDeg:  45; iOrb: 2),   // oktil, semiquadrat, f�lkvadr�t
           (cAspectLetter: '<'; sAspectName: 'H�rom-nyolcadf�ny'; sOtherAspectName : 'Szeszkvikvadr�t'; iDeg: 135; iOrb: 2),

           // Leveg� energia
           (cAspectLetter: 'b'; sAspectName: 'Harmadf�ny';        sOtherAspectName : 'Trigon';          iDeg: 120; iOrb: 5),
           (cAspectLetter: 'n'; sAspectName: 'Hatodf�ny';         sOtherAspectName : 'Szextil';         iDeg:  60; iOrb: 2.5),
           (cAspectLetter: '>'; sAspectName: 'Tizenkettedf�ny';   sOtherAspectName : 'Szemiszextil';    iDeg:  30; iOrb: 1),
           (cAspectLetter: '?'; sAspectName: '�t-tizenkettedf�ny';sOtherAspectName : 'Kvinkunx';        iDeg: 150; iOrb: 1),

           // T�z energia
           (cAspectLetter: '�'; sAspectName: '�t�df�ny';          sOtherAspectName : 'Kvintil';         iDeg:  72; iOrb: 3),
           (cAspectLetter: '�'; sAspectName: 'Tizedf�ny';         sOtherAspectName : 'Decil';           iDeg:  36; iOrb: 2.5),
           (cAspectLetter: '�'; sAspectName: 'K�t-�t�df�ny';      sOtherAspectName : 'Bikvintil';       iDeg: 144; iOrb: 3)
        );

      // ******************** J�rt- H�ratlan �t ******************************** //

      cJARTJARATLANZODIACs: array[1..3, 1..4] of byte =
        (
          (cZDS_Kos,      cZDS_Bak,  cZDS_Merleg,  cZDS_Rak),
          (cZDS_Oroszlan, cZDS_Bika, cZDS_Vizonto, cZDS_Skorpio),
          (cZDS_Nyilas,   cZDS_Szuz, cZDS_Ikrek,   cZDS_Halak)
        );

      // ******************** Be�ll�t�sok INI file sections ******************** //

      cGRP_chkbZodiakusJelek = 'chkbZodiakusJelek';
      cGRPITM_chkbZodiakusJelek_AnalogPlanet_KELL_E = 'KELL_E_ANALOG';
      cGRPITM_chkbZodiakusJelek : array[0..11] of TAssignSettingsINI =
        (
          (sItemName: 'KOS'; iAssignedItem: cZDS_Kos),
          (sItemName: 'BIKA'; iAssignedItem: cZDS_Bika),
          (sItemName: 'IKREK'; iAssignedItem: cZDS_Ikrek),
          (sItemName: 'RAK'; iAssignedItem: cZDS_Rak),
          (sItemName: 'OROSZLAN'; iAssignedItem: cZDS_Oroszlan),
          (sItemName: 'SZUZ'; iAssignedItem: cZDS_Szuz),
          (sItemName: 'MERLEG'; iAssignedItem: cZDS_Merleg),
          (sItemName: 'SKORPIO'; iAssignedItem: cZDS_Skorpio),
          (sItemName: 'NYILAS'; iAssignedItem: cZDS_Nyilas),
          (sItemName: 'BAK'; iAssignedItem: cZDS_Bak),
          (sItemName: 'VIZONTO'; iAssignedItem: cZDS_Vizonto),
          (sItemName: 'HALAK'; iAssignedItem: cZDS_Halak)
        );

      cGRP_chkbHazHatarok = 'chkbHazHatarok';
      cGRPITM_chkbHazHatarok : array[0..11] of TAssignSettingsINI =
        (
          (sItemName: 'HOUSE_1'; iAssignedItem: cHSN_House01),
          (sItemName: 'HOUSE_2'; iAssignedItem: cHSN_House02),
          (sItemName: 'HOUSE_3'; iAssignedItem: cHSN_House03),
          (sItemName: 'HOUSE_4'; iAssignedItem: cHSN_House04),
          (sItemName: 'HOUSE_5'; iAssignedItem: cHSN_House05),
          (sItemName: 'HOUSE_6'; iAssignedItem: cHSN_House06),
          (sItemName: 'HOUSE_7'; iAssignedItem: cHSN_House07),
          (sItemName: 'HOUSE_8'; iAssignedItem: cHSN_House08),
          (sItemName: 'HOUSE_9'; iAssignedItem: cHSN_House09),
          (sItemName: 'HOUSE_10'; iAssignedItem: cHSN_House10),
          (sItemName: 'HOUSE_11'; iAssignedItem: cHSN_House11),
          (sItemName: 'HOUSE_12'; iAssignedItem: cHSN_House12)
        );

      cGRP_chkbHazSzamok = 'chkbHazSzamok';
      cGRPITM_chkbHazSzamok : array[0..11] of TAssignSettingsINI =
        (
          (sItemName: 'HOUSE_1'; iAssignedItem: cHSN_House01),
          (sItemName: 'HOUSE_2'; iAssignedItem: cHSN_House02),
          (sItemName: 'HOUSE_3'; iAssignedItem: cHSN_House03),
          (sItemName: 'HOUSE_4'; iAssignedItem: cHSN_House04),
          (sItemName: 'HOUSE_5'; iAssignedItem: cHSN_House05),
          (sItemName: 'HOUSE_6'; iAssignedItem: cHSN_House06),
          (sItemName: 'HOUSE_7'; iAssignedItem: cHSN_House07),
          (sItemName: 'HOUSE_8'; iAssignedItem: cHSN_House08),
          (sItemName: 'HOUSE_9'; iAssignedItem: cHSN_House09),
          (sItemName: 'HOUSE_10'; iAssignedItem: cHSN_House10),
          (sItemName: 'HOUSE_11'; iAssignedItem: cHSN_House11),
          (sItemName: 'HOUSE_12'; iAssignedItem: cHSN_House12)
        );

      cGRP_chkbTengelyek = 'chkbTengelyek';
      cGRPITM_chkbTengelyek : array[0..7] of string[10] = 
        ('AC', 'MC', 'DC', 'IC', 'VTX', 'EP', 'CAC', 'PAC');

      cGRP_chkbBolygok = 'chkbBolygok';
      cGRPITM_chkbBolygok : array[0..9] of TAssignSettingsINI =
        (
          (sItemName: 'SUN'; iAssignedItem: SE_SUN),
          (sItemName: 'MOON'; iAssignedItem: SE_MOON),
          (sItemName: 'MERCURY'; iAssignedItem: SE_MERCURY),
          (sItemName: 'VENUS'; iAssignedItem: SE_VENUS),
          (sItemName: 'MARS'; iAssignedItem: SE_MARS),
          (sItemName: 'JUPITER'; iAssignedItem: SE_JUPITER),
          (sItemName: 'SATURN'; iAssignedItem: SE_SATURN),
          (sItemName: 'URANUS'; iAssignedItem: SE_URANUS),
          (sItemName: 'NEPTUNE'; iAssignedItem: SE_NEPTUNE),
          (sItemName: 'PLUTO'; iAssignedItem: SE_PLUTO)
        );

      cGRP_chkbKisBolygok = 'chkbKisBolygok';
      cGRPITM_chkbKisBolygok : array[0..7] of TAssignSettingsINI =
        (
          (sItemName: 'CHIRON'; iAssignedItem: SE_CHIRON),
          (sItemName: 'PHOLUS'; iAssignedItem: SE_PHOLUS),
          (sItemName: 'CERES'; iAssignedItem: SE_CERES),
          (sItemName: 'PALLAS'; iAssignedItem: SE_PALLAS),
          (sItemName: 'JUNO'; iAssignedItem: SE_JUNO),
          (sItemName: 'VESTA'; iAssignedItem: SE_VESTA),
          (sItemName: 'ERIS'; iAssignedItem: SE_ERIS),
          (sItemName: 'LILITH'; iAssignedItem: SE_MEAN_APOG)
        );

      cGRP_chkbHoldcsomo = 'chkbHoldcsomo';
      cGRPITM_chkbHoldcsomo : array[0..1] of string[10] =
        ('FELSZ_NODE', 'LESZ_NODE');

      cGRP_chkbHoldocsomoTipus = 'chkbHoldocsomoTipus';
      cGRPITM_chkbHoldcsomoTipus : array[0..1] of string[10] =
        ('MEAN_NODE', 'TRUE_NODE');

      cGRP_chkbFenyszogek = 'chkbFenyszogek';
      cGRPITM_chkbFenyszogek : array[0..11] of TAssignSettingsINI =
        (
          (sItemName: 'KONJUKCIO'; iAssignedItem: cFSZ_EGYUTTALLAS),
          (sItemName: 'OPPOZICIO'; iAssignedItem: cFSZ_SZEMBENALLAS),
          (sItemName: 'KVADRAT'; iAssignedItem: cFSZ_NEGYEDFENY),
          (sItemName: 'SEMIQUADRAT'; iAssignedItem: cFSZ_NYOLCADFENY),
          (sItemName: 'SZESZKVIKVADRAT'; iAssignedItem: cFSZ_3NYOLCADFENY),
          (sItemName: 'TRIGON'; iAssignedItem: cFSZ_HARMADFENY),
          (sItemName: 'SZEXTIL'; iAssignedItem: cFSZ_HATODFENY),
          (sItemName: 'SZEMISZEXTIL'; iAssignedItem: cFSZ_TIZENKETTEDFENY),
          (sItemName: 'KVINKUNX'; iAssignedItem: cFSZ_5TIZENKETTEDFENY),
          (sItemName: 'KVINTIL'; iAssignedItem: cFSZ_OTODFENY),
          (sItemName: 'DECIL'; iAssignedItem: cFSZ_TIZEDFENY),
          (sItemName: 'BIKVINTIL'; iAssignedItem: cFSZ_2OTODFENY)
        );

      cGRP_chkbFenyszogJelek = 'chkbFenyszogJelek';
      cGRPITM_chkbFenyszogJelek : array[0..11] of string[20] =
        ('KONJUKCIO', 'OPPOZICIO', 'KVADRAT', 'SEMIQUADRAT', 'SZESZKVIKVADRAT', 'TRIGON', 'SZEXTIL', 'SZEMISZEXTIL',
         'KVINKUNX', 'KVINTIL', 'DECIL', 'BIKVINTIL');

      cGRP_chkbFenyszogeltTengelyek = 'chkbFenyszogeltTengelyek';
      cGRPITM_chkbFenyszogeltTengelyek : array[0..3] of TAssignSettingsINI =
        (
          (sItemName: 'AC'; iAssignedItem: SE_ASC),
          (sItemName: 'MC'; iAssignedItem: SE_MC),
          (sItemName: 'DC'; iAssignedItem: 255),
          (sItemName: 'IC'; iAssignedItem: 255)
        );

      cGRP_chkbFenyszogeltCsompontok = 'chkbFenyszogeltCsompontok';
      cGRPITM_chkbFenyszogeltCsompontok : array[0..1] of string[10] =
        ('FELSZ_NODE', 'LESZ_NODE');

      cGRP_chkbFenyszogeltHazak = 'chkbFenyszogeltHazak';
      cGRPITM_chkbFenyszogeltHazak : array[0..11] of TAssignSettingsINI =
        (
          (sItemName: 'HOUSE_1'; iAssignedItem: cHSN_House01),
          (sItemName: 'HOUSE_2'; iAssignedItem: cHSN_House02),
          (sItemName: 'HOUSE_3'; iAssignedItem: cHSN_House03),
          (sItemName: 'HOUSE_4'; iAssignedItem: cHSN_House04),
          (sItemName: 'HOUSE_5'; iAssignedItem: cHSN_House05),
          (sItemName: 'HOUSE_6'; iAssignedItem: cHSN_House06),
          (sItemName: 'HOUSE_7'; iAssignedItem: cHSN_House07),
          (sItemName: 'HOUSE_8'; iAssignedItem: cHSN_House08),
          (sItemName: 'HOUSE_9'; iAssignedItem: cHSN_House09),
          (sItemName: 'HOUSE_10'; iAssignedItem: cHSN_House10),
          (sItemName: 'HOUSE_11'; iAssignedItem: cHSN_House11),
          (sItemName: 'HOUSE_12'; iAssignedItem: cHSN_House12)
        );

      cGRP_chkbFenyszogeltBolygok = 'chkbFenyszogeltBolygok';
      cGRPITM_chkbFenyszogeltBolygok : array[0..9] of TAssignSettingsINI =
        (
          (sItemName: 'SUN'; iAssignedItem: SE_SUN),
          (sItemName: 'MOON'; iAssignedItem: SE_MOON),
          (sItemName: 'MERCURY'; iAssignedItem: SE_MERCURY),
          (sItemName: 'VENUS'; iAssignedItem: SE_VENUS),
          (sItemName: 'MARS'; iAssignedItem: SE_MARS),
          (sItemName: 'JUPITER'; iAssignedItem: SE_JUPITER),
          (sItemName: 'SATURN'; iAssignedItem: SE_SATURN),
          (sItemName: 'URANUS'; iAssignedItem: SE_URANUS),
          (sItemName: 'NEPTUNE'; iAssignedItem: SE_NEPTUNE),
          (sItemName: 'PLUTO'; iAssignedItem: SE_PLUTO)
        );

      cGRP_chkbFenyszogeltKisBolygok = 'chkbFenyszogeltKisBolygok';
      cGRPITM_chkbFenyszogeltKisBolygok : array[0..7] of TAssignSettingsINI =
        (
          (sItemName: 'CHIRON'; iAssignedItem: SE_CHIRON),
          (sItemName: 'PHOLUS'; iAssignedItem: SE_PHOLUS),
          (sItemName: 'CERES'; iAssignedItem: SE_CERES),
          (sItemName: 'PALLAS'; iAssignedItem: SE_PALLAS),
          (sItemName: 'JUNO'; iAssignedItem: SE_JUNO),
          (sItemName: 'VESTA'; iAssignedItem: SE_VESTA),
          (sItemName: 'ERIS'; iAssignedItem: SE_ERIS),
          (sItemName: 'LILITH'; iAssignedItem: SE_MEAN_APOG)
        );

      cGRP_chkbEgyebMegjelenitesek = 'chkbEgyebMegjelenitesek';
      cGRPITM_chkbEgyebMegjelenitesek : array[0..5] of string[30] =
        ('SELFMARKERS', 'RETROGADE', 'PLANETDEG', 'HOUSELORDS', 'HOUSENUMSBYARABICNUMBERS', 'SELFMARKERATORIGPLACE');

      cGRP_chkbFokjelolok = 'chkbFokjelolok';
      cGRPITM_chkbFokjelolok : array[0..4] of string[20] =
        ('OUTERZODIACDEG', 'INNERZODIACDEG', 'INNERASPECTDEG', 'HOUSEDEG', 'ZODIACDEGKULON');

      cGRP_chkbBolygoTablazat = 'chkbBolygoTablazat';
      cGRPITM_chkbBolygoTablazat_KELL_E = 'KELL_E';
      cGRPITM_chkbBolygoTablazat : array[0..3] of string[10] =
        ('PLANETDEG', 'ZODIACSIGN', 'HOUSENUM', 'HOUSELORDS');

      cGRP_chkbHazTablazat = 'chkbHazTablazat';
      cGRPITM_chkbHazTablazat_KELL_E = 'KELL_E';
      cGRPITM_chkbHazTablazat : array[0..1] of string[10] =
        ('HOUSEDEG', 'ZODIACSIGN');

      cGRP_chkbFenyszogTablazat = 'chkbFenyszogTablazat';
      cGRPITM_chkbFenyszogTablazat_KELL_E = 'KELL_E';

      cGRP_chkbFejlecKijelzesek = 'chkbFejlecKijelzesek';
      cGRPITM_chkbFejlecKijelzesek_KELL_E = 'KELL_E';
      cGRPITM_chkbFejlecKijelzesek : array[0..11] of string[15] =
        ('NAME', 'BIRTHDATE', 'BIRTHTIME', 'BIRTHDAY', 'TIMEZONE', 'DST', 'UT', 'ST', 'PRINTTYPE', 'BIRTHPLACE', 'BIRTCOORD', 'HOUSESYSTEM');

      cGRP_chkbLablecKijelzesek = 'chkbLablecKijelzesek';
      cGRPITM_chkbLablecKijelzesek_KELL_E = 'KELL_E';
      cGRPITM_chkbLablecKijelzesek : array[0..1] of string[10] =
        ('BASEINFO', 'REGINFO');

      cGRP_chkbEletStratTablazat = 'chkbEletStratTablazat';
      cGRPITM_chkbEletStratTablazat_KELL_E = 'KELL_E';

      cGRP_chkbNyomtatas = 'chkbNyomtatasSzinesben';
      cGRPITM_chkbNyomtatasSzinesben = 'NyomtatSzinesben';

      cGRP_chkbHazrendszer = 'chkbHazrendszer';
      cGRPITM_chkbHazrendszer = 'Hazrendszer';

      cGRP_chkbZodiakus = 'chkbZodiakus';
      cGRPITM_chkbZodiakus = 'Zodiakus';

      cGRP_chkbInditasTeljesMeret = 'chkbProgramInditas';
      cGRPITM_chkbInditasTeljesMeret = 'InditasTeljesMeretben';

      cGRP_chkbZodiakusBackGroundColor = 'chkbZodiakusBackGroundColor';
      cGRPITM_chkbZodiakusBackGroundColor : array[0..3] of string[15] =
        ('TUZES', 'FOLDES', 'LEVEGOS', 'VIZES');

      cGRP_chkbFenyszogColor = 'chkbFenyszogColor';
      cGRPITM_chkbFenyszogColor : array[cFSZ_EGYUTTALLAS..cFSZ_2OTODFENY] of string[25] =
        ('Konjunkcio', 'Oppozicio', 'Kvadrat', 'Semiquadrat', 'Szeszkvikvadrat', 'Trigon', 'Szextil',
         'Szemiszextil', 'Kvinkunx', 'Kvintil', 'Decil', 'Bikvintil' );

      cGRP_chkbFenyszogHatterSzine = 'chkbFenyszogekBackgroundColor';
      cGRPITM_chkbFenyszogHatterSzine = 'FenyszogBackgroundColor';

      cASPECTITEMSTYLE : array[1..3] of TAspectStyleRec =
        (
          (sItemName : 'Sima';       psPenStyle : psSolid),
          (sItemName : 'Szaggatott'; psPenStyle : psDash),
          (sItemName : 'Pettyezett'; psPenStyle : psDot)
        );

      cGRP_chkbFenyszogStyle = 'chkbFenyszogStyle';
      cGRPITM_chkbFenyszogStlye : array[cFSZ_EGYUTTALLAS..cFSZ_2OTODFENY] of string[25] =
        ('Konjunkcio', 'Oppozicio', 'Kvadrat', 'Semiquadrat', 'Szeszkvikvadrat', 'Trigon', 'Szextil',
         'Szemiszextil', 'Kvinkunx', 'Kvintil', 'Decil', 'Bikvintil' );

      cGRP_chkbEgyebek = 'chkbEgyebek';
      cGRPITM_chkbEgyebek : array[1..3] of string[25] =
        ('TelepulesDB', 'KivalTelepules', 'LastOpenedFilesNum');

      cGRP_rgrpEnallapotJelolMod = 'rgrpEnallapotJelolMod';
      cGRPITM_rgrpEnallapotJelolMod = 'JelolesMod';

      cGRP_dlgExportHelye = 'dlgExportHelye';
      cGRPITM_dlgExportHelye = 'ExportalasHelye';

      cGRP_BetumeretSzorzo = 'grpBetumeretSzorzo';
      cGRPITM_BetumeretSzorzo = 'BetumeretSzorzo';

implementation

end.
