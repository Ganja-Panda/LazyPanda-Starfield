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
  If LPSystemUtil_Debug.GetValue() as Bool
    Debug.Trace(logMsg, 0)
  EndIf
EndFunction

Function SetAllSettings(Float newValue)
  Int size = SettingsGlobals.GetSize()
  Int index = 0
  While index < size
    GlobalVariable currentSetting = SettingsGlobals.GetAt(index) as GlobalVariable
    currentSetting.SetValue(newValue)
    Log(("Setting index " + index as String) + " to " + newValue as String)
    index += 1
  EndWhile
EndFunction

Function UpdateAllToggleDisplay(ObjectReference akTerminalRef, Float currentValue)
  If currentValue == 1.0
    akTerminalRef.AddTextReplacementData("AllToggle", LPOnMsg as Form)
    Log("Setting AllToggle to LPOnMsg")
  ElseIf currentValue == 0.0
    akTerminalRef.AddTextReplacementData("AllToggle", LPOffMsg as Form)
    Log("Setting AllToggle to LPOffMsg")
  EndIf
EndFunction

Function ForceTerminalRefresh(TerminalMenu akTerminalBase, ObjectReference akTerminalRef)
  akTerminalBase.ClearDynamicMenuItems(akTerminalRef)
  akTerminalBase.ClearDynamicBodyTextItems(akTerminalRef)
  akTerminalBase.AddDynamicMenuItem(akTerminalRef, 0, 0, None)
  Log("Terminal forced refresh triggered")
EndFunction

Event OnTerminalMenuEnter(TerminalMenu akTerminalBase, ObjectReference akTerminalRef)
  Log("OnTerminalMenuEnter triggered")
  GlobalVariable currentSetting = SettingsGlobals.GetAt(0) as GlobalVariable
  Log("Current setting value: " + currentSetting.GetValue() as String)
  UpdateAllToggleDisplay(akTerminalRef, currentSetting.GetValue())
EndEvent

Event OnTerminalMenuItemRun(Int auiMenuItemID, TerminalMenu akTerminalBase, ObjectReference akTerminalRef)
  Log("OnTerminalMenuItemRun triggered with auiMenuItemID: " + auiMenuItemID as String)
  If akTerminalBase == CurrentTerminalMenu
    Log("Terminal menu matches CurrentTerminalMenu")
    If auiMenuItemID == 0
      Log("Menu item 0 selected: Toggle all settings")
      GlobalVariable AllToggle = SettingsGlobals.GetAt(0) as GlobalVariable
      Float currentValue = AllToggle.GetValue()
      Log("AllToggle current value: " + currentValue as String)
      Float newValue = 0.0
      If currentValue == 1.0
        newValue = 0.0
      Else
        newValue = 1.0
      EndIf
      SetAllSettings(newValue)
      UpdateAllToggleDisplay(akTerminalRef, newValue)
      ForceTerminalRefresh(akTerminalBase, akTerminalRef)
    EndIf
  EndIf
EndEvent
