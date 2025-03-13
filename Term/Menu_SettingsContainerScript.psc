ScriptName LZP:Term:Menu_SettingsContainerScript Extends TerminalMenu hidden

;-- Variables ---------------------------------------

;-- Properties --------------------------------------
Group GlobalVariable_Autofill
  GlobalVariable Property LPSetting_RemoveCorpses Auto mandatory
  GlobalVariable Property LPSetting_ContTakeAll Auto mandatory
  GlobalVariable Property LPSetting_AutoUnlock Auto mandatory
  GlobalVariable Property LPSetting_AutoUnlockSkillCheck Auto mandatory
EndGroup

Group Message_Autofill
  Message Property LPOffMsg Auto Const mandatory
  Message Property LPOnMsg Auto Const mandatory
EndGroup

Group Misc
  TerminalMenu Property CurrentTerminalMenu Auto Const mandatory
  GlobalVariable Property LPSystemUtil_Debug Auto Const mandatory
EndGroup


;-- Functions ---------------------------------------

Function Log(String logMsg)
  If LPSystemUtil_Debug.GetValue() as Bool
    Debug.Trace(logMsg, 0)
  EndIf
EndFunction

Function UpdateSettingDisplay(GlobalVariable setting, String label, ObjectReference akTerminalRef)
  If setting.GetValue() == 1.0
    akTerminalRef.AddTextReplacementData(label, LPOnMsg as Form)
    Log("Setting " + label + " to LPOnMsg")
  Else
    akTerminalRef.AddTextReplacementData(label, LPOffMsg as Form)
    Log("Setting " + label + " to LPOffMsg")
  EndIf
EndFunction

Function ToggleSetting(GlobalVariable setting, String label, ObjectReference akTerminalRef)
  If setting.GetValue() == 1.0
    setting.SetValue(0.0)
  Else
    setting.SetValue(1.0)
  EndIf
  UpdateSettingDisplay(setting, label, akTerminalRef)
EndFunction

Event OnTerminalMenuEnter(TerminalMenu akTerminalBase, ObjectReference akTerminalRef)
  Log("OnTerminalMenuEnter triggered")
  Bool currentRemoveCorpsesSetting = LPSetting_RemoveCorpses.GetValue() == 1.0
  Bool currentTakeAllSetting = LPSetting_ContTakeAll.GetValue() == 1.0
  Bool currentAutoUnlockSetting = LPSetting_AutoUnlock.GetValue() == 1.0
  Bool currentAutoUnlockSkillCheckSetting = LPSetting_AutoUnlockSkillCheck.GetValue() == 1.0
  Log(((("Current settings - RemoveCorpses: " + currentRemoveCorpsesSetting as String) + ", TakeAll: " + currentTakeAllSetting as String) + ", AutoUnlock: " + currentAutoUnlockSetting as String) + ", AutoUnlockSkillCheck: " + currentAutoUnlockSkillCheckSetting as String)
  UpdateSettingDisplay(LPSetting_AutoUnlock, "AutoUnlock", akTerminalRef)
  UpdateSettingDisplay(LPSetting_AutoUnlockSkillCheck, "AutoUnlockSkillCheck", akTerminalRef)
  UpdateSettingDisplay(LPSetting_RemoveCorpses, "Corpses", akTerminalRef)
  UpdateSettingDisplay(LPSetting_ContTakeAll, "TakeAll", akTerminalRef)
EndEvent

Event OnTerminalMenuItemRun(Int auiMenuItemID, TerminalMenu akTerminalBase, ObjectReference akTerminalRef)
  Log("OnTerminalMenuItemRun triggered with auiMenuItemID: " + auiMenuItemID as String)
  If akTerminalBase == CurrentTerminalMenu
    Log("Terminal menu matches CurrentTerminalMenu")
    If auiMenuItemID == 0
      Log("Toggling AutoUnlock")
      ToggleSetting(LPSetting_AutoUnlock, "AutoUnlock", akTerminalRef)
    ElseIf auiMenuItemID == 1
      Log("Toggling AutoUnlockSkillCheck")
      ToggleSetting(LPSetting_AutoUnlockSkillCheck, "AutoUnlockSkillCheck", akTerminalRef)
    ElseIf auiMenuItemID == 2
      Log("Toggling Corpses")
      ToggleSetting(LPSetting_RemoveCorpses, "Corpses", akTerminalRef)
    ElseIf auiMenuItemID == 3
      Log("Toggling TakeAll")
      ToggleSetting(LPSetting_ContTakeAll, "TakeAll", akTerminalRef)
    EndIf
  EndIf
EndEvent
