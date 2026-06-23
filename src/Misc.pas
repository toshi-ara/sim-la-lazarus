unit Misc;

{$mode objfpc}{$H+}


interface

uses
  Sysutils, StrUtils, LCLTranslator, Translations;

function SecondsToHMS(const TotalSeconds: Double): String;
function getEnvironmentLang(): String;



implementation

function SecondsToHMS(const TotalSeconds: Double): String;
var
  H, M, S: Integer;
begin
  H := Trunc(TotalSeconds) div 3600;
  M := (Trunc(TotalSeconds) mod 3600) div 60;
  S := Trunc(TotalSeconds) mod 60;
  Result := Format('%d:%.2d:%.2d', [H, M, S]);
end;


{ get current Locale in environment variable `LANG` }
{
  en / en_*           -> en_US
  ja / ja_*           -> ja_JP
  ko / ko_*           -> ko_KR
  zh_* (except zh_TW) -> zh_CN
  others              -> en_US (fallback)
}
function getEnvironmentLang(): String;
var
  L: TLanguageID;
  p: Integer;
  Parts: TStringArray;
begin
  Result := Trim(GetEnvironmentVariable('LANG'));

  p := Pos('.', Result);
  if p > 0 then
    SetLength(Result, p - 1);

  if SameText(Result, 'C') or SameText(Result, 'POSIX') then
    Result := '';

  if Result = '' then
  { When LANG is undifined }
  begin
    L := GetLanguageID;

    if L.CountryCode <> '' then
      Result := L.LanguageCode + '_' + UpperCase(L.CountryCode)
    else
      Result := L.LanguageCode;
  end;

  { LANG conversion }
  Parts := SplitString(Result, '_');
  case Parts[0] of
    'en': Result := 'en_US';
    'ja': Result := 'ja_JP';
    'ko': Result := 'ko_KR';
    'zh': if Result <> 'zh_TW' then Result := 'zh_CN';
  else
    Result := 'en_US';  { fallback }
  end;
end;

end.

