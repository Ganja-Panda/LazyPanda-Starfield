;======================================================================
; Script Name   : LZP:Potion:AidLootToggleScript
; Author        : Ganja Panda
; Mod           : Lazy Panda - A Scav's Auto Loot for Starfield
; Purpose       : Toggles the core looting system on or off via consumable
; Description   : This ActiveMagicEffect toggles looting using a global variable.
;                 It displays messages to the player and restores the toggle potion
;                 upon use. Logging is available for tracking toggle events.
; Dependencies  : LazyPanda.esm, LoggerScript, Message forms, Potion
; Usage         : Used in an aid item that triggers this effect
;======================================================================

ScriptName LZP:Potion:AidLootToggleScript Extends ActiveMagicEffect hidden

;======================================================================
; PROPERTIES
;======================================================================

;-- Toggle Control
; Global that tracks the current looting enabled state
Group ToggleControl
    GlobalVariable Property LPSystemUtil_ToggleLooting Auto
EndGroup

;-- Message Feedback
; Messages displayed to the player when looting is toggled
Group MessageFeedback
    Message Property LPLootingEnabledMsg Auto
    Message Property LPLootingDisabledMsg Auto
EndGroup

;-- Potion Reference
; The aid item that triggers this script and is returned to the player
Group PotionReference
    Potion Property LP_Aid_ToggleLooting Auto
EndGroup

;-- Logger Property --
Group Logger
    LZP:Debug:LoggerScript Property Logger Auto Const
EndGroup

;======================================================================
; EVENTS
;======================================================================

;-- OnEffectStart Event Handler --
; @param akTarget: The reference the effect is applied to (should be the player)
; @param akCaster: The actor who cast the effect
; @param akBaseEffect: The originating MagicEffect
; @param afMagnitude: Effect magnitude
; @param afDuration: Effect duration
; Main logic for toggling looting, showing messages, and restoring the item
Event OnEffectStart(ObjectReference akTarget, Actor akCaster, MagicEffect akBaseEffect, Float afMagnitude, Float afDuration)
    ObjectReference playerRef = Game.GetPlayer()
    
    ; Ensure the effect is applied to the player.
    If akTarget != playerRef
        Return
    EndIf
    
    ; Check if the required global variables and messages are set.
    If LPSystemUtil_ToggleLooting == None
        If Logger && Logger.IsEnabled()
            Logger.Log("LZP:Potion:AidLootToggleScript: Error: LPSystemUtil_ToggleLooting not set")
        EndIf
        Return
    EndIf
    If LPLootingEnabledMsg == None || LPLootingDisabledMsg == None
        If Logger && Logger.IsEnabled()
            Logger.Log("LZP:Potion:AidLootToggleScript: Error: Message properties not set")
        EndIf
        Return
    EndIf
    If LP_Aid_ToggleLooting == None
        If Logger && Logger.IsEnabled()
            Logger.Log("LZP:Potion:AidLootToggleScript: Error: LP_Aid_ToggleLooting not set")
        EndIf
        Return
    EndIf
    
    ; Get the current toggle value.
    Int toggleValue = LPSystemUtil_ToggleLooting.GetValueInt()
    
    ; Toggle the looting system and display the appropriate message.
    If toggleValue == 1
        LPLootingDisabledMsg.Show(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
        LPSystemUtil_ToggleLooting.SetValue(0 as Float)
        If Logger && Logger.IsEnabled()
            Logger.Log("LZP:Potion:AidLootToggleScript: Looting disabled")
        EndIf
    Else
        LPLootingEnabledMsg.Show(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
        LPSystemUtil_ToggleLooting.SetValue(1 as Float)
        If Logger && Logger.IsEnabled()
            Logger.Log("LZP:Potion:AidLootToggleScript: Looting enabled")
        EndIf
    EndIf
    
    ; Add the toggle potion back to the player's inventory.
    akTarget.AddItem(LP_Aid_ToggleLooting as Form, 1, True)
EndEvent
