;======================================================================
; Script: LZP:System:VersionManagerScript
; Description: This script manages the version control for the Lazy Panda mod.
; It checks the current version against the saved version and updates if necessary.
; Debug logging is integrated to assist with troubleshooting.
;======================================================================

ScriptName LZP:System:VersionManagerScript Extends ReferenceAlias hidden

;======================================================================
; PROPERTY DEFINITIONS
;======================================================================

;-- Version Properties --
; Current version of the mod.
Float Property CurrentMajor = 2.0 Auto Const
Float Property CurrentMinor = 1.0 Auto Const
Float Property CurrentPatch = 0.0 Auto Const

;-- Global Variables --
; Global variables to store the saved version.
GlobalVariable Property LPVersion_Major Auto Const Mandatory
GlobalVariable Property LPVersion_Minor Auto Const Mandatory
GlobalVariable Property LPVersion_Patch Auto Const Mandatory

;-- Logging System --
; Reference to the LoggerScript for debug output.
LZP:Debug:LoggerScript Property LoggerScript Auto Const Mandatory


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

    ; Optional debug output: show current saved version
    If LoggerScript
        LoggerScript.Log("[VersionManager] Detected: Save Version " + savedMajor + "." + savedMinor + "." + savedPatch, 3)
    EndIf

    ; Check if any component of the version has changed
    If savedMajor < CurrentMajor || savedMinor < CurrentMinor || savedPatch < CurrentPatch
        If LoggerScript
            LoggerScript.Log("[VersionManager] Updating to " + CurrentMajor + "." + CurrentMinor + "." + CurrentPatch, 3)
        EndIf

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