ScriptName LZP:Term:Menu_UtilInventoryScript Extends TerminalMenu hidden

;-- Variables ---------------------------------------

;-- Properties --------------------------------------
Group Menu_UtilProperties
  TerminalMenu Property CurrentTerminalMenu Auto Const mandatory
  ObjectReference Property LodgeSafeRef Auto Const mandatory
  ObjectReference Property LPDummyHoldingRef Auto Const mandatory
  ObjectReference Property PlayerRef Auto Const mandatory
  ReferenceAlias Property PlayerHomeShip Auto Const mandatory
EndGroup

Group DebugProperties
  GlobalVariable Property LPSystemUtil_Debug Auto Const mandatory
EndGroup

Group GlobalVariable_Autofill
  GlobalVariable Property LPSystemUtil_ToggleLooting Auto mandatory
EndGroup

Group Message_Autofill
  Message Property LPOffMsg Auto Const mandatory
  Message Property LPOnMsg Auto Const mandatory
  Message Property LPDebugOnMsg Auto Const mandatory
  Message Property LPDebugOffMsg Auto Const mandatory
EndGroup


;-- Functions ---------------------------------------

Function Log(String logMsg)
  If LPSystemUtil_Debug.GetValue() as Bool ; #DEBUG_LINE_NO:52
    Debug.Trace(logMsg, 0) ; #DEBUG_LINE_NO:53
  EndIf
EndFunction

Function UpdateLootingDisplay(ObjectReference akTerminalRef, Bool currentLootSetting)
  If !currentLootSetting ; #DEBUG_LINE_NO:60
    Self.Log("Updating display: Looting is off") ; #DEBUG_LINE_NO:61
    akTerminalRef.AddTextReplacementData("Looting", LPOffMsg as Form) ; #DEBUG_LINE_NO:62
  Else
    Self.Log("Updating display: Looting is on") ; #DEBUG_LINE_NO:64
    akTerminalRef.AddTextReplacementData("Looting", LPOnMsg as Form) ; #DEBUG_LINE_NO:65
  EndIf
EndFunction

Function UpdateDebugDisplay(ObjectReference akTerminalRef, Bool currentDebugStatus)
  If currentDebugStatus ; #DEBUG_LINE_NO:72
    Self.Log("Updating display: Debugging is on") ; #DEBUG_LINE_NO:73
    akTerminalRef.AddTextReplacementData("Logging", LPDebugOnMsg as Form) ; #DEBUG_LINE_NO:74
  Else
    Self.Log("Updating display: Debugging is off") ; #DEBUG_LINE_NO:76
    akTerminalRef.AddTextReplacementData("Logging", LPDebugOffMsg as Form) ; #DEBUG_LINE_NO:77
  EndIf
EndFunction

Event OnTerminalMenuEnter(TerminalMenu akTerminalBase, ObjectReference akTerminalRef)
  Self.Log("OnTerminalMenuEnter triggered") ; #DEBUG_LINE_NO:88
  Bool currentLootSetting = LPSystemUtil_ToggleLooting.GetValue() as Bool ; #DEBUG_LINE_NO:91
  Bool currentDebugStatus = LPSystemUtil_Debug.GetValue() as Bool ; #DEBUG_LINE_NO:92
  Self.Log("Current loot setting: " + currentLootSetting as String) ; #DEBUG_LINE_NO:95
  Self.Log("Current debug status: " + currentDebugStatus as String) ; #DEBUG_LINE_NO:96
  Self.UpdateLootingDisplay(akTerminalRef, currentLootSetting) ; #DEBUG_LINE_NO:99
  Self.UpdateDebugDisplay(akTerminalRef, currentDebugStatus) ; #DEBUG_LINE_NO:100
EndEvent

Event OnTerminalMenuItemRun(Int auiMenuItemID, TerminalMenu akTerminalBase, ObjectReference akTerminalRef)
  Self.Log("OnTerminalMenuItemRun triggered with auiMenuItemID: " + auiMenuItemID as String) ; #DEBUG_LINE_NO:106
  If akTerminalBase == CurrentTerminalMenu ; #DEBUG_LINE_NO:107
    Self.Log("Terminal menu matches CurrentTerminalMenu") ; #DEBUG_LINE_NO:108
    If auiMenuItemID == 1 ; #DEBUG_LINE_NO:111
      Self.Log("Menu item 1 selected") ; #DEBUG_LINE_NO:112
      Bool currentLootSetting = LPSystemUtil_ToggleLooting.GetValue() as Bool ; #DEBUG_LINE_NO:113
      Self.Log("Current loot setting: " + currentLootSetting as String) ; #DEBUG_LINE_NO:114
      If !currentLootSetting ; #DEBUG_LINE_NO:115
        Self.Log("Turning looting on") ; #DEBUG_LINE_NO:116
        LPSystemUtil_ToggleLooting.SetValue(1.0) ; #DEBUG_LINE_NO:117
      Else
        Self.Log("Turning looting off") ; #DEBUG_LINE_NO:119
        LPSystemUtil_ToggleLooting.SetValue(0.0) ; #DEBUG_LINE_NO:120
      EndIf
      Self.UpdateLootingDisplay(akTerminalRef, LPSystemUtil_ToggleLooting.GetValue() as Bool) ; #DEBUG_LINE_NO:123
    ElseIf auiMenuItemID == 2 ; #DEBUG_LINE_NO:126
      Self.Log("Menu item 2 selected") ; #DEBUG_LINE_NO:127
      Self.Log("Activating LodgeSafeRef") ; #DEBUG_LINE_NO:128
      LodgeSafeRef.Activate(PlayerRef, False) ; #DEBUG_LINE_NO:129
    ElseIf auiMenuItemID == 3 ; #DEBUG_LINE_NO:132
      Self.Log("Menu item 3 selected") ; #DEBUG_LINE_NO:133
      Self.Log("Opening inventory for LPDummyHoldingRef") ; #DEBUG_LINE_NO:134
      (LPDummyHoldingRef as Actor).OpenInventory(True, None, False) ; #DEBUG_LINE_NO:135
    ElseIf auiMenuItemID == 4 ; #DEBUG_LINE_NO:138
      Self.Log("Menu item 4 selected") ; #DEBUG_LINE_NO:139
      Self.Log("Opening inventory for PlayerHomeShip") ; #DEBUG_LINE_NO:140
      spaceshipreference PlayerShip = PlayerHomeShip.GetRef() as spaceshipreference ; #DEBUG_LINE_NO:141
      PlayerShip.OpenInventory() ; #DEBUG_LINE_NO:142
    ElseIf auiMenuItemID == 5 ; #DEBUG_LINE_NO:145
      Self.Log("Menu item 5 selected - Enable Debugging") ; #DEBUG_LINE_NO:146
      Bool currentDebugSetting = LPSystemUtil_Debug.GetValue() as Bool ; #DEBUG_LINE_NO:147
      Self.Log("Current debug setting: " + currentDebugSetting as String) ; #DEBUG_LINE_NO:148
      If !currentDebugSetting ; #DEBUG_LINE_NO:149
        Self.Log("Turning debugging on") ; #DEBUG_LINE_NO:150
        LPSystemUtil_Debug.SetValue(1.0) ; #DEBUG_LINE_NO:151
      Else
        Self.Log("Turning debugging off") ; #DEBUG_LINE_NO:153
        LPSystemUtil_Debug.SetValue(0.0) ; #DEBUG_LINE_NO:154
      EndIf
      Self.UpdateDebugDisplay(akTerminalRef, LPSystemUtil_Debug.GetValue() as Bool) ; #DEBUG_LINE_NO:157
    EndIf
  EndIf
EndEvent
