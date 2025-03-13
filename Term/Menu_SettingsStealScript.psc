ScriptName LZP:Term:Menu_SettingsStealScript Extends TerminalMenu hidden

;-- Variables ---------------------------------------

;-- Properties --------------------------------------
Group GlobalVariable_Autofill
  GlobalVariable Property LPSetting_AllowStealing Auto mandatory
  GlobalVariable Property LPSetting_StealingIsHostile Auto mandatory
EndGroup

Group Message_Autofill
  Message Property LPOffMsg Auto Const mandatory
  Message Property LPOnMsg Auto Const mandatory
EndGroup

Group Misc
  TerminalMenu Property CurrentTerminalMenu Auto Const mandatory
  GlobalVariable Property LPSystemUtil_Debug Auto Const mandatory
EndGroup


;-- Functions ---------------------------------------

Function Log(String logMsg)
  If LPSystemUtil_Debug.GetValue() as Bool ; #DEBUG_LINE_NO:19
    Debug.Trace("[LZP:Settings] " + logMsg, 0) ; #DEBUG_LINE_NO:20
  EndIf
EndFunction

Function UpdateStealingSetting(ObjectReference akTerminalRef, Bool isEnabled)
  Message msgToUse = LPOffMsg ; #DEBUG_LINE_NO:25
  If isEnabled ; #DEBUG_LINE_NO:26
    msgToUse = LPOnMsg ; #DEBUG_LINE_NO:27
  EndIf
  akTerminalRef.AddTextReplacementData("Stealing", msgToUse as Form) ; #DEBUG_LINE_NO:29
  Self.Log("Updated Stealing to " + isEnabled as String) ; #DEBUG_LINE_NO:30
EndFunction

Function UpdateHostileSetting(ObjectReference akTerminalRef, Bool isEnabled)
  Message msgToUse = LPOffMsg ; #DEBUG_LINE_NO:34
  If isEnabled ; #DEBUG_LINE_NO:35
    msgToUse = LPOnMsg ; #DEBUG_LINE_NO:36
  EndIf
  akTerminalRef.AddTextReplacementData("Hostile", msgToUse as Form) ; #DEBUG_LINE_NO:38
  Self.Log("Updated Hostile to " + isEnabled as String) ; #DEBUG_LINE_NO:39
EndFunction

Event OnTerminalMenuEnter(TerminalMenu akTerminalBase, ObjectReference akTerminalRef)
  Self.Log("OnTerminalMenuEnter triggered") ; #DEBUG_LINE_NO:43
  Bool allowStealing = LPSetting_AllowStealing.GetValue() as Bool ; #DEBUG_LINE_NO:45
  Bool stealingIsHostile = LPSetting_StealingIsHostile.GetValue() as Bool ; #DEBUG_LINE_NO:46
  Self.UpdateStealingSetting(akTerminalRef, allowStealing) ; #DEBUG_LINE_NO:48
  Self.UpdateHostileSetting(akTerminalRef, stealingIsHostile) ; #DEBUG_LINE_NO:49
EndEvent

Event OnTerminalMenuItemRun(Int auiMenuItemID, TerminalMenu akTerminalBase, ObjectReference akTerminalRef)
  Self.Log("OnTerminalMenuItemRun triggered: MenuItemID = " + auiMenuItemID as String) ; #DEBUG_LINE_NO:53
  If akTerminalBase != CurrentTerminalMenu ; #DEBUG_LINE_NO:55
    Self.Log("Terminal menu does not match. Exiting event.") ; #DEBUG_LINE_NO:56
    Return  ; #DEBUG_LINE_NO:57
  EndIf
  If auiMenuItemID == 0 ; #DEBUG_LINE_NO:60
    Bool newStealState = !LPSetting_AllowStealing.GetValue() as Bool ; #DEBUG_LINE_NO:61
    LPSetting_AllowStealing.SetValue(newStealState as Float) ; #DEBUG_LINE_NO:62
    Self.UpdateStealingSetting(akTerminalRef, newStealState) ; #DEBUG_LINE_NO:63
    If !newStealState ; #DEBUG_LINE_NO:65
      LPSetting_StealingIsHostile.SetValue(0.0) ; #DEBUG_LINE_NO:66
      Self.UpdateHostileSetting(akTerminalRef, False) ; #DEBUG_LINE_NO:67
    EndIf
  ElseIf auiMenuItemID == 1 ; #DEBUG_LINE_NO:70
    Bool newHostileState = !LPSetting_StealingIsHostile.GetValue() as Bool ; #DEBUG_LINE_NO:71
    LPSetting_StealingIsHostile.SetValue(newHostileState as Float) ; #DEBUG_LINE_NO:72
    Self.UpdateHostileSetting(akTerminalRef, newHostileState) ; #DEBUG_LINE_NO:73
  EndIf
EndEvent
