unit LangText;

interface


type
  TLang = (langEN, langJP, langZHTW);

  TTextItem = record
    EN: string;
    JP: string;
    ZHTW: string;
  end;

function GetText(const Item: TTextItem; Lang: TLang): string;


const
  Text_ButtonNewExp: TTextItem = (
    EN: 'New Exp';
    JP: '新規実験';
    ZHTW: '新規實驗';
  );

  Text_ButtonStart: TTextItem = (
    EN: 'Start';
    JP: '開始';
    ZHTW: '開始';
  );

  Text_ButtonPause: TTextItem = (
    EN: 'Pause';
    JP: '一時停止';
    ZHTW: '一時停止';
  );

  Text_ButtonRestart: TTextItem = (
    EN: 'ReStart';
    JP: '再開';
    ZHTW: '再開';
  );

  Text_ButtonQuit: TTextItem = (
    EN: 'Quit';
    JP: '終了';
    ZHTW: '終了';
  );

  Text_ButtonSave: TTextItem = (
    EN: 'Save';
    JP: '保存';
    ZHTW: '保存';
  );


  Text_LabelSpeed: TTextItem = (
    EN: 'Speed';
    JP: '速度';
    ZHTW: '速度';
  );

  Text_LabelResponsePlus: TTextItem = (
    EN: 'Respond';
    JP: '反応あり';
    ZHTW: '有反應';
  );

  Text_LabelResponseMinus: TTextItem = (
    EN: 'Not Respond';
    JP: '反応なし';
    ZHTW: '沒反應';
  );


  Text_MsgNewExp: TTextItem = (
    EN: 'Do you want to start a new experiment?';
    JP: '新規実験を行いますか?';
    ZHTW: '要開始新的實驗嗎?';
  );

  Text_MsgQuit: TTextItem = (
    EN: 'Do you want to quit?';
    JP: '終了しますか?';
    ZHTW: '確定要退出嗎?';
  );

  Text_LabelConfirm: TTextItem = (
    EN: 'Confirm';
    JP: '確認';
    ZHTW: '確認';
  );

  Text_LabelYes: TTextItem = (
    EN: 'Yes';
    JP: 'はい';
    ZHTW: '是的';
  );

  Text_LabelNo: TTextItem = (
    EN: 'No';
    JP: 'いいえ';
    ZHTW: '不';
  );


implementation

function GetText(const Item: TTextItem; Lang: TLang): string;
begin
  case Lang of
    langEN:   Result := Item.EN;
    langJP:   Result := Item.JP;
    langZHTW: Result := Item.ZHTW;
  end;
end;

end.
