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
LZP:System:VersionManagerScript Property VersionManager Auto Const Mandatory

;======================================================================
; EVENT HANDLERS
;======================================================================

Event OnAliasInit()
    LZP:SystemScript.Log("OnAliasInit triggered", 3)
    CheckForUpdates()
EndEvent

Event OnPlayerLoadGame()
    LZP:SystemScript.Log("OnPlayerLoadGame triggered", 3)
    CheckForUpdates()
EndEvent

;======================================================================
; UPDATE SYSTEM FUNCTIONS
;======================================================================

Function CheckForUpdates()
    LZP:SystemScript.Log("CheckForUpdates called", 3)

    Int iCurrentVersion = (VersionManager.GetMajor() * 1000) + VersionManager.GetMinor()
    LZP:SystemScript.Log("Current version number: " + iCurrentVersion as String, 3)

    Int iAppliedVersion = sUpdatesAppliedVersion as Int
    LZP:SystemScript.Log("Previously applied version: " + iAppliedVersion as String, 3)

    If iAppliedVersion < iCurrentVersion
        LZP:SystemScript.Log("Updates needed. Applying updates from version " + iAppliedVersion as String + " to " + iCurrentVersion as String, 3)

        If iAppliedVersion < 1001
            UpdateStep_1001()
            iAppliedVersion = 1001
        EndIf

        ; [Add future version steps here]

        sUpdatesAppliedVersion = iAppliedVersion as String
        LZP:SystemScript.Log("Updates applied. New applied version: " + sUpdatesAppliedVersion, 3)
    Else
        LZP:SystemScript.Log("No updates needed", 3)
    EndIf
EndFunction

Function UpdateStep_1001()
    LZP:SystemScript.Log("Executing UpdateStep_1001: Adding missing perks", 3)
    AddPerks()
EndFunction

Function AddPerks()
    LZP:SystemScript.Log("AddPerks called", 3)
    Int index = 0
    While index < LPSystem_Script_Perks.GetSize()
        Perk currentPerk = LPSystem_Script_Perks.GetAt(index) as Perk
        LZP:SystemScript.Log("Checking perk: " + currentPerk as String, 3)
        If !Game.GetPlayer().HasPerk(currentPerk)
            LZP:SystemScript.Log("Adding perk: " + currentPerk as String, 3)
            Game.GetPlayer().AddPerk(currentPerk, False)
        Else
            LZP:SystemScript.Log("Player already has perk: " + currentPerk as String, 3)
        EndIf
        index += 1
    EndWhile
EndFunction
