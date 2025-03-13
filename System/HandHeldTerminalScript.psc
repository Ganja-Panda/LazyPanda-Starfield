;======================================================================
; Script: LZP:System:HandHeldTerminalScript
; Description: This script manages the handheld terminal functionality.
; It provides the player with a toggle looting potion and handles the
; activation of the terminal dummy when the control weapon is equipped.
; Debug logging is integrated to assist with troubleshooting.
;======================================================================

ScriptName LZP:System:HandHeldTerminalScript Extends ReferenceAlias

;======================================================================
; PROPERTIES
;======================================================================

;-- Properties --
; References and items required for the terminal functionality.
Actor Property PlayerRef Auto Const Mandatory
ObjectReference Property LP_TerminalDummyRef Auto Const Mandatory
Weapon Property LP_TerminalControlWeapon Auto Const Mandatory
Potion Property LP_Aid_ToggleLooting Auto Const Mandatory
GlobalVariable Property LPSystemUtil_Debug Auto Const Mandatory

;======================================================================
; UTILITY FUNCTIONS
;======================================================================

;-- Log Function --
; Logs a message if the global debug setting is enabled.
Function Log(String logMsg)
    If LPSystemUtil_Debug.GetValue() as Bool
        Debug.Trace(logMsg, 0)
    EndIf
EndFunction

;-- ValidateProperties Function --
; Validates that all required properties are set.
Function ValidateProperties()
    If PlayerRef == None
        Log("Error: PlayerRef is None")
    EndIf
    If LP_TerminalDummyRef == None
        Log("Error: LP_TerminalDummyRef is None")
    EndIf
    If LP_TerminalControlWeapon == None
        Log("Error: LP_TerminalControlWeapon is None")
    EndIf
    If LP_Aid_ToggleLooting == None
        Log("Error: LP_Aid_ToggleLooting is None")
    EndIf
EndFunction

;======================================================================
; EVENT HANDLERS
;======================================================================

;-- OnAliasInit Event Handler --
; Called when the alias is initialized. Validates properties and gives the toggle looting item to the player.
Event OnAliasInit()
    Log("OnAliasInit triggered")
    ValidateProperties()
EndEvent

;-- OnItemEquipped Event Handler --
; Called when an item is equipped. Activates the terminal dummy if the control weapon is equipped.
Event OnItemEquipped(Form akBaseObject, ObjectReference akReference)
    If (akBaseObject == LP_TerminalControlWeapon) && (Game.IsMenuControlsEnabled() || Game.IsFavoritesControlsEnabled())
        Log("Terminal control weapon equipped; activating terminal dummy")
        LP_TerminalDummyRef.Activate(PlayerRef, False)
        PlayerRef.UnequipItem(LP_TerminalControlWeapon, False, True)
    EndIf
EndEvent