;======================================================================
; Script Name   : LZP:System:HandHeldTerminalScript
; Author        : Ganja Panda
; Mod           : Lazy Panda - A Scav's Auto Loot for Starfield
; Purpose       : Triggers a dummy terminal when player equips the Hand Terminal
; Description   : Listens for the Terminal Control Weapon to be equipped,
;                 then automatically activates a target terminal reference
;                 and unequips the weapon to simulate a UI interaction.
; Dependencies  : LP_TerminalControlWeapon (Weapon), LP_TerminalDummyRef (ObjectReference)
;======================================================================

ScriptName LZP:System:HandHeldTerminalScript Extends ReferenceAlias

;======================================================================
; PROPERTIES
;======================================================================

;-- TerminalActivation
; Core components for detecting and simulating terminal use
Group TerminalActivation
    Weapon Property LP_TerminalControlWeapon Auto Const mandatory         ; Weapon used to trigger the terminal
    ObjectReference Property LP_TerminalDummyRef Auto Const mandatory     ; In-world terminal reference to activate
EndGroup

;-- Logger
; Logging system for diagnostics and debug trace
Group Logger
    LZP:Debug:LoggerScript Property Logger Auto Const  ; LoggerScript reference for output and diagnostics
EndGroup

;======================================================================
; EVENT: OnAliasInit
; Called when the alias is initialized in-game
;======================================================================
Event OnAliasInit()
    if Logger && Logger.IsEnabled()
        Logger.LogInfo("HandHeldTerminalScript: OnAliasInit triggered.")
    endif

    ValidateProperties()
EndEvent

;======================================================================
; EVENT: OnItemEquipped
; Called when the player equips an item in this alias
;
; @param akBaseObject - The item that was equipped
; @param akReference  - The actor or object equipping it
;======================================================================
Event OnItemEquipped(Form akBaseObject, ObjectReference akReference)
    if akBaseObject != LP_TerminalControlWeapon
        return
    endif

    Actor player = Game.GetPlayer()

    if Logger && Logger.IsEnabled()
        Logger.LogInfo("Hand Terminal equipped. Activating terminal UI.")
    endif

    LP_TerminalDummyRef.Activate(player)
    player.UnequipItem(LP_TerminalControlWeapon, false, true)
EndEvent

;======================================================================
; FUNCTION: ValidateProperties
; Verifies essential object references are set
;======================================================================
Function ValidateProperties()
    if LP_TerminalDummyRef == None
        if Logger && Logger.IsEnabled()
            Logger.LogError("Missing LP_TerminalDummyRef reference.")
        endif
    endif

    if LP_TerminalControlWeapon == None
        if Logger && Logger.IsEnabled()
            Logger.LogError("Missing LP_TerminalControlWeapon reference.")
        endif
    endif
EndFunction
