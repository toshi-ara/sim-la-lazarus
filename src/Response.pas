unit Response;

{$mode objfpc}{$H+}

interface

uses
  math,
  ConstValues, DrugParameters, MyStat;

function GetCircleNumber(const X: Integer; const Y: Integer;
                         const Circles: TPositionArray): Integer;
function GetProbability(const time: Double;
                        const drugType: Integer;
                        const params: TParamArray): Double;



implementation

const
  ProbThreshold = 0.05;  { threshold of probability not to respond }

function GetCircleNumber(const X: Integer; const Y: Integer;
                         const Circles: TPositionArray): Integer;
var
  i, number: Integer;
begin
  number := -1;
  for i := 0 to High(Circles) do
  begin
    if (X - Circles[i][0])**2 + (Y - Circles[i][1])**2 <= RADIUS**2 then
    begin
      number := i;
      break;
    end
  end;
  Result := number;
end;


{ time (min) }
function GetProbability(const time: Double;
                        const drugType: Integer;
                        const params: TParamArray): Double;
var
  X, prob: Double;
  param: TParam;    { Mean, SD, adr }
begin
  { get probability at each drugType }
  if drugType = 0 then  { saline }
  begin
    if time < 30.0 then prob := 0.99 else prob := 1.0;
  end
  else  { other drugs }
  begin
    param := params[drugType - 1];
    X := 100 - (1 - param[2]) * time;
    prob := NormalCDF((X - param[0]) / param[1], True);

    { not respond when probability is less than threshold }
    if prob < ProbThreshold then
    begin
      prob := 0.0;
    end;
  end;

  Result := prob;
end;

end.

