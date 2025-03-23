;======================================================================
; Script Name   : LZP:System:VersionManagerScript
; Author        : Ganja Panda
; Mod           : Lazy Panda - A Scav's Auto Loot for Starfield
; Purpose       : Tracks and manages the mod's version state
; Description   : Compares the mod's current version to saved values on load.
;                 If the version has changed, it reinitializes player systems,
;                 logs the version change, and stores the updated version.
; Dependencies  : LazyPanda.esm, LoggerScript, player alias reference
; Usage         : Attach to a quest alias to monitor version updates
;======================================================================

ScriptName LZP:System:VersionManagerScript Extends ReferenceAlias hidden

;======================================================================
; PROPERTIES
;======================================================================

Float Property CurrentMajor = 2.0 Auto Const
Float Property CurrentMinor = 1.0 Auto Const
Float Property CurrentPatch = 0.0 Auto Const

GlobalVariable Property LPVersion_Major Auto Const Mandatory
GlobalVariable Property LPVersion_Minor Auto Const Mandatory
GlobalVariable Property LPVersion_Patch Auto Const Mandatory

LZP:Debug:LoggerScript Property LoggerScript Auto Const Mandatory

ReferenceAlias Property PlayerAlias Auto Const Mandatory

;======================================================================
; EVENT HANDLERS
;======================================================================

Event OnInit()
	CheckModVersion()
EndEvent

Event OnPlayerLoadGame()
	CheckModVersion()
EndEvent

;======================================================================
; FUNCTIONS
;======================================================================

Function CheckModVersion()
	Float savedMajor = LPVersion_Major.GetValue()
	Float savedMinor = LPVersion_Minor.GetValue()
	Float savedPatch = LPVersion_Patch.GetValue()

	If LoggerScript
		LoggerScript.LogAdv("Save version: " + savedMajor + "." + savedMinor + "." + savedPatch, 1, "VersionManager")
	EndIf

	If savedMajor < CurrentMajor || savedMinor < CurrentMinor || savedPatch < CurrentPatch
		If LoggerScript
			LoggerScript.LogAdv("Updating to version: " + CurrentMajor + "." + CurrentMinor + "." + CurrentPatch, 1, "VersionManager")
		EndIf

		PlayerAlias.Clear()
		Utility.Wait(0.1)
		PlayerAlias.ForceRefTo(Game.GetPlayer())

		If PlayerAlias.GetReference() != Game.GetPlayer()
			If LoggerScript
				LoggerScript.LogAdv("WARNING: Failed to rebind PlayerAlias after version update!", 2, "VersionManager")
			EndIf
		EndIf

		LPVersion_Major.SetValue(CurrentMajor)
		LPVersion_Minor.SetValue(CurrentMinor)
		LPVersion_Patch.SetValue(CurrentPatch)

	ElseIf LoggerScript
		LoggerScript.LogAdv("No version change detected. Skipping update.", 0, "VersionManager")
	EndIf
EndFunction

;======================================================================
; PUBLIC ACCESSORS
;======================================================================

Float Function GetMajor()
	return LPVersion_Major.GetValue()
EndFunction

Float Function GetMinor()
	return LPVersion_Minor.GetValue()
EndFunction

Float Function GetPatch()
	return LPVersion_Patch.GetValue()
EndFunction