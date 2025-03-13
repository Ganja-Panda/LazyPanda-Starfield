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
  If LPSystemUtil_Debug.GetValue() as Bool
    Debug.Trace(logMsg, 0)
  EndIf
EndFunction

Function UpdateDestinationDisplay(ObjectReference akTerminalRef, Int dest)
  If dest == 1
    akTerminalRef.AddTextReplacementData("Destination", LPDestPlayerMsg as Form)
    Log("Setting Destination to LPDestPlayerMsg")
  ElseIf dest == 2
    akTerminalRef.AddTextReplacementData("Destination", LPDestLodgeSafeMsg as Form)
    Log("Setting Destination to LPDestLodgeSafeMsg")
  ElseIf dest == 3
    akTerminalRef.AddTextReplacementData("Destination", LPDestDummyMsg as Form)
    Log("Setting Destination to LPDestDummyMsg")
  EndIf
EndFunction

Function CycleRadius(ObjectReference akTerminalRef)
  Float currentRadius = LPSetting_Radius.GetValue()
  Int currentRadiusIndex = RadiusChoices.find(currentRadius, 0)
  Int newRadiusIndex = currentRadiusIndex + 1
  If currentRadiusIndex == RadiusChoices.Length - 1
    newRadiusIndex = 0
  EndIf
  LPSetting_Radius.SetValue(RadiusChoices[newRadiusIndex])
  akTerminalRef.AddTextReplacementValue("currentRadius", RadiusChoices[newRadiusIndex])
  Log("Cycled radius to " + RadiusChoices[newRadiusIndex] as String)
EndFunction

Event OnTerminalMenuEnter(TerminalMenu akTerminalBase, ObjectReference akTerminalRef)
  Log("OnTerminalMenuEnter triggered")
  Float currentRadius = LPSetting_Radius.GetValue()
  akTerminalRef.AddTextReplacementValue("currentRadius", currentRadius)
  Log("Current radius: " + currentRadius as String)
  Int currentDest = LPSetting_SendTo.GetValue() as Int
  UpdateDestinationDisplay(akTerminalRef, currentDest)
  Log("Current destination: " + currentDest as String)
EndEvent

Event OnTerminalMenuItemRun(Int auiMenuItemID, TerminalMenu akTerminalBase, ObjectReference akTerminalRef)
  Log("OnTerminalMenuItemRun triggered with auiMenuItemID: " + auiMenuItemID as String)
  If akTerminalBase == CurrentTerminalMenu
    Log("Terminal menu matches CurrentTerminalMenu")
    If auiMenuItemID == 0
      Log("Cycling radius")
      CycleRadius(akTerminalRef)
    ElseIf auiMenuItemID == 1
      Log("Cycling destination")
      Int currentDest = LPSetting_SendTo.GetValue() as Int
      If currentDest == 3
        LPSetting_SendTo.SetValue(1.0)
        currentDest = 1
      ElseIf currentDest == 1
        LPSetting_SendTo.SetValue(2.0)
        currentDest = 2
      ElseIf currentDest == 2
        LPSetting_SendTo.SetValue(3.0)
        currentDest = 3
      EndIf
      UpdateDestinationDisplay(akTerminalRef, currentDest)
      Log("New destination: " + currentDest as String)
    EndIf
  EndIf
EndEvent
