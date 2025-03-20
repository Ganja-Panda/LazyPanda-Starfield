;======================================================================
; Script: LZP:Potion:AidLootToggleScript
; Description: This ActiveMagicEffect script toggles the looting system on or off.
; It uses global variables to manage the state and provides feedback to the player
; through messages. Debug logging is integrated to assist with troubleshooting.
;======================================================================

ScriptName LZP:Potion:AidLootToggleScript Extends ActiveMagicEffect hidden

;======================================================================
; PROPERTY GROUPS
;======================================================================

;-- Global Variables --
; Global variables that control the looting system and debug logging.
GlobalVariable Property LPSystemUtil_ToggleLooting Auto
GlobalVariable Property LPSystemUtil_Debug Auto

;-- Messages --
; Messages displayed to the player when toggling the looting system.
Message Property LPLootingEnabledMsg Auto
Message Property LPLootingDisabledMsg Auto

;-- Potion --
; Potion used to toggle the looting system.
Potion Property LP_Aid_ToggleLooting Auto

;======================================================================
; EVENT HANDLERS
;======================================================================

;-- OnEffectStart Event Handler --
; Called when the magic effect starts. Toggles the looting system and provides feedback to the player.
Event OnEffectStart(ObjectReference akTarget, Actor akCaster, MagicEffect akBaseEffect, Float afMagnitude, Float afDuration)
    ObjectReference playerRef = Game.GetPlayer()
    
    ; Ensure the effect is applied to the player.
    If akTarget != playerRef
        Return
    EndIf
    
    ; Check if the required global variables and messages are set.
    If LPSystemUtil_ToggleLooting == None
        LZP:SystemScript.Log("Error: LPSystemUtil_ToggleLooting not set", 1)
        Return
    EndIf
    If LPLootingEnabledMsg == None || LPLootingDisabledMsg == None
        LZP:SystemScript.Log("Error: Message properties not set", 1)
        Return
    EndIf
    If LP_Aid_ToggleLooting == None
        LZP:SystemScript.Log("Error: LP_Aid_ToggleLooting not set", 1)
        Return
    EndIf
    
    ; Get the current toggle value.
    Int toggleValue = LPSystemUtil_ToggleLooting.GetValueInt()
    
    ; Toggle the looting system and display the appropriate message.
    If toggleValue == 1
        LPLootingDisabledMsg.Show(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
        LPSystemUtil_ToggleLooting.SetValue(0 as Float)
        LZP:SystemScript.Log("Looting disabled", 3)
    Else
        LPLootingEnabledMsg.Show(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
        LPSystemUtil_ToggleLooting.SetValue(1 as Float)
        LZP:SystemScript.Log("Looting enabled", 3)
    EndIf
    
    ; Add the toggle potion back to the player's inventory.
    akTarget.AddItem(LP_Aid_ToggleLooting as Form, 1, True)
EndEvent