ScriptName LZP:Term:Menu_SettingsAlwaysLootScript Extends TerminalMenu hidden

;-- Variables ---------------------------------------

;-- Properties --------------------------------------
TerminalMenu Property CurrentTerminalMenu Auto Const mandatory
Form[] Property SettingsGlobals Auto Const mandatory
Message Property LPOffMsg Auto Const mandatory
Message Property LPOnMsg Auto Const mandatory

;-- Functions ---------------------------------------

Event OnTerminalMenuEnter(TerminalMenu akTerminalBase, ObjectReference akTerminalRef)
  Debug.Trace("OnTerminalMenuEnter triggered", 0) ; #DEBUG_LINE_NO:10
  Int index = 0 ; #DEBUG_LINE_NO:11
  While index < Self.SettingsGlobals.Length ; #DEBUG_LINE_NO:13
    GlobalVariable currentItem = Self.SettingsGlobals[index] as GlobalVariable ; #DEBUG_LINE_NO:14
    Bool currentSetting = currentItem.GetValue() as Bool ; #DEBUG_LINE_NO:15
    Debug.Trace(("Checking setting at index: " + index as String) + " with value: " + currentSetting as String, 0) ; #DEBUG_LINE_NO:16
    If !currentSetting ; #DEBUG_LINE_NO:18
      akTerminalRef.AddTextReplacementData("State" + index as String, Self.LPOffMsg as Form) ; #DEBUG_LINE_NO:19
      Debug.Trace(("Setting State" + index as String) + " to LPOffMsg", 0) ; #DEBUG_LINE_NO:20
    ElseIf currentSetting
      akTerminalRef.AddTextReplacementData("State" + index as String, Self.LPOnMsg as Form) ; #DEBUG_LINE_NO:22
      Debug.Trace(("Setting State" + index as String) + " to LPOnMsg", 0) ; #DEBUG_LINE_NO:23
    EndIf
    index += 1 ; #DEBUG_LINE_NO:25
  EndWhile
EndEvent

Event OnTerminalMenuItemRun(Int auiMenuItemID, TerminalMenu akTerminalBase, ObjectReference akTerminalRef)
  Debug.Trace("OnTerminalMenuItemRun triggered with auiMenuItemID: " + auiMenuItemID as String, 0) ; #DEBUG_LINE_NO:31
  If akTerminalBase == Self.CurrentTerminalMenu ; #DEBUG_LINE_NO:32
    Debug.Trace("Terminal menu matches CurrentTerminalMenu", 0) ; #DEBUG_LINE_NO:33
    GlobalVariable currentItem = Self.SettingsGlobals[auiMenuItemID] as GlobalVariable ; #DEBUG_LINE_NO:34
    Bool currentSetting = currentItem.GetValue() as Bool ; #DEBUG_LINE_NO:35
    Debug.Trace("Current setting value: " + currentSetting as String, 0) ; #DEBUG_LINE_NO:36
    If !currentSetting ; #DEBUG_LINE_NO:38
      currentItem.SetValue(1.0) ; #DEBUG_LINE_NO:39
      akTerminalRef.AddTextReplacementData("State" + auiMenuItemID as String, Self.LPOnMsg as Form) ; #DEBUG_LINE_NO:40
      Debug.Trace(("Setting State" + auiMenuItemID as String) + " to LPOnMsg", 0) ; #DEBUG_LINE_NO:41
    ElseIf currentSetting
      currentItem.SetValue(0.0) ; #DEBUG_LINE_NO:43
      akTerminalRef.AddTextReplacementData("State" + auiMenuItemID as String, Self.LPOffMsg as Form) ; #DEBUG_LINE_NO:44
      Debug.Trace(("Setting State" + auiMenuItemID as String) + " to LPOffMsg", 0) ; #DEBUG_LINE_NO:45
    EndIf
  EndIf
EndEvent
