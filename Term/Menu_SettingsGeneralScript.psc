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
EndGroup


;-- Functions ---------------------------------------

Event OnTerminalMenuEnter(TerminalMenu akTerminalBase, ObjectReference akTerminalRef)
  Debug.Trace("OnTerminalMenuEnter: Entered terminal menu", 0) ; #DEBUG_LINE_NO:26
  Float currentRadius = Self.LPSetting_Radius.GetValue() ; #DEBUG_LINE_NO:27
  Debug.Trace("OnTerminalMenuEnter: Current radius is " + currentRadius as String, 0) ; #DEBUG_LINE_NO:28
  akTerminalRef.AddTextReplacementValue("currentRadius", currentRadius) ; #DEBUG_LINE_NO:29
  Int currentDest = Self.LPSetting_SendTo.GetValue() as Int ; #DEBUG_LINE_NO:30
  Debug.Trace("OnTerminalMenuEnter: Current destination is " + currentDest as String, 0) ; #DEBUG_LINE_NO:31
  If currentDest == 1 ; #DEBUG_LINE_NO:32
    akTerminalRef.AddTextReplacementData("Destination", Self.LPDestPlayerMsg as Form) ; #DEBUG_LINE_NO:33
    Debug.Trace("OnTerminalMenuEnter: Destination set to Player", 0) ; #DEBUG_LINE_NO:34
  ElseIf currentDest == 2 ; #DEBUG_LINE_NO:35
    akTerminalRef.AddTextReplacementData("Destination", Self.LPDestLodgeSafeMsg as Form) ; #DEBUG_LINE_NO:36
    Debug.Trace("OnTerminalMenuEnter: Destination set to Lodge Safe", 0) ; #DEBUG_LINE_NO:37
  ElseIf currentDest == 3 ; #DEBUG_LINE_NO:38
    akTerminalRef.AddTextReplacementData("Destination", Self.LPDestDummyMsg as Form) ; #DEBUG_LINE_NO:39
    Debug.Trace("OnTerminalMenuEnter: Destination set to Dummy", 0) ; #DEBUG_LINE_NO:40
  EndIf
EndEvent

Event OnTerminalMenuItemRun(Int auiMenuItemID, TerminalMenu akTerminalBase, ObjectReference akTerminalRef)
  Debug.Trace(("OnTerminalMenuItemRun: Menu item " + auiMenuItemID as String) + " selected", 0) ; #DEBUG_LINE_NO:46
  If akTerminalBase == Self.CurrentTerminalMenu ; #DEBUG_LINE_NO:47
    If auiMenuItemID == 0 ; #DEBUG_LINE_NO:48
      Float currentRadius = Self.LPSetting_Radius.GetValue() ; #DEBUG_LINE_NO:49
      Debug.Trace("OnTerminalMenuItemRun: Current radius is " + currentRadius as String, 0) ; #DEBUG_LINE_NO:50
      Int currentRadiusIndex = Self.RadiusChoices.find(currentRadius, 0) ; #DEBUG_LINE_NO:51
      Debug.Trace("OnTerminalMenuItemRun: Current radius index is " + currentRadiusIndex as String, 0) ; #DEBUG_LINE_NO:52
      If currentRadiusIndex == Self.RadiusChoices.Length - 1 ; #DEBUG_LINE_NO:53
        Self.LPSetting_Radius.SetValue(Self.RadiusChoices[0]) ; #DEBUG_LINE_NO:54
        akTerminalRef.AddTextReplacementValue("currentRadius", Self.RadiusChoices[0]) ; #DEBUG_LINE_NO:55
        Debug.Trace("OnTerminalMenuItemRun: Radius set to " + Self.RadiusChoices[0] as String, 0) ; #DEBUG_LINE_NO:56
      Else
        Int newRadiusIndex = currentRadiusIndex + 1 ; #DEBUG_LINE_NO:58
        Self.LPSetting_Radius.SetValue(Self.RadiusChoices[newRadiusIndex]) ; #DEBUG_LINE_NO:59
        akTerminalRef.AddTextReplacementValue("currentRadius", Self.RadiusChoices[newRadiusIndex]) ; #DEBUG_LINE_NO:60
        Debug.Trace("OnTerminalMenuItemRun: Radius set to " + Self.RadiusChoices[newRadiusIndex] as String, 0) ; #DEBUG_LINE_NO:61
      EndIf
    ElseIf auiMenuItemID == 1 ; #DEBUG_LINE_NO:63
      Int currentDest = Self.LPSetting_SendTo.GetValue() as Int ; #DEBUG_LINE_NO:64
      Debug.Trace("OnTerminalMenuItemRun: Current destination is " + currentDest as String, 0) ; #DEBUG_LINE_NO:65
      If currentDest == 3 ; #DEBUG_LINE_NO:66
        Self.LPSetting_SendTo.SetValue(1.0) ; #DEBUG_LINE_NO:67
        akTerminalRef.AddTextReplacementData("Destination", Self.LPDestPlayerMsg as Form) ; #DEBUG_LINE_NO:68
        Debug.Trace("OnTerminalMenuItemRun: Destination set to Player", 0) ; #DEBUG_LINE_NO:69
      ElseIf currentDest == 1 ; #DEBUG_LINE_NO:70
        Self.LPSetting_SendTo.SetValue(2.0) ; #DEBUG_LINE_NO:71
        akTerminalRef.AddTextReplacementData("Destination", Self.LPDestLodgeSafeMsg as Form) ; #DEBUG_LINE_NO:72
        Debug.Trace("OnTerminalMenuItemRun: Destination set to Lodge Safe", 0) ; #DEBUG_LINE_NO:73
      ElseIf currentDest == 2 ; #DEBUG_LINE_NO:74
        Self.LPSetting_SendTo.SetValue(3.0) ; #DEBUG_LINE_NO:75
        akTerminalRef.AddTextReplacementData("Destination", Self.LPDestDummyMsg as Form) ; #DEBUG_LINE_NO:76
        Debug.Trace("OnTerminalMenuItemRun: Destination set to Dummy", 0) ; #DEBUG_LINE_NO:77
      EndIf
    EndIf
  EndIf
EndEvent
