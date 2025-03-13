ScriptName LZP:Term:Menu_FilterScript Extends TerminalMenu hidden

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

Function UpdateSetting(Int index, Float newValue, Message newMsg, ObjectReference akTerminalRef)
  GlobalVariable setting = SettingsGlobals.GetAt(index) as GlobalVariable
  If setting
    setting.SetValue(newValue)
    akTerminalRef.AddTextReplacementData("State" + index as String, newMsg as Form)
    String stateStr = ""
    If newValue == 1.0
      stateStr = "LPOnMsg"
    Else
      stateStr = "LPOffMsg"
    EndIf
    Log(("Setting State" + index as String) + " updated to " + stateStr)
  Else
    Log("No setting found at index: " + index as String)
  EndIf
EndFunction

Event OnTerminalMenuEnter(TerminalMenu akTerminalBase, ObjectReference akTerminalRef)
  Log("OnTerminalMenuEnter triggered")
  Int count = SettingsGlobals.GetSize()
  Int index = 0
  While index < count
    GlobalVariable setting = SettingsGlobals.GetAt(index) as GlobalVariable
    If setting
      Float value = setting.GetValue()
      Message replacementMsg = None
      String stateStr = ""
      If value == 1.0
        replacementMsg = LPOnMsg
        stateStr = "LPOnMsg"
      Else
        replacementMsg = LPOffMsg
        stateStr = "LPOffMsg"
      EndIf
      akTerminalRef.AddTextReplacementData("State" + index as String, replacementMsg as Form)
      Log(("Setting State" + index as String) + " to " + stateStr)
    Else
      Log("No setting found at index: " + index as String)
    EndIf
    index += 1
  EndWhile
EndEvent

Event OnTerminalMenuItemRun(Int auiMenuItemID, TerminalMenu akTerminalBase, ObjectReference akTerminalRef)
  Log("OnTerminalMenuItemRun triggered with auiMenuItemID: " + auiMenuItemID as String)
  If akTerminalBase != CurrentTerminalMenu
    Return
  EndIf
  If auiMenuItemID == 0
    Log("Menu item 0 selected: Toggle all settings")
    GlobalVariable allToggle = SettingsGlobals.GetAt(0) as GlobalVariable
    Float newValue = 0.0
    If allToggle.GetValue() == 1.0
      newValue = 0.0
    Else
      newValue = 1.0
    EndIf
    Message newMsg = None
    If newValue == 1.0
      newMsg = LPOnMsg
    Else
      newMsg = LPOffMsg
    EndIf
    Int count = SettingsGlobals.GetSize()
    Int index = 0
    While index < count
      UpdateSetting(index, newValue, newMsg, akTerminalRef)
      index += 1
    EndWhile
  Else
    Log(("Menu item " + auiMenuItemID as String) + " selected: Toggle specific setting")
    GlobalVariable setting = SettingsGlobals.GetAt(auiMenuItemID) as GlobalVariable
    If setting
      Float newvalue = 0.0
      If setting.GetValue() == 1.0
        newvalue = 0.0
      Else
        newvalue = 1.0
      EndIf
      Message newmsg = None
      If newvalue == 1.0
        newmsg = LPOnMsg
      Else
        newmsg = LPOffMsg
      EndIf
      UpdateSetting(auiMenuItemID, newvalue, newmsg, akTerminalRef)
    Else
      Log("No setting found for menu item " + auiMenuItemID as String)
    EndIf
  EndIf
EndEvent
