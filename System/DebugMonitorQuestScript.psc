ScriptName LZP:System:DebugMonitorQuestScript Extends Quest

;-- Variables ---------------------------------------
Bool bDebugEnabled = False

;-- Properties --------------------------------------
GlobalVariable Property LPSystemUtil_Debug Auto Const mandatory
ReferenceAlias Property PlayerAlias Auto Const mandatory
Float Property checkInterval = 5.0 Auto

;-- Functions ---------------------------------------

Event OnInit()
  Log("[Lazy Panda] DebugMonitorQuestScript OnInit triggered")
  StartTimer(checkInterval, 0)
EndEvent

Event OnTimer(Int aiTimerID)
  CheckDebugStatus()
  StartTimer(checkInterval, 0)
EndEvent

Function Log(String logMsg)
  Debug.Trace(logMsg, 0)
EndFunction

Function CheckDebugStatus()
  Bool currentDebugStatus = LPSystemUtil_Debug.GetValue() != 0.0
  If currentDebugStatus != bDebugEnabled
    bDebugEnabled = currentDebugStatus
    If bDebugEnabled
      Log("[Lazy Panda] Debugging enabled, triggering update")
      PlayerAlias.GetReference().GetActorRefOwner().EvaluatePackage(False)
    Else
      Log("[Lazy Panda] Debugging disabled")
    EndIf
  EndIf
EndFunction
