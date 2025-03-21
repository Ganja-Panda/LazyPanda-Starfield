;======================================================================
; Script: LZP:System:DeathMonitorQuestScript
; Description: This script monitors the player's death events and handles
; specific actions when the player dies. It uses the LoggerScript for
; debug logging.
;======================================================================

Scriptname LZP:System:DeathMonitorQuestScript extends Quest

;======================================================================
; PROPERTY DEFINITIONS
;======================================================================

;-- Logger Property --
Group Logger
    LZP:Debug:LoggerScript Property Logger Auto Const
EndGroup

;-- Corpse Processor Property --
LZP:Looting:CorpseProcessorScript Property CorpseProcessor Auto

;======================================================================
; EVENT HANDLERS
;======================================================================

;-- OnInit Event Handler --
; Called when the quest starts or the game loads.
Event OnInit()
    If Logger && Logger.IsEnabled()
        Logger.Log("[Lazy Panda] DeathMonitorQuestScript initialized")
    EndIf
EndEvent