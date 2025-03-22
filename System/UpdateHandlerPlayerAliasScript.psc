;======================================================================
; Script Name   : LZP:System:UpdateHandlerPlayerAliasScript
; Author        : Ganja Panda
; Mod           : Lazy Panda - A Scav's Auto Loot for Starfield
; Purpose       : Tracks and applies version-controlled updates for the player
; Description   : Compares current mod version with last applied update version.
;                 Executes update steps such as adding perks to the player. Uses
;                 VersionManagerScript for version state, and LoggerScript for
;                 debugging each stage of update execution.
; Dependencies  : LazyPanda.esm, VersionManagerScript, LoggerScript
; Usage         : Attach to the player alias in a system quest. Triggers on init/load.
;======================================================================

ScriptName LZP:System:UpdateHandlerPlayerAliasScript Extends ReferenceAlias hidden

;======================================================================
; VARIABLES
;======================================================================

;-- Runtime State
; Tracks the last applied version to avoid reapplying updates
String sUpdatesAppliedVersion = "0"

;======================================================================
; PROPERTIES
;======================================================================

;-- References
; Required player and perk references
Group ReferenceData
    Actor Property PlayerRef Auto Const Mandatory
    FormList Property LPSystem_Script_Perks Auto Const Mandatory
EndGroup

;-- Version Manager
; Handles current version data
Group Versioning
    LZP:System:VersionManagerScript Property VersionManager Auto Const Mandatory
EndGroup

;-- Logging System
; Central debug output system
Group Logger
    LZP:Debug:LoggerScript Property LoggerScript Auto Const Mandatory
EndGroup

;======================================================================
; EVENT HANDLERS
;======================================================================

;-- OnAliasInit Event Handler --
; Called when the alias initializes. Used to check for updates.
Event OnAliasInit()
    If LoggerScript
        LoggerScript.Log("UpdateHandler: OnAliasInit triggered", 3)
    EndIf
    CheckForUpdates()
EndEvent

;-- OnPlayerLoadGame Event Handler --
; Called after a save is loaded. Ensures updates are checked post-load.
Event OnPlayerLoadGame()
    If LoggerScript
        LoggerScript.Log("UpdateHandler: OnPlayerLoadGame triggered", 3)
    EndIf
    CheckForUpdates()
EndEvent

;======================================================================
; UPDATE SYSTEM FUNCTIONS
;======================================================================

;-- CheckForUpdates Function --
; Compares applied version to current version and triggers updates if needed.
Function CheckForUpdates()
    If LoggerScript
        LoggerScript.Log("UpdateHandler: CheckForUpdates called", 3)
    EndIf

    ; Grab version components from the VersionManager
    Float major = VersionManager.GetMajor()
    Float minor = VersionManager.GetMinor()
    Float patch = VersionManager.GetPatch()
    
    ; Convert to a single Int version for comparison
    Int iCurrentVersion = ((major * 1000.0) + minor) as Int

    If LoggerScript
        LoggerScript.Log("UpdateHandler: Current version number: " + iCurrentVersion as String, 3)
    EndIf

    Int iAppliedVersion = sUpdatesAppliedVersion as Int
    If LoggerScript
        LoggerScript.Log("UpdateHandler: Previously applied version: " + iAppliedVersion as String, 3)
    EndIf

    If iAppliedVersion < iCurrentVersion
        If LoggerScript
            LoggerScript.Log("UpdateHandler: Updates needed. Applying updates from version " + iAppliedVersion as String + " to " + iCurrentVersion as String, 3)
        EndIf

        ; === Begin update steps ===
        If iAppliedVersion < 1001
            UpdateStep_1001()
            iAppliedVersion = 1001
        EndIf

        ; [Add future version steps here]

        ; Record applied version
        sUpdatesAppliedVersion = iAppliedVersion as String
        If LoggerScript
            LoggerScript.Log("UpdateHandler: Updates applied. New applied version: " + sUpdatesAppliedVersion, 3)
        EndIf
    Else
        If LoggerScript
            LoggerScript.Log("UpdateHandler: No updates needed", 3)
        EndIf
    EndIf
EndFunction

;-- UpdateStep_1001 Function --
; First update step: adds missing perks to player.
Function UpdateStep_1001()
    If LoggerScript
        LoggerScript.Log("UpdateHandler: Executing UpdateStep_1001: Adding missing perks", 3)
    EndIf
    AddPerks()
EndFunction

;-- AddPerks Function --
; Adds any perks from the system perk list that the player is missing.
Function AddPerks()
    If LoggerScript
        LoggerScript.Log("UpdateHandler: AddPerks called", 3)
    EndIf

    Int index = 0
    While index < LPSystem_Script_Perks.GetSize()
        Perk currentPerk = LPSystem_Script_Perks.GetAt(index) as Perk
        If LoggerScript
            LoggerScript.Log("UpdateHandler: Checking perk: " + currentPerk as String, 3)
        EndIf

        If !Game.GetPlayer().HasPerk(currentPerk)
            If LoggerScript
                LoggerScript.Log("UpdateHandler: Adding perk: " + currentPerk as String, 3)
            EndIf
            Game.GetPlayer().AddPerk(currentPerk, False)
        Else
            If LoggerScript
                LoggerScript.Log("UpdateHandler: Player already has perk: " + currentPerk as String, 3)
            EndIf
        EndIf

        index += 1
    EndWhile
EndFunction