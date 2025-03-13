ScriptName LZP:Term:Menu_SettingsGeneralScript Extends TerminalMenu hidden

;-- Variables ---------------------------------------

;-- Properties --------------------------------------
Group GlobalVariable_Autofill
  GlobalVariable Property LPSetting_Radius Auto mandatory
  GlobalVariable Property LPSetting_SendTo Auto mandatory
EndGroup

Group Message_Autofill
  Message Property LPDestLodgeSafeMsg Auto Const mandatory
  Message Property LPDestPlayerMsg Auto Const mandatory
  Message Property LPDestDummyMsg Auto Const mandatory
  Message Property LPOffMsg Auto Const mandatory
  Message Property LPOnMsg Auto Const mandatory
EndGroup

Group Misc
  Float[] Property RadiusChoices Auto Const mandatory
  TerminalMenu Property CurrentTerminalMenu Auto Const mandatory
  GlobalVariable Property LPSystemUtil_Debug Auto Const mandatory
EndGroup


;-- Functions ---------------------------------------

Function Log(String logMsg)
  If LPSystemUtil_Debug.GetValue() as Bool ; #DEBUG_LINE_NO:46
    Debug.Trace(logMsg, 0) ; #DEBUG_LINE_NO:47
  EndIf
EndFunction

Function UpdateDestinationDisplay(ObjectReference akTerminalRef, Int dest)
  If dest == 1 ; #DEBUG_LINE_NO:54
    akTerminalRef.AddTextReplacementData("Destination", LPDestPlayerMsg as Form) ; #DEBUG_LINE_NO:55
    Self.Log("Setting Destination to LPDestPlayerMsg") ; #DEBUG_LINE_NO:56
  ElseIf dest == 2 ; #DEBUG_LINE_NO:57
    akTerminalRef.AddTextReplacementData("Destination", LPDestLodgeSafeMsg as Form) ; #DEBUG_LINE_NO:58
    Self.Log("Setting Destination to LPDestLodgeSafeMsg") ; #DEBUG_LINE_NO:59
  ElseIf dest == 3 ; #DEBUG_LINE_NO:60
    akTerminalRef.AddTextReplacementData("Destination", LPDestDummyMsg as Form) ; #DEBUG_LINE_NO:61
    Self.Log("Setting Destination to LPDestDummyMsg") ; #DEBUG_LINE_NO:62
  EndIf
EndFunction

Function CycleRadius(ObjectReference akTerminalRef)
  Float currentRadius = LPSetting_Radius.GetValue() ; #DEBUG_LINE_NO:69
  Int currentRadiusIndex = RadiusChoices.find(currentRadius, 0) ; #DEBUG_LINE_NO:71
  Int newRadiusIndex = currentRadiusIndex + 1 ; #DEBUG_LINE_NO:72
  If currentRadiusIndex == RadiusChoices.Length - 1 ; #DEBUG_LINE_NO:74
    newRadiusIndex = 0 ; #DEBUG_LINE_NO:75
  EndIf
  LPSetting_Radius.SetValue(RadiusChoices[newRadiusIndex]) ; #DEBUG_LINE_NO:78
  akTerminalRef.AddTextReplacementValue("currentRadius", RadiusChoices[newRadiusIndex]) ; #DEBUG_LINE_NO:79
  Self.Log("Cycled radius to " + RadiusChoices[newRadiusIndex] as String) ; #DEBUG_LINE_NO:80
EndFunction

Event OnTerminalMenuEnter(TerminalMenu akTerminalBase, ObjectReference akTerminalRef)
  Self.Log("OnTerminalMenuEnter triggered") ; #DEBUG_LINE_NO:90
  Float currentRadius = LPSetting_Radius.GetValue() ; #DEBUG_LINE_NO:92
  akTerminalRef.AddTextReplacementValue("currentRadius", currentRadius) ; #DEBUG_LINE_NO:93
  Self.Log("Current radius: " + currentRadius as String) ; #DEBUG_LINE_NO:94
  Int currentDest = LPSetting_SendTo.GetValue() as Int ; #DEBUG_LINE_NO:97
  Self.UpdateDestinationDisplay(akTerminalRef, currentDest) ; #DEBUG_LINE_NO:98
  Self.Log("Current destination: " + currentDest as String) ; #DEBUG_LINE_NO:99
EndEvent

Event OnTerminalMenuItemRun(Int auiMenuItemID, TerminalMenu akTerminalBase, ObjectReference akTerminalRef)
  Self.Log("OnTerminalMenuItemRun triggered with auiMenuItemID: " + auiMenuItemID as String) ; #DEBUG_LINE_NO:105
  If akTerminalBase == CurrentTerminalMenu ; #DEBUG_LINE_NO:106
    Self.Log("Terminal menu matches CurrentTerminalMenu") ; #DEBUG_LINE_NO:107
    If auiMenuItemID == 0 ; #DEBUG_LINE_NO:109
      Self.Log("Cycling radius") ; #DEBUG_LINE_NO:110
      Self.CycleRadius(akTerminalRef) ; #DEBUG_LINE_NO:111
    ElseIf auiMenuItemID == 1 ; #DEBUG_LINE_NO:113
      Self.Log("Cycling destination") ; #DEBUG_LINE_NO:114
      Int currentDest = LPSetting_SendTo.GetValue() as Int ; #DEBUG_LINE_NO:115
      If currentDest == 3 ; #DEBUG_LINE_NO:117
        LPSetting_SendTo.SetValue(1.0) ; #DEBUG_LINE_NO:118
        currentDest = 1 ; #DEBUG_LINE_NO:119
      ElseIf currentDest == 1 ; #DEBUG_LINE_NO:120
        LPSetting_SendTo.SetValue(2.0) ; #DEBUG_LINE_NO:121
        currentDest = 2 ; #DEBUG_LINE_NO:122
      ElseIf currentDest == 2 ; #DEBUG_LINE_NO:123
        LPSetting_SendTo.SetValue(3.0) ; #DEBUG_LINE_NO:124
        currentDest = 3 ; #DEBUG_LINE_NO:125
      EndIf
      Self.UpdateDestinationDisplay(akTerminalRef, currentDest) ; #DEBUG_LINE_NO:127
      Self.Log("New destination: " + currentDest as String) ; #DEBUG_LINE_NO:128
    EndIf
  EndIf
EndEvent
