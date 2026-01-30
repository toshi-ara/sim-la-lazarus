//////////////////////////////////////
// Random number generator for Multivariate normal distribution
//  using Cholesky Decomposition
//  (coded by ChatGPT-5)
//////////////////////////////////////

unit MultivariateNormal;

{$mode objfpc}{$H+}


interface

uses
  SysUtils, Xoshiro256StarStar;

type
  TVector = array of Double;
  TMatrix = array of array of Double;

  TMultivariateNormal = class
  private
    FDim: Integer;
    FMean: TVector;
    FL: TMatrix;
    FRng: TXoshiro256SS;

    function RandNormal: Double;
    procedure CholeskyDecomposition(const Cov: TMatrix);

  public
    // seed (+)
    constructor Create(
      const Mean: TVector;
      const Cov: TMatrix;
      Seed: QWord;
      N: Integer);

    // seed (-)
    constructor Create(
      const Mean: TVector;
      const Cov: TMatrix;
      N: Integer);

    procedure Sample(var X: TVector);
    destructor Destroy; override;
  end;



implementation

function TMultivariateNormal.RandNormal: Double;
var
  u1, u2: Double;
begin
  u1 := FRng.NextDouble;
  if u1 = 0.0 then u1 := 1e-16;
  u2 := FRng.NextDouble;
  Result := Sqrt(-2.0 * Ln(u1)) * Cos(2.0 * Pi * u2);
end;

procedure TMultivariateNormal.CholeskyDecomposition(
  const Cov: TMatrix);
var
  i, j, k: Integer;
  sum: Double;
begin
  SetLength(FL, FDim, FDim);

  for i := 0 to FDim - 1 do
    for j := 0 to i do
    begin
      sum := Cov[i][j];
      for k := 0 to j - 1 do
        sum := sum - FL[i][k] * FL[j][k];

      if i = j then
      begin
        if sum <= 0 then
          raise Exception.Create('Covariance matrix is not positive definite');
        FL[i][j] := Sqrt(sum);
      end
      else
        FL[i][j] := sum / FL[j][j];
    end;
end;


{ constructor: seed (+) }
constructor TMultivariateNormal.Create(
  const Mean: TVector;
  const Cov: TMatrix;
  Seed: QWord;
  N: Integer);
var
  i: Integer;
begin
  inherited Create;

  FDim := N;
  SetLength(FMean, FDim);
  for i := 0 to FDim - 1 do
    FMean[i] := Mean[i];

  FRng := TXoshiro256SS.Create(Seed);
  CholeskyDecomposition(Cov);
end;

{ constructor: seed (-) }
constructor TMultivariateNormal.Create(
  const Mean: TVector;
  const Cov: TMatrix;
  N: Integer);
var
  autoSeed: QWord;
begin
  Randomize;
  autoSeed :=
    QWord(GetTickCount64) xor
    // QWord(PtrUInt(@autoSeed)) xor
    QWord(Random($7FFFFFFF));
  Create(Mean, Cov, autoSeed, N);
end;


{ generate random number (sampling) }
procedure TMultivariateNormal.Sample(var X: TVector);
var
  Z: TVector;
  i, j: Integer;
begin
  if Length(X) <> FDim then
    raise Exception.Create('Dimension mismatch');

  Z := nil;
  SetLength(Z, FDim);

  for i := 0 to FDim - 1 do
    Z[i] := RandNormal;

  for i := 0 to FDim - 1 do
  begin
    X[i] := FMean[i];
    for j := 0 to i do
      X[i] := X[i] + FL[i][j] * Z[j];
  end;
end;


destructor TMultivariateNormal.Destroy;
begin
  FRng.Free;
  inherited Destroy;
end;

end.

