unit Main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  ComCtrls, FPReadPNG, LClType, LCLTranslator,
  ConstValues, DrugParameters, Misc, MultiLang, Response,
  VariableTimerUnit, Version;

const
  IntervalResponse = 300;  { duration to show response (msec) }
  CounterInitial = 1000;   { for data save }
  CounterIncrease = 500;

type
  { type for data save }
  TResult = record
    Time: Double;
    Drug: String;
    Response: Integer;
  end;

  { TForm1 }
  TForm1 = class(TForm)
    PanelLeft: TPanel;
    PanelSpeed: TPanel;
    PanelImage: TPanel;

    ButtonNewExp: TButton;
    ButtonStart: TButton;
    ButtonSave: TButton;
    ButtonQuit: TButton;
    ComboBoxLang: TComboBox;
    PaintBox1: TPaintBox;
    LabelResult: TLabel;
    LabelSpeed: TLabel;
    LabelTimer: TLabel;
    SliderSpeed: TTrackBar;

    SaveDialog1: TSaveDialog;
    Timer1: TTimer;
    VariableTimer: TTimer;

    procedure FormCreate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormDestroy();
    procedure ComboBoxLangChange();
    procedure ButtonNewExpClick();
    procedure ButtonStartClick();
    procedure ButtonQuitClick();
    procedure ButtonSaveClick();
    procedure SliderSpeedChange();

    procedure PaintBox1Paint();
    procedure PaintBox1MouseDown(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);

    procedure Timer1Timer();
    procedure VariableTimerTimer();

    function ConfirmQuit(): Boolean;
    function IsRespond(drugType: Integer): Boolean;

  private
    FTimer: TVariableTimer;
    IsClick: Boolean;  { for Timer }
    IsReset: Boolean;  { for Start / Restart }

    { data retention }
    ResultArray: array of TResult;
    CounterResult: Integer;
    CounterLimit: Integer;

    procedure SaveResourceToFile(const ResourceName: String; const TargetPath: String);
    procedure SetLocale();
    procedure Initialize();
  end;

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
var
  EnvLang: String;
  Index: Integer;
  Info: TLangInfo;
begin
  { Title }
  Self.Caption := 'Simulator of Local Anesthetics (version ' + Ver + ')';

  { Timer }
  FTimer := TVariableTimer.Create;

  { load images from Resource }
  DoubleBuffered := True;
  ImageBack1 := TPicture.Create;
  ImageBack2 := TPicture.Create;
  ImageBack1.LoadFromResourceName(HInstance, 'ANIMAL_IMAGE1');
  ImageBack2.LoadFromResourceName(HInstance, 'ANIMAL_IMAGE2');

  { set current image }
  CurrentImage := ImageBack1;
  PaintBox1.Invalidate;

  { get current Locale in environment variable `LANG` }
  EnvLang := Misc.GetEnvironmentLANG();

  { set initial index of ComboBox }
  Index := 0;
  for Info in LangInfoData do
  begin
    if Info.Lang = EnvLang then Break;
    Index := Index + 1;
  end;
  if Index > High(LangInfoData) then Index := 0; { fallback to en_US }

  { set ComboBox for language selection }
  ComboBoxLang.Items.Clear;
  for Info in LangInfoData do
  begin
    ComboBoxLang.Items.Add(Info.DisplayStr);
  end;

  ComboBoxLang.ItemIndex := Index;

  SetLocale();

  { Slider }
  SliderSpeed.Min := SliderSpeedMin;
  SliderSpeed.Max := SliderSpeedMax;

  { Array for preservetion of results}
  SetLength(ResultArray, 0);

  Initialize();
end;


{ called at first and at new experiment}
procedure TForm1.Initialize();
begin
  SetParameters(Params);

  FTimer.Reset;
  FTimer.ChangeSpeed(SliderSpeedMin);
  SliderSpeed.Position := SliderSpeedMin;
  Timer1.Interval := IntervalResponse;

  ButtonNewExp.Caption := rsButtonNewExp;
  ButtonStart.Caption := rsButtonStart;
  ButtonSave.Caption := rsButtonSave;
  ButtonQuit.Caption := rsButtonQuit;
  ButtonStart.Enabled := True;
  ButtonNewExp.Enabled := True;
  ButtonQuit.Enabled := True;

  LabelSpeed.Caption := Format('%s (x %d)', [rsLabelSpeed, SliderSpeed.Position]);

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


{ draw CurrentImage to PaintBox1 }
procedure TForm1.PaintBox1Paint();
var
  DestRect: TRect;
begin
  if Assigned(CurrentImage) and Assigned(CurrentImage.Graphic) then
  begin
    DestRect.Left := 0;
    DestRect.Top := 0;
    DestRect.Right := ScaleX(CurrentImage.Width, 96 * 2);
    DestRect.Bottom := ScaleY(CurrentImage.Height, 96 * 2);

    PaintBox1.Canvas.StretchDraw(DestRect, CurrentImage.Graphic);
  end;
end;


//////////////////////////////////
// Button => call procedure
//////////////////////////////////
{ NewExp }
procedure TForm1.ButtonNewExpClick();
begin
  if MessageDlg(rsLabelConfirm, rsMsgNewExp, mtConfirmation,
                [mbYes, mbNo], 0) = mrYes then
  begin
    Initialize();
  end;
end;


{ Start / Stop / Restart }
procedure TForm1.ButtonStartClick();
begin
  if (FTimer.isRunning) then
  begin
    FTimer.Pause;
    ButtonStart.Caption := rsButtonRestart;
    { enable buttons }
    ButtonNewExp.Enabled := True;
    ButtonQuit.Enabled := True;
    ButtonSave.Enabled := True;
    ComboBoxLang.Enabled := True;
  end
  else
  begin
    IsReset := False;
    FTimer.Start;
    ButtonStart.Caption := rsButtonPause;
    { disable buttons }
    ButtonNewExp.Enabled := False;
    ButtonQuit.Enabled := False;
    ButtonSave.Enabled := False;
    ComboBoxLang.Enabled := False;
  end;
end;


{ Quit }
function TForm1.ConfirmQuit: Boolean;
begin
  Result := MessageDlg(rsLabelConfirm, rsMsgQuit, mtConfirmation,
                       [mbYes, mbNo], 0) = mrYes;

end;

procedure TForm1.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
  CanClose := ConfirmQuit;
end;

procedure TForm1.ButtonQuitClick();
begin
  Close;
end;


{ Save data as CSV }
procedure TForm1.ButtonSaveClick();
var
  i: Integer;
  SL: TStringList;  { text data for CSV file }
begin
  { setting for save dialog }
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
      { write header }
      SL.Add('Time, Drug, Response');

      { write data: comma-separeted }
      for i:= 0 to CounterResult - 1 do
      begin
        SL.Add(Format('%.1f, %s, %d',
            [ResultArray[i].Time, ResultArray[i].Drug, ResultArray[i].Response]));
      end;

      { save data to file as UTF-8 }
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
    LabelSpeed.Caption := Format('%s (x %d)', [rsLabelSpeed, SliderSpeed.Position]);
  end;
end;

procedure TForm1.VariableTimerTimer();
begin
  if Assigned(FTimer) then
  begin
    FTimer.Update;
    LabelTimer.Caption := Misc.SecondsToHMS(FTimer.GetSeconds);
  end;
end;



//////////////////////////////////
// Click
//////////////////////////////////

procedure TForm1.PaintBox1MouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  drugType: Integer;
  ResponseNum: Integer;
  ScaledWidth, ScaledHeight: Integer; // Drawing size after applying magnification
  OriginalX, OriginalY: Integer;      // Original image coordinates after inverse scaling
begin
  if not FTimer.isRunning then exit;
  if IsClick then exit;  { during responding image }

  { Inverse coordinate transformation process based on screen zoom level }
  if Assigned(CurrentImage) and Assigned(CurrentImage.Graphic) then
  begin
    { Size of the (scaled) image currently displayed on the screen }
    ScaledWidth := ScaleX(CurrentImage.Width, 96 * 2);
    ScaledHeight := ScaleY(CurrentImage.Height, 96 * 2);

    { Prevent division by zero }
    if (ScaledWidth > 0) and (ScaledHeight > 0) then
    begin
      { Convert clicked screen coordinates (X, Y)
        to the coordinates of the original image size (100%) }
      OriginalX := MulDiv(X, CurrentImage.Width, ScaledWidth);
      OriginalY := MulDiv(Y, CurrentImage.Height, ScaledHeight);
    end
    else
    begin
      OriginalX := X;
      OriginalY := Y;
    end;
  end
  else
  begin
    OriginalX := X;
    OriginalY := Y;
  end;

  drugType := Response.GetCircleNumber(OriginalX, OriginalY, ConstValues.Circles);
  if drugType = -1 then exit;  { outside circles }

  IsResponse := IsRespond(drugType);

  { save data to ResultArray }
  if IsRespond(drugType) then ResponseNum := 1 else ResponseNum := 0;
  ResultArray[CounterResult].Time := FTimer.GetMinutes();
  ResultArray[CounterResult].Drug := DrugName[drugType];
  ResultArray[CounterResult].Response := ResponseNum;

  CounterResult := CounterResult + 1;
  if CounterResult = CounterLimit then
  begin
    CounterLimit := CounterLimit + CounterIncrease;
    SetLength(ResultArray, CounterLimit);
  end;

  if IsResponse then
  begin
    { change image and redraw }
    CurrentImage := ImageBack2;
    PaintBox1.Invalidate;

    LabelTimer.Font.Color := clRed;
    LabelResult.Font.Color := clRed;
    LabelResult.Caption := rsLabelResponsePlus;
  end
  else
  begin
    LabelResult.Caption := rsLabelResponseMinus;
  end;

  IsClick := True;
  Timer1.Enabled := True;
end;


procedure TForm1.Timer1Timer();
begin
  if not FTimer.isRunning then exit;

  { revert image and redraw }
  CurrentImage := ImageBack1;
  PaintBox1.Invalidate;

  LabelTimer.Font.Color := clBlack;
  LabelResult.Font.Color := clBlack;
  LabelResult.Caption := '';

  IsClick := False;
  Timer1.Enabled := False;
end;


function TForm1.IsRespond(drugType: Integer): Boolean;
var
  time, prob: Double;
begin
  time := FTimer.GetSeconds() / 60.0;  { convert to minute }
  prob := Response.GetProbability(time, drugType, Params);
  Result := Random() <= prob;
end;



//////////////////////////////////
// Language
//////////////////////////////////

procedure TForm1.ComboBoxLangChange();
begin
  SetLocale();

  if IsReset then
    ButtonStart.Caption := rsButtonStart
  else
    ButtonStart.Caption := rsButtonRestart;

  ButtonNewExp.Caption := rsButtonNewExp;
  ButtonSave.Caption := rsButtonSave;
  ButtonQuit.Caption := rsButtonQuit;

  LabelSpeed.Caption := Format('%s (x %d)', [rsLabelSpeed, SliderSpeed.Position]);
end;



//////////////////////////////////
// output po file from resource
//////////////////////////////////

procedure TForm1.SaveResourceToFile(const ResourceName: String; const TargetPath: String);
var
  ResStream: TResourceStream;
  FileStream: TFileStream;
begin
  try
    ResStream := TResourceStream.Create(HInstance, ResourceName, RT_RCDATA);
    try
      FileStream := TFileStream.Create(TargetPath, fmCreate);
      try
        FileStream.CopyFrom(ResStream, ResStream.Size);
      finally
        FileStream.Free;
      end;
    finally
      ResStream.Free;
    end;
  except
    on EResNotFound do ;
  end;
end;


//////////////////////////////////
// Set locale using SelectedLang
//////////////////////////////////

procedure TForm1.SetLocale();
var
  Index: Integer;
  Info: TLangInfo;
  AppDir, TargetPoName, TargetResName, FullPoPath: String;
begin
  Index := ComboBoxLang.ItemIndex;
  if Index < 0 then Index := 0;  { unselected -> select first item }

  Info := LangInfoData[Index];
  TargetResName := Info.ResourceName;
  TargetPoName  := Info.PoFileName;

  if (TargetResName <> '') and (TargetPoName <> '') then
  begin
    AppDir := ExtractFilePath(ParamStr(0));
    FullPoPath := AppDir + TargetPoName;

    try
      SaveResourceToFile(TargetResName, FullPoPath); { outpot po file }
      SetDefaultLang(Info.Lang);
    finally
      { delete po file }
      if FileExists(FullPoPath) then DeleteFile(FullPoPath);
    end;
  end
end;

end.
