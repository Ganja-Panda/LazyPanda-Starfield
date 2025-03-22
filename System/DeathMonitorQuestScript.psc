;======================================================================
; Script Name   : LZP:System:DeathMonitorQuestScript
; Author        : Ganja Panda
; Mod           : Lazy Panda - A Scav's Auto Loot for Starfield
; Purpose       : Monitors the player's death and triggers corpse processing
; Description   : Attached to a persistent quest. Initializes once and logs status.
;                 Intended to react to death-related events in future extensions.
; Dependencies  : LazyPanda.esm, LoggerScript, CorpseProcessorScript
; Usage         : Attach to a quest that starts with the game or system state
;======================================================================

Scriptname LZP:System:DeathMonitorQuestScript extends Quest

;======================================================================
; PROPERTIES
;======================================================================

;-- Logger Property --
Group Logger
    LZP:Debug:LoggerScript Property Logger Auto Const
EndGroup

;-- Corpse Processor
; Script responsible for processing corpse cleanup and looting
Group CorpseProcessor
    LZP:Looting:CorpseProcessorScript Property CorpseProcessor Auto
EndGroup

;======================================================================
; EVENTS
;======================================================================

;-- OnInit Event Handler --
; Triggered when the quest is initialized
; Used to log that the DeathMonitor is active
Event OnInit()
    If Logger && Logger.IsEnabled()
        Logger.Log("[Lazy Panda] DeathMonitorQuestScript initialized")
    EndIf
EndEvent