unit MultiLang;

interface

type
  TLangInfo = record
    Lang: String;
    DisplayStr: String;
    ResourceName: String;
    PoFileName: String;
  end;

const
  LangInfoData: array of TLangInfo = (
    (
      Lang: 'en_US';
      DisplayStr: 'English';
      ResourceName: 'SIMLA_EN';
      PoFileName: 'SimLA.en.po';
    ),
    (
      Lang: 'ja_JP';
      DisplayStr: '日本語';
      ResourceName: 'SIMLA_JA';
      PoFileName: 'SimLA.ja.po';
    ),
    (
      Lang: 'ko_KR';
      DisplayStr: '한국어';
      ResourceName: 'SIMLA_KO';
      PoFileName: 'SimLA.ko.po';
    ),
    (
      Lang: 'zh_TW';
      DisplayStr: '中文（繁体）';
      ResourceName: 'SIMLA_ZHTW';
      PoFileName: 'SimLA.zh_TW.po';
    )
  );


resourcestring
  rsButtonNewExp = 'NewExp';
  rsButtonStart = 'Start';
  rsButtonRestart = 'Restart';
  rsButtonPause = 'Pause';
  rsButtonSave = 'Save';
  rsButtonQuit = 'Quit';

  rsLabelSpeed = 'Speed';
  rsLabelResponsePlus = 'Respond';
  rsLabelResponseMinus = 'NotRespond';

  rsMsgNewExp = 'dialogMsgNewExp';
  rsMsgQuit = 'dialogMsgQuit';
  rsLabelConfirm = 'Confirm';


implementation

end.

