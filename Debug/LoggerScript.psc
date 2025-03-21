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

;======================================================================
; GLOBAL FUNCTIONS
;======================================================================

;-- ToggleLogging Function --
; Global function for CGF/hotkey toggle
; Example: cgf "LZP:Debug:LoggerScript.ToggleLogging"
Function ToggleLogging() Global
    LoggerScript loggerInstance = Game.GetFormFromFile(0x0000098D, "LazyPanda.esm") as LoggerScript
    Message LPDebugOnMsgGlobal = Game.GetFormFromFile(0x00000996, "LazyPanda.esm") as Message
    Message LPDebugOffMsgGlobal = Game.GetFormFromFile(0x00000995, "LazyPanda.esm") as Message

    If loggerInstance
        Bool newState = !loggerInstance.IsEnabled()
        loggerInstance.LPSystemUtil_Debug.SetValue(newState as Float)

        If newState
            LPDebugOnMsgGlobal.Show()
            Debug.TraceUser("Lazy Panda", "Debug mode enabled")
        Else
            LPDebugOffMsgGlobal.Show()
            Debug.TraceUser("Lazy Panda", "Debug mode disabled")
        EndIf
    Else
        Debug.Notification("[Lazy Panda] ERROR: LoggerScript not found")
        Debug.Trace("[Lazy Panda] ERROR: LoggerScript quest not found at expected FormID.")
    EndIf
EndFunction


