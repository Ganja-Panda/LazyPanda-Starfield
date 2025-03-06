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

;======================================================================
; PROPERTIES
;======================================================================

;-- Properties --
; References and items required for the update handler functionality.
Actor Property PlayerRef Auto Const Mandatory
FormList Property LPSystem_Script_Perks Auto Const Mandatory
GlobalVariable Property LPVersion_Major Auto Const Mandatory
GlobalVariable Property LPVersion_Minor Auto Const Mandatory
GlobalVariable Property LPSystem_Debug Auto Const Mandatory
ScriptObject Property SystemScript Auto ; Reference to the SystemScript

;======================================================================
; UTILITY FUNCTIONS
;======================================================================

;-- Log Function --
; Logs a message if the global debug setting is enabled.
Function Log(String logMsg)
    If LPSystem_Debug.GetValue() as Bool
        Debug.Trace(logMsg, 0)
    EndIf
EndFunction

;======================================================================
; EVENT HANDLERS
;======================================================================

;-- OnAliasInit Event Handler --
; Called when the alias is initialized. Checks for updates.
Event OnAliasInit()
    Log("OnAliasInit triggered")
    CheckForUpdates()
EndEvent

;-- OnPlayerLoadGame Event Handler --
; Called when the player loads a game. Checks for updates.
Event OnPlayerLoadGame()
    Log("OnPlayerLoadGame triggered")
    CheckForUpdates()
EndEvent

;======================================================================
; UPDATE SYSTEM FUNCTIONS
;======================================================================

;-- CheckForUpdates Function --
; Checks if updates are needed and applies them if necessary.
Function CheckForUpdates()
    Log("CheckForUpdates called")
    
    ; Compute the current version as an integer (e.g., major * 1000 + minor).
    Int iCurrentVersion = (LPVersion_Major.GetValueInt() * 1000) + LPVersion_Minor.GetValueInt()
    Log("Current version number: " + iCurrentVersion as String)
    
    ; Retrieve the previously applied version; if not set, it defaults to 0.
    Int iAppliedVersion = sUpdatesAppliedVersion as Int
    Log("Previously applied version: " + iAppliedVersion as String)
    
    ; Check if updates are needed.
    If iAppliedVersion < iCurrentVersion
        Log("Updates needed. Applying updates from version " + iAppliedVersion as String + " to " + iCurrentVersion as String)
        
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
        Log("Updates applied. New applied version: " + sUpdatesAppliedVersion)
    Else
        Log("No updates needed")
    EndIf

    ; Initialize SystemScript if debugging is enabled
    If LPSystem_Debug.GetValue() as Bool
        Log("Debugging enabled, initializing SystemScript")
        SystemScript.OnInit()
    EndIf
EndFunction

;-- UpdateStep_1001 Function --
; Applies updates for version 1001.
Function UpdateStep_1001()
    Log("Executing UpdateStep_1001: Adding missing perks")
    AddPerks()
EndFunction

;-- AddPerks Function --
; Adds missing perks to the player.
Function AddPerks()
    Log("AddPerks called")
    Int index = 0
    While index < LPSystem_Script_Perks.GetSize()
        Perk currentPerk = LPSystem_Script_Perks.GetAt(index) as Perk
        Log("Checking perk: " + currentPerk as String)
        If !Game.GetPlayer().HasPerk(currentPerk)
            Log("Adding perk: " + currentPerk as String)
            Game.GetPlayer().AddPerk(currentPerk, False)
        Else
            Log("Player already has perk: " + currentPerk as String)
        EndIf
        index += 1
    EndWhile
EndFunction