unit MyStat;

{$mode objfpc}{$H+}

interface

function NormalCDF(x: Double; upper: Boolean): Double;


implementation

const
  M_SQ_2 = 0.7071067811865475;

{
  Cumulative distribution function (CDF) of normal distribution
    Abramowitz and Stegun (1964) formula 7.1.26
    precision: abs(err) < 1.5e-7
}
function NormalCDF(x: Double; upper: Boolean): Double;
const
   a1 =  0.254829592;
   a2 = -0.284496736;
   a3 =  1.421413741;
   a4 = -1.453152027;
   a5 =  1.061405429;
   p  =  0.3275911;
var
  sign, signup: Integer;
  xx, t, erf: Double;
begin
  xx := Abs(x) * M_SQ_2;  { := Abs(x) / Sqrt(2); }
  t := 1 / (1 + p * xx);
  erf := 1 - (((((a5 * t + a4) * t) + a3) * t + a2) * t + a1) * t * Exp(-xx * xx);

  if x < 0 then sign := -1 else sign := 1;
  if upper then signup := -1 else signup := 1;
  Result := (1 + signup * sign * erf) * 0.5;
end;

end.

