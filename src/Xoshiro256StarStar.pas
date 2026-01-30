//////////////////////////////////////
// Xoshiro256**
//  (coded by ChatGPT-5)
//////////////////////////////////////

unit Xoshiro256StarStar;

{$mode objfpc}{$H+}


interface

uses
  SysUtils;

type
  TXoshiro256SS = class
  private
    s: array[0..3] of QWord;
    function RotL(x: QWord; k: Integer): QWord;
  public
    constructor Create(seed: QWord);
    function NextUInt64: QWord;
    function NextDouble: Double;
  end;



implementation

function TXoshiro256SS.RotL(x: QWord; k: Integer): QWord;
begin
  Result := (x shl k) or (x shr (64 - k));
end;


function SplitMix64(var x: QWord): QWord;
begin
  x := x + $9E3779B97F4A7C15;
  Result := x;
  Result := (Result xor (Result shr 30)) * $BF58476D1CE4E5B9;
  Result := (Result xor (Result shr 27)) * $94D049BB133111EB;
  Result := Result xor (Result shr 31);
end;


constructor TXoshiro256SS.Create(seed: QWord);
var
  i: Integer;
  x: QWord;
begin
  inherited Create;
  if seed = 0 then
    raise Exception.Create('Seed must be non-zero');

  x := seed;
  for i := 0 to 3 do
    s[i] := SplitMix64(x);
end;


function TXoshiro256SS.NextUInt64: QWord;
var
  t: QWord;
begin
  Result := RotL(s[1] * 5, 7) * 9;

  t := s[1] shl 17;

  s[2] := s[2] xor s[0];
  s[3] := s[3] xor s[1];
  s[1] := s[1] xor s[2];
  s[0] := s[0] xor s[3];

  s[2] := s[2] xor t;
  s[3] := RotL(s[3], 45);
end;


function TXoshiro256SS.NextDouble: Double;
begin
  Result := (NextUInt64 shr 11) * (1.0 / 9007199254740992.0);
end;

end.

