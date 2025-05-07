;======================================================================
; Script Name   : LZP:Debug:LoggerScript
; Author        : Ganja Panda
; Mod           : Lazy Panda - A Scav's Auto Loot for Starfield
; Purpose       : Centralized toggleable logging system for Lazy Panda
; Description   : Routes trace messages to LazyPanda.log using Debug.TraceUser().
;                 Controlled by the LPSystemUtil_Debug GlobalVariable.
;                 Logs all messages (including verbose) when enabled.
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
	GlobalVariable Property LZP_System_Logging Auto Const Mandatory ; 1 = ON, 0 = OFF
EndGroup

;-- Debug Messages
; Messages displayed when toggling debug on or off.
Group DebugMessages
	Message Property LZP_MESG_Logging_Enabled  Auto Const Mandatory ; Message shown when debug is enabled
	Message Property LZP_MESG_Logging_Disabled Auto Const Mandatory ; Message shown when debug is disabled
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
	PollDebugStateAsync()
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

;-- IsEnabled Function --
; Checks the current debug toggle state
Bool Function IsEnabled()
	Return LZP_System_Logging.GetValue() == 1.0
EndFunction

;-- Async Polling Function (non-blocking)
Function PollDebugStateAsync()
	Bool currentState = IsEnabled()
	If currentState != bLastKnownState
		InitializeLog()
		If currentState
			LZP_MESG_Logging_Enabled.Show()
			LogAdv("Debug mode enabled", 1, "LazyPanda")
		Else
			LZP_MESG_Logging_Disabled.Show()
			LogAdv("Debug mode disabled", 1, "LazyPanda")
		EndIf
		bLastKnownState = currentState
	EndIf

	If !bPollingStarted
		bPollingStarted = True
		Utility.Wait(5.0)
		PollDebugStateAsync()
	EndIf
EndFunction

;======================================================================
; PUBLIC FUNCTIONS
;======================================================================

;----------------------------------------------------------------------
; Function : Log
; Purpose  : Primary logging function for basic output
; Params   : msg - The message to log
;----------------------------------------------------------------------
Function Log(String msg)
	If IsEnabled()
		InitializeLog()
		LogAdv(msg, 1, "LazyPanda")
	EndIf
EndFunction

;----------------------------------------------------------------------
; Function : LogAdv
; Purpose  : Advanced logging with severity and optional source tag
; Params   : msg     - The message to log
;            severity - 0 (Verbose), 1 (Info), 2 (Warn), 3 (Error)
;            source   - Optional identifier for log origin
;----------------------------------------------------------------------
Function LogAdv(String msg, Int severity = 1, String source = "LazyPanda")
	If IsEnabled()
		InitializeLog()

		; Set log level labels
		String levelLabel = "INFO"
		If severity == 0
			levelLabel = "VERBOSE"
		ElseIf severity == 2
			levelLabel = "WARN"
		ElseIf severity == 3
			levelLabel = "ERROR"
		EndIf

		; Get timestamp (in-game time as fallback)
		Float gameTime = Utility.GetCurrentGameTime()
		Int hours = (gameTime * 24) % 24
		Int minutes = (gameTime * 1440) % 60
		Int seconds = (gameTime * 86400) % 60
		String timestamp = hours + ":" + minutes + ":" + seconds

		; Format the log message
		String formattedMessage = "[" + timestamp + "][" + levelLabel + "][" + source + "] " + msg

		; Write to log
		Debug.TraceUser("Lazy Panda", formattedMessage)
	EndIf
EndFunction
