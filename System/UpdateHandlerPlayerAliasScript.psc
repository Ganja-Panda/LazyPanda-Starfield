;======================================================================
; Script: LZP:System:UpdateHandlerPlayerAliasScript
; Description: Handles updates for the player alias. Version logic is centralized.
;======================================================================

ScriptName LZP:System:UpdateHandlerPlayerAliasScript Extends ReferenceAlias hidden

;======================================================================
; VARIABLES
;======================================================================

; Stores the last applied update version as a string.
String sUpdatesAppliedVersion = "0"

;======================================================================
; PROPERTIES
;======================================================================

;-- References --
Actor Property PlayerRef Auto Const Mandatory
FormList Property LPSystem_Script_Perks Auto Const Mandatory

;-- Version Manager --
; Reference to the VersionManagerScript for version control.
LZP:System:VersionManagerScript Property VersionManager Auto Const Mandatory

;-- Logging System --
; Reference to the LoggerScript for centralized logging.
LZP:Debug:LoggerScript Property LoggerScript Auto Const Mandatory

;======================================================================
; EVENT HANDLERS
;======================================================================

Event OnAliasInit()
    If LoggerScript
        LoggerScript.Log("UpdateHandler: OnAliasInit triggered", 3)
    EndIf
    CheckForUpdates()
EndEvent

Event OnPlayerLoadGame()
    If LoggerScript
        LoggerScript.Log("UpdateHandler: OnPlayerLoadGame triggered", 3)
    EndIf
    CheckForUpdates()
EndEvent

;======================================================================
; UPDATE SYSTEM FUNCTIONS
;======================================================================

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

Function UpdateStep_1001()
    If LoggerScript
        LoggerScript.Log("UpdateHandler: Executing UpdateStep_1001: Adding missing perks", 3)
    EndIf
    AddPerks()
EndFunction

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