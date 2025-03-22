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
                Debug.TraceUser("Lazy Panda", "Debug mode enabled")
            Else
                LPDebugOffMsg.Show()
                Debug.TraceUser("Lazy Panda", "Debug mode disabled")
            EndIf

            bLastKnownState = currentState
        EndIf

        Utility.Wait(5.0)
    EndWhile
EndFunction

;======================================================================
; PUBLIC FUNCTIONS
;======================================================================

;-- Log Function --
; @param msg: The message to write to the log file.
; @param severity: Unused optional level of severity (default = 1).
; Writes to LazyPanda.log if debug is enabled.
Function Log(String msg, Int severity = 1)
    If IsEnabled()
        InitializeLog()

        String fullMsg = "[Lazy Panda] " + msg
        Debug.TraceUser("Lazy Panda", fullMsg)
    EndIf
EndFunction

;-- IsEnabled Function --
; @return: True if debug logging is currently enabled.
Bool Function IsEnabled()
    return LPSystemUtil_Debug.GetValue() as Bool
EndFunction

;-- Toggle Function --
; Flips debug state and shows a notification.
Function Toggle()
    Bool newState = !IsEnabled()
    LPSystemUtil_Debug.SetValue(newState as Float)

    InitializeLog()

    If newState
        LPDebugOnMsg.Show()
        Debug.TraceUser("Lazy Panda", "Debug mode enabled")
    Else
        LPDebugOffMsg.Show()
        Debug.TraceUser("Lazy Panda", "Debug mode disabled")
    EndIf
EndFunction

;-- StartPolling Function --
; Begins background thread to monitor debug state changes.
Function StartPolling()
    If bPollingStarted
        Return
    EndIf

    bLastKnownState = IsEnabled()
    bPollingStarted = True
    PollDebugState()
EndFunction
