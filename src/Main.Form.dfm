object frmMain: TfrmMain
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'SwissTransit'
  ClientHeight = 161
  ClientWidth = 542
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  OnCreate = FormCreate
  TextHeight = 15
  object llStation: TLabel
    Left = 6
    Top = 10
    Width = 146
    Height = 15
    Caption = 'Swiss Railway Station Name'
  end
  object eStation: TEdit
    Left = 156
    Top = 6
    Width = 295
    Height = 23
    TabOrder = 0
  end
  object btnSearch: TButton
    Left = 461
    Top = 6
    Width = 75
    Height = 25
    Caption = 'Search'
    TabOrder = 1
    OnClick = btnSearchClick
  end
  object mResult: TMemo
    Left = 156
    Top = 33
    Width = 295
    Height = 120
    TabOrder = 2
  end
end
