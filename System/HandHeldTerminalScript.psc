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
    Weapon Property LZP_Weap_Terminal Auto Const mandatory         ; Weapon used to trigger the terminal
    ObjectReference Property LZP_Terminal_DummyRef Auto Const mandatory     ; In-world terminal reference to activate
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
        Logger.LogAdv("HandHeldTerminalScript: OnAliasInit triggered.", 1, "HandHeldTerminalScript")
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
    if akBaseObject != LZP_Weap_Terminal
        return
    endif

    Actor player = Game.GetPlayer()

    if Logger && Logger.IsEnabled()
        Logger.LogAdv("HandHeldTerminalScript: Hand Terminal equipped. Activating terminal UI.", 1, "HandHeldTerminalScript")
    endif

    LZP_Terminal_DummyRef.Activate(player)
    player.UnequipItem(LZP_Weap_Terminal, false, true)
EndEvent

;======================================================================
; FUNCTION: ValidateProperties
; Verifies essential object references are set
;======================================================================
Function ValidateProperties()
    if LZP_Terminal_DummyRef == None
        if Logger && Logger.IsEnabled()
            Logger.LogAdv("HandHeldTerminalScript: Missing LP_TerminalDummyRef reference.", 3, "HandHeldTerminalScript")
        endif
    endif

    if LZP_Weap_Terminal == None
        if Logger && Logger.IsEnabled()
            Logger.LogAdv("HandHeldTerminalScript: Missing LP_TerminalControlWeapon reference.", 3, "HandHeldTerminalScript")
        endif
    endif
EndFunction
