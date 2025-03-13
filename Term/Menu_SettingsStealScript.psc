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
  If LPSystemUtil_Debug.GetValue() as Bool
    Debug.Trace("[LZP:Settings] " + logMsg, 0)
  EndIf
EndFunction

Function UpdateStealingSetting(ObjectReference akTerminalRef, Bool isEnabled)
  Message msgToUse = LPOffMsg
  If isEnabled
    msgToUse = LPOnMsg
  EndIf
  akTerminalRef.AddTextReplacementData("Stealing", msgToUse as Form)
  Log("Updated Stealing to " + isEnabled as String)
EndFunction

Function UpdateHostileSetting(ObjectReference akTerminalRef, Bool isEnabled)
  Message msgToUse = LPOffMsg
  If isEnabled
    msgToUse = LPOnMsg
  EndIf
  akTerminalRef.AddTextReplacementData("Hostile", msgToUse as Form)
  Log("Updated Hostile to " + isEnabled as String)
EndFunction

Event OnTerminalMenuEnter(TerminalMenu akTerminalBase, ObjectReference akTerminalRef)
  Log("OnTerminalMenuEnter triggered")
  Bool allowStealing = LPSetting_AllowStealing.GetValue() as Bool
  Bool stealingIsHostile = LPSetting_StealingIsHostile.GetValue() as Bool
  UpdateStealingSetting(akTerminalRef, allowStealing)
  UpdateHostileSetting(akTerminalRef, stealingIsHostile)
EndEvent

Event OnTerminalMenuItemRun(Int auiMenuItemID, TerminalMenu akTerminalBase, ObjectReference akTerminalRef)
  Log("OnTerminalMenuItemRun triggered: MenuItemID = " + auiMenuItemID as String)
  If akTerminalBase != CurrentTerminalMenu
    Log("Terminal menu does not match. Exiting event.")
    Return
  EndIf
  If auiMenuItemID == 0
    Bool newStealState = !LPSetting_AllowStealing.GetValue() as Bool
    LPSetting_AllowStealing.SetValue(newStealState as Float)
    UpdateStealingSetting(akTerminalRef, newStealState)
    If !newStealState
      LPSetting_StealingIsHostile.SetValue(0.0)
      UpdateHostileSetting(akTerminalRef, False)
    EndIf
  ElseIf auiMenuItemID == 1
    Bool newHostileState = !LPSetting_StealingIsHostile.GetValue() as Bool
    LPSetting_StealingIsHostile.SetValue(newHostileState as Float)
    UpdateHostileSetting(akTerminalRef, newHostileState)
  EndIf
EndEvent
