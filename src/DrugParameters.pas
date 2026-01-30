unit DrugParameters;

{$mode objfpc}{$H+}


interface

uses
  MultivariateNormal;

type
  { for generated drug parameters: [Pro, Lid, Mep, Bup. Lid + Adr] }
  TParam = array[0..2] of Double;     { [Mean, SD, Adr] }
  TParamArray = array[0..4] of TParam;
  TMatrix = array of array of Double;

var
  Params: TParamArray;
  Cov: TMatrix;  { Covariance Matrix for drug parameters }

procedure SetParameters(var P: TParamArray);


implementation

type
  { drug parameter (population) }
  TParam0 = array[0..1] of Double;     { [Mean, SD] }
  TParam0Array = array[0..3] of TParam0;

const
  { Pro, Lid, Mep, Bup }
  MU0: TParam0Array = (
    (75, 8),
    (67, 5),
    (43, 6),
    (30, 10)
  );
  LOG_SIGMA0: TParam0Array = (
    (2.2, 0.4),
    (2.4, 0.4),
    (2.4, 0.4),
    (2.5, 0.5)
  );
  ADR = 0.7;

  { Covariance Matrix for drug parameters }
  { r between mean and logSigma }
  r1 = -0.22;  { Pro }
  r2 = -0.30;  { Lid }
  r3 = -0.01;  { Mep }
  r4 = -0.16;  { Bup }

  { mean among drugs }
  m12 = 0.57;  { Pro vs. Lid }
  m13 = 0.47;  { Pro vs. Mep }
  m14 = 0.50;  { Pro vs. Bup }
  m23 = 0.53;  { Lid vs. Mep }
  m24 = 0.53;  { Lid vs. Bup }
  m34 = 0.42;  { Mep vs. Bup }

  { logSigma among drugs }
  s12 = 0.42;  { Pro vs. Lid }
  s13 = 0.34;  { Pro vs. Mep }
  s14 = 0.26;  { Pro vs. Bup }
  s23 = 0.41;  { Lid vs. Mep }
  s24 = 0.47;  { Lid vs. Bup }
  s34 = 0.56;  { Mep vs. Bup }


procedure SetParameters(var P: TParamArray);
var
  i, n: Integer;
  Mean, X: TVector;
  MVN: TMultivariateNormal;
begin
  n := 8;
  Mean := nil;
  X := nil;
  SetLength(Mean, n);
  SetLength(X, n);

  Mean := [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0];
  MVN := TMultivariateNormal.Create(Mean, Cov, n);
  MVN.Sample(X);

  { Pro, Lid, Mep, Bup }
  for i:= 0 to 3 do
  begin
    P[i][0] := MU0[i][0] + MU0[i][1] * X[i];
    P[i][1] := Exp(LOG_SIGMA0[i][0] + LOG_SIGMA0[i][1] * X[i + 4]);
    P[i][2] := 0.0;
  end;

  { Lid + Adr }
  P[4][0] := P[1][0];
  P[4][1] := P[1][1];
  P[4][2] := ADR;
end;


initialization
  SetLength(Cov, 8, 8);
  {
    [
      [ 1,   m12, m13, m14, r1,  0,   0,   0   ],
      [ m12, 1,   m23, m24, 0,   r2,  0,   0   ],
      [ m13, m23, 1,   m34, 0,   0,   r3,  0   ],
      [ m14, m24, m34, 1,   0,   0,   0,   r4  ],
      [ r1,  0,   0,   0,   1,   s12, s13, s14 ],
      [ 0,   r2,  0,   0,   s12, 1,   s23, s24 ],
      [ 0,   0,   r3,  0,   s13, s23, 1,   s34 ],
      [ 0,   0,   0,   r4,  s14, s24, s34, 1   ]
    ];
  }
  Cov[0, 0] := 1;   Cov[0, 1] := m12; Cov[0, 2] := m13; Cov[0, 3] := m14;
  Cov[0, 4] := r1;  Cov[0, 5] := 0;   Cov[0, 6] := 0;   Cov[0, 7] := 0;

  Cov[1, 0] := m12; Cov[1, 1] := 1;   Cov[1, 2] := m23; Cov[1, 3] := m24;
  Cov[1, 4] := 0;   Cov[1, 5] := r2;  Cov[1, 6] := 0;   Cov[1, 7] := 0;

  Cov[2, 0] := m13; Cov[2, 1] := m23; Cov[2, 2] := 1;   Cov[2, 3] := m34;
  Cov[2, 4] := 0;   Cov[2, 5] := 0;   Cov[2, 6] := r3;  Cov[2, 7] := 0;

  Cov[3, 0] := m14; Cov[3, 1] := m24; Cov[3, 2] := m34; Cov[3, 3] := 1;
  Cov[3, 4] := 0;   Cov[3, 5] := 0;   Cov[3, 6] := 0;   Cov[3, 7] := r4;

  Cov[4, 0] := r1;  Cov[4, 1] := 0;   Cov[4, 2] := 0;   Cov[4, 3] := 0;
  Cov[4, 4] := 1;   Cov[4, 5] := s12; Cov[4, 6] := s13; Cov[4, 7] := s14;

  Cov[5, 0] := 0;   Cov[5, 1] := r2;  Cov[5, 2] := 0;   Cov[5, 3] := 0;
  Cov[5, 4] := s12; Cov[5, 5] := 1;   Cov[5, 6] := s23; Cov[5, 7] := s24;

  Cov[6, 0] := 0;   Cov[6, 1] := 0;   Cov[6, 2] := r3;  Cov[6, 3] := 0;
  Cov[6, 4] := s13; Cov[6, 5] := s23; Cov[6, 6] := 1;   Cov[6, 7] := s34;

  Cov[7, 0] := 0;   Cov[7, 1] := 0;   Cov[7, 2] := 0;   Cov[7, 3] := r4;
  Cov[7, 4] := s14; Cov[7, 5] := s24; Cov[7, 6] := s34; Cov[7, 7] := 1;

end.

