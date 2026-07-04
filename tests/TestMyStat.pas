unit TestMyStat;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, fpcunit, testutils, testregistry,
  MyStat;

type
  TMyStatTest= class(TTestCase)
  const
    Delta = 1e-6;

  published
    procedure TestNormalCDF_Lower;
    procedure TestNormalCDF_Upper;
  end;

implementation

procedure TMyStatTest.TestNormalCDF_Lower;
begin
  AssertEquals(NormalCDF(-0.7, False), 0.241963652223073, Delta);
  AssertEquals(NormalCDF(0.0,  False), 0.5, Delta);
  AssertEquals(NormalCDF(0.5,  False), 0.691462461274013, Delta);
  AssertEquals(NormalCDF(1.5,  False), 0.9331927987311419, Delta);
end;

procedure TMyStatTest.TestNormalCDF_Upper;
begin
  AssertEquals(NormalCDF(0.7,  True), 0.241963652223073, Delta);
  AssertEquals(NormalCDF(0.0,  True), 0.5, Delta);
  AssertEquals(NormalCDF(-0.5, True), 0.691462461274013, Delta);
  AssertEquals(NormalCDF(-1.5, True), 0.9331927987311419, Delta);
end;



initialization
  RegisterTest(TMyStatTest);

end.

