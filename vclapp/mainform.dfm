object Form54: TForm54
  Left = 0
  Top = 0
  Caption = 'Form54'
  ClientHeight = 441
  ClientWidth = 624
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  TextHeight = 15
  object Button1: TButton
    Left = 8
    Top = 8
    Width = 75
    Height = 25
    Caption = 'Start Hook'
    TabOrder = 0
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 112
    Top = 8
    Width = 75
    Height = 25
    Caption = 'Stop Hook'
    TabOrder = 1
    OnClick = Button2Click
  end
  object Button3: TButton
    Left = 328
    Top = 8
    Width = 75
    Height = 25
    Caption = 'Add Hotkey'
    TabOrder = 2
    OnClick = Button3Click
  end
  object mdb: TMemo
    Left = 0
    Top = 136
    Width = 624
    Height = 305
    Align = alBottom
    TabOrder = 3
    ExplicitTop = 128
    ExplicitWidth = 622
  end
  object al: TActionList
    Left = 504
    Top = 64
    object acAction: TAction
      Caption = 'MyAction'
      OnExecute = acActionExecute
    end
  end
end
