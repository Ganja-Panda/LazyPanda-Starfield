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

GlobalVariable Property LZP_Version_Major Auto Const Mandatory ; Saved major version value
GlobalVariable Property LZP_Version_Minor Auto Const Mandatory ; Saved minor version value
GlobalVariable Property LZP_Version_Patch Auto Const Mandatory ; Saved patch version value
GlobalVariable Property LZP_Version_Build Auto Const Mandatory ; Saved build version value
GlobalVariable Property LZP_Version_ForceUpdate Auto Const Mandatory ; Set to 1.0 to force version update
GlobalVariable Property LZP_Version_TimeStamp Auto Const Mandatory ; Timestamp recorded at last version update

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
	Float savedMajor = LZP_Version_Major.GetValue()
	Float savedMinor = LZP_Version_Minor.GetValue()
	Float savedPatch = LZP_Version_Patch.GetValue()
	Float savedBuild = LZP_Version_Build.GetValue()
	Bool bForceVersionUpdate = (LZP_Version_ForceUpdate.GetValue() == 1.0)

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

		LZP_Version_Major.SetValue(CurrentMajor)
		LZP_Version_Minor.SetValue(CurrentMinor)
		LZP_Version_Patch.SetValue(CurrentPatch)
		LZP_Version_Build.SetValue(CurrentBuildVersion)
		LZP_Version_TimeStamp.SetValue(Utility.GetCurrentRealTime())
		LZP_Version_ForceUpdate.SetValue(0.0)

		If LoggerScript
			LoggerScript.LogAdv("Timestamp set to: " + LZP_Version_TimeStamp.GetValue() as String, 0, "VersionManager")
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
	return LZP_Version_Major.GetValue()
EndFunction

;----------------------------------------------------------------------
; Function : GetMinor
; @return  : Current saved minor version
;----------------------------------------------------------------------
Float Function GetMinor()
	return LZP_Version_Minor.GetValue()
EndFunction

;----------------------------------------------------------------------
; Function : GetPatch
; @return  : Current saved patch version
;----------------------------------------------------------------------
Float Function GetPatch()
	return LZP_Version_Patch.GetValue()
EndFunction

;----------------------------------------------------------------------
; Function : GetBuild
; @return  : Current saved build version
;----------------------------------------------------------------------
Float Function GetBuild()
	return LZP_Version_Build.GetValue()
EndFunction
