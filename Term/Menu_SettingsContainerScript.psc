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
EndGroup


;-- Functions ---------------------------------------

Event OnTerminalMenuEnter(TerminalMenu akTerminalBase, ObjectReference akTerminalRef)
  Debug.Trace("OnTerminalMenuEnter triggered", 0) ; #DEBUG_LINE_NO:24
  Bool currentRemoveCorpsesSetting = Self.LPSetting_RemoveCorpses.GetValue() as Bool ; #DEBUG_LINE_NO:25
  Bool currentTakeAllSetting = Self.LPSetting_ContTakeAll.GetValue() as Bool ; #DEBUG_LINE_NO:26
  Bool currentAutoUnlockSetting = Self.LPSetting_AutoUnlock.GetValue() as Bool ; #DEBUG_LINE_NO:27
  Bool currentAutoUnlockSkillCheckSetting = Self.LPSetting_AutoUnlockSkillCheck.GetValue() as Bool ; #DEBUG_LINE_NO:28
  Debug.Trace(((("Current settings - RemoveCorpses: " + currentRemoveCorpsesSetting as String) + ", TakeAll: " + currentTakeAllSetting as String) + ", AutoUnlock: " + currentAutoUnlockSetting as String) + ", AutoUnlockSkillCheck: " + currentAutoUnlockSkillCheckSetting as String, 0) ; #DEBUG_LINE_NO:29
  If !currentAutoUnlockSetting ; #DEBUG_LINE_NO:31
    akTerminalRef.AddTextReplacementData("AutoUnlock", Self.LPOffMsg as Form) ; #DEBUG_LINE_NO:32
    Debug.Trace("Setting AutoUnlock to LPOffMsg", 0) ; #DEBUG_LINE_NO:33
  ElseIf currentAutoUnlockSetting
    akTerminalRef.AddTextReplacementData("AutoUnlock", Self.LPOnMsg as Form) ; #DEBUG_LINE_NO:35
    Debug.Trace("Setting AutoUnlock to LPOnMsg", 0) ; #DEBUG_LINE_NO:36
  EndIf
  If !currentAutoUnlockSkillCheckSetting ; #DEBUG_LINE_NO:38
    akTerminalRef.AddTextReplacementData("AutoUnlockSkillCheck", Self.LPOffMsg as Form) ; #DEBUG_LINE_NO:39
    Debug.Trace("Setting AutoUnlockSkillCheck to LPOffMsg", 0) ; #DEBUG_LINE_NO:40
  ElseIf currentAutoUnlockSkillCheckSetting
    akTerminalRef.AddTextReplacementData("AutoUnlockSkillCheck", Self.LPOnMsg as Form) ; #DEBUG_LINE_NO:42
    Debug.Trace("Setting AutoUnlockSkillCheck to LPOnMsg", 0) ; #DEBUG_LINE_NO:43
  EndIf
  If !currentRemoveCorpsesSetting ; #DEBUG_LINE_NO:45
    akTerminalRef.AddTextReplacementData("Corpses", Self.LPOffMsg as Form) ; #DEBUG_LINE_NO:46
    Debug.Trace("Setting Corpses to LPOffMsg", 0) ; #DEBUG_LINE_NO:47
  ElseIf currentRemoveCorpsesSetting
    akTerminalRef.AddTextReplacementData("Corpses", Self.LPOnMsg as Form) ; #DEBUG_LINE_NO:49
    Debug.Trace("Setting Corpses to LPOnMsg", 0) ; #DEBUG_LINE_NO:50
  EndIf
  If !currentTakeAllSetting ; #DEBUG_LINE_NO:52
    akTerminalRef.AddTextReplacementData("TakeAll", Self.LPOffMsg as Form) ; #DEBUG_LINE_NO:53
    Debug.Trace("Setting TakeAll to LPOffMsg", 0) ; #DEBUG_LINE_NO:54
  ElseIf currentTakeAllSetting
    akTerminalRef.AddTextReplacementData("TakeAll", Self.LPOnMsg as Form) ; #DEBUG_LINE_NO:56
    Debug.Trace("Setting TakeAll to LPOnMsg", 0) ; #DEBUG_LINE_NO:57
  EndIf
EndEvent

Event OnTerminalMenuItemRun(Int auiMenuItemID, TerminalMenu akTerminalBase, ObjectReference akTerminalRef)
  Debug.Trace("OnTerminalMenuItemRun triggered with auiMenuItemID: " + auiMenuItemID as String, 0) ; #DEBUG_LINE_NO:63
  If akTerminalBase == Self.CurrentTerminalMenu ; #DEBUG_LINE_NO:64
    Debug.Trace("Terminal menu matches CurrentTerminalMenu", 0) ; #DEBUG_LINE_NO:65
    If auiMenuItemID == 0 ; #DEBUG_LINE_NO:67
      Bool currentAutoUnlockSetting = Self.LPSetting_AutoUnlock.GetValue() as Bool ; #DEBUG_LINE_NO:68
      Debug.Trace("Current AutoUnlock setting: " + currentAutoUnlockSetting as String, 0) ; #DEBUG_LINE_NO:69
      If !currentAutoUnlockSetting ; #DEBUG_LINE_NO:70
        Self.LPSetting_AutoUnlock.SetValue(1.0) ; #DEBUG_LINE_NO:71
        akTerminalRef.AddTextReplacementData("AutoUnlock", Self.LPOnMsg as Form) ; #DEBUG_LINE_NO:72
        Debug.Trace("Setting AutoUnlock to LPOnMsg", 0) ; #DEBUG_LINE_NO:73
      ElseIf currentAutoUnlockSetting
        Self.LPSetting_AutoUnlock.SetValue(0.0) ; #DEBUG_LINE_NO:75
        akTerminalRef.AddTextReplacementData("AutoUnlock", Self.LPOffMsg as Form) ; #DEBUG_LINE_NO:76
        Debug.Trace("Setting AutoUnlock to LPOffMsg", 0) ; #DEBUG_LINE_NO:77
      EndIf
    ElseIf auiMenuItemID == 1 ; #DEBUG_LINE_NO:80
      Bool currentAutoUnlockSkillCheckSetting = Self.LPSetting_AutoUnlockSkillCheck.GetValue() as Bool ; #DEBUG_LINE_NO:81
      Debug.Trace("Current AutoUnlockSkillCheck setting: " + currentAutoUnlockSkillCheckSetting as String, 0) ; #DEBUG_LINE_NO:82
      If !currentAutoUnlockSkillCheckSetting ; #DEBUG_LINE_NO:83
        Self.LPSetting_AutoUnlockSkillCheck.SetValue(1.0) ; #DEBUG_LINE_NO:84
        akTerminalRef.AddTextReplacementData("AutoUnlockSkillCheck", Self.LPOnMsg as Form) ; #DEBUG_LINE_NO:85
        Debug.Trace("Setting AutoUnlockSkillCheck to LPOnMsg", 0) ; #DEBUG_LINE_NO:86
      ElseIf currentAutoUnlockSkillCheckSetting
        Self.LPSetting_AutoUnlockSkillCheck.SetValue(0.0) ; #DEBUG_LINE_NO:88
        akTerminalRef.AddTextReplacementData("AutoUnlockSkillCheck", Self.LPOffMsg as Form) ; #DEBUG_LINE_NO:89
        Debug.Trace("Setting AutoUnlockSkillCheck to LPOffMsg", 0) ; #DEBUG_LINE_NO:90
      EndIf
    ElseIf auiMenuItemID == 2 ; #DEBUG_LINE_NO:93
      Bool currentRemoveCorpsesSetting = Self.LPSetting_RemoveCorpses.GetValue() as Bool ; #DEBUG_LINE_NO:94
      Debug.Trace("Current RemoveCorpses setting: " + currentRemoveCorpsesSetting as String, 0) ; #DEBUG_LINE_NO:95
      If !currentRemoveCorpsesSetting ; #DEBUG_LINE_NO:96
        Self.LPSetting_RemoveCorpses.SetValue(1.0) ; #DEBUG_LINE_NO:97
        akTerminalRef.AddTextReplacementData("Corpses", Self.LPOnMsg as Form) ; #DEBUG_LINE_NO:98
        Debug.Trace("Setting Corpses to LPOnMsg", 0) ; #DEBUG_LINE_NO:99
      ElseIf currentRemoveCorpsesSetting
        Self.LPSetting_RemoveCorpses.SetValue(0.0) ; #DEBUG_LINE_NO:101
        akTerminalRef.AddTextReplacementData("Corpses", Self.LPOffMsg as Form) ; #DEBUG_LINE_NO:102
        Debug.Trace("Setting Corpses to LPOffMsg", 0) ; #DEBUG_LINE_NO:103
      EndIf
    ElseIf auiMenuItemID == 3 ; #DEBUG_LINE_NO:106
      Bool currentTakeAllSetting = Self.LPSetting_ContTakeAll.GetValue() as Bool ; #DEBUG_LINE_NO:107
      Debug.Trace("Current TakeAll setting: " + currentTakeAllSetting as String, 0) ; #DEBUG_LINE_NO:108
      If !currentTakeAllSetting ; #DEBUG_LINE_NO:109
        Self.LPSetting_ContTakeAll.SetValue(1.0) ; #DEBUG_LINE_NO:110
        akTerminalRef.AddTextReplacementData("TakeAll", Self.LPOnMsg as Form) ; #DEBUG_LINE_NO:111
        Debug.Trace("Setting TakeAll to LPOnMsg", 0) ; #DEBUG_LINE_NO:112
      ElseIf currentTakeAllSetting
        Self.LPSetting_ContTakeAll.SetValue(0.0) ; #DEBUG_LINE_NO:114
        akTerminalRef.AddTextReplacementData("TakeAll", Self.LPOffMsg as Form) ; #DEBUG_LINE_NO:115
        Debug.Trace("Setting TakeAll to LPOffMsg", 0) ; #DEBUG_LINE_NO:116
      EndIf
    EndIf
  EndIf
EndEvent
