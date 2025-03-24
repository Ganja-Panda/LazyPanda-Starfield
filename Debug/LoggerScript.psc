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
	GlobalVariable Property LPSystemUtil_Debug Auto Const Mandatory ; 1 = ON, 0 = OFF
EndGroup

;-- Debug Messages
; Messages displayed when toggling debug on or off.
Group DebugMessages
	Message Property LPDebugOnMsg  Auto Const Mandatory ; Message shown when debug is enabled
	Message Property LPDebugOffMsg Auto Const Mandatory ; Message shown when debug is disabled
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
	Return LPSystemUtil_Debug.GetValue() == 1.0
EndFunction

;-- Async Polling Function (non-blocking)
Function PollDebugStateAsync()
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
		Debug.TraceUser("Lazy Panda", "[LOG] " + msg)
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

		String prefix = "[INFO] "
		If severity == 2
			prefix = "[WARN] "
		ElseIf severity == 3
			prefix = "[ERROR] "
		ElseIf severity == 0
			prefix = "[VERBOSE] "
		EndIf

		Debug.TraceUser(source, prefix + msg)
	EndIf
EndFunction
