unit VariableTimerUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

type
  { TTimer }
  TVariableTimer = class
  private
    _isRunning: Boolean;
    _Speed: Double;
    LastTime: Int64;   { last time of operation }
    TotalElapsedTime: Int64;    { total elasped time }
    function GetNow(): Int64;
  public
    constructor Create;
    procedure Start();
    procedure Pause();
    procedure Reset();
    procedure Update();
    procedure ChangeSpeed(const NewSpeed: Double);
    function GetMillis(): Int64;
    function GetSeconds(): Double;
    function GetMinutes(): Double;
    property isRunning: Boolean read _isRunning write _isRunning;
    property Speed: Double read _Speed write ChangeSpeed;
  end;



implementation

constructor TVariableTimer.Create;
begin
  Reset();
end;


function TVariableTimer.GetNow(): Int64;
begin
  Result := GetTickCount64;  { msec }
end;


procedure TVariableTimer.Start();
begin
  if not _isRunning then
  begin
    LastTime := GetNow();
    isRunning := True;
  end;
end;


procedure TVariableTimer.Pause();
begin
  if _isRunning then
  begin
    Update();
    isRunning := False;
  end;
end;


procedure TVariableTimer.Reset();
begin
  _isRunning := False;
  TotalElapsedTime := 0;
  _Speed := 1.0;
end;


procedure TVariableTimer.Update();
var
  CurrentTime, Delta: Int64;
begin
  if _isRunning then
  begin
    CurrentTime := GetNow();
    Delta := CurrentTime - LastTime;  { time elapsed since LastTime }
    LastTime := CurrentTime;          { set new LastTime }

    TotalElapsedTime := TotalElapsedTime + Round(Delta * _Speed);
  end;
end;


procedure TVariableTimer.ChangeSpeed(const NewSpeed: Double);
begin
  if _isRunning then
  begin
    Update();
    LastTime := GetNow();
  end;
  _Speed := NewSpeed;
end;


function TVariableTimer.GetMillis(): Int64;
begin
  Result := TotalElapsedTime;
end;

function TVariableTimer.GetSeconds(): Double;
begin
  Result := TotalElapsedTime / 1000.0;
end;

function TVariableTimer.GetMinutes(): Double;
begin
  Result := TotalElapsedTime / 60000.0;
end;

end.
