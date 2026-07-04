unit TestFunctions;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, fpcunit, testutils, testregistry,
  Response, ConstValues, DrugParameters;

type
  TTestFunctions= class(TTestCase)
  const
    CENTERS: TPositionArray = (
      (200, 100), (300, 100), (400, 100),
      (200, 200), (300, 200), (400, 200)
    );
    radius = 20;

    param: TParamArray = (
      (50.0, 10.0, 0.0),
      (50.0, 10.0, 0.7),
      (0.0, 1.0, 0.0),
      (0.0, 1.0, 0.0),
      (0.0, 1.0, 0.0)
    );
    Delta = 1e-6;

  published
    procedure TestIsInCircleCenter;
    procedure TestIsInCircleXminus10;
    procedure TestIsInCircleXplus10;
    procedure TestIsInCircleYminus10;
    procedure TestIsInCircleYplus10;
    procedure TestIsInCircleXYplus10;
    procedure TestIsInCircleXYplus15;
    procedure TestGetCircleNumber;

    procedure TestGetProbability;
  end;

implementation

procedure TTestFunctions.TestIsInCircleCenter;
begin
  AssertTrue('(1) Center', isInCircle(200, 100, CENTERS[0], radius));
  AssertTrue('(2) Center', isInCircle(300, 100, CENTERS[1], radius));
  AssertTrue('(3) Center', isInCircle(400, 100, CENTERS[2], radius));
  AssertTrue('(4) Center', isInCircle(200, 200, CENTERS[3], radius));
  AssertTrue('(5) Center', isInCircle(300, 200, CENTERS[4], radius));
  AssertTrue('(6) Center', isInCircle(400, 200, CENTERS[5], radius));
end;

procedure TTestFunctions.TestIsInCircleXminus10;
begin
  AssertTrue('(1) X-10', isInCircle(200 - 10, 100, CENTERS[0], radius));
  AssertTrue('(2) X-10', isInCircle(300 - 10, 100, CENTERS[1], radius));
  AssertTrue('(3) X-10', isInCircle(400 - 10, 100, CENTERS[2], radius));
  AssertTrue('(4) X-10', isInCircle(200 - 10, 200, CENTERS[3], radius));
  AssertTrue('(5) X-10', isInCircle(300 - 10, 200, CENTERS[4], radius));
  AssertTrue('(6) X-10', isInCircle(400 - 10, 200, CENTERS[5], radius));
end;

procedure TTestFunctions.TestIsInCircleXplus10;
begin
  AssertTrue('(1) X+10', isInCircle(200 + 10, 100, CENTERS[0], radius));
  AssertTrue('(2) X+10', isInCircle(300 + 10, 100, CENTERS[1], radius));
  AssertTrue('(3) X+10', isInCircle(400 + 10, 100, CENTERS[2], radius));
  AssertTrue('(4) X+10', isInCircle(200 + 10, 200, CENTERS[3], radius));
  AssertTrue('(5) X+10', isInCircle(300 + 10, 200, CENTERS[4], radius));
  AssertTrue('(6) X+10', isInCircle(400 + 10, 200, CENTERS[5], radius));
end;

procedure TTestFunctions.TestIsInCircleYminus10;
begin
  AssertTrue('(1) Y-10', isInCircle(200, 100 - 10, CENTERS[0], radius));
  AssertTrue('(2) Y-10', isInCircle(300, 100 - 10, CENTERS[1], radius));
  AssertTrue('(3) Y-10', isInCircle(400, 100 - 10, CENTERS[2], radius));
  AssertTrue('(4) Y-10', isInCircle(200, 200 - 10, CENTERS[3], radius));
  AssertTrue('(5) Y-10', isInCircle(300, 200 - 10, CENTERS[4], radius));
  AssertTrue('(6) Y-10', isInCircle(400, 200 - 10, CENTERS[5], radius));
end;

procedure TTestFunctions.TestIsInCircleYplus10;
begin
  AssertTrue('(1) Y+10', isInCircle(200, 100 + 10, CENTERS[0], radius));
  AssertTrue('(2) Y+10', isInCircle(300, 100 + 10, CENTERS[1], radius));
  AssertTrue('(3) Y+10', isInCircle(400, 100 + 10, CENTERS[2], radius));
  AssertTrue('(4) Y+10', isInCircle(200, 200 + 10, CENTERS[3], radius));
  AssertTrue('(5) Y+10', isInCircle(300, 200 + 10, CENTERS[4], radius));
  AssertTrue('(6) Y+10', isInCircle(400, 200 + 10, CENTERS[5], radius));
end;

procedure TTestFunctions.TestIsInCircleXYplus10;
begin
  AssertTrue('(1) X+10, Y+10', isInCircle(200 + 10, 100 + 10, CENTERS[0], radius));
  AssertTrue('(2) X+10, Y+10', isInCircle(300 + 10, 100 + 10, CENTERS[1], radius));
  AssertTrue('(3) X+10, Y+10', isInCircle(400 + 10, 100 + 10, CENTERS[2], radius));
  AssertTrue('(4) X+10, Y+10', isInCircle(200 + 10, 200 + 10, CENTERS[3], radius));
  AssertTrue('(5) X+10, Y+10', isInCircle(300 + 10, 200 + 10, CENTERS[4], radius));
  AssertTrue('(6) X+10, Y+10', isInCircle(400 + 10, 200 + 10, CENTERS[5], radius));
end;

// x + 15, y + 15 => r = 21.21...
procedure TTestFunctions.TestIsInCircleXYplus15;
begin
  AssertFalse('(1) X+15, Y+15', isInCircle(200 + 15, 100 + 15, CENTERS[0], radius));
  AssertFalse('(2) X+15, Y+15', isInCircle(300 + 15, 100 + 15, CENTERS[1], radius));
  AssertFalse('(3) X+15, Y+15', isInCircle(400 + 15, 100 + 15, CENTERS[2], radius));
  AssertFalse('(4) X+15, Y+15', isInCircle(200 + 15, 200 + 15, CENTERS[3], radius));
  AssertFalse('(5) X+15, Y+15', isInCircle(300 + 15, 200 + 15, CENTERS[4], radius));
  AssertFalse('(6) X+15, Y+15', isInCircle(400 + 15, 200 + 15, CENTERS[5], radius));
end;

procedure TTestFunctions.TestGetCircleNumber;
begin
  AssertEquals('(1) Center', GetCircleNumber(200, 100, CENTERS, radius), 0);
  AssertEquals('(2) Center', GetCircleNumber(300, 100, CENTERS, radius), 1);
  AssertEquals('(3) Center', GetCircleNumber(400, 100, CENTERS, radius), 2);
  AssertEquals('(4) Center', GetCircleNumber(200, 200, CENTERS, radius), 3);
  AssertEquals('(5) Center', GetCircleNumber(300, 200, CENTERS, radius), 4);
  AssertEquals('(6) Center', GetCircleNumber(400, 200, CENTERS, radius), 5);
  AssertEquals('(7) Outer', GetCircleNumber(221, 100, CENTERS, radius), -1);
end;

procedure TTestFunctions.TestGetProbability;
begin
  // without Adr
  AssertEquals('(1) phi(-0.7)', GetProbability(43.0, 1, param),
    0.241963652223073, Delta);
  AssertEquals('(2) phi(0.0)', GetProbability(50.0, 1, param),
    0.5, Delta);
  AssertEquals('(3) phi(0.5)', GetProbability(55.0, 1, param),
    0.691462461274013, Delta);
  AssertEquals('(4) phi(1.5)', GetProbability(65.0, 1, param),
    0.9331927987311419, Delta); // phi(1.5)

  // with Adr
  AssertEquals('(6) with Adr', GetProbability(120.0, 2, param),
    0.08075665923, Delta);
end;



initialization
  RegisterTest(TTestFunctions);

end.

