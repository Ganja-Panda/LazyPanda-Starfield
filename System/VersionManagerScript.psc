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

Float Property CurrentMajor = 2.0 Auto Const ; Current major version
Float Property CurrentMinor = 1.0 Auto Const ; Current minor version
Float Property CurrentPatch = 0.0 Auto Const ; Current patch version
Float Property CurrentBuildVersion = 20100.0 Auto Const ; Composite build version (e.g. 2.1.0 = 20100)

GlobalVariable Property LPVersion_Major Auto Const Mandatory ; Saved major version value
GlobalVariable Property LPVersion_Minor Auto Const Mandatory ; Saved minor version value
GlobalVariable Property LPVersion_Patch Auto Const Mandatory ; Saved patch version value
GlobalVariable Property LPVersion_Build Auto Const Mandatory ; Saved build version value
GlobalVariable Property LPVersion_ForceUpdate Auto Const Mandatory ; Set to 1.0 to force version update
GlobalVariable Property GLOB_LZP_Version_Timestamp Auto Const Mandatory ; Timestamp recorded at last version update

LZP:Debug:LoggerScript Property LoggerScript Auto Const Mandatory ; Logger script reference
ReferenceAlias Property PlayerAlias Auto Const Mandatory ; Player alias reference

;======================================================================
; EVENT HANDLERS
;======================================================================

;----------------------------------------------------------------------
; Event : OnInit
; Purpose: Triggered when the quest initializes
;----------------------------------------------------------------------
Event OnInit()
	CheckModVersion()
EndEvent

;----------------------------------------------------------------------
; Event : OnPlayerLoadGame
; Purpose: Triggered after a game load
;----------------------------------------------------------------------
Event OnPlayerLoadGame()
	CheckModVersion()
EndEvent

;======================================================================
; FUNCTIONS
;======================================================================

;----------------------------------------------------------------------
; Function : CheckModVersion
; Purpose  : Compares saved version against current. If mismatch, resets systems.
;----------------------------------------------------------------------
Function CheckModVersion()
	Float savedMajor = LPVersion_Major.GetValue()
	Float savedMinor = LPVersion_Minor.GetValue()
	Float savedPatch = LPVersion_Patch.GetValue()
	Float savedBuild = LPVersion_Build.GetValue()
	Bool bForceVersionUpdate = (LPVersion_ForceUpdate.GetValue() == 1.0)

	If LoggerScript
		LoggerScript.LogAdv("Save version: " + savedMajor + "." + savedMinor + "." + savedPatch + " (" + savedBuild + ")", 1, "VersionManager")
	EndIf

	Bool versionChanged = (savedMajor < CurrentMajor || (savedMajor == CurrentMajor && savedMinor < CurrentMinor) || (savedMajor == CurrentMajor && savedMinor == CurrentMinor && savedPatch < CurrentPatch) || savedBuild < CurrentBuildVersion || bForceVersionUpdate)

	If versionChanged
		If LoggerScript
			LoggerScript.LogAdv("Updating to version: " + CurrentMajor + "." + CurrentMinor + "." + CurrentPatch + " (" + CurrentBuildVersion + ")", 1, "VersionManager")
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
		LPVersion_Build.SetValue(CurrentBuildVersion)
		GLOB_LZP_Version_Timestamp.SetValue(Utility.GetCurrentRealTime())
		LPVersion_ForceUpdate.SetValue(0.0)

		If LoggerScript
			LoggerScript.LogAdv("Timestamp set to: " + GLOB_LZP_Version_Timestamp.GetValue() as String, 0, "VersionManager")
		EndIf
	ElseIf LoggerScript
		LoggerScript.LogAdv("No version change detected. Skipping update.", 0, "VersionManager")
	EndIf
EndFunction

;======================================================================
; PUBLIC ACCESSORS
;======================================================================

;----------------------------------------------------------------------
; Function : GetMajor
; @return  : Current saved major version
;----------------------------------------------------------------------
Float Function GetMajor()
	return LPVersion_Major.GetValue()
EndFunction

;----------------------------------------------------------------------
; Function : GetMinor
; @return  : Current saved minor version
;----------------------------------------------------------------------
Float Function GetMinor()
	return LPVersion_Minor.GetValue()
EndFunction

;----------------------------------------------------------------------
; Function : GetPatch
; @return  : Current saved patch version
;----------------------------------------------------------------------
Float Function GetPatch()
	return LPVersion_Patch.GetValue()
EndFunction

;----------------------------------------------------------------------
; Function : GetBuild
; @return  : Current saved build version
;----------------------------------------------------------------------
Float Function GetBuild()
	return LPVersion_Build.GetValue()
EndFunction
