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
GlobalVariable Property LPSystemUtil_ToggleLooting Auto

;-- Messages --
Message Property LPLootingEnabledMsg Auto
Message Property LPLootingDisabledMsg Auto

;-- Potion --
Potion Property LP_Aid_ToggleLooting Auto

;-- Logger Property --
Group Logger
    LZP:Debug:LoggerScript Property Logger Auto Const
EndGroup

;======================================================================
; EVENT HANDLERS
;======================================================================

;-- OnEffectStart Event Handler --
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
