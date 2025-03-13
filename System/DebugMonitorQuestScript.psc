ScriptName LZP:System:DebugMonitorQuestScript Extends Quest

;-- Variables ---------------------------------------
Bool bDebugEnabled = False

;-- Properties --------------------------------------
GlobalVariable Property LPSystemUtil_Debug Auto Const mandatory
ReferenceAlias Property PlayerAlias Auto Const mandatory
Float Property checkInterval = 5.0 Auto

;-- Functions ---------------------------------------

Event OnInit()
  Self.Log("[Lazy Panda] DebugMonitorQuestScript OnInit triggered") ; #DEBUG_LINE_NO:37
  Self.StartTimer(checkInterval, 0) ; #DEBUG_LINE_NO:38
EndEvent

Event OnTimer(Int aiTimerID)
  Self.CheckDebugStatus() ; #DEBUG_LINE_NO:44
  Self.StartTimer(checkInterval, 0) ; #DEBUG_LINE_NO:45
EndEvent

Function Log(String logMsg)
  Debug.Trace(logMsg, 0) ; #DEBUG_LINE_NO:55
EndFunction

Function CheckDebugStatus()
  Bool currentDebugStatus = LPSystemUtil_Debug.GetValue() != 0.0 ; #DEBUG_LINE_NO:62
  If currentDebugStatus != bDebugEnabled ; #DEBUG_LINE_NO:63
    bDebugEnabled = currentDebugStatus ; #DEBUG_LINE_NO:64
    If bDebugEnabled ; #DEBUG_LINE_NO:65
      Self.Log("[Lazy Panda] Debugging enabled, triggering update") ; #DEBUG_LINE_NO:66
      PlayerAlias.GetReference().GetActorRefOwner().EvaluatePackage(False) ; #DEBUG_LINE_NO:68
    Else
      Self.Log("[Lazy Panda] Debugging disabled") ; #DEBUG_LINE_NO:70
    EndIf
  EndIf
EndFunction
