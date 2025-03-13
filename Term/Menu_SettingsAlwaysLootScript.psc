ScriptName LZP:Term:Menu_SettingsAlwaysLootScript Extends TerminalMenu hidden

;-- Variables ---------------------------------------

;-- Properties --------------------------------------
TerminalMenu Property CurrentTerminalMenu Auto Const mandatory
Form[] Property SettingsGlobals Auto Const mandatory
Message Property LPOffMsg Auto Const mandatory
Message Property LPOnMsg Auto Const mandatory

;-- Functions ---------------------------------------

Function UpdateSettingDisplay(Int index, ObjectReference akTerminalRef)
  GlobalVariable setting = SettingsGlobals[index] as GlobalVariable ; #DEBUG_LINE_NO:28
  If setting ; #DEBUG_LINE_NO:29
    Float value = setting.GetValue() ; #DEBUG_LINE_NO:30
    Message replacementMsg = None ; #DEBUG_LINE_NO:31
    If value == 1.0 ; #DEBUG_LINE_NO:32
      replacementMsg = LPOnMsg ; #DEBUG_LINE_NO:33
    Else
      replacementMsg = LPOffMsg ; #DEBUG_LINE_NO:35
    EndIf
    akTerminalRef.AddTextReplacementData("State" + index as String, replacementMsg as Form) ; #DEBUG_LINE_NO:37
  Else
    Debug.Trace(("UpdateSettingDisplay: Setting at index " + index as String) + " not found", 0) ; #DEBUG_LINE_NO:39
  EndIf
EndFunction

Event OnTerminalMenuEnter(TerminalMenu akTerminalBase, ObjectReference akTerminalRef)
  Int index = 0 ; #DEBUG_LINE_NO:50
  While index < SettingsGlobals.Length ; #DEBUG_LINE_NO:51
    Self.UpdateSettingDisplay(index, akTerminalRef) ; #DEBUG_LINE_NO:52
    index += 1 ; #DEBUG_LINE_NO:53
  EndWhile
EndEvent

Event OnTerminalMenuItemRun(Int auiMenuItemID, TerminalMenu akTerminalBase, ObjectReference akTerminalRef)
  If akTerminalBase == CurrentTerminalMenu ; #DEBUG_LINE_NO:60
    GlobalVariable setting = SettingsGlobals[auiMenuItemID] as GlobalVariable ; #DEBUG_LINE_NO:61
    If setting ; #DEBUG_LINE_NO:62
      Float value = setting.GetValue() ; #DEBUG_LINE_NO:63
      If value == 1.0 ; #DEBUG_LINE_NO:64
        setting.SetValue(0.0) ; #DEBUG_LINE_NO:65
      Else
        setting.SetValue(1.0) ; #DEBUG_LINE_NO:67
      EndIf
      Self.UpdateSettingDisplay(auiMenuItemID, akTerminalRef) ; #DEBUG_LINE_NO:69
    Else
      Debug.Trace(("OnTerminalMenuItemRun: Setting at index " + auiMenuItemID as String) + " not found", 0) ; #DEBUG_LINE_NO:71
    EndIf
  EndIf
EndEvent
