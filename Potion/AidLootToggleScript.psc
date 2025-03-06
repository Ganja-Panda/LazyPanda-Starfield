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
GlobalVariable Property LPSystem_Debug Auto

;-- Messages --
; Messages displayed to the player when toggling the looting system.
Message Property LPLootingEnabledMsg Auto
Message Property LPLootingDisabledMsg Auto

;-- Potion --
; Potion used to toggle the looting system.
Potion Property LP_Aid_ToggleLooting Auto

;======================================================================
; DEBUG LOGGING HELPER FUNCTION
;======================================================================

; Logs a message if the global debug setting is enabled.
Function Log(String logMsg)
    If LPSystem_Debug.GetValue() as Bool
        Debug.Trace(logMsg, 0)
    EndIf
EndFunction

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
        Log("Error: LPSystemUtil_ToggleLooting not set")
        Return
    EndIf
    If LPLootingEnabledMsg == None || LPLootingDisabledMsg == None
        Log("Error: Message properties not set")
        Return
    EndIf
    If LP_Aid_ToggleLooting == None
        Log("Error: LP_Aid_ToggleLooting not set")
        Return
    EndIf
    
    ; Get the current toggle value.
    Int toggleValue = LPSystemUtil_ToggleLooting.GetValueInt()
    
    ; Toggle the looting system and display the appropriate message.
    If toggleValue == 1
        LPLootingDisabledMsg.Show(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
        LPSystemUtil_ToggleLooting.SetValue(0 as Float)
        Log("Looting disabled")
    Else
        LPLootingEnabledMsg.Show(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
        LPSystemUtil_ToggleLooting.SetValue(1 as Float)
        Log("Looting enabled")
    EndIf
    
    ; Add the toggle potion back to the player's inventory.
    akTarget.AddItem(LP_Aid_ToggleLooting as Form, 1, True)
EndEvent