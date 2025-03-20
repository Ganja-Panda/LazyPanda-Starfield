;======================================================================
; Script: LZP:System:DebugMonitorQuestScript
; Description: This Quest script monitors the debug flag and triggers
; updates based on its status. It periodically checks the debug flag
; and logs messages to assist with troubleshooting.
;======================================================================

ScriptName LZP:System:DebugMonitorQuestScript Extends Quest

;======================================================================
; PROPERTIES
;======================================================================

;-- Global Variables --
; Global variables that control the debug system.
GlobalVariable Property LPSystemUtil_Debug Auto Const Mandatory
ReferenceAlias Property PlayerAlias Auto Const Mandatory

;-- Timer Properties --
; Interval in seconds to check the debug flag.
Float Property checkInterval = 5.0 Auto

;======================================================================
; VARIABLES
;======================================================================

; Local flag to track the debug status.
Bool bDebugEnabled = False

;======================================================================
; EVENT HANDLERS
;======================================================================

;-- OnInit Event Handler --
; Called when the quest is initialized. Begins the debug check timer.
Event OnInit()
    LZP:SystemScript.Log("[Lazy Panda] DebugMonitorQuestScript OnInit triggered", 3)
    StartTimer(checkInterval)
EndEvent

;-- OnTimer Event Handler --
; Called when the timer expires. Checks the debug status and restarts the timer.
Event OnTimer(Int aiTimerID)
    CheckDebugStatus()
    StartTimer(checkInterval)
EndEvent

;======================================================================
; UTILITY FUNCTIONS
;======================================================================
;-- CheckDebugStatus Function --
; Checks the current debug status and triggers updates if the status changes.
Function CheckDebugStatus()
    ; Convert the global variable's value to boolean (non-zero means true)
    Bool currentDebugStatus = (LPSystemUtil_Debug.GetValue() != 0.0)
    If currentDebugStatus != bDebugEnabled
        bDebugEnabled = currentDebugStatus
        If bDebugEnabled
            LZP:SystemScript.Log("[Lazy Panda] Debugging enabled, triggering update", 3)
            ; Trigger the player's update (EvaluatePackage is assumed to be valid here)
            PlayerAlias.GetReference().GetActorRefOwner().EvaluatePackage()
        Else
            LZP:SystemScript.Log("[Lazy Panda] Debugging disabled", 3)
        EndIf
    EndIf
EndFunction