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
  If LPSystemUtil_Debug.GetValue() as Bool ; #DEBUG_LINE_NO:43
    Debug.Trace(logMsg, 0) ; #DEBUG_LINE_NO:44
  EndIf
EndFunction

Function UpdateSetting(Int index, Float newValue, Message newMsg, ObjectReference akTerminalRef)
  GlobalVariable setting = SettingsGlobals.GetAt(index) as GlobalVariable ; #DEBUG_LINE_NO:51
  If setting ; #DEBUG_LINE_NO:52
    setting.SetValue(newValue) ; #DEBUG_LINE_NO:53
    akTerminalRef.AddTextReplacementData("State" + index as String, newMsg as Form) ; #DEBUG_LINE_NO:54
    String stateStr = "" ; #DEBUG_LINE_NO:56
    If newValue == 1.0 ; #DEBUG_LINE_NO:57
      stateStr = "LPOnMsg" ; #DEBUG_LINE_NO:58
    Else
      stateStr = "LPOffMsg" ; #DEBUG_LINE_NO:60
    EndIf
    Self.Log(("Setting State" + index as String) + " updated to " + stateStr) ; #DEBUG_LINE_NO:62
  Else
    Self.Log("No setting found at index: " + index as String) ; #DEBUG_LINE_NO:64
  EndIf
EndFunction

Event OnTerminalMenuEnter(TerminalMenu akTerminalBase, ObjectReference akTerminalRef)
  Self.Log("OnTerminalMenuEnter triggered") ; #DEBUG_LINE_NO:75
  Int count = SettingsGlobals.GetSize() ; #DEBUG_LINE_NO:76
  Int index = 0 ; #DEBUG_LINE_NO:77
  While index < count ; #DEBUG_LINE_NO:78
    GlobalVariable setting = SettingsGlobals.GetAt(index) as GlobalVariable ; #DEBUG_LINE_NO:79
    If setting ; #DEBUG_LINE_NO:80
      Float value = setting.GetValue() ; #DEBUG_LINE_NO:81
      Message replacementMsg = None ; #DEBUG_LINE_NO:82
      String stateStr = "" ; #DEBUG_LINE_NO:83
      If value == 1.0 ; #DEBUG_LINE_NO:84
        replacementMsg = LPOnMsg ; #DEBUG_LINE_NO:85
        stateStr = "LPOnMsg" ; #DEBUG_LINE_NO:86
      Else
        replacementMsg = LPOffMsg ; #DEBUG_LINE_NO:88
        stateStr = "LPOffMsg" ; #DEBUG_LINE_NO:89
      EndIf
      akTerminalRef.AddTextReplacementData("State" + index as String, replacementMsg as Form) ; #DEBUG_LINE_NO:91
      Self.Log(("Setting State" + index as String) + " to " + stateStr) ; #DEBUG_LINE_NO:92
    Else
      Self.Log("No setting found at index: " + index as String) ; #DEBUG_LINE_NO:94
    EndIf
    index += 1 ; #DEBUG_LINE_NO:96
  EndWhile
EndEvent

Event OnTerminalMenuItemRun(Int auiMenuItemID, TerminalMenu akTerminalBase, ObjectReference akTerminalRef)
  Self.Log("OnTerminalMenuItemRun triggered with auiMenuItemID: " + auiMenuItemID as String) ; #DEBUG_LINE_NO:103
  If akTerminalBase != CurrentTerminalMenu ; #DEBUG_LINE_NO:104
    Return  ; #DEBUG_LINE_NO:105
  EndIf
  If auiMenuItemID == 0 ; #DEBUG_LINE_NO:108
    Self.Log("Menu item 0 selected: Toggle all settings") ; #DEBUG_LINE_NO:109
    GlobalVariable allToggle = SettingsGlobals.GetAt(0) as GlobalVariable ; #DEBUG_LINE_NO:110
    Float newValue = 0.0 ; #DEBUG_LINE_NO:111
    If allToggle.GetValue() == 1.0 ; #DEBUG_LINE_NO:112
      newValue = 0.0 ; #DEBUG_LINE_NO:113
    Else
      newValue = 1.0 ; #DEBUG_LINE_NO:115
    EndIf
    Message newMsg = None ; #DEBUG_LINE_NO:118
    If newValue == 1.0 ; #DEBUG_LINE_NO:119
      newMsg = LPOnMsg ; #DEBUG_LINE_NO:120
    Else
      newMsg = LPOffMsg ; #DEBUG_LINE_NO:122
    EndIf
    Int count = SettingsGlobals.GetSize() ; #DEBUG_LINE_NO:125
    Int index = 0 ; #DEBUG_LINE_NO:126
    While index < count ; #DEBUG_LINE_NO:127
      Self.UpdateSetting(index, newValue, newMsg, akTerminalRef) ; #DEBUG_LINE_NO:128
      index += 1 ; #DEBUG_LINE_NO:129
    EndWhile
  Else
    Self.Log(("Menu item " + auiMenuItemID as String) + " selected: Toggle specific setting") ; #DEBUG_LINE_NO:132
    GlobalVariable setting = SettingsGlobals.GetAt(auiMenuItemID) as GlobalVariable ; #DEBUG_LINE_NO:133
    If setting ; #DEBUG_LINE_NO:134
      Float newvalue = 0.0 ; #DEBUG_LINE_NO:135
      If setting.GetValue() == 1.0 ; #DEBUG_LINE_NO:136
        newvalue = 0.0 ; #DEBUG_LINE_NO:137
      Else
        newvalue = 1.0 ; #DEBUG_LINE_NO:139
      EndIf
      Message newmsg = None ; #DEBUG_LINE_NO:142
      If newvalue == 1.0 ; #DEBUG_LINE_NO:143
        newmsg = LPOnMsg ; #DEBUG_LINE_NO:144
      Else
        newmsg = LPOffMsg ; #DEBUG_LINE_NO:146
      EndIf
      Self.UpdateSetting(auiMenuItemID, newvalue, newmsg, akTerminalRef) ; #DEBUG_LINE_NO:149
    Else
      Self.Log("No setting found for menu item " + auiMenuItemID as String) ; #DEBUG_LINE_NO:151
    EndIf
  EndIf
EndEvent
