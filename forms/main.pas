unit Main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  ComCtrls, FPReadPNG,
  ConstValues, DrugParameters, LangText, Response, VariableTimerUnit, Version;

const
  IntervalResponse = 300;  { duration to show response (msec) }
  CounterInitial = 1000;
  CounterIncrease = 500;

type
  TResult = record
    Time: Double;
    Drug: String;
    Response: Integer;
  end;

  { TForm1 }
  TForm1 = class(TForm)
    ButtonNewExp: TButton;
    ButtonStart: TButton;
    ButtonSave: TButton;
    ButtonQuit: TButton;
    ComboBoxLang: TComboBox;
    PaintBox1: TPaintBox;
    LabelResult: TLabel;
    LabelSpeed: TLabel;
    LabelTimer: TLabel;
    Panel1: TPanel;
    PanelImage: TPanel;
    PanelLeft: TPanel;
    PanelSpeed: TPanel;
    SaveDialog1: TSaveDialog;
    Timer1: TTimer;
    VariableTimer: TTimer;
    SliderSpeed: TTrackBar;
    procedure FormCreate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormDestroy();
    procedure ComboBoxLangChange();
    procedure ButtonNewExpClick();
    procedure ButtonStartClick();
    procedure ButtonQuitClick();
    procedure ButtonSaveClick();
    procedure PaintBox1Paint();
    procedure PaintBox1MouseDown(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure SliderSpeedChange();
    procedure Timer1Timer();
    procedure VariableTimerTimer();
    function ConfirmQuit(): Boolean;
    function IsRespond(site: Integer): Boolean;

  private
    FTimer: TVariableTimer;
    SelectedLang: TLang;
    IsClick: Boolean;  { for Timer }
    IsReset: Boolean;  { for Start / Restart }
    ResultArray: array of TResult;  { save results }
    CounterResult: Integer;
    CounterLimit: Integer;
    procedure Initialize();

  public

  end;

  { independent to GUI }
  function SecondsToHMS(TotalSeconds: Double): String;

var
  Form1: TForm1;



implementation

{$R *.lfm}

var
  IsResponse: Boolean;
  ImageBack1, ImageBack2: TPicture;
  CurrentImage: TPicture;



//////////////////////////////////
// Start / Initialize
//////////////////////////////////

procedure TForm1.FormCreate(Sender: TObject);
begin
  { Title }
  Self.Caption := 'Simulator of Local Anesthetics (version ' + Ver + ')';

  { Timer }
  FTimer := TVariableTimer.Create;

  { images }
  DoubleBuffered := True;
  ImageBack1 := TPicture.Create;
  ImageBack2 := TPicture.Create;
  ImageBack1.LoadFromResourceName(HInstance, 'ANIMAL_IMAGE1');
  ImageBack2.LoadFromResourceName(HInstance, 'ANIMAL_IMAGE2');

  { current image }
  CurrentImage := ImageBack1;
  PaintBox1.Invalidate;

  { ComboBox for language selection }
  ComboBoxLang.Items.Clear;
  ComboBoxLang.Items.AddObject('English', TObject(langEN));
  ComboBoxLang.Items.AddObject('日本語 (Japanese)', TObject(langJP));
  ComboBoxLang.Items.AddObject('中文（繁体）', TObject(langZHTW));
  // initial setting
  ComboBoxLang.ItemIndex := 0;  { English }
  SelectedLang := TLang(PtrInt(ComboBoxLang.Items.Objects[ComboBoxLang.ItemIndex]));

  { Slider }
  SliderSpeed.Min := 1;
  SliderSpeed.Max := 10;

  SetLength(ResultArray, 0);

  Initialize();
end;


procedure TForm1.Initialize();
begin
  SetParameters(Params);

  FTimer.Reset;
  FTimer.ChangeSpeed(1);
  SliderSpeed.Position := 1;
  Timer1.Interval := IntervalResponse;

  ButtonNewExp.Caption := GetText(Text_ButtonNewExp, SelectedLang);
  ButtonStart.Caption := GetText(Text_ButtonStart, SelectedLang);
  ButtonSave.Caption := GetText(Text_ButtonSave, SelectedLang);
  ButtonQuit.Caption := GetText(Text_ButtonQuit, SelectedLang);
  ButtonStart.Enabled := True;
  ButtonNewExp.Enabled := True;
  ButtonQuit.Enabled := True;

  LabelSpeed.Caption := Format('%s (x %d)',
    [GetText(Text_LabelSpeed, SelectedLang), SliderSpeed.Position]);

  LabelResult.Caption := '';

  IsReset := True;
  IsClick := False;

  CounterResult := 0;
  CounterLimit := CounterInitial;
  SetLength(ResultArray, CounterLimit);
end;


procedure TForm1.FormDestroy();
begin
  ImageBack1.Free;
  ImageBack2.Free;
  CurrentImage.Free;
end;


procedure TForm1.PaintBox1Paint();
begin
  if Assigned(CurrentImage) and Assigned(CurrentImage.Graphic) then
    PaintBox1.Canvas.Draw(0, 0, CurrentImage.Graphic);
end;



//////////////////////////////////
// Button => call procedure
//////////////////////////////////
{ NewExp }
procedure TForm1.ButtonNewExpClick();
begin
  if QuestionDlg(GetText(Text_LabelConfirm, SelectedLang),
                 GetText(Text_MsgNewExp, SelectedLang),
                 mtConfirmation,
                 [mrOk, GetText(Text_LabelYes, SelectedLang),
                  mrCancel, GetText(Text_LabelNo, SelectedLang),
                  'IsDefault'], 0) = mrOk then
  begin
    Initialize();
  end;
end;


{ Start / Stop / Restart }
procedure TForm1.ButtonStartClick();
begin
  if (FTimer.Running) then
  begin
    FTimer.Pause;
    ButtonStart.Caption := GetText(Text_ButtonRestart, SelectedLang);
    ButtonNewExp.Enabled := True;
    ButtonQuit.Enabled := True;
    ButtonSave.Enabled := True;
    ComboBoxLang.Enabled := True;
  end
  else
  begin
    IsReset := False;
    FTimer.Start;
    ButtonStart.Caption := GetText(Text_ButtonPause, SelectedLang);
    ButtonNewExp.Enabled := False;
    ButtonQuit.Enabled := False;
    ButtonSave.Enabled := False;
    ComboBoxLang.Enabled := False;
  end;
end;


{ Quit }
function TForm1.ConfirmQuit: Boolean;
begin
  Result := QuestionDlg(GetText(Text_LabelConfirm, SelectedLang),
                        GetText(Text_MsgQuit, SelectedLang),
                        mtConfirmation, 
                        [mrOk, GetText(Text_LabelYes, SelectedLang),
                         mrCancel, GetText(Text_LabelNo, SelectedLang),
                         'IsDefault'], 0) = mrOk;
end;

procedure TForm1.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
  CanClose := ConfirmQuit;
end;

procedure TForm1.ButtonQuitClick();
begin
  Close;
end;


{ Save Log }
procedure TForm1.ButtonSaveClick();
var
  i: Integer;
  SL: TStringList;
begin
  with SaveDialog1 do
  begin
    Filter := 'CSV files (*.csv)|*.csv|All files (*.*)|*.*';
    DefaultExt := 'csv';
    Options := [ofOverwritePrompt, ofPathMustExist, ofNoChangeDir];
  end;

  if SaveDialog1.Execute then
  begin
    SL := TStringList.Create;
    try
      { header }
      SL.Add('Time, Drug, Response');

      { data }
      for i:= 0 to CounterResult - 1 do
      begin
        SL.Add(Format('%.1f, %s, %d',
            [ResultArray[i].Time, ResultArray[i].Drug, ResultArray[i].Response]));
      end;

      { save as CSV }
      SL.SaveToFile(SaveDialog1.FileName, TEncoding.UTF8);
    finally
      SL.Free;
    end;
  end;
end;



//////////////////////////////////
// Slider / Timer
//////////////////////////////////
procedure TForm1.SliderSpeedChange();
begin
  if Assigned(FTimer) then
  begin
    FTimer.ChangeSpeed(SliderSpeed.Position);
    LabelSpeed.Caption := Format('%s (x %d)',
      [GetText(Text_LabelSpeed, SelectedLang), SliderSpeed.Position]);
  end;
end;

procedure TForm1.VariableTimerTimer();
begin
  if Assigned(FTimer) then
  begin
    FTimer.Update;
    LabelTimer.Caption := SecondsToHMS(FTimer.GetSeconds);
  end;
end;



//////////////////////////////////
// Click
//////////////////////////////////

procedure TForm1.PaintBox1MouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  circle: Integer;
  ResponseNum: Integer;
begin
  if not FTimer.Running then exit;
  if IsClick then exit;  { during responding image } 

  circle := Response.GetCircleNumber(X, Y, ConstValues.Circles);
  if circle = -1 then exit;  { outside circles }

  IsResponse := IsRespond(circle);

  { save data }
  if IsRespond(circle) then ResponseNum := 1 else ResponseNum := 0;
  ResultArray[CounterResult].Time := FTimer.GetMinutes();
  ResultArray[CounterResult].Drug := DrugName[circle];
  ResultArray[CounterResult].Response := ResponseNum;

  CounterResult := CounterResult + 1;
  if CounterResult = CounterLimit then
  begin
    CounterLimit := CounterLimit + CounterIncrease;
    SetLength(ResultArray, CounterLimit);
  end;

  if IsResponse then
  begin
    CurrentImage := ImageBack2;     // change image
    PaintBox1.Invalidate;           // redraw

    LabelTimer.Font.Color := clRed;
    LabelResult.Font.Color := clRed;
    LabelResult.Caption :=
      GetText(Text_LabelResponsePlus, SelectedLang);
  end
  else
  begin
    LabelResult.Caption :=
      GetText(Text_LabelResponseMinus, SelectedLang);
  end;

  IsClick := True;
  Timer1.Enabled := True;
end;


procedure TForm1.Timer1Timer();
begin
  if not FTimer.Running then exit;

  CurrentImage := ImageBack1;
  PaintBox1.Invalidate;

  LabelTimer.Font.Color := clBlack;
  LabelResult.Font.Color := clBlack;
  LabelResult.Caption := '';

  IsClick := False;
  Timer1.Enabled := False;
end;


function TForm1.IsRespond(site: Integer): Boolean;
var
  time, prob: Double;
begin
  time := FTimer.GetSeconds() / 60.0;  { convert to minute }
  prob := Response.GetProbability(time, site, Params);
  Result := Random() <= prob;
end;



//////////////////////////////////
// Language
//////////////////////////////////

procedure TForm1.ComboBoxLangChange();
begin
  SelectedLang := TLang(PtrInt(ComboBoxLang.Items.Objects[ComboBoxLang.ItemIndex]));

  if IsReset then
  begin
    ButtonStart.Caption := GetText(Text_ButtonStart, SelectedLang);
  end
  else
  begin
    ButtonStart.Caption := GetText(Text_ButtonRestart, SelectedLang);
  end;
  ButtonNewExp.Caption := GetText(Text_ButtonNewExp, SelectedLang);
  ButtonSave.Caption := GetText(Text_ButtonSave, SelectedLang);
  ButtonQuit.Caption := GetText(Text_ButtonQuit, SelectedLang);

  LabelSpeed.Caption := Format('%s (x %d)',
    [GetText(Text_LabelSpeed, SelectedLang), SliderSpeed.Position]);
end;



//////////////////////////////////
// Independent to GUI
//////////////////////////////////

function SecondsToHMS(TotalSeconds: Double): String;
var
  H, M, S: Integer;
begin
  H := Trunc(TotalSeconds) div 3600;
  M := (Trunc(TotalSeconds) mod 3600) div 60;
  S := Trunc(TotalSeconds) mod 60;
  Result := Format('%d:%.2d:%.2d', [H, M, S]);
end;

end.
