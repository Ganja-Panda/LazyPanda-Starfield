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
;-- ValidateProperties Function --
; Validates that all required properties are set.
Function ValidateProperties()
    If PlayerRef == None
        LZP:SystemScript.Log("Error: PlayerRef is None", 1)
    EndIf
    If LP_TerminalDummyRef == None
        LZP:SystemScript.Log("Error: LP_TerminalDummyRef is None", 1)
    EndIf
    If LP_TerminalControlWeapon == None
        LZP:SystemScript.Log("Error: LP_TerminalControlWeapon is None", 1)
    EndIf
    If LP_Aid_ToggleLooting == None
        LZP:SystemScript.Log("Error: LP_Aid_ToggleLooting is None", 1)
    EndIf
EndFunction

;======================================================================
; EVENT HANDLERS
;======================================================================

;-- OnAliasInit Event Handler --
; Called when the alias is initialized. Validates properties and gives the toggle looting item to the player.
Event OnAliasInit()
    LZP:SystemScript.Log("OnAliasInit triggered", 3)
    ValidateProperties()
EndEvent

;-- OnItemEquipped Event Handler --
; Called when an item is equipped. Activates the terminal dummy if the control weapon is equipped.
Event OnItemEquipped(Form akBaseObject, ObjectReference akReference)
    If (akBaseObject == LP_TerminalControlWeapon) && (Game.IsMenuControlsEnabled() || Game.IsFavoritesControlsEnabled())
        LZP:SystemScript.Log("Terminal control weapon equipped; activating terminal dummy", 3)
        LP_TerminalDummyRef.Activate(PlayerRef, False)
        PlayerRef.UnequipItem(LP_TerminalControlWeapon, False, True)
    EndIf
EndEvent