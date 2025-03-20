;======================================================================
; Script: LZP:System:UpdateHandlerPlayerAliasScript
; Description: This script handles updates for the player alias. It checks
; for version updates and applies necessary changes. Debug logging is
; integrated to assist with troubleshooting.
;======================================================================

ScriptName LZP:System:UpdateHandlerPlayerAliasScript Extends ReferenceAlias hidden

;======================================================================
; VARIABLES
;======================================================================

; Store the applied version as a string representing an integer.
; "0" means no updates have been applied.
String sUpdatesAppliedVersion = "0"

; Timer for periodically checking the debug global.
Float fDebugCheckInterval = 10.0 ; Check every 10 seconds.

;======================================================================
; PROPERTIES
;======================================================================

;-- Properties --
; References and items required for the update handler functionality.
Actor Property PlayerRef Auto Const Mandatory
FormList Property LPSystem_Script_Perks Auto Const Mandatory
GlobalVariable Property LPVersion_Major Auto Const Mandatory
GlobalVariable Property LPVersion_Minor Auto Const Mandatory
GlobalVariable Property LPSystemUtil_Debug Auto Const Mandatory

;======================================================================
; UTILITY FUNCTIONS
;======================================================================

;-- CheckDebugGlobal Function --
; Periodically checks if the debug global is set to 1 and logs a message if it is.
Function CheckDebugGlobal()
    While True  ; Infinite loop, but controlled by Wait() to avoid recursion
        If LPSystemUtil_Debug.GetValue() as Bool
            LZP:SystemScript.Log("Debugging enabled", 3)
        EndIf
        Utility.Wait(fDebugCheckInterval)  ; Wait before running again
    EndWhile
EndFunction

;======================================================================
; EVENT HANDLERS
;======================================================================

;-- OnAliasInit Event Handler --
; Called when the alias is initialized. Checks for updates.
Event OnAliasInit()
    LZP:SystemScript.Log("OnAliasInit triggered", 3)
    CheckForUpdates()
    ; Start the timer to check the debug global.
    CheckDebugGlobal()
EndEvent

;-- OnPlayerLoadGame Event Handler --
; Called when the player loads a game. Checks for updates.
Event OnPlayerLoadGame()
    LZP:SystemScript.Log("OnPlayerLoadGame triggered", 3)
    CheckForUpdates()
    ; Start the timer to check the debug global.
    CheckDebugGlobal()
EndEvent

;======================================================================
; UPDATE SYSTEM FUNCTIONS
;======================================================================

;-- CheckForUpdates Function --
; Checks if updates are needed and applies them if necessary.
Function CheckForUpdates()
    LZP:SystemScript.Log("CheckForUpdates called", 3)
    
    ; Compute the current version as an integer (e.g., major * 1000 + minor).
    Int iCurrentVersion = (LPVersion_Major.GetValueInt() * 1000) + LPVersion_Minor.GetValueInt()
    LZP:SystemScript.Log("Current version number: " + iCurrentVersion as String, 3)
    
    ; Retrieve the previously applied version; if not set, it defaults to 0.
    Int iAppliedVersion = sUpdatesAppliedVersion as Int
    LZP:SystemScript.Log("Previously applied version: " + iAppliedVersion as String, 3)
    
    ; Check if updates are needed.
    If iAppliedVersion < iCurrentVersion
        LZP:SystemScript.Log("Updates needed. Applying updates from version " + iAppliedVersion as String + " to " + iCurrentVersion as String, 3)
        
        ; Dynamic update step(s)
        ; For example, if the applied version is less than 1001, run UpdateStep_1001().
        If iAppliedVersion < 1001
            UpdateStep_1001()
            iAppliedVersion = 1001
        EndIf
        
        ; [Future update steps can be added here, e.g.:]
        ; If iAppliedVersion < 1002
        ;     UpdateStep_1002()
        ;     iAppliedVersion = 1002
        ; EndIf
        
        ; Store the new applied version.
        sUpdatesAppliedVersion = iCurrentVersion as String
        LZP:SystemScript.Log("Updates applied. New applied version: " + sUpdatesAppliedVersion, 3)
    Else
        LZP:SystemScript.Log("No updates needed", 3)
    EndIf
EndFunction

;-- UpdateStep_1001 Function --
; Applies updates for version 1001.
Function UpdateStep_1001()
    LZP:SystemScript.Log("Executing UpdateStep_1001: Adding missing perks", 3)
    AddPerks()
EndFunction

;-- AddPerks Function --
; Adds missing perks to the player.
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
