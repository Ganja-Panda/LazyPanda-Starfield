ScriptName LZP:Term:Menu_FilterMainScript Extends TerminalMenu hidden

;-- Variables ---------------------------------------

;-- Properties --------------------------------------
Group Autofill
  Message Property LPOffMsg Auto Const mandatory
  Message Property LPOnMsg Auto Const mandatory
EndGroup

Group MenuSpecific
  FormList Property SettingsGlobals Auto Const mandatory
EndGroup

Group Terminal
  TerminalMenu Property CurrentTerminalMenu Auto Const mandatory
EndGroup

GlobalVariable Property LPSystemUtil_Debug Auto Const mandatory

;-- Functions ---------------------------------------

Function Log(String logMsg)
  If LPSystemUtil_Debug.GetValue() as Bool ; #DEBUG_LINE_NO:42
    Debug.Trace(logMsg, 0) ; #DEBUG_LINE_NO:43
  EndIf
EndFunction

Function SetAllSettings(Float newValue)
  Int size = Self.SettingsGlobals.GetSize() ; #DEBUG_LINE_NO:50
  Int index = 0 ; #DEBUG_LINE_NO:51
  While index < size ; #DEBUG_LINE_NO:52
    GlobalVariable currentSetting = Self.SettingsGlobals.GetAt(index) as GlobalVariable ; #DEBUG_LINE_NO:53
    currentSetting.SetValue(newValue) ; #DEBUG_LINE_NO:54
    Self.Log(("Setting index " + index as String) + " to " + newValue as String) ; #DEBUG_LINE_NO:55
    index += 1 ; #DEBUG_LINE_NO:56
  EndWhile
EndFunction

Function UpdateAllToggleDisplay(ObjectReference akTerminalRef, Float currentValue)
  If currentValue == 1.0 ; #DEBUG_LINE_NO:63
    akTerminalRef.AddTextReplacementData("AllToggle", Self.LPOnMsg as Form) ; #DEBUG_LINE_NO:64
    Self.Log("Setting AllToggle to LPOnMsg") ; #DEBUG_LINE_NO:65
  ElseIf currentValue == 0.0 ; #DEBUG_LINE_NO:66
    akTerminalRef.AddTextReplacementData("AllToggle", Self.LPOffMsg as Form) ; #DEBUG_LINE_NO:67
    Self.Log("Setting AllToggle to LPOffMsg") ; #DEBUG_LINE_NO:68
  EndIf
EndFunction

Function ForceTerminalRefresh(TerminalMenu akTerminalBase, ObjectReference akTerminalRef)
  akTerminalBase.ClearDynamicMenuItems(akTerminalRef) ; #DEBUG_LINE_NO:75
  akTerminalBase.ClearDynamicBodyTextItems(akTerminalRef) ; #DEBUG_LINE_NO:76
  akTerminalBase.AddDynamicMenuItem(akTerminalRef, 0, 0, None) ; #DEBUG_LINE_NO:77
  Self.Log("Terminal forced refresh triggered") ; #DEBUG_LINE_NO:78
EndFunction

Event OnTerminalMenuEnter(TerminalMenu akTerminalBase, ObjectReference akTerminalRef)
  Self.Log("OnTerminalMenuEnter triggered") ; #DEBUG_LINE_NO:88
  GlobalVariable currentSetting = Self.SettingsGlobals.GetAt(0) as GlobalVariable ; #DEBUG_LINE_NO:89
  Self.Log("Current setting value: " + currentSetting.GetValue() as String) ; #DEBUG_LINE_NO:90
  Self.UpdateAllToggleDisplay(akTerminalRef, currentSetting.GetValue()) ; #DEBUG_LINE_NO:91
EndEvent

Event OnTerminalMenuItemRun(Int auiMenuItemID, TerminalMenu akTerminalBase, ObjectReference akTerminalRef)
  Self.Log("OnTerminalMenuItemRun triggered with auiMenuItemID: " + auiMenuItemID as String) ; #DEBUG_LINE_NO:97
  If akTerminalBase == Self.CurrentTerminalMenu ; #DEBUG_LINE_NO:98
    Self.Log("Terminal menu matches CurrentTerminalMenu") ; #DEBUG_LINE_NO:99
    If auiMenuItemID == 0 ; #DEBUG_LINE_NO:100
      Self.Log("Menu item 0 selected: Toggle all settings") ; #DEBUG_LINE_NO:101
      GlobalVariable AllToggle = Self.SettingsGlobals.GetAt(0) as GlobalVariable ; #DEBUG_LINE_NO:102
      Float currentValue = AllToggle.GetValue() ; #DEBUG_LINE_NO:103
      Self.Log("AllToggle current value: " + currentValue as String) ; #DEBUG_LINE_NO:104
      Float newValue = 0.0 ; #DEBUG_LINE_NO:106
      If currentValue == 1.0 ; #DEBUG_LINE_NO:107
        newValue = 0.0 ; #DEBUG_LINE_NO:108
      Else
        newValue = 1.0 ; #DEBUG_LINE_NO:110
      EndIf
      Self.SetAllSettings(newValue) ; #DEBUG_LINE_NO:113
      Self.UpdateAllToggleDisplay(akTerminalRef, newValue) ; #DEBUG_LINE_NO:114
      Self.ForceTerminalRefresh(akTerminalBase, akTerminalRef) ; #DEBUG_LINE_NO:115
    EndIf
  EndIf
EndEvent
