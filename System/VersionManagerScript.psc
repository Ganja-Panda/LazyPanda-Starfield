;======================================================================
; Script Name   : LZP:System:VersionManagerScript
; Author        : Ganja Panda
; Mod           : Lazy Panda - A Scav's Auto Loot for Starfield
; Purpose       : Tracks and manages the mod's version state
; Description   : Compares the mod's current version to saved values on load.
;                 If the version has changed, it reinitializes player systems
;                 and stores the updated version into GlobalVariables.
; Dependencies  : LazyPanda.esm, LoggerScript, player alias reference
; Usage         : Attach to a quest alias to monitor version updates
;======================================================================

ScriptName LZP:System:VersionManagerScript Extends ReferenceAlias hidden

;======================================================================
; PROPERTIES
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
; Triggered when the version quest initializes
; Calls version check to determine if updates are needed
Event OnInit()
    CheckModVersion()
EndEvent

;-- OnPlayerLoadGame Event Handler --
; Triggered after a save is loaded
; Ensures version check runs after load
Event OnPlayerLoadGame()
    CheckModVersion()
EndEvent

;======================================================================
; FUNCTIONS
;======================================================================

;-- CheckModVersion Function --
; Compares saved GlobalVariables to hardcoded version
; If mismatched, updates version and resets PlayerAlias
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

;-- GetMajor Function --
; @return: The major version number stored in GlobalVariable
Float Function GetMajor()
    return LPVersion_Major.GetValue()
EndFunction

;-- GetMinor Function --
; @return: The minor version number stored in GlobalVariable
Float Function GetMinor()
    return LPVersion_Minor.GetValue()
EndFunction

;-- GetPatch Function --
; @return: The patch version number stored in GlobalVariable
Float Function GetPatch()
    return LPVersion_Patch.GetValue()
EndFunction