;======================================================================
; Script: LZP:Debug:LoggerScript
; Description: Central logging utility for Lazy Panda. Controlled by
; the LPSystemUtil_Debug global variable. Logs are routed to a dedicated
; LazyPanda.log file using Debug.TraceUser().
;======================================================================

ScriptName LZP:Debug:LoggerScript Extends Quest

;======================================================================
; PROPERTIES
;======================================================================

GlobalVariable Property LPSystemUtil_Debug Auto Const Mandatory
Message Property LPDebugOnMsg Auto Const Mandatory
Message Property LPDebugOffMsg Auto Const Mandatory

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
; Opens the dedicated LazyPanda.log file for user logging
Function InitializeLog()
    If !bLogInitialized
        Debug.OpenUserLog("LazyPanda")
        bLogInitialized = True
    EndIf
EndFunction

;-- PollDebugState Function --
; Internal polling thread that detects changes in debug state
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
; Writes a message to the LazyPanda.log file if logging is enabled
Function Log(String msg, Int severity = 1)
    If IsEnabled()
        InitializeLog()

        String fullMsg = "[Lazy Panda] " + msg

        Debug.TraceUser("Lazy Panda", fullMsg)
    EndIf
EndFunction

;-- IsEnabled Function --
; Returns True if debug logging is currently enabled
Bool Function IsEnabled()
    return LPSystemUtil_Debug.GetValue() as Bool
EndFunction

;-- Toggle Function --
; Toggles logging on/off and notifies the player
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
; Launches background monitoring of debug toggle
Function StartPolling()
    If bPollingStarted
        Return
    EndIf

    bLastKnownState = IsEnabled()
    bPollingStarted = True
    PollDebugState()
EndFunction