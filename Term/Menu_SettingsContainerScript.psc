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
  If LPSystemUtil_Debug.GetValue() as Bool ; #DEBUG_LINE_NO:37
    Debug.Trace(logMsg, 0) ; #DEBUG_LINE_NO:38
  EndIf
EndFunction

Function UpdateSettingDisplay(GlobalVariable setting, String label, ObjectReference akTerminalRef)
  If setting.GetValue() == 1.0 ; #DEBUG_LINE_NO:45
    akTerminalRef.AddTextReplacementData(label, LPOnMsg as Form) ; #DEBUG_LINE_NO:46
    Self.Log("Setting " + label + " to LPOnMsg") ; #DEBUG_LINE_NO:47
  Else
    akTerminalRef.AddTextReplacementData(label, LPOffMsg as Form) ; #DEBUG_LINE_NO:49
    Self.Log("Setting " + label + " to LPOffMsg") ; #DEBUG_LINE_NO:50
  EndIf
EndFunction

Function ToggleSetting(GlobalVariable setting, String label, ObjectReference akTerminalRef)
  If setting.GetValue() == 1.0 ; #DEBUG_LINE_NO:57
    setting.SetValue(0.0) ; #DEBUG_LINE_NO:58
  Else
    setting.SetValue(1.0) ; #DEBUG_LINE_NO:60
  EndIf
  Self.UpdateSettingDisplay(setting, label, akTerminalRef) ; #DEBUG_LINE_NO:62
EndFunction

Event OnTerminalMenuEnter(TerminalMenu akTerminalBase, ObjectReference akTerminalRef)
  Self.Log("OnTerminalMenuEnter triggered") ; #DEBUG_LINE_NO:72
  Bool currentRemoveCorpsesSetting = LPSetting_RemoveCorpses.GetValue() == 1.0 ; #DEBUG_LINE_NO:75
  Bool currentTakeAllSetting = LPSetting_ContTakeAll.GetValue() == 1.0 ; #DEBUG_LINE_NO:76
  Bool currentAutoUnlockSetting = LPSetting_AutoUnlock.GetValue() == 1.0 ; #DEBUG_LINE_NO:77
  Bool currentAutoUnlockSkillCheckSetting = LPSetting_AutoUnlockSkillCheck.GetValue() == 1.0 ; #DEBUG_LINE_NO:78
  Self.Log(((("Current settings - RemoveCorpses: " + currentRemoveCorpsesSetting as String) + ", TakeAll: " + currentTakeAllSetting as String) + ", AutoUnlock: " + currentAutoUnlockSetting as String) + ", AutoUnlockSkillCheck: " + currentAutoUnlockSkillCheckSetting as String) ; #DEBUG_LINE_NO:79
  Self.UpdateSettingDisplay(LPSetting_AutoUnlock, "AutoUnlock", akTerminalRef) ; #DEBUG_LINE_NO:82
  Self.UpdateSettingDisplay(LPSetting_AutoUnlockSkillCheck, "AutoUnlockSkillCheck", akTerminalRef) ; #DEBUG_LINE_NO:83
  Self.UpdateSettingDisplay(LPSetting_RemoveCorpses, "Corpses", akTerminalRef) ; #DEBUG_LINE_NO:84
  Self.UpdateSettingDisplay(LPSetting_ContTakeAll, "TakeAll", akTerminalRef) ; #DEBUG_LINE_NO:85
EndEvent

Event OnTerminalMenuItemRun(Int auiMenuItemID, TerminalMenu akTerminalBase, ObjectReference akTerminalRef)
  Self.Log("OnTerminalMenuItemRun triggered with auiMenuItemID: " + auiMenuItemID as String) ; #DEBUG_LINE_NO:91
  If akTerminalBase == CurrentTerminalMenu ; #DEBUG_LINE_NO:92
    Self.Log("Terminal menu matches CurrentTerminalMenu") ; #DEBUG_LINE_NO:93
    If auiMenuItemID == 0 ; #DEBUG_LINE_NO:95
      Self.Log("Toggling AutoUnlock") ; #DEBUG_LINE_NO:96
      Self.ToggleSetting(LPSetting_AutoUnlock, "AutoUnlock", akTerminalRef) ; #DEBUG_LINE_NO:97
    ElseIf auiMenuItemID == 1 ; #DEBUG_LINE_NO:98
      Self.Log("Toggling AutoUnlockSkillCheck") ; #DEBUG_LINE_NO:99
      Self.ToggleSetting(LPSetting_AutoUnlockSkillCheck, "AutoUnlockSkillCheck", akTerminalRef) ; #DEBUG_LINE_NO:100
    ElseIf auiMenuItemID == 2 ; #DEBUG_LINE_NO:101
      Self.Log("Toggling Corpses") ; #DEBUG_LINE_NO:102
      Self.ToggleSetting(LPSetting_RemoveCorpses, "Corpses", akTerminalRef) ; #DEBUG_LINE_NO:103
    ElseIf auiMenuItemID == 3 ; #DEBUG_LINE_NO:104
      Self.Log("Toggling TakeAll") ; #DEBUG_LINE_NO:105
      Self.ToggleSetting(LPSetting_ContTakeAll, "TakeAll", akTerminalRef) ; #DEBUG_LINE_NO:106
    EndIf
  EndIf
EndEvent
