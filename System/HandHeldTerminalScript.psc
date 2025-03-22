;======================================================================
; Script Name   : LZP:System:HandHeldTerminalScript
; Author        : Ganja Panda
; Mod           : Lazy Panda - A Scav's Auto Loot for Starfield
; Purpose       : Manages handheld terminal activation via weapon equip
; Description   : When the player equips a specific control weapon, this
;                 script triggers the dummy terminal reference to simulate
;                 a terminal interface. Also gives the player a toggle
;                 potion on alias init for enabling looting.
; Dependencies  : LazyPanda.esm, LoggerScript, LP_TerminalDummyRef, LP_Aid_ToggleLooting
; Usage         : Attach to a ReferenceAlias bound to the player or other actor
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

;-- Logger Property --
Group Logger
    LZP:Debug:LoggerScript Property Logger Auto Const
EndGroup

;======================================================================
; UTILITY FUNCTIONS
;======================================================================

;-- ValidateProperties Function --
; Validates that all required properties are set.
Function ValidateProperties()
    If PlayerRef == None
        If Logger && Logger.IsEnabled()
            Logger.Log("LZP:System:HandHeldTerminalScript: Error: PlayerRef is None")
        EndIf
    EndIf
    If LP_TerminalDummyRef == None
        If Logger && Logger.IsEnabled()
            Logger.Log("LZP:System:HandHeldTerminalScript: Error: LP_TerminalDummyRef is None")
        EndIf
    EndIf
    If LP_TerminalControlWeapon == None
        If Logger && Logger.IsEnabled()
            Logger.Log("LZP:System:HandHeldTerminalScript: Error: LP_TerminalControlWeapon is None")
        EndIf
    EndIf
    If LP_Aid_ToggleLooting == None
        If Logger && Logger.IsEnabled()
            Logger.Log("LZP:System:HandHeldTerminalScript: Error: LP_Aid_ToggleLooting is None")
        EndIf
    EndIf
EndFunction

;======================================================================
; EVENT HANDLERS
;======================================================================

;-- OnAliasInit Event Handler --
; Called when the alias is initialized. Validates properties and gives the toggle looting item to the player.
Event OnAliasInit()
    If Logger && Logger.IsEnabled()
        Logger.Log("LZP:System:HandHeldTerminalScript: OnAliasInit triggered")
    EndIf
    ValidateProperties()
EndEvent

;-- OnItemEquipped Event Handler --
; Called when an item is equipped. Activates the terminal dummy if the control weapon is equipped.
Event OnItemEquipped(Form akBaseObject, ObjectReference akReference)
    If (akBaseObject == LP_TerminalControlWeapon) && (Game.IsMenuControlsEnabled() || Game.IsFavoritesControlsEnabled())
        If Logger && Logger.IsEnabled()
            Logger.Log("LZP:System:HandHeldTerminalScript: Terminal control weapon equipped; activating terminal dummy")
        EndIf
        LP_TerminalDummyRef.Activate(PlayerRef, False)
        PlayerRef.UnequipItem(LP_TerminalControlWeapon, False, True)
    EndIf
EndEvent
