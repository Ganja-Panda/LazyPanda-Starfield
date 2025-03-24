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

String sUpdatesAppliedVersion = "0"

;======================================================================
; PROPERTIES
;======================================================================

Group ReferenceData
	Actor Property PlayerRef Auto Const Mandatory					; Player reference
	FormList Property LPSystem_Script_Perks Auto Const Mandatory	; List of perks to add to player
EndGroup

Group Versioning
	LZP:System:VersionManagerScript Property VersionManager Auto Const Mandatory	; Version manager script
EndGroup

Group Logger
	LZP:Debug:LoggerScript Property LoggerScript Auto Const Mandatory	; Logger script
EndGroup

;======================================================================
; EVENT HANDLERS
;======================================================================

Event OnAliasInit()
	Log("OnAliasInit triggered", 1)
	CheckForUpdates()
EndEvent

Event OnPlayerLoadGame()
	Log("OnPlayerLoadGame triggered", 1)
	CheckForUpdates()
EndEvent

;======================================================================
; UPDATE SYSTEM FUNCTIONS
;======================================================================

Function CheckForUpdates()
	Log("CheckForUpdates called", 1)

	Float major = VersionManager.GetMajor()
	Float minor = VersionManager.GetMinor()
	Float patch = VersionManager.GetPatch()
	Int iCurrentVersion = ((major * 1000.0) + minor) as Int
	Int iAppliedVersion = sUpdatesAppliedVersion as Int

	Log("Current version number: " + iCurrentVersion, 1)
	Log("Previously applied version: " + iAppliedVersion, 1)

	If iCurrentVersion < iAppliedVersion
		Log("WARNING: Save version is newer than mod version. Possible rollback detected.", 2)
		Return
	EndIf

	If iAppliedVersion < iCurrentVersion
		Log("Updates needed. Applying updates from version " + iAppliedVersion + " to " + iCurrentVersion, 1)

		; === Begin update steps ===
		If iAppliedVersion < 1001
			RunUpdateStep_1001()
			iAppliedVersion = 1001
		EndIf

		; [Add future version steps here]

		sUpdatesAppliedVersion = iAppliedVersion as String
		Log("Updates applied. New applied version: " + sUpdatesAppliedVersion, 1)

		Debug.Notification("Lazy Panda updated to version " + major + "." + minor + "." + patch)
	Else
		Log("No updates needed", 0)
	EndIf
EndFunction

Function RunUpdateStep_1001()
	Log("Applying update step 1001: Add AutoLoot Perks", 1)
	UpdateStep_1001()
EndFunction

Function UpdateStep_1001()
	Log("UpdateStep_1001 - Changelog: Added AutoLoot perks to player.", 1)
	AddPerks()
EndFunction

Function AddPerks()
	Log("AddPerks called", 1)

	If !LPSystem_Script_Perks
		Log("ERROR: LPSystem_Script_Perks FormList not found!", 3)
		Return
	EndIf

	Int index = 0
	While index < LPSystem_Script_Perks.GetSize()
		Perk currentPerk = LPSystem_Script_Perks.GetAt(index) as Perk
		Log("Checking perk: " + currentPerk as String, 0)

		If !PlayerRef.HasPerk(currentPerk)
			Log("Adding perk: " + currentPerk as String, 1)
			PlayerRef.AddPerk(currentPerk, False)
		Else
			Log("Player already has perk: " + currentPerk as String, 0)
		EndIf
		index += 1
	EndWhile
EndFunction

Function Log(String msg, Int severity = 1)
	If LoggerScript
		LoggerScript.LogAdv(msg, severity, "UpdateHandler")
	EndIf
EndFunction