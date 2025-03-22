;======================================================================
; Script Name   : LZP:Debug:LoggerScript
; Author        : Ganja Panda
; Mod           : Lazy Panda - A Scav's Auto Loot for Starfield
; Purpose       : Centralized toggleable logging system for Lazy Panda
; Description   : Routes trace messages to LazyPanda.log using Debug.TraceUser().
;                 Controlled by the LPSystemUtil_Debug GlobalVariable. Supports
;                 verbosity levels with potential expansion via the severity arg:
;                   1 = Info, 2 = Warning, 3 = Error
; Dependencies  : LazyPanda.esm
; Usage         : Call Logger.Log("message") or use Toggle() to enable/disable
;======================================================================
ScriptName LZP:Debug:LoggerScript Extends Quest

;======================================================================
; PROPERTIES
;======================================================================

;-- Debug Controls
; Controls whether debug logging is enabled at runtime.
Group DebugControls
    GlobalVariable Property LPSystemUtil_Debug Auto Const Mandatory
EndGroup

;-- Debug Messages
; Messages displayed when toggling debug on or off.
Group DebugMessages
    Message Property LPDebugOnMsg  Auto Const Mandatory
    Message Property LPDebugOffMsg Auto Const Mandatory
EndGroup

;======================================================================
; VARIABLES
;======================================================================
Bool bLogInitialized = False  ; Tracks whether the user log has been opened
Bool bLastKnownState = False  ; Tracks previous debug value to detect change
Bool bPollingStarted = False  ; Prevents duplicate polling threads

;======================================================================
; EVENTS
;======================================================================
Event OnInit()
    StartPolling()
EndEvent

;======================================================================
; PRIVATE FUNCTIONS
;======================================================================

;-- InitializeLog Function --
; Opens the LazyPanda.log file once per session.
Function InitializeLog()
    If !bLogInitialized
        Debug.OpenUserLog("LazyPanda")
        bLogInitialized = True
    EndIf
EndFunction

;-- PollDebugState Function --
; Continuously checks for changes in debug toggle state and logs transitions.
Function PollDebugState()
    While bPollingStarted
        Bool currentState = IsEnabled()

        If currentState != bLastKnownState
            InitializeLog()

            If currentState
                LPDebugOnMsg.Show()
                Debug.TraceUser("Lazy Panda", "[INFO] Debug mode enabled")
            Else
                LPDebugOffMsg.Show()
                Debug.TraceUser("Lazy Panda", "[INFO] Debug mode disabled")
            EndIf

            bLastKnownState = currentState
        EndIf

        Utility.Wait(5.0)
    EndWhile
EndFunction

;======================================================================
; PUBLIC FUNCTIONS
;======================================================================

;-- Determines if debug mode is currently enabled
Bool Function IsEnabled()
    Return (LPSystemUtil_Debug.GetValueInt() > 0)
EndFunction

;-- Starts the polling thread if not already started
Function StartPolling()
    If !bPollingStarted
        bPollingStarted = True
        PollDebugState()
    EndIf
EndFunction

;-- Toggles the debug variable between on and off
Function Toggle()
    If IsEnabled()
        LPSystemUtil_Debug.SetValueInt(0)
    Else
        LPSystemUtil_Debug.SetValueInt(1)
    EndIf
EndFunction

;-- Logs a message with optional severity: 1=Info (default), 2=Warning, 3=Error
Function Log(String msg, Int severity = 1)
    If !IsEnabled()
        Return
    EndIf

    InitializeLog()

    String prefix = "[INFO] "
    If severity == 2
        prefix = "[WARN] "
    ElseIf severity == 3
        prefix = "[ERROR] "
    EndIf

    Debug.TraceUser("Lazy Panda", prefix + msg)
EndFunction

;-- Convenience wrapper for warning-level log
Function LogWarn(String msg)
    Log(msg, 2)
EndFunction

;-- Convenience wrapper for error-level log
Function LogError(String msg)
    Log(msg, 3)
EndFunction
