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

;======================================================================
; VARIABLES
;======================================================================

Bool bLogInitialized = False  ; Tracks whether the user log has been opened

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

;======================================================================
; PUBLIC FUNCTIONS
;======================================================================

;-- Log Function --
; Writes a message to the LazyPanda.log file if logging is enabled
Function Log(String msg, Int severity = 1)
    If IsEnabled()
        InitializeLog()

        String fullMsg = "[Lazy Panda] " + msg

        ; Always use TraceUser to ensure it goes to LazyPanda.log
        Debug.TraceUser(fullMsg)
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

    String msg
    If newState
        msg = "[Lazy Panda] Logging Enabled"
    Else
        msg = "[Lazy Panda] Logging Disabled"
    EndIf

    Debug.Notification(msg)
    Debug.TraceUser(msg)
EndFunction
