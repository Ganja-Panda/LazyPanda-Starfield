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

ScriptName LZP:System:DeathMonitorQuestScript Extends Quest

;======================================================================
; PROPERTIES
;======================================================================

;-- Logger
; Logging system for initialization and exposed for fragment access
Group Logger
    LZP:Debug:LoggerScript Property Logger Auto                         ; Accessible from fragments via (kmyQuest as DeathMonitorQuestScript).Logger
EndGroup

;-- CorpseProcessor
; Reserved for future death detection logic and corpse cleanup
Group CorpseProcessor
    LZP:Looting:CorpseProcessorScript Property CorpseProcessor Auto
EndGroup

;======================================================================
; EVENT: OnInit
; Called when the quest initializes
;======================================================================
Event OnInit()
    if Logger && Logger.IsEnabled()
        Logger.LogInfo("DeathMonitorQuestScript initialized.")
    endif
EndEvent
