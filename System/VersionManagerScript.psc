;======================================================================
; Script: LZP:System:VersionManagerScript
; Description: This script manages the version control for the Lazy Panda mod.
; It checks the current version against the saved version and updates if necessary.
; Debug logging is integrated to assist with troubleshooting.
;======================================================================

ScriptName LZP:System:VersionManagerScript Extends Quest

;======================================================================
; PROPERTY DEFINITIONS
;======================================================================

;-- Version Properties --
; Current version of the mod.
Float Property CurrentMajor = 2.0 Auto Const
Float Property CurrentMinor = 0.0 Auto Const
Float Property CurrentPatch = 1.0 Auto Const

;-- Global Variables --
; Global variables to store the saved version.
GlobalVariable Property LPVersion_Major Auto Const Mandatory
GlobalVariable Property LPVersion_Minor Auto Const Mandatory
GlobalVariable Property LPVersion_Patch Auto Const Mandatory

;-- Reference Aliases --
; Alias for the player.
ReferenceAlias Property PlayerAlias Auto Const Mandatory

;======================================================================
; EVENT HANDLERS
;======================================================================

;-- OnInit Event Handler --
; Called when the quest starts or the game loads.
Event OnInit()
    CheckModVersion()
EndEvent

;-- OnPlayerLoadGame Event Handler --
; Called when the player loads a game.
Event OnPlayerLoadGame()
    CheckModVersion()
EndEvent

;======================================================================
; FUNCTIONS
;======================================================================

;-- CheckModVersion Function --
; Checks the current mod version against the saved version and updates if necessary.
Function CheckModVersion()
    Float savedMajor = LPVersion_Major.GetValue()
    Float savedMinor = LPVersion_Minor.GetValue()
    Float savedPatch = LPVersion_Patch.GetValue()

    ; Check if any component of the version has changed
    If savedMajor < CurrentMajor || savedMinor < CurrentMinor || savedPatch < CurrentPatch
        LZP:SystemScript.Log("[VersionManager] Updating to " + CurrentMajor + "." + CurrentMinor + "." + CurrentPatch, 3)

        ; Reset the PlayerAlias to reload its script
        PlayerAlias.Clear()
        Utility.Wait(0.1)
        PlayerAlias.ForceRefTo(Game.GetPlayer())

        ; Store the new version in the save
        LPVersion_Major.SetValue(CurrentMajor)
        LPVersion_Minor.SetValue(CurrentMinor)
        LPVersion_Patch.SetValue(CurrentPatch)
    EndIf
EndFunction

;======================================================================
; PUBLIC ACCESSORS
;======================================================================

; Returns the current major version from the GlobalVariable
Float Function GetMajor()
    return LPVersion_Major.GetValue()
EndFunction

; Returns the current minor version from the GlobalVariable
Float Function GetMinor()
    return LPVersion_Minor.GetValue()
EndFunction

; Returns the current patch version from the GlobalVariable
Float Function GetPatch()
    return LPVersion_Patch.GetValue()
EndFunction

; Returns the version as a formatted string, e.g., "2.0.1"
String Function GetVersionString()
    return GetMajor() + "." + GetMinor() + "." + GetPatch()
EndFunction

;======================================================================
; VERSION COMPARISON UTILITIES
;======================================================================

; Returns True if the current saved version is *less than* the given version
Bool Function IsVersionNewerThan(Float major, Float minor, Float patch)
    Float savedMajor = GetMajor()
    Float savedMinor = GetMinor()
    Float savedPatch = GetPatch()

    If savedMajor < major
        return True
    ElseIf savedMajor == major && savedMinor < minor
        return True
    ElseIf savedMajor == major && savedMinor == minor && savedPatch < patch
        return True
    EndIf

    return False
EndFunction

; Returns True if the saved version exactly matches the provided version
Bool Function IsVersionEqualTo(Float major, Float minor, Float patch)
    return GetMajor() == major && GetMinor() == minor && GetPatch() == patch
EndFunction

; Returns True if the current version (in code) is different from the saved version
Bool Function HasVersionChanged()
    return CurrentMajor != GetMajor() || CurrentMinor != GetMinor() || CurrentPatch != GetPatch()
EndFunction