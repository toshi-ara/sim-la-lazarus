unit VariableTimerUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

type
  { TTimer }
  TVariableTimer = class
  private
    FRunning: Boolean;
    FLastTick: Int64;
    FVirtual: Int64;
    FSpeed: Double;
    function GetNow: Int64;
  public
    constructor Create;
    procedure Start;
    procedure Pause;
    procedure Reset;
    procedure Update;
    procedure ChangeSpeed(ANewSpeed: Double);
    function GetMillis: Int64;
    function GetSeconds: Double;
    function GetMinutes: Double;
    property Speed: Double read FSpeed write ChangeSpeed;
    property Running: Boolean read FRunning;
  end;



implementation

constructor TVariableTimer.Create;
begin
  Reset;
end;

function TVariableTimer.GetNow: Int64;
begin
  Result := GetTickCount64;  { msec }
end;

procedure TVariableTimer.Start;
begin
  if not FRunning then
  begin
    FLastTick := GetNow;
    FRunning := True;
  end;
end;

procedure TVariableTimer.Pause;
begin
  if FRunning then
  begin
    Update;
    FRunning := False;
  end;
end;

procedure TVariableTimer.Reset;
begin
  FRunning := False;
  FVirtual := 0;
  FSpeed := 1.0;
end;

procedure TVariableTimer.Update;
var
  NowTick, Delta: Int64;
begin
  if not FRunning then Exit;

  NowTick := GetNow;
  Delta := NowTick - FLastTick;
  FLastTick := NowTick;

  FVirtual := FVirtual + Round(Delta * FSpeed);
end;


procedure TVariableTimer.ChangeSpeed(ANewSpeed: Double);
begin
  if FRunning then
  begin
    Update;
    FLastTick := GetNow;
  end;
  FSpeed := ANewSpeed;
end;


function TVariableTimer.GetMillis: Int64;
begin
  Result := FVirtual;
end;


function TVariableTimer.GetSeconds: Double;
begin
  Result := FVirtual / 1000.0;
end;

function TVariableTimer.GetMinutes: Double;
begin
  Result := FVirtual / 60000.0;
end;

end.
