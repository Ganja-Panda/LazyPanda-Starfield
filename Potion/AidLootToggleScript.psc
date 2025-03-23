;======================================================================
; Script Name   : LZP:Potion:AidLootToggleScript
; Author        : Ganja Panda
; Mod           : Lazy Panda - A Scav's Auto Loot for Starfield
; Purpose       : Toggles the core looting system on or off via consumable
; Description   : ActiveMagicEffect script that toggles the looting state
;                 through a global variable, shows player feedback messages,
;                 logs the event, and restores the aid item.
; Dependencies  : LazyPanda.esm, LoggerScript, ToggleLootingPotion, Messages
; Usage         : Attach this to an Aid item’s MagicEffect
;======================================================================

ScriptName LZP:Potion:AidLootToggleScript Extends ActiveMagicEffect Hidden

;======================================================================
; PROPERTIES
;======================================================================

;-- ToggleControl
; Controls global state of looting system (1 = ON, 0 = OFF)
Group ToggleControl
    GlobalVariable Property LPSystemUtil_ToggleLooting Auto
EndGroup

;-- MessageFeedback
; UI messages shown to the player when looting is toggled
Group MessageFeedback
    Message Property LPLootingEnabledMsg Auto
    Message Property LPLootingDisabledMsg Auto
EndGroup

;-- PotionReference
; The toggle potion used by the player (added back after use)
Group PotionReference
    Potion Property LP_Aid_ToggleLooting Auto
EndGroup

;-- Logger
; Logging interface for debug messages
Group Logger
    LZP:Debug:LoggerScript Property Logger Auto Const
EndGroup

;======================================================================
; EVENT: OnEffectStart
; Called when the player consumes the toggle potion
;
; @param akTarget     - Reference receiving the effect (should be the player)
; @param akCaster     - Actor who cast the effect
; @param akBaseEffect - Source magic effect
; @param afMagnitude  - Magnitude of effect
; @param afDuration   - Duration of effect
;======================================================================
Event OnEffectStart(ObjectReference akTarget, Actor akCaster, MagicEffect akBaseEffect, Float afMagnitude, Float afDuration)
    if akTarget != Game.GetPlayer()
        return
    endif

    if LPSystemUtil_ToggleLooting == None
        if Logger && Logger.IsEnabled()
            Logger.LogError("LPSystemUtil_ToggleLooting is not set.")
        endif
        return
    endif

    if LPLootingEnabledMsg == None || LPLootingDisabledMsg == None
        if Logger && Logger.IsEnabled()
            Logger.LogError("Feedback messages not assigned.")
        endif
        return
    endif

    if LP_Aid_ToggleLooting == None
        if Logger && Logger.IsEnabled()
            Logger.LogError("LP_Aid_ToggleLooting property is not set.")
        endif
        return
    endif

    int toggleValue = LPSystemUtil_ToggleLooting.GetValueInt()

    if toggleValue == 1
        LPSystemUtil_ToggleLooting.SetValue(0.0)
        LPLootingDisabledMsg.Show()
        if Logger && Logger.IsEnabled()
            Logger.LogInfo("Looting disabled by toggle item.")
        endif
    else
        LPSystemUtil_ToggleLooting.SetValue(1.0)
        LPLootingEnabledMsg.Show()
        if Logger && Logger.IsEnabled()
            Logger.LogInfo("Looting enabled by toggle item.")
        endif
    endif

    akTarget.AddItem(LP_Aid_ToggleLooting as Form, 1, true)
EndEvent
