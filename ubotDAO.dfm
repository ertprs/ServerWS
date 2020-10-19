object botDAO: TbotDAO
  OldCreateOrder = False
  OnCreate = DataModuleCreate
  Height = 430
  Width = 740
  object conexaoBDG: TFDConnection
    Params.Strings = (
      'User_Name=SYSDBA'
      'Password=masterkey'
      'DriverID=FB')
    LoginPrompt = False
    Left = 80
    Top = 44
  end
  object FDGUIxWaitCursor1: TFDGUIxWaitCursor
    Provider = 'Forms'
    Left = 80
    Top = 118
  end
  object FDPhysFBDriverLink1: TFDPhysFBDriverLink
    VendorLib = 'fbclient.dll'
    Left = 80
    Top = 192
  end
  object qryP2PWS: TFDQuery
    Connection = conexaoBDG
    Left = 360
    Top = 160
  end
end
